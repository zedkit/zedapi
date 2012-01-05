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

describe BetaAddress do
  let(:project) { Project.create! name: "Created Project" }
  let(:user) { project.users.create! email: "gargamel@whatever.com" }
  let(:address) { project.beta_addresses.new email: "address@apple.com" }
  let(:created) { project.beta_addresses.create! email: "steve@apple.com" }

  context "when new" do
    it "is valid with valid default attributes" do
      address.should be_valid
      address.uuid.should be_valid_uuid
      address.version.should eql 1
    end

    it "is invalid without a project" do
      address.project = nil
      address.should validate_with("The project does not exist or its use is not available.").on(:project)
    end
    it "is invalid with a non-existent project" do
      address.project_id = $bson
      address.should validate_with("The project does not exist or its use is not available.").on(:project)
    end

    it "is invalid without an email address" do
      address.email = nil
      address.should validate_with("The email address is a required data item.").on(:email)
    end
    it "is invalid with an invalid email address" do
      address.email = "a%gst#$aa"
      address.should validate_with("The email address is invalid.").on(:email)
    end
    it "is invalid with an email address that is too short" do
      address.email = "A"
      address.should validate_with("An email address must be at least 5 characters.").on(:email)
    end
    it "is invalid with an email address that is too long" do
      address.email = Array.new(75, "a").join << "@" << Array.new(75, "a").join << ".com"
      address.should validate_with("An email address cannot exceed 128 characters.").on(:email)
    end
    it "is invalid with an email address already registered" do
      address.email = created.email
      address.should validate_with("The email address is already regstered for early access.").on(:email)
    end

    it "is invalid without an invited value" do
      address.invited = nil
      address.should validate_with("The invitation status is required.").on(:invited)
    end
    it "is invalid witn an invalid invited value" do
      address.invited = "HUH"
      address.should validate_with("The invitation status submitted is invalid.").on(:invited)
    end
  end

  context "when created" do
    it "with audit has an addition audit trail" do
      address.save_with_audit_trail(project, user.id) do |tt|
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        tt.state_from.should eql "{}"
        tt.state_to.should include "address"
        tt.action.should eql AuditTrail::ACTION_ADDITION
      end
      address.errors.should be_empty
      address.uuid.should be_valid_uuid
      address.version.should eql 1
    end
  end

  context "when updated" do
    it "with audit has an update audit trail" do
      created.set_audit.email = "new@apple.com"
      created.save_with_audit_trail(project, user.id) do |tt|
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        tt.state_from.should include "steve"
        tt.state_to.should include "new"
        tt.action.should eql AuditTrail::ACTION_UPDATE
      end
      created.errors.should be_empty
      created.version.should eql 2
    end
  end

  context "when deleted" do
    it "with audit has a deletion audit trail" do
    end
  end
end
