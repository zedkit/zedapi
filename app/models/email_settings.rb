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

class EmailSettings < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  belongs_to :project, index: true, inverse_of: :email_settings
  field :provider, default: EmailProvider::SENDGRID
  field :uuid
  field :username
  field :password
  field :version, type: Integer, default: 0
  field :status,  default: ACTIVE

  index :uuid
  index :status
  index [[:project_id, Mongo::ASCENDING], [:provider, Mongo::ASCENDING]]

  set_as_audited fields: [ :provider, :username, :password, :status ]

  before_validation :set_uuid, :set_provider, :set_version
  validate :valid_associations?, :unique_provider?
  validates :project, presence: true
  validates :provider, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :username, presence: true, length: { minimum: 1, maximum: 48 }
  validates :password, presence: true, length: { minimum: 1, maximum: 48 }
  validates :version, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def to_api
    {
      "project" => { "uuid" => project.uuid }, "provider" => { "code" => provider },
      "uuid" => uuid, "username" => username, "password" => password,
      "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api
    }
  end

  protected
  def valid_associations?
    errors.add :project if error_free?(:project) && Project.invalid_id?(project_id)
    errors.add :provider if error_free?(:provider) && EmailProvider.invalid_code?(provider)
  end
  def unique_provider?
    if error_free?(:project) && error_free?(:provider) && provider.present?
      if new_record?
        errors.add(:provider, :taken) if EmailSettings.active_exists?(project_id: project_id, provider: provider)
      else
        EmailSettings.each_active(project_id: project_id, provider: provider) do |es|
          errors.add(:provider, :taken) if id != es.id
        end
      end
    end
  end

  def set_provider
    self.provider.upcase! if provider.present?
  end
end
