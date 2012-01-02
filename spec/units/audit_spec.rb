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

require File.dirname(__FILE__) + "/../spec_helper"

describe AuditTrail do
  let(:project) { Project.create! name: "Gargamel's Secret Project" }
  let(:user) { project.users.create! email: "gargamel@whatever.com" }
  let(:audit) do
    AuditTrail.new user: user, master_type: "Project", master_uuid: project.uuid, object_type: "User",
                   object_uuid: $uuid, state_to: "{\"name\":\"after\"}", action: AuditTrail::ACTION_ADDITION
  end

  context "when new and validated" do 
    it "is valid with valid addition attributes" do
      audit.should be_valid
      audit.uuid.should be_valid_uuid
      audit.user.uuid.should eql user.uuid
    end
    it "is valid with valid update attributes" do
      audit.state_from = "{\"name\":\"before\"}"
      audit.action = AuditTrail::ACTION_UPDATE
      audit.should be_valid
      audit.uuid.should be_valid_uuid
      audit.user.uuid.should eql user.uuid
    end
    it "is valid with valid deletion attributes" do
      audit.state_from = "{\"name\":\"before\"}"
      audit.action = AuditTrail::ACTION_DELETION
      audit.should be_valid
      audit.uuid.should be_valid_uuid
      audit.user.uuid.should eql user.uuid
    end

    it "is invalid without a user" do
      audit.user = nil
      audit.should validate_with("The user does not exist or its use is not available.").on(:user)
    end
    it "is invalid with a non-existent user" do
      audit.user_id = $bson
      audit.should validate_with("The user does not exist or its use is not available.").on(:user)
    end

    it "is invalid without master object type" do
      audit.master_type = nil
      audit.should validate_with("The master object type is a required data item.").on(:master_type)
    end
    it "is invalid with a master object type that is too short" do
      audit.master_type = "Yo"
      audit.should validate_with("The master object's type must be between 4 and 32 characters.").on(:master_type)
    end
    it "is invalid with a master object type that is too long" do
      audit.master_type = "Averylongobjectnameforvalidationfailure"
      audit.should validate_with("The master object's type must be between 4 and 32 characters.").on(:master_type)
    end

    it "is invalid without a master object uuid" do
      audit.master_uuid = nil
      audit.should validate_with("The master object does not exist or its use is not available.").on(:master_uuid)
    end
  
    it "is invalid without object type" do
      audit.object_type = nil
      audit.should validate_with("The audited object's type is a required data item.").on(:object_type)
    end
    it "is invalid with an object type that is too short" do
      audit.object_type = "Yo"
      audit.should validate_with("The audited object's type must be between 4 and 32 characters.").on(:object_type)
    end
    it "is invalid with an object type that is too long" do
      audit.object_type = "Averylongobjectnameforvalidationfailure"
      audit.should validate_with("The audited object's type must be between 4 and 32 characters.").on(:object_type)
    end
    it "is invalid with an object type that is not a valid constant" do
      ## TBD
    end

    it "is invalid without an object uuid" do
      audit.object_uuid = nil
      audit.should validate_with("The audited object does not exist or its use is not available.").on(:object_uuid)
    end
    it "is invalid with an invalid object uuid" do
      audit.object_uuid = "YO"
      audit.should validate_with("An audited object's unique UUID must be 32 characters.").on(:object_uuid)
    end
    it "is invalid with an object uuid that does not exist in the object type's collection" do
      ## TBD
    end

    it "is invalid without from json for an update operation" do
      audit.state_from = nil
      audit.action = AuditTrail::ACTION_UPDATE
      audit.should validate_with("Before state information is a required data item for UPDATE and DELETION operations.").on(:state_from)
    end
    it "is invalid with invalid from json" do
      audit.state_from = "{\"name\":\"before"
      audit.action = AuditTrail::ACTION_UPDATE
      audit.should validate_with("Before state information is invalid JSON.").on(:state_from)
    end
  
    it "is invalid without to json" do
      audit.state_to = nil
      audit.should validate_with("After state information is a required data item.").on(:state_to)
    end
    it "is invalid with invalid to json" do
      audit.state_to = "{\"name\":\"after"
      audit.should validate_with("After state information is invalid JSON.").on(:state_to)
    end

    it "is invalid without an action" do
      audit.action = nil
      audit.should validate_with("The audit action is a required data item.").on(:action)
    end
    it "is invalid with an invalid action" do
      audit.action = "HUH"
      audit.should validate_with("The audit action is invalid.").on(:action)
    end
    it "is invalid when a deletion action does not contain a status data item change" do
      ## TBD
    end
  end
end
