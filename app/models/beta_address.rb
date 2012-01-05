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

class BetaAddress < TranslationObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  belongs_to :project, index: true, inverse_of: :beta_addresses
  field :uuid
  field :email
  field :invited, default: CollectionObject::NO
  field :version, type: Integer, default: 0
  field :status,  default: CollectionObject::ACTIVE

  index :uuid, unique: true
  index :email
  index :status
  index [[:project_id, Mongo::ASCENDING], [:email, Mongo::ASCENDING]]

  set_as_audited fields: [ :email, :invited, :status ]

  before_validation :set_uuid, :set_email, :set_version
  validate :valid_associations?, :unique_email?
  validates :project, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :email, presence: true, length: { minimum: 5, maximum: 128 }, format: { with: /@/i }
  validates :invited, presence: true, inclusion: { in: %w(YES NO) }
  validates :version, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def to_api
    {
      "project" => { "uuid" => project.uuid }, "uuid" => uuid,
      "email" => email, "invited" => invited,
      "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api
    }
  end

  protected
  def valid_associations?
    errors.add :project if error_free?(:project) && Project.invalid_id?(project_id)
  end
  def unique_email?
    if email.present? && error_free?(:email)
      if new_record?
        errors.add(:email, :taken) if BetaAddress.active_exists?(project_id: project_id, email: email)
      else
        BetaAddress.each_active(email: email) {|ba| errors.add(:email, :taken) if id != ba.id } end
    end
  end

  def set_email
    self.email.downcase! if email.present?
  end
end
