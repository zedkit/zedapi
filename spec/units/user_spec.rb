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

describe User do
  let(:project) { Project.create! name: "created project" }
  let(:user) { User.new project: project, first_name: "Steve", surname: "Jobs", email: "steve@apple.com" }
  let(:created) { project.users.create! first_name: "Steve", surname: "Wozniak", email: "woz@apple.com" }

  context "when new" do
    it "is valid with valid default attributes" do
      user.set_password("test")
      user.should be_valid
      user.uuid.should be_valid_uuid
      user.locale.should eql ZedkitLocale::ENGLISH
      user.email.should eql "steve@apple.com"
      user.username.length.should eql CollectionObject::LENGTH_GENERATED_USERNAME
      user.version.should eql 1
    end
    it "is valid without a name or username" do
      user.first_name, user.surname = nil, nil
      user.should be_valid
      user.version.should eql 1
    end
    it "is valid without a password" do
      user.should be_valid
      user.version.should eql 1
    end
    it "is valid without an email address for a project that does not require one" do
    end
    it "is valid with password and confirmations that work" do
      user.set_password("test")
      user.password_again = "test"
      user.should be_valid
      user.should be_valid_password("test")
    end
    
    it "is invalid without project" do
      user.project = nil
      user.should validate_with("The project does not exist or its use is not available.").on(:project)
    end
    it "is invalid with a non-existent project" do
      user.project_id = $bson
      user.should validate_with("The project does not exist or its use is not available.").on(:project)
    end
    
    it "is invalid without locale" do
      user.locale = nil
      user.should validate_with("The locale does not exist or its use is not available.").on(:locale)
    end
    it "is invalid with invalid locale" do
      user.locale = "zz"
      user.should validate_with("The locale does not exist or its use is not available.").on(:locale)
    end
    
    it "is invalid with a first name that is too long" do
    end
    it "is invalid with initials that are too long" do
    end
    it "is invalid with a surname that is too long" do
    end

    it "is invalid with an invalid username" do
      user.username = "invalid!"
      user.should validate_with("The username can only be letters and numbers.").on(:username)
    end
    it "is invalid with a username that is too short" do
      user.username = "a"
      user.should validate_with("The username must be between 2 and 18 characters.").on(:username)
    end
    it "is invalid with a username that is too long" do
      user.username = "toolongusernametocheck"
      user.should validate_with("The username must be between 2 and 18 characters.").on(:username)
    end
    it "is invalid with a username already in use wihin the same project" do
      user.username = created.username
      user.should validate_with("The username is already in use.").on(:username)
    end
    
    it "is invalid with an invalid email address" do
      user.email = "not an email address"
      user.should validate_with("The email address is not a valid email address.").on(:email)
    end
    it "is invalid without an email address with project that requires one" do
    end
    it "is invalid with an email address that is too long" do
      user.email = "steve@apple.this.is.very.long.not.very.likely.to.be.real.if.this.long.com"
      user.should validate_with("The email address must be between 5 and 128 characters.").on(:email)
    end
    it "is invalid with an email address already in use within the same project" do
      user.email = created.email
      user.should validate_with("The email address is already in use.").on(:email)    
    end
    
    it "is invalid with a different password and password confirmation" do
      user.set_password('test')
      user.password_again = 'nottest'
      user.should validate_with("The password and password confirmation do not match.").on(:password)
    end

    it "is invalid with an invalid user key" do
      user.user_key = "not valid"
      user.should validate_with("A user API key can only be 18 alphanumeric characters.").on(:user_key)    
    end
  end

  context "when created" do
    it "with audit has an addition audit trail" do
    end
  end

  context "when updated" do
    it "with audit has an update audit trail" do
      created.set_audit.email = "new@apple.com"
      created.save_with_audit_trail(project, created.id) do |tt|
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        tt.state_from.should include "woz"
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
