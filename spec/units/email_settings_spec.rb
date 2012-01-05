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

describe EmailSettings do
  let(:project) { Project.create! name: "Created Project" }
  let(:settings) { EmailSettings.new project: project, username: "whatever", password: "password" }
  let(:created) { EmailSettings.create! project: project, username: "whatever", password: "password" }

  context "when new" do
    it "is valid with valid default attributes" do
      settings.should be_valid
      settings.uuid.should be_valid_uuid
      settings.username.should eql "whatever"
      settings.password.should eql "password"
      settings.version.should eql 1
    end

    it "is invalid without a project" do
      settings.project = nil
      settings.should validate_with("The project does not exist or its use is not available.").on(:project)
    end
    it "is invalid with a non-existent project" do
      settings.project_id = $bson
      settings.should validate_with("The project does not exist or its use is not available.").on(:project)
    end

    it "is invalid without a provider" do
      settings.provider = nil
      settings.should validate_with("The email provider is invalid.").on(:provider)
    end
    it "is invalid with a non-existent provider" do
      settings.provider = "ZZ"
      settings.should validate_with("The email provider is invalid.").on(:provider)
    end
    it "is invalid with provider already set" do
      settings.project = @project_bert
      settings.provider = EmailProvider::SENDGRID
      settings.should validate_with("Email settings already exist for the email provider.").on(:provider)
    end
    
    it "is invalid without an username" do
      settings.username = nil
      settings.should validate_with("The username is a required data item.").on(:username)
    end
    it "is invalid with an username that is too long" do
      settings.username = Array.new(50, "a").join
      settings.should validate_with("The username is too long. The username cannot exceed 48 characters.").on(:username)
    end

    it "is invalid without a password" do
      settings.password = nil
      settings.should validate_with("The password is a required data item.").on(:password)
    end
    it "is invalid with a password that is too long" do
      settings.password = Array.new(50, "a").join
      settings.should validate_with("The password is too long. The password cannot exceed 48 characters.").on(:password)
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
    end
  end
end
