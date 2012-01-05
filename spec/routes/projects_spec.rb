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

describe "ZedAPI" do
  context "project key verification" do
    it "should verify a project key" do
      visit "/projects/verify", :get, { project_key: pk(:bert) }
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.uuid
        hh["name"].should eql @project_bert.name
      end
    end

    it "should fail with an invalid prokect key" do
      visit "/projects/verify", :get, { project_key: "abcd" }
      response.should be_http_failure 403
    end
  end

  context "trail" do
    it "should return a project's audit trail" do
    end
  end

  context "snapshot" do
    it "should return a project snapshot" do
      hit "/projects/#{@project_bert.uuid}/snapshot", :get, pk_with_auth(:bert)
      response.should be_zedkit_snapshot.with(%w(project))
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["project"]["name"].should eql @project_bert.name
      end
    end

    it "should fail without authentication" do
      hit "/projects/#{@project_bert.uuid}/snapshot", :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail for non-existent project" do
      hit "/projects/#{$uuid}/snapshot", :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for deleted project" do
    end
    it "should fail without project connection" do
      hit "/projects/#{@project_fred.uuid}/snapshot", :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end

  context "project's list" do
    it "should return a user's projects" do
      hit "/projects", :get, pk_with_auth(:bert)
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql 1
        hh.detect {|project| project["project"]["uuid"] == @project_bert["uuid"] }.should be_present
      end
    end
    it "should return empty list for user without projects" do
    end

    it "should fail without authentication" do
      hit "/projects", :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
  end

  context "project get" do
    it "should return a project" do
      hit "/projects/" << @project_bert.uuid, :get, pk_with_auth(:bert)
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.uuid
        hh["name"].should eql @project_bert.name
        hh.should have(1)["admins"]
        hh.should have(1)["blogs"]
      end
    end

    it "should fail without authentication" do
      hit "/projects/" << @project_bert.uuid, :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail for non-existent project" do
      hit "/projects/" << $uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for deleted project" do
    end
    it "should fail without project connection" do
      hit "/projects/" << @project_bert.uuid, :get, { project_key: pk(:bert), username: @fred.username, password: "AbCd" }
      response.should be_http_failure 403
    end
  end

  context "project creation" do
    it "should create a new project" do
      hit "/projects", :post, pk_with_auth(:bert).merge({ project: { name: "new project" } })                                
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["locales"]["default"].should eql "en"
        hh["name"].should eql "new project"
        hh["version"].should eql 1
        hh.should have(1)["admins"]
        Project.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should create a new project with default locale" do
      hit "/projects", :post, pk_with_auth(:bert).merge({ project: { locale: "es", name: "new project" } })                                
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["locales"]["default"].should eql "es"
        hh["version"].should eql 1
        Project.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should not persist a new project in the sandbox" do
      hit "/projects", :post, pk_with_auth(:bert).merge({ project: { locale: "es", name: "new project" } }).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["name"].should eql "new project"
        hh["version"].should eql 1
        Project.valid_uuid?(hh['uuid']).should be_false
      end
    end

    it "should fail without authentication" do
      hit "/projects", :post, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail without name" do
      hit "/projects", :post, pk_with_auth(:bert)
      response.should be_http_failure(400)
    end
    it "should fail wih project location already in use" do
      hit "/projects", :post, pk_with_auth(:bert).merge({ project: { name: "new project", location: @project_bert.location } })
      response.should be_validation_failure_on(:location).with("The project location is already in use.")
    end
  end

  context "project update" do
    it "should update a project" do
      hit "/projects/" << @project_bert.uuid, :put, pk_with_auth(:bert).merge({ project: { name: "whatever new NAME" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["name"].should eql "whatever new NAME"
        hh["version"].should eql 2
        Project.find_by_uuid(hh["uuid"]).name.should eql "whatever new NAME"
      end
    end
    it "should not persist a project update in the sandbox" do
      hit "/projects/" << @project_bert.uuid, :put, pk_with_auth(:bert).merge({ project: { name: "whatever new NAME" } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["name"].should eql "whatever new NAME"
        hh["version"].should eql 2
        Project.find_by_uuid(hh["uuid"]).name.should eql @project_bert.name
      end
    end

    it "should fail without authentication" do
      hit "/projects/" << @project_fred.uuid, :put, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with non-existent project uuid" do
      hit "/projects/" << $uuid, :put, pk_with_auth(:bert).merge({ project: { name: "whatever new name" } })                                         
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/projects/" << @project_fred.uuid, :put, pk_with_auth(:bert).merge({ project: { name: "whatever new name" } })
      response.should be_http_failure 403
    end
    it "should fail with project location already in use" do
      hit "/projects/" << @project_bert.uuid, :put, pk_with_auth(:bert).merge({ project: { location: @project_fred.location } })
      response.should be_validation_failure_on(:location).with("The project location is already in use.")
    end
  end

  context "project deletion" do
    it "should delete a project" do
      hit "/projects/" << @project_bert.uuid, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      Project.valid_uuid?(@project_bert.uuid).should be_false
    end
    it "should not persist a project deletion in the sandbox" do
      hit "/projects/" << @project_bert.uuid, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      Project.valid_uuid?(@project_bert.uuid).should be_true
    end

    it "should fail without authentication" do
      hit "/projects/" << @project_fred.uuid, :delete, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with non-existent project uuid" do
      hit "/projects/" << $uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/projects/" << @project_fred.uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
