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

describe Blog do
  let(:project) { Project.create! name: "created project" }
  let(:user) { project.users.create! email: "gargamel@whatever.com" }
  let(:blog) { project.blogs.new name: "Whatever" }
  let(:created) { project.blogs.create! name: "Whatever" }

  context "when new" do
    it "is valid with valid default attributes" do
      blog.should be_valid
      blog.uuid.should be_valid_uuid
      blog.name.should eql "Whatever"
      blog.version.should eql 1
    end

    it "is invalid without a project" do
      blog.project = nil
      blog.should validate_with("The project does not exist or its use is not available.").on(:project)
    end
    it "is invalid with a non-existent project" do
      blog.project_id = $bson
      blog.should validate_with("The project does not exist or its use is not available.").on(:project)
    end

    it "is invalid without a name" do
      blog.name = nil
      blog.should validate_with("The blog name is a required data item.").on(:name)
    end
    it "is invalid with a name that is too short" do
      blog.name = "A"
      blog.should validate_with("A blog's name must be between 2 and 24 characters.").on(:name)
    end
    it "is invalid with a name that is too long" do
      blog.name = "whateveryousaybigboyuhuhyeahneedstobeverylongforthistest"
      blog.should validate_with("A blog's name must be between 2 and 24 characters.").on(:name)
    end
  end

  context "when created" do
    it "with audit has an addition audit trail" do
      blog.save_with_audit_trail(project, user.id) do |tt|
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        tt.state_from.should eql "{}"
        tt.state_to.should include "Whatever"
        tt.action.should eql AuditTrail::ACTION_ADDITION
      end
      blog.errors.should be_empty
      blog.uuid.should be_valid_uuid
      blog.version.should eql 1
    end
  end

  context "when updated" do
    it "with audit has an update audit trail" do
      created.set_audit.name = "New Name"
      created.save_with_audit_trail(project, user.id) do |tt|
        lambda { JSON.parse(tt.state_from) }.should_not raise_error
        lambda { JSON.parse(tt.state_to) }.should_not raise_error
        tt.state_from.should include "Whatever"
        tt.state_to.should include "New"
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
