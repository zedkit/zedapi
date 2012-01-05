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

describe Shortener do
  let(:project) { Project.create! name: "created project" }
  let(:user) { project.users.create! email: "gargamel@whatever.com" }
  let(:shortener) { project.shorteners.new domain: "whatever.com" }
  let(:created) { project.shorteners.create! domain: "created.com" }

  context "when new" do
    it "is valid with valid default attributes" do
      shortener.should be_valid
      shortener.uuid.should be_valid_uuid
      shortener.domain.should eql "whatever.com"
      shortener.version.should eql 1
    end

    it "is invalid without a project" do
      shortener.project = nil
      shortener.should validate_with("The project does not exist or its use is not available.").on(:project)
    end
    it "is invalid with a non-existent project" do
      shortener.project_id = $bson
      shortener.should validate_with("The project does not exist or its use is not available.").on(:project)
    end

    it "is invalid without a domain" do
      shortener.domain = nil
      shortener.should validate_with("The domain name is a required data item.").on(:domain)
    end
    it "is invalid with a domain that is too short" do
      shortener.domain = "a.a"
      shortener.should validate_with("A domain must be at least 5 characters.").on(:domain)
    end
    it "is invalid with a name that is too long" do
      shortener.domain = "whateveryousaybigboyuhuhyeahneedstobeverylongforthistest-whateveryousay.com"
      shortener.should validate_with("A domain cannot exceed 48 characters.").on(:domain)
    end
    it "is invalid with a domain already in use" do
      shortener.domain = created.domain
      shortener.should validate_with("The domain name is already in use.").on(:domain)
    end
  end

  context "when created" do
    it "with audit has an addition audit trail" do
      shortener.save_with_audit_trail(project, user.id) do |tt|
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        tt.should_not be_new_record
        tt.state_from.should eql "{}"
        tt.state_to.should include "whatever"
        tt.action.should eql AuditTrail::ACTION_ADDITION
      end
      shortener.errors.should be_empty
      shortener.uuid.should be_valid_uuid
      shortener.version.should eql 1
    end
  end

  context "when updated" do
    it "with audit has an update audit trail" do
      created.set_audit.domain = "created.com"
      created.save_with_audit_trail(project, user.id) do |tt|
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        tt.should_not be_new_record
        tt.object_type.should eql "Shortener"
        tt.state_from.should include "whatever"
        tt.state_to.should include "domain"
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
