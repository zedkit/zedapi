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

describe Project do
  let(:project) { Project.new name: "New Project" }
  let(:created) { Project.create! name: "Created Project" }
  let(:user) { created.users.create! email: "gargamel@whatever.com" }

  context "when new and validated" do
    it "is valid with valid default attributes" do
      project.should be_valid
      project.has_settings?.should be_false
      project.uuid.should be_valid_uuid
      project.name.should eql "New Project"
      project.locale.should eql ZedkitLocale::ENGLISH
      project.version.should eql 1
    end
    it "is valid with spaces in name" do
      project.name = "Whatever Works"
      project.should be_valid
      project.uuid.should be_valid_uuid
      project.name.should eql "Whatever Works"
    end
    it "is valid with random characters in name" do
      project.name = "Whatever $$ It Makes @@"
      project.should be_valid
      project.uuid.should be_valid_uuid
      project.name.should eql "Whatever $$ It Makes @@"
    end
    it "is valid with mixed-case english locale" do
      project.locale = "eN"
      project.should be_valid
      project.uuid.should be_valid_uuid
      project.locale.should eql "en"
    end
    it "is valid with spanish locale" do
      project.locale = "es"
      project.should be_valid
      project.uuid.should be_valid_uuid
      project.locale.should eql "es"
    end

    it "is invalid without a name" do
      project.name = nil
      project.should validate_with("A project name is required.").on(:name)
    end
    it "is invalid with a blank name" do
      project.name = ""
      project.should validate_with("A project name is required.").on(:name)
    end
    it "is invalid with a name that is too short" do
      project.name = "A"
      project.should validate_with("The project name is too short. A project name must be at least 2 characters.").on(:name)
    end
    it "is invalid with a name that is too long" do
      project.name = "this is a very long project name too long but it needs to be even longer to trigger validation"
      project.should validate_with("The project name is too long. A project name cannot exceed 48 characters.").on(:name)
    end

    it "is invalid without a locale" do
      project.locale = nil
      project.should validate_with("The locale is invalid.").on(:locale)
    end
    it "is invalid without a blank locale" do
      project.locale = ""
      project.should validate_with("The locale is invalid.").on(:locale)
    end
    it "is invalid with an invalid locale" do
      project.locale = "zz"
      project.should validate_with("The locale is invalid.").on(:locale)
    end

    it "is invalid with an invalid location" do
      project.location = "NAME$%"
      project.should validate_with("The project location is invalid.").on(:location)
    end
    it "is invalid with a location that is too short" do
      project.location = "w"
      project.should validate_with("The project location is too short. A project location must be at least 2 characters.").on(:location)
    end
    it "is invalid with a location that is too long" do
      project.location = "averylongbutvalidlookingdomainnamebutcantgoonforever"
      project.should validate_with("The project location is too long. A project location cannot exceed 32 characters.").on(:location)
    end
    it "is invalid with a reserved location" do
      project.location = Project::RESERVED_LOCATIONS[2]
      project.should validate_with("The project location is reserved and cannot be used.").on(:location)
    end
    it "is invalid with a location already in use" do
      project.location = created.location
      project.should validate_with("The project location is already in use.").on(:location)
    end

    it "is invalid with an invalid locales key" do
      project.locales_key = "F@sgAAs%^sSSBIwy@X"
      project.should validate_with("The project locales key is invalid.").on(:locales_key)
    end
    it "is invalid with a locales key the wrong length" do
      project.locales_key = "FFsgBBsh3s"
      project.should validate_with("The project locales key must be 18 characters.").on(:locales_key)
    end
    it "is invalid with a locales key already in use" do
      project.locales_key = created.locales_key
      project.should validate_with("The project locales key is already in use.").on(:locales_key)
    end
  end

  context "when created" do
    it "has no audit creation trail" do
    end
  end

  context "when updated" do
    it "has an audit update trail" do
      created.set_audit.name = "New Name"
      created.save_with_audit_trail(created, user.id) do |tt|
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        tt.state_from.should include "Created"
        tt.state_to.should include "New"
        tt.action.should eql AuditTrail::ACTION_UPDATE
      end
      created.version.should eql 2
      created.should have(1).audits
    end
  end

  context "when deleted" do
    it "with audit has a deletion audit trail" do
    end
  end
end
