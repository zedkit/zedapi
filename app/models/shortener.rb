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

class Shortener < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  belongs_to :project, index: true, inverse_of: :shorteners
  field :uuid
  field :domain
  field :home
  field :sequence, type: Integer, default: 1
  field :version,  type: Integer, default: 0
  field :status,   default: CollectionObject::ACTIVE

  index :uuid
  index :domain, unique: true
  index :status

  has_many :urls, class_name: "ShortenedUrl", autosave: true

  set_as_audited fields: [ :domain, :status ]

  before_validation :set_uuid, on: :create
  before_validation :set_version
  validate :valid_associations?, :unique_domain?
  validates :project, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :domain, presence: true, uniqueness: true, length: { minimum: 5, maximum: 48 }
  validates :sequence, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :version, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def to_api
    {
      "project" => { "uuid" => project.uuid, "name" => project.name },
      "uuid" => uuid, "domain" => domain,
      "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api
    }
  end

  protected
  def valid_associations?
    errors.add :project if error_free?(:project) && Project.invalid_id?(project_id)
  end
  def unique_domain?
    if error_free? :domain
      if new_record?
        errors.add(:domain, :taken) if Shortener.active_exists?(domain: domain)
      else
        Shortener.each_active(domain: domain) {|sh| errors.add(:domain, :taken) if id != sh.id } end end
  end
end
