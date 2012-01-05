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

class ProjectKey < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  PROJECT_KEY_LENGTH = 18

  embedded_in :project, inverse_of: :project_keys
  field :platform, default: ZedkitPlatform::WWW
  field :uuid
  field :name
  field :project_key
  field :status, default: CollectionObject::ACTIVE

  index :uuid
  index :project_key
  index :status

  set_as_audited fields: [ :platform, :name, :project_key, :status ]

  before_validation :set_uuid, :set_key, on: :create
  validate :valid_associations?
  validates :project, presence: true
  validates :platform, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :name, presence: true, length: { minimum: 2, maximum: 32 }
  validates :project_key, presence: true, uniqueness: true, length: { is: PROJECT_KEY_LENGTH }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def to_api
    {
      "project" => { "uuid" => project.uuid, "name" => project.name },
      "uuid" => uuid, "platform" => { "code" => platform },
      "key" => project_key, "name" => name, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api
    }
  end

  protected
  def valid_associations?
    errors.add :platform if error_free?(:platform) && ZedkitPlatform.invalid_code?(platform)
  end
  def set_key
    self.project_key = RandomCode.new(length: PROJECT_KEY_LENGTH).code if project_key.blank?
  end
end
