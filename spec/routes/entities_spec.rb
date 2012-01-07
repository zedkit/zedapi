# encoding: utf-8
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
  context "country entities" do
    it "should return countries without project key or authorization" do
      visit "/entities/countries", :get
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh[0]["name"].should_not be_nil
        hh[0]["code"].should_not be_nil
        hh.length.should eql ZedkitCountry.count - 2
        hh.detect {|country| country["code"] == "US" }.should be_present
        hh.detect {|country| country["code"] == "CA" }.should be_present
      end
    end
    it "should return countries without authorization" do
      visit "/entities/countries", :get, { :project_key => pk(:bert) }
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh[0]["name"].should_not be_nil
        hh[0]["code"].should_not be_nil
        hh.length.should eql ZedkitCountry.count - 2
        hh.detect {|country| country["code"] == "US" }.should be_present
        hh.detect {|country| country["code"] == "CA" }.should be_present
      end
    end
    it "should return countries" do
      hit "/entities/countries", :get, pk_with_auth(:bert)
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh[0]["name"].should_not be_nil
        hh[0]["code"].should_not be_nil
        hh.length.should eql ZedkitCountry.count - 2
        hh.detect {|country| country["code"] == "US" }.should be_present
        hh.detect {|country| country["code"] == "CA" }.should be_present
      end
    end

    it "should return countries in french" do
      hit "/entities/countries", :get, pk_with_auth(:bert).merge!({ locale: "fr" })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        ## TBD
      end
    end
    it "should return countries in spanish" do
      hit "/entities/countries", :get, pk_with_auth(:bert).merge!({ locale: "es" })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        ## TBD
      end
    end
  end

  context "region entities" do
    it "should return regions" do
      hit "/entities/regions", :get, pk_with_auth(:bert)
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql ZedkitRegion.count
        hh[0]["code"].should_not be_nil
        hh[0]["name"].should_not be_nil
        hh.detect {|region| region["name"] == "Alabama" }.should be_present
      end
    end
    it "should return states for USA" do
      hit "/entities/regions", :get, pk_with_auth(:bert).merge({ country: { code: "US" } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql ZedkitRegion.in(ZedkitCountry::UNITED_STATES).count
        hh[0]["code"].should_not be_nil
        hh[0]["name"].should_not be_nil
        hh.detect {|region| region["name"] == "Alabama" }.should be_present
        hh.detect {|region| region["name"] == "Alberta" }.should_not be_present
      end
    end
    it "should return provinces for Canada" do
      hit "/entities/regions", :get, pk_with_auth(:bert).merge({ country: { code: "CA" } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql ZedkitRegion.in(ZedkitCountry::CANADA).count
        hh[0]["code"].should_not be_nil
        hh[0]["name"].should_not be_nil
        hh.detect {|region| region["name"] == "Alberta" }.should be_present
        hh.detect {|region| region["name"] == "Alabama" }.should_not be_present
      end
    end

    it "should fail for invalid country code" do
      hit "/entities/regions", :get, pk_with_auth(:bert).merge({ country: { code: "HH" } })
      response.should be_zedapi_status(805).with("Parameter Value Submitted is Invalid")
    end
  end

  context "Zedkit entities" do
    it "should return entities for Zedkit" do
      hit "/entities/zedkit", :get, { :project_key => pk(:bert) }
      response.status.should eql 200
      lambda { JSON.parse(response.body) }.should_not raise_error
      with_parsed response.body do |hh|
        hh["locales"].length.should eql ZedkitLocale.count
        hh["languages"].length.should eql Language.count
        hh["email_providers"].length.should eql EmailProvider.count
        hh["locales"].detect {|locale| locale["name"] == "Arabic" }
        hh["languages"].detect {|language| language["name"] == "Arabic" }
      end
    end
  end

  context "Zedlocales entities" do
    it "should return entities for Zedlocales" do
      hit "/entities/zedlocales", :get, { :project_key => pk(:bert) }
      response.status.should eql 200
      lambda { JSON.parse(response.body) }.should_not raise_error
      with_parsed response.body do |hh|
        hh["locales"].length.should eql ZedkitLocale.count
        hh["languages"].length.should eql Language.count
      end
    end
  end
end
