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
  context "fatal" do
    it "should return a HTTP 500" do
      begin
        visit "/tests/fatal", :get, { project_key: pk(:bert) }
        raise Exception("Should not get here.")
      rescue Webrat::PageLoadError => e
        e.to_s.should include "Code: 500" end
    end
  end

  context "missing" do
    it "should return a HTTP 404" do
      visit "/tests/missing", :get, { project_key: pk(:bert) }
      response.should be_http_failure(404)
    end
  end

  context "unauthorized" do
    it "should create a HTTP 401" do
      visit "/tests/unauthorized", :get, { project_key: pk(:bert) }
      response.should be_http_failure(401)
    end
  end
end
