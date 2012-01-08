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

describe ProjectAdmin do
  let(:project) { Project.create! name: "existing project" }
  let(:user) { project.users.create! email: "gargamel@whatever.com" }
  let(:admin) { project.project_admins.new user_id: user.id }
  let(:created) { project.project_admins.create! user_id: user.id }

  context "when new and validated" do
    it "is valid with valid attributes" do
      admin.should be_valid
      admin.project.uuid.should eql project.uuid
      admin.uuid.should be_valid_uuid
      admin.role.should eql AdminRole::PRINCIPAL
    end

    it "is invalid without the role" do
      admin.role = nil
      admin.should validate_with("The user role is invalid.").on(:role)
    end
    it "is invalid with an invalid role" do
      admin.role = "HUH"
      admin.should validate_with("The user role is invalid.").on(:role)
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
