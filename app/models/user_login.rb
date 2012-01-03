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

class UserLogin < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, inverse_of: :logins
  field :uuid
  field :country, default: ZedkitCountry::UNKNOWN
  field :address
  field :status,  default: CollectionObject::ACTIVE

  index :uuid, unique: true

  before_validation :set_uuid
  validate :valid_associations?, :valid_address?
  validates :user, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :country, presence: true
  validates :address, presence: true
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def to_api
    { "user" => { "uuid" => user.uuid }, "uuid" => uuid, "address" => address, "login_at" => created_at.to_api }
  end

  protected
  def valid_associations?
    errors.add :user if error_free?(:user) && User.invalid_id?(user_id)
    errors.add :country if error_free?(:country) && ZedkitCountry.invalid_code?(country)
  end
  def valid_address?
    errors.add :address if error_free?(:address) && LocationObject.invalid_ip_address?(address)
  end
end
