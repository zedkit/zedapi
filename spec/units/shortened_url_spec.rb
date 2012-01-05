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

describe ShortenedUrl do
  let(:project) { Project.create! name: "existing project" }
  let(:user) { project.users.create! email: "gargamel@whatever.com" }
  let(:shortener) { project.shorteners.create! domain: "whatever.com" }
  let(:url) { shortener.urls.new user: user, destination: "http://zedkit.com/" }
  let(:created) { shortener.urls.create! user: user, destination: "http://zedkit.com/" }

  context "when new" do
    it "is valid with valid attributes" do
      url.should be_valid
      url.uuid.should be_valid_uuid
      url.url_path.should eql "1"
      url.version.should eql 1
    end
    it "is valid without a user" do
      url.user = nil
      url.should be_valid
      url.version.should eql 1
    end

    it "is invalid without a shortener" do
      url.shortener = nil
      url.should validate_with("The shortener does not exist or its use is not available.").on(:shortener)
    end
    it "is invalid with a non-existent shortener" do
      url.shortener_id = $bson
      url.should validate_with("The shortener does not exist or its use is not available.").on(:shortener)
    end

    it "is invalid without a destination" do
      url.destination = nil
      url.should validate_with("The destination URL is a required data item.").on(:destination)
    end
    it "is invalid with a destination that is too short" do
      url.destination = "http://k.m"
      url.should validate_with("The destination URL must be at least 12 characters.").on(:destination)
    end
    it "is invalid with a destination that is too long" do
      url.destination = "http://" << Array.new(1750, "a").join << ".com"
      url.should validate_with("The destination URL cannot exceed 1024 characters.").on(:destination)
    end

    it "is invalid with invalid standing" do
      url.standing = "HUH"
      url.should validate_with("The shortened URL's standing is invalid.").on(:standing)
    end
  end

  context "when created" do
    it "with audit has an addition audit trail" do
      ## TBD
    end
  end

  context "when updated" do
    it "with audit has an update audit trail" do
      ## TBD
    end
  end

  context "when deleted" do
    it "with audit has a deletion audit trail" do
      ## TBD
    end
  end
end

