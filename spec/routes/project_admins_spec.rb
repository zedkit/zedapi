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
  let(:bert_admin_path) { "/projects/#{@project_bert.uuid}/admins/#{@project_bert.project_admins.first.uuid}" }
  let(:fred_admin_path) { "/projects/#{@project_fred.uuid}/admins/#{@project_fred.project_admins.first.uuid}" }

  context "project's admins list" do
    it "should return a project's admins" do
      hit "/projects/#{@project_bert.uuid}/admins", :get, pk_with_auth(:bert)
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql 1
        hh.detect {|pa| pa["uuid"] == @project_bert.project_admins.first.uuid }.should be_present
      end
    end

    it "should fail without authentication" do
      hit "/projects/#{$uuid}/admins", :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/admins", :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/projects/#{@project_fred.uuid}/admins", :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end

  context "project admin creation" do
    it "should create a new project admin" do
      hit "/projects/#{@project_bert.uuid}/admins", :post, pk_with_auth(:bert).merge({ user: { uuid: @fred.uuid } })
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["user"]["uuid"].should eql @fred.uuid
        hh["role"]["code"].should eql AdminRole::PRINCIPAL
        @project_bert.reload.project_admins.detect {|pa| pa.uuid == hh["uuid"] }.should be_present
      end
    end
    it "should not persist a new project admin within the sandbox" do
      hit "/projects/#{@project_bert.uuid}/admins", :post, pk_with_auth(:bert).merge({ user: { uuid: @fred.uuid } }).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        @project_bert.reload.project_admins.detect {|pk| pk.uuid == hh["uuid"] }.should_not be_present
      end
    end

    it "should fail without authentication" do
      hit "/projects/#{@project_bert.uuid}/admins", :get, { project_key: pk(:bert) }.merge({ user: { uuid: @fred.uuid } })
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/admins", :get, pk_with_auth(:bert).merge({ user: { uuid: @fred.uuid } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/projects/#{@project_fred.uuid}/admins", :get, pk_with_auth(:bert).merge({ user: { uuid: @fred.uuid } })
      response.should be_http_failure 403
    end
  end

  context "project admin update" do
    it "should update a project admin" do
      hit bert_admin_path, :put, pk_with_auth(:bert).merge({ user: { role: AdminRole::PRINCIPAL } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["role"]["code"].should eql AdminRole::PRINCIPAL
        @project_bert.reload.project_admins.detect {|pa| pa.role == hh["role"]["code"] }.should be_present
      end
    end
    it "should not persist a project admin update within the sandbox" do
      hit bert_admin_path, :put, pk_with_auth(:bert).merge({ user: { role: AdminRole::PRINCIPAL } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["role"]["code"].should eql AdminRole::PRINCIPAL
        @project_bert.reload.project_admins.detect {|pa| pa.role == hh["role"]["code"] }.should_not be_present
      end
    end

    it "should fail without authentication" do
      hit bert_admin_path, :put, { project_key: pk(:bert) }.merge({ user: { role: AdminRole::PRINCIPAL } })
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/admins/#{$uuid}", :put, pk_with_auth(:bert).merge({ user: { role: AdminRole::PRINCIPAL } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit fred_admin_path, :put, pk_with_auth(:bert).merge({ user: { role: AdminRole::PRINCIPAL } })
      response.should be_http_failure 403
    end
  end

  context "project admin deletion" do
    it "should delete a project admin" do
      hit bert_admin_path, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      @project_bert.reload.project_admins.first.should be_delete
    end
    it "should not persist a project admin deletion within the sandbox" do
      hit bert_admin_path, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      @project_bert.reload.project_admins.first.should be_active
    end

    it "should fail without authentication" do
      hit bert_admin_path, :delete, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/admins/#{$uuid}", :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail with an unconnected project" do
      hit fred_admin_path, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
