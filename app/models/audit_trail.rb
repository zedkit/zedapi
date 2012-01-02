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

class AuditTrail < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps

  ACTION_ADDITION = "ADDITION"
  ACTION_UPDATE   = "UPDATE"
  ACTION_DELETION = "DELETION"

  belongs_to :user, :inverse_of => :audits, :index => true
  field :uuid
  field :master_type
  field :master_uuid
  field :object_type
  field :object_uuid
  field :state_from
  field :state_to
  field :action

  index :uuid
  index :master_uuid

  before_validation :set_uuid, :on => :create
  validate :valid_associations?, :valid_master?, :valid_object?, :valid_json?
  validates :user, :presence => true
  validates :uuid, :presence => true, :uniqueness => true, :length => { :is => LENGTH_UUID }
  validates :master_type, :presence => true, :length => { :minimum => 4, :maximum => 32 }
  validates :master_uuid, :presence => true, :length => { :is => LENGTH_UUID }
  validates :object_type, :presence => true, :length => { :minimum => 4, :maximum => 32 }
  validates :object_uuid, :presence => true, :length => { :is => LENGTH_UUID }
  validates :state_from, :presence => true, :unless => "errors[:state_from].any? || action == 'ADDITION'"
  validates :state_to, :presence => true
  validates :action, :presence => true, :inclusion => { :in => %w(ADDITION UPDATE DELETION) }
  after_validation :compress_messages

  def to_api
    ## TBD
  end

  protected
  def valid_associations?
    errors.add :user if error_free?(:user) && User.invalid_id?(user_id)
  end
  def valid_master?
    ## TBD
  end
  def valid_object?
    ## TBD
  end
  def valid_json?
    if state_from.present? && error_free?(:state_from)
      begin
        JSON.parse(state_from)
      rescue JSON::ParserError
        errors.add :state_from end
    end
    if state_to.present? && error_free?(:state_to)
      begin
        JSON.parse(state_to)
      rescue JSON::ParserError
        errors.add :state_to end
    end
  end
end
