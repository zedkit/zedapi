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
  let(:bert_key_path) { "/projects/#{@project_bert.uuid}/keys/#{@project_bert.project_keys.first.uuid}" }
  let(:fred_key_path) { "/projects/#{@project_fred.uuid}/keys/#{@project_fred.project_keys.first.uuid}" }

  context "project's keys list" do
    it "should return a project's project keys" do
      hit "/projects/#{@project_bert.uuid}/keys", :get, pk_with_auth(:bert)
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql 1
        hh.detect {|pk| pk["uuid"] == @project_bert.project_keys.first.uuid }.should be_present
      end
    end

    it "should fail without authentication" do
      hit "/projects/#{$uuid}/keys", :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/keys", :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/projects/#{@project_fred.uuid}/keys", :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end

  context "project key creation" do
    it "should create a new project key" do
      hit "/projects/#{@project_bert.uuid}/keys", :post, pk_with_auth(:bert).merge({ key: { name: "whatever name" } })
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["name"].should eql "whatever name"
        @project_bert.reload.project_keys.detect {|pk| pk.uuid == hh["uuid"] }.should be_present
      end
    end
    it "should not persist a new project key within the sandbox" do
      hit "/projects/#{@project_bert.uuid}/keys", :post, pk_with_auth(:bert).merge({ key: { name: "whatever name" } }).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        @project_bert.reload.project_keys.detect {|pk| pk.uuid == hh["uuid"] }.should_not be_present
      end
    end

    it "should fail without authentication" do
      hit "/projects/#{@project_bert.uuid}/keys", :get, { project_key: pk(:bert) }.merge({ key: { name: "whatever name" } })
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/keys", :get, pk_with_auth(:bert).merge({ key: { name: "whatever name" } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/projects/#{@project_fred.uuid}/keys", :get, pk_with_auth(:bert).merge({ key: { name: "whatever name" } })
      response.should be_http_failure 403
    end
  end

  context "project key update" do
    it "should update a project key" do
      hit bert_key_path, :put, pk_with_auth(:bert).merge({ key: { name: "updated name" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["name"].should eql "updated name"
        @project_bert.reload.project_keys.detect {|pk| pk.name == hh["name"] }.should be_present
      end
    end
    it "should not persist a project key update within the sandbox" do
      hit bert_key_path, :put, pk_with_auth(:bert).merge({ key: { name: "updated name" } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["name"].should eql "updated name"
        @project_bert.reload.project_keys.detect {|pk| pk.name == hh["name"] }.should_not be_present
      end
    end

    it "should fail without authentication" do
      hit bert_key_path, :put, { project_key: pk(:bert) }.merge({ key: { name: "updated name" } })
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/keys/#{$uuid}", :put, pk_with_auth(:bert).merge({ key: { name: "updated name" } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit fred_key_path, :put, pk_with_auth(:bert).merge({ key: { name: "updated name" } })
      response.should be_http_failure 403
    end
  end

  context "project key deletion" do
    it "should delete a project key" do
      hit bert_key_path, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      @project_bert.reload.project_keys.first.should be_delete
    end
    it "should not persist a project key deletion within the sandbox" do
      hit bert_key_path, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      @project_bert.reload.project_keys.first.should be_active
    end

    it "should fail without authentication" do
      hit bert_key_path, :delete, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/keys/#{$uuid}", :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail with an unconnected project" do
      hit fred_key_path, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
