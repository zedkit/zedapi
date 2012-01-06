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
  context "blogs list" do
    it "should return a project's blogs" do
      hit "/blogs", :get, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql @project_bert.blogs.length
        hh.detect {|blog| blog["uuid"] == @project_bert.blogs[0]["uuid"] }.should be_present
        hh.detect {|blog| blog["name"] == @project_bert.blogs[0]["name"] }.should be_present
      end
    end

    it "should fail without project uuid" do
      hit "/blogs", :get, pk_with_auth(:bert) 
      response.should be_http_failure 400
    end
    it "should fail with non-existent project" do
      hit "/blogs", :get, pk_with_auth(:bert).merge({ project: { uuid: $uuid } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/blogs", :get, pk_with_auth(:bert).merge({ project: { uuid: @project_fred.uuid } })
      response.should be_http_failure 403
    end
  end

  context "blog get" do
    it "should return a blog" do
      hit "/blogs/" << @blog_bert.uuid, :get, pk_with_auth(:bert)
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @blog_bert.uuid
        hh["name"].should eql @blog_bert.name
      end
    end

    it "should fail with non-existent blog uuid" do
      hit "/blogs/" << $uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for unconnected blog" do
      hit "/blogs/" << @blog_fred.uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end

  context "blog creation" do
    it "should create a blog" do
      hit "/blogs", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid }, blog: { name: "New NEW" } })
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["name"].should eql "New NEW"
        hh["version"].should eql 1
        Blog.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should create a blog with a default name" do
      hit "/blogs", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid } })
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["name"].should eql @project_bert.name
        Blog.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should not persist a new blog in the sandbox" do
      hit "/blogs", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid }, blog: { name: "New NEW" } }).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["name"].should eql "New NEW"
        hh["version"].should eql 1
        Blog.valid_uuid?(hh['uuid']).should be_false
      end
    end

    it "should fail with a non-exsistent project" do
      hit "/blogs", :post, pk_with_auth(:bert).merge({ project: { uuid: $uuid }, blog: { name: "New NEW" } })
      response.should be_http_failure 404
    end
    it "should fail with a unconnected project" do
      hit "/blogs", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_fred.uuid }, blog: { name: "New NEW" } })
      response.should be_http_failure 403
    end
  end
  
  context "blog update" do
    it "should update a blog" do
      hit "/blogs/" << @blog_bert.uuid, :put, pk_with_auth(:bert).merge({ blog: { name: "Updated Name" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.blogs[0].uuid
        hh["name"].should eql "Updated Name"
        hh["version"].should eql 2
        Blog.find_by_uuid(hh["uuid"]).name.should eql "Updated Name"
      end
    end
    it "should not persist a blog update in the sandbox" do
      hit "/blogs/" << @blog_bert.uuid, :put, pk_with_auth(:bert).merge({ blog: { name: "Updated Name" } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.blogs[0].uuid
        hh["name"].should eql "Updated Name"
        hh["version"].should eql 2
        Blog.find_by_uuid(hh["uuid"]).name.should eql @project_bert.blogs[0].name
      end
    end
    
    it "should fail with non-exsistent blog uuid" do
      hit "/blogs/" << $uuid, :put, pk_with_auth(:bert).merge({ blog: { name: "Updated Name" } })
      response.should be_http_failure 404
    end
    it "should fail with unconnected blog" do
      hit "/blogs/" << @blog_fred.uuid, :put, pk_with_auth(:bert).merge({ blog: { name: "Updated Name" } })
      response.should be_http_failure 403
    end
  end

  context "blog deletion" do
    it "should delete a blog" do
      hit "/blogs/" << @blog_bert.uuid, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      Blog.valid_uuid?(@blog_bert.uuid).should be_false
    end
    it "should not persist a blog deletion in the sandbox" do
      hit "/blogs/" << @blog_bert.uuid, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      Blog.valid_uuid?(@blog_bert.uuid).should be_true
    end

    it "shoud fail for non-existent blog" do
      hit "/blogs/" << $uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for unconnected blog" do
      hit "/blogs/" << @blog_fred.uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
