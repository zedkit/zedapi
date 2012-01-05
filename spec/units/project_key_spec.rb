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

describe ProjectKey do
  let(:project) { Project.create! name: "existing project" }
  let(:user) { project.users.create! email: "gargamel@whatever.com" }
  let(:key) { project.project_keys.new name: "Website" }
  let(:created) { project.project_keys.create! platform: ZedkitPlatform::IPAD, name: "iPad" }

  context "when new and validated" do
    it "is valid with valid attributes" do
      key.should be_valid
      key.project.uuid.should eql project.uuid
      key.uuid.should be_valid_uuid
      key.platform.should eql ZedkitPlatform::WWW
      key.name.should eql "Website"
    end

    it "is invalid without the platform" do
      key.platform = nil
      key.should validate_with("The platform is invalid.").on(:platform)
    end
    it "is invalid with an invalid platform" do
      key.platform = "HUH"
      key.should validate_with("The platform is invalid.").on(:platform)
    end

    it "is invalid without the name" do
      key.name = nil
      key.should validate_with("The project API key's name is a required data item.").on(:name)
    end
    it "is invalid with a name that is too short" do
      key.name = "H"
      key.should validate_with("The project API key's name must be between 2 and 32 characters.").on(:name)
    end
    it "is invalid with a name that is too long" do
      key.name = "H"
      key.should validate_with("The project API key's name must be between 2 and 32 characters.").on(:name)
    end
  end

  context "when created" do
    it "with audit has an addition audit trail" do
    end
  end

  context "when updated" do
    it "with audit has an update audit trail" do
    end
  end

  context "when deleted" do
    it "with audit has a deletion audit trail" do
      created.set_audit.status = CollectionObject::DELETE
      created.save_with_audit_trail(created.project, user.id) do |tt|
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        tt.state_to.should include "status"
        tt.action.should eql AuditTrail::ACTION_DELETION
      end
      created.errors.should be_empty
    end
  end
end
