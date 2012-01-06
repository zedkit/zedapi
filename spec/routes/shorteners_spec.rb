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
  context "shorteners list" do
    it "should return a project's shorteners" do
      hit "/shorteners", :get, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql @project_bert.shorteners.length
        hh.detect {|shortener| shortener["uuid"] == @project_bert.shorteners[0]["uuid"] }.should be_present
        hh.detect {|shortener| shortener["domain"] == @project_bert.shorteners[0]["domain"] }.should be_present
      end
    end

    it "should fail without project uuid" do
      hit "/shorteners", :get, pk_with_auth(:bert) 
      response.should be_http_failure 400
    end
    it "should fail with non-existent project" do
      hit "/shorteners", :get, pk_with_auth(:bert).merge({ project: { uuid: $uuid } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/shorteners", :get, pk_with_auth(:bert).merge({ project: { uuid: @project_fred.uuid } })
      response.should be_http_failure 403
    end
  end

  context "shortener get" do
    it "should return a a shortener" do
      hit "/shorteners/" << @shortener_bert.uuid, :get, pk_with_auth(:bert)
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.shorteners[0].uuid
        hh["domain"].should eql @project_bert.shorteners[0].domain
      end
    end

    it "should fail with non-existent shortener uuid" do
      hit "/shorteners/" << $uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for unconnected shortener" do
      hit "/shorteners/" << @shortener_fred.uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
  
  context "shortener creation" do
    it "should create a shortener" do
      hit "/shorteners", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid }, shortener: { domain: "yo.im" } })
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["domain"].should eql "yo.im"
        hh["version"].should eql 1
        Shortener.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should not persist a new shortener in the sandbox" do
      hit "/shorteners", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid }, shortener: { domain: "yo.im" } }).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["domain"].should eql "yo.im"
        hh["version"].should eql 1
        Shortener.valid_uuid?(hh['uuid']).should be_false
      end
    end

    it "should fail with a non-exsistent project" do
      hit "/shorteners", :post, pk_with_auth(:bert).merge({ project: { uuid: $uuid }, shortener: { domain: "yo.im" } })
      response.should be_http_failure 404
    end
    it "should fail with a unconnected project" do
      hit "/shorteners", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_fred.uuid }, shortener: { domain: "yo.im" } })
      response.should be_http_failure 403
    end
    it "should fail without a domain name" do
      hit "/shorteners", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid } })
      response.should be_http_failure 400
    end
  end
  
  context "shortener update" do
    it "should update a shortener" do
      hit "/shorteners/" << @shortener_bert.uuid, :put, pk_with_auth(:bert).merge({ shortener: { domain: "updated.com" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @shortener_bert.uuid
        hh["domain"].should eql "updated.com"
        hh["version"].should eql @shortener_bert.version += 1
        Shortener.find_by_uuid(hh["uuid"]).domain.should eql "updated.com"
      end
    end
    it "should not persist a shortener update in the sandbox" do
      hit "/shorteners/" << @shortener_bert.uuid, :put, pk_with_auth(:bert).merge({ shortener: { domain: "updated.com" } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @shortener_bert.uuid
        hh["domain"].should eql "updated.com"
        hh["version"].should eql @shortener_bert.version += 1
        Shortener.find_by_uuid(hh["uuid"]).domain.should eql @shortener_bert.domain
      end
    end
    
    it "should fail with non-exsistent shortener uuid" do
      hit "/shorteners/" << $uuid, :put, pk_with_auth(:bert).merge({ shortener: { domain: "updated.com" } })
      response.should be_http_failure 404
    end
    it "should fail with unconnected shortener" do
      hit "/shorteners/" << @shortener_fred.uuid, :put, pk_with_auth(:bert).merge({ shortener: { domain: "updated.com" } })
      response.should be_http_failure 403
    end
    it "should fail without a domain name" do
      hit "/shorteners/" << @shortener_bert.uuid, :put, pk_with_auth(:bert)
      response.should be_http_failure 400
    end
  end

  context "shortener deletion" do
    it "should delete a shortener" do
      hit "/shorteners/" << @shortener_bert.uuid, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      Shortener.valid_uuid?(@shortener_bert.uuid).should be_false
    end
    it "should not persist a shortener deletion in the sandbox" do
      hit "/shorteners/" << @shortener_bert.uuid, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      Shortener.valid_uuid?(@shortener_bert.uuid).should be_true
    end

    it "shoud fail for non-existent shortener" do
      hit "/shorteners/" << $uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for unconnected shortener" do
      hit "/shorteners/" << @shortener_fred.uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
