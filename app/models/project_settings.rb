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

class ProjectSettings < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  embedded_in :project, :inverse_of => :project_settings
  field :uuid
  field :email,   :default => CollectionObject::YES        ## Email address required for user signup?
  field :version, :type => Integer, :default => 0
  field :status,  :default => CollectionObject::ACTIVE

  index :uuid
  index :status

  set_as_audited :fields => [ :status ]

  before_validation :set_uuid, :on => :create
  before_validation :set_values, :set_version

  validates_presence_of :project, :unless => "errors[:project].any?"
  validates_presence_of :uuid, :unless => "errors[:uuid].any?"
  validates_length_of :uuid, :is => LENGTH_UUID, :unless => "errors[:uuid].any?"
  validates_uniqueness_of :uuid, :unless => "errors[:uuid].any?"
  validates_presence_of :email, :unless => "errors[:email].any?"
  validates_inclusion_of :email, :in => %w(YES NO), :unless => "errors[:email].any?"
  validates_numericality_of :version, :greater_than_or_equal_to => 1, :only_integer => true
  validates_presence_of :status, :unless => "errors[:status].any?"
  validates_inclusion_of :status, :in => %w(ACTIVE DELETE), :unless => "errors[:status].any?"

  def email_required?
    ZedkitBoolean.boolean_value(email)
  end

  def to_api
    {
      "email_required" => email_required?,
      "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api
    }
  end
  
  class << self
    def email_required_by_default?
      true
    end

    def to_api_with_defaults(project)
      {
        "email_required" => ZedkitBoolean.boolean_value(CollectionObject::YES),
        "version" => 1, "created_at" => project.created_at.to_api, "updated_at" => project.updated_at.to_api
      }
    end
  end
  
  protected
  def set_values
    self.email.upcase! if email.present?
  end
end
