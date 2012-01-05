#
# Copyright (c) Zedkit.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

class EmailMessage < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  belongs_to :project, index: true, inverse_of: :email_messages
  field :uuid
  field :email_key
  field :name
  field :from
  field :subject
  field :content_text
  field :content_html
  field :version, type: Integer, default: 0
  field :status,  default: ACTIVE

  index :uuid
  index :status
  index [[:project_id, Mongo::ASCENDING], [:email_key, Mongo::ASCENDING]]

  has_many :translations, class_name: "EmailTranslation"

  set_as_audited fields: [ :email_key, :name, :from, :subject, :content_text, :content_html, :status ]

  before_validation :set_uuid, on: :create
  before_validation :set_content_key, :set_version
  validate :valid_associations?, :unique_email_key?
  validates :project, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :email_key, presence: true, length: { minimum: 2, maximum: 24 }, format: { with: /\A[A-Za-z0-9_-]+\Z/ }
  validates :name, presence: true, length: { minimum: 1, maximum: 48 }, :allow_blank => true
  validates :from, presence: true, length: { minimum: 1, maximum: 96 }, :allow_blank => true,
                   format: { with: /@/ }, format: { with: /\A[A-Za-z0-9\.@_-]+\Z/ }
  validates :subject, presence: true, length: { minimum: 1, maximum: 96 }, :allow_blank => true
  validates :content_text, length: { minimum: 1, maximum: 2500 }, :allow_blank => true
  validates :content_html, length: { minimum: 1, maximum: 2500 }, :allow_blank => true
  validates :version, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def has_text_content?
    content_text.present?
  end
  def has_html_content?
    content_html.present?
  end

  def to_api
    ts = {
      "project" => { "uuid" => project.uuid }, "uuid" => uuid,
      "key" => email_key, "name" => name, "from" => from, "subject" => subject
    }
    ts["content_text"] = content_text if has_text_content?
    ts["content_html"] = content_html if has_html_content?
    ts.merge({ "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api })
  end

  class << self
    def attribute_conversion_for(att)
      att == :email_key ? "key" : att
    end

    def valid_key?(project_id, key)
      exists?(conditions: { project_id: project_id, email_key: key }) && first(conditions: { project_id: project_id, email_key: key }).active?
    end
    def find_by_key(project_id, key)
      me = first(conditions: { project_id: project_id, email_key: key })
      return me if me.present && me.active?
      nil
    end
  end

  protected
  def valid_associations?
    errors.add :project if error_free?(:project) && Project.invalid_id?(project_id)
  end
  def unique_email_key?
    if error_free?(:project) && error_free?(:email_key) && email_key.present?
      if new_record?
        errors.add(:email_key, :taken) if EmailMessage.active_exists?(project_id: project_id, email_key: email_key)
      else
        EmailMessage.each_active(project_id: project_id, email_key: email_key) {|em| errors.add(:email_key, :taken) if id != em.id } end
    end
  end

  private
  def set_content_key
    self.email_key = key_to_normalized_value(email_key) unless email_key.blank?
  end
end
