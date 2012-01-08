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

class ProjectAdmin < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  embedded_in :project
  field :user_id
  field :uuid
  field :role,   default: AdminRole::PRINCIPAL
  field :status, default: CollectionObject::ACTIVE

  index :uuid, unique: true
  index :status

  set_as_audited fields: [ :role, :status ]

  before_validation :set_uuid, on: :create
  validate :valid_associations?, :unique_user?
  validates :user_id, presence: true
  validates :role, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def permissions
    {}
  end
  def to_api
    {
      "project" => { "uuid" => project.uuid, "name" => project.name }, "user" => { "uuid" => User.find(user_id).uuid },
      "uuid" => uuid,
      "role" => { "code" => role }, "permissions" => permissions,
      "created_at" => created_at.to_api, "updated_at" => updated_at.to_api
    }
  end

  protected
  def valid_associations?
    errors.add :user_id if error_free?(:user_id) && User.invalid_id?(user_id)
    errors.add :role if error_free?(:role) && AdminRole.invalid_code?(role)
  end
  def unique_user?                                                                         ## Array.count() DOES NOT WORK? (to p136)
    errors.add(:user_id, :taken) if error_free?(:user_id) && project.project_admins.select {|pu| pu.user_id == user_id }.length >= 2
  end
end
