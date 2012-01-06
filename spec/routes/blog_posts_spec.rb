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
  context "blog posts list" do
    it "should return a blog's posts" do
      hit "/posts", :get, pk_with_auth(:bert).merge({ blog: { uuid: @project_bert.blogs[0].uuid } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql @project_bert.blogs[0].posts.length
        hh.detect {|post| post["uuid"]  == @project_bert.blogs[0].posts[0]["uuid"] }.should be_present
        hh.detect {|post| post["title"] == @project_bert.blogs[0].posts[0]["title"] }.should be_present
      end
    end
    it "should return a blog's posted posts" do
      hit "/posts", :get, pk_with_auth(:bert).merge({ blog: { uuid: @blog_bert.uuid }, where: { stage: "POSTED" } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql @project_bert.blogs[0].posts.where(stage: "POSTED").length
        hh.detect {|post| post["stage"] != "POSTED" }.should be_nil
      end
    end
    it "should list a specific post" do
      hit "/posts", :get, pk_with_auth(:bert).merge({ blog: { uuid: @blog_bert.uuid },
                                                      where: { stage: "POSTED", title_path: "ernie" } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql 1
        hh[0]["title_path"] = "ernie"
        hh[0]["stage"] = "POSTED"
      end
    end

    it "should fail without a referenced blog" do
      hit "/posts", :get, pk_with_auth(:bert)
      response.should be_http_failure 400
    end
    it "should fail with non-existent blog" do
      hit "/posts", :get, pk_with_auth(:bert).merge({ blog: { uuid: $uuid } })
      response.should be_http_failure 404
    end
    it "should fail with an unconnected blog" do
      hit "/posts", :get, pk_with_auth(:bert).merge({ blog: { uuid: @blog_fred.uuid } })
      response.should be_http_failure 403
    end
  end

  context "blog post get" do
    it "should return a blog post" do
      hit "/posts/" << @blog_bert.posts[0].uuid, :get, pk_with_auth(:bert)
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @blog_bert.posts[0].uuid
        hh["title_path"].should eql @blog_bert.posts[0].title_path
      end
    end

    it "should fail with a non-existent blog post" do
      hit "/posts/" << $uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail with an unconnected blog post" do
      hit "/posts/" << @blog_fred.posts[0].uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end

  context "blog post creation" do
    it "should create a new blog post" do
      hit "/posts", :post, pk_with_auth(:bert).merge({ blog: { uuid: @blog_bert.uuid },
                                                       post: { author: @bert.uuid, title: "New NEW" } })
      response.should be_zedkit_object.with_http_code(201)
      with_parsed response.body do |hh|
        hh["blog"]["uuid"].should eql @blog_bert.uuid
        hh["title"].should eql "New NEW"
        hh["title_path"].should eql "new-new"
        hh["version"].should eql 1
        BlogPost.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should create a new blog post with a url" do
      hit "/posts", :post, pk_with_auth(:bert).merge({ blog: { uuid: @blog_bert.uuid },
                                                       post: { author: @bert.uuid, title: "New NEW",
                                                               :url => "http://techcrunch.com/2011/01/23/why-i-don't-buy-the-quora-hype/" } })
      response.should be_zedkit_object.with_http_code(201)
      with_parsed response.body do |hh|
        hh["blog"]["uuid"].should eql @blog_bert.uuid
        hh["url"].should eql "http://techcrunch.com/2011/01/23/why-i-don't-buy-the-quora-hype/"
        hh["version"].should eql 1
        BlogPost.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should not persist a new blog post within the sandbox" do
      hit "/posts", :post, pk_with_auth(:bert).merge({ blog: { uuid: @blog_bert.uuid },
                                                       post: { author: @bert.uuid, title: "New NEW" } }).sandbox
      response.should be_zedkit_object.with_http_code(201)
      with_parsed response.body do |hh|
        hh["blog"]["uuid"].should eql @blog_bert.uuid
        hh["version"].should eql 1
        BlogPost.valid_uuid?(hh['uuid']).should be_false
      end
    end

    it "should fail for an unconnected blog" do
      hit "/posts", :post, pk_with_auth(:bert).merge({ blog: { uuid: @blog_fred.uuid },
                                                       post: { author: @bert.uuid, title: "New NEW" } })
      response.should be_http_failure 403
    end
    it "should fail without a title" do
      hit "/posts", :post, pk_with_auth(:bert).merge({ blog: { uuid: @blog_bert.uuid }, post: { author: @bert.uuid } })
      response.should be_http_failure 400
    end
    it "should fail with an invalid title" do
    end
  end

  context "blog post update" do
    it "should update a blog post" do
      hit "/posts/" << @blog_bert.posts[0].uuid, :put, pk_with_auth(:bert).merge({ post: { author: @ernie.uuid, title: "Updated NEW" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["blog"]["uuid"].should eql @blog_bert.uuid
        hh["title"].should eql "Updated NEW"
        hh["title_path"].should eql "updated-new"
        hh["version"].should eql 2
      end
    end
    it "should not persiste a blog post update within the sandbox" do
      hit "/posts/" << @blog_bert.posts[0].uuid, :put, pk_with_auth(:bert).merge({ post: { author: @ernie.uuid,
                                                                                   title: "Updated NEW" } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["blog"]["uuid"].should eql @blog_bert.uuid
        hh["version"].should eql 2
        BlogPost.find_by_uuid(@blog_bert.posts[0].uuid).user.uuid.should eql @bert.uuid
      end
    end

    it "should fail for a non-existent blog post" do
    end
    it "should fail for an unconnected blog post" do
    end
    it "should fail with an invalid title" do
    end
  end

  context "blog post deletion" do
    it "should delete a blog post" do
      hit "/posts/" << @blog_bert.posts[0].uuid, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      BlogPost.valid_uuid?(@blog_bert.posts[0].uuid).should be_false
    end
    it "should not persist a blog post deletion within the sandbox" do
      hit "/posts/" << @blog_bert.posts[0].uuid, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      BlogPost.valid_uuid?(@blog_bert.posts[0].uuid).should be_true
    end

    it "should fail for a non-existent blog post" do
      hit "/posts/" << $uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for an unconnected blog post" do
      hit "/posts/" << @blog_fred.posts[0].uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
