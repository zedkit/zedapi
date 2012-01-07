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
  context "beta addresses list" do
    it "should return a project's beta email addresses" do
      hit "/betas", :get, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql @project_bert.beta_addresses.length
        hh.detect {|beta| beta["uuid"] == @project_bert.beta_addresses.first["uuid"] }.should be_present
        hh.detect {|beta| beta["email"] == @project_bert.beta_addresses.first["email"] }.should be_present
      end
    end

    it "should fail without project uuid" do
      hit "/betas", :get, pk_with_auth(:bert) 
      response.should be_http_failure 400
    end
    it "should fail with non-existent project" do
      hit "/betas", :get, pk_with_auth(:bert).merge({ project: { uuid: $uuid } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/betas", :get, pk_with_auth(:bert).merge({ project: { uuid: @project_fred.uuid } })
      response.should be_http_failure 403
    end
  end

  context "beta address get" do
    it "should return a beta email address" do
      hit "/betas/" << @project_bert.beta_addresses.first.uuid, :get, pk_with_auth(:bert)
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.beta_addresses.first.uuid
        hh["email"].should eql @project_bert.beta_addresses.first.email
      end
    end

    it "should fail with non-existent beta address uuid" do
      hit "/betas/" << $uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for unconnected beta address" do
      hit "/betas/" << @project_fred.beta_addresses.first.uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end

  context "beta address creation" do
    it "should create a beta email address" do
      hit "/betas", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid }, beta: { email: "boss@hog.com" } })
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["email"].should eql "boss@hog.com"
        hh["version"].should eql 1
        BetaAddress.valid_uuid?(hh["uuid"]).should be_true
      end
    end
    it "should not persist a new beta email address in the sandbox" do
      hit "/betas", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid }, beta: { email: "boss@hog.com" } }).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["email"].should eql "boss@hog.com"
        hh["version"].should eql 1
        BetaAddress.valid_uuid?(hh["uuid"]).should be_false
      end
    end

    it "should fail with a non-exsistent project" do
      hit "/betas", :post, pk_with_auth(:bert).merge({ project: { uuid: $uuid }, beta: { email: "New NEW" } })
      response.should be_http_failure 404
    end
    it "should fail with a unconnected project" do
      hit "/betas", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_fred.uuid }, beta: { email: "New NEW" } })
      response.should be_http_failure 403
    end
  end

  context "beta address update" do
    it "should update a beta email address" do
      hit "/betas/" << @project_bert.beta_addresses.first.uuid, :put, pk_with_auth(:bert).merge({ beta: { email: "updated@hog.com" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.beta_addresses.first.uuid
        hh["email"].should eql "updated@hog.com"
        hh["version"].should eql 2
        BetaAddress.find_by_uuid(hh["uuid"]).email.should eql "updated@hog.com"
      end
    end
    it "should not persist a beta email address update in the sandbox" do
      hit "/betas/" << @project_bert.beta_addresses.first.uuid, :put, pk_with_auth(:bert).merge({ beta: { email: "updated@hog.com" } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.beta_addresses.first.uuid
        hh["email"].should eql "updated@hog.com"
        hh["version"].should eql 2
        BetaAddress.find_by_uuid(hh["uuid"]).email.should eql @project_bert.beta_addresses.first.email
      end
    end

    it "should fail with non-exsistent beta email address uuid" do
      hit "/betas/" << $uuid, :put, pk_with_auth(:bert).merge({ beta: { email: "updated@hog.com" } })
      response.should be_http_failure 404
    end
    it "should fail with unconnected beta email address" do
      hit "/betas/" << @project_fred.beta_addresses.first.uuid, :put, pk_with_auth(:bert).merge({ beta: { email: "updated@hog.com" } })
      response.should be_http_failure 403
    end
  end

  context "beta address deletion" do
    it "should delete a beta email address" do
      hit "/betas/" << @project_bert.beta_addresses.first.uuid, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      BetaAddress.valid_uuid?(@project_bert.beta_addresses.first.uuid).should be_false
    end
    it "should not persist a beta email address deletion in the sandbox" do
      hit "/betas/" << @project_bert.beta_addresses.first.uuid, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      BetaAddress.valid_uuid?(@project_bert.beta_addresses.first.uuid).should be_true
    end

    it "shoud fail for non-existent beta email address" do
      hit "/betas/" << $uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for unconnected beta email address" do
      hit "/betas/" << @project_fred.beta_addresses.first.uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
