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
  context "user preferences get" do
    it "should return a user's preferences" do
      hit "/users/#{@bert.uuid}/preferences", :get, pk_with_auth(:bert)
      response.status.should eql 200
      lambda { JSON.parse(response.body) }.should_not raise_error
      with_parsed response.body do |hh|
        hh["remember"].should eql UserPreferences::YES
      end
    end

    it "should fail without authentication" do
      visit "/users/#{@bert.uuid}/preferences", :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
  end

  context "user preferences update" do
    it "should update a user's preferences" do
      hit "/users/#{@bert.uuid}/preferences", :put, pk_with_auth(:bert).merge({ preferences: { remember: UserPreferences::NO } })
      response.status.should eql 200
      lambda { JSON.parse(response.body) }.should_not raise_error
      with_parsed response.body do |hh|
        hh["remember"].should eql UserPreferences::NO
      end
    end

    it "should fail without authentication" do
      visit "/users/#{@bert.uuid}/preferences", :put, { project_key: pk(:bert) }.merge({ preferences: { remember: UserPreferences::YES } })
      response.should be_http_failure 401
    end
    it "should fail with an invalid value for remember preference" do
      hit "/users/#{@bert.uuid}/preferences", :put, pk_with_auth(:bert).merge({ preferences: { remember: "INVALID" } })
      response.should be_validation_failure_on(:remember).with("The automatic login preference is invalid.")
    end
  end
end
