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
  let(:project) { Project.create! name: "existing project" }
  let(:user) { project.users.create! email: "gargamel@whatever.com" }
  let(:blog) { project.blogs.create! name: "Whatever" }
  let(:post) { blog.posts.new user: user, title: "Whatever You Like", content: "YO" }
  let(:created) { blog.posts.create! user: user, title: "Whatever You Like", content: "YO" }

  context "when new and validated" do
    it "is valid with valid attributes" do
      post.should be_valid
      post.uuid.should be_valid_uuid
      post.markup.should eql ContentMarkup::HTML
      post.title.should eql "Whatever You Like"
      post.content.should eql "YO"
      post.version.should eql 1
      post.title_path.should eql "whatever-you-like"
    end

    it "is invalid without a blog" do
      post.blog = nil
      post.should validate_with("The blog does not exist or its use is not available.").on(:blog)
    end
    it "is invalid with a non-existent blog" do
      post.blog_id = $bson
      post.should validate_with("The blog does not exist or its use is not available.").on(:blog)
    end

    it "is invalid without a user" do
      post.user = nil
      post.should validate_with("The user does not exist or its use is not available.").on(:user)
    end
    it "is invalid with a non-existent user" do
      post.user_id = $bson
      post.should validate_with("The user does not exist or its use is not available.").on(:user)
    end

    it "is invalid with a invalid content markup" do
      post.markup = "HUH"
      post.should validate_with("The content markup type is invalid.").on(:markup)
    end

    it "is invalid without a title" do
      post.title = nil
      post.should validate_with("The post title is a required data item.").on(:title)
    end
    it "is invalid with a title that is too short" do
      post.title = "A"
      post.should validate_with("A post's title must be between 2 and 128 characters.").on(:title)
    end
    it "is invalid with a title that is too long" do
      post.title = "whateveryousaybigboyuhuhyeahneedstobeverylongforthistestwhateveryousaybigboyuhuhyeahneedstobeverylongforthistestwhateveryousaybigbo"
      post.should validate_with("A post's title must be between 2 and 128 characters.").on(:title)
    end
  
    it "is invalid with an invalid URL" do
    end

    it "is invalid with an invalid stage" do
      post.stage = "HUH"
      post.should validate_with("The blog post's stage is invalid.").on(:stage)
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

