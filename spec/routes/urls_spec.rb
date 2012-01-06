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
  context "URL list" do
    it "should return a shortener's URLs" do
      hit "/urls", :get, pk_with_auth(:bert).merge({ shortener: { uuid: @shortener_bert.uuid } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql @shortener_bert.urls.length
        hh.detect {|url| url["uuid"] == @shortener_bert.urls[0]["uuid"] }.should be_present
        hh.detect {|url| url["url_path"] == @shortener_bert.urls[0]["url_path"] }.should be_present
        hh.detect {|url| url["destination"] == @shortener_bert.urls[0]["destination"] }.should be_present
      end
    end

    it "should fail without a referenced shortener" do
      hit "/urls", :get, pk_with_auth(:bert)
      response.should be_http_failure 400
    end
    it "should fail with non-existent shortener" do
      hit "/urls", :get, pk_with_auth(:bert).merge({ shortener: { uuid: $uuid } })
      response.should be_http_failure 404
    end
    it "should fail with an unconnected shortener" do
      hit "/urls", :get, pk_with_auth(:bert).merge({ shortener: { uuid: @shortener_fred.uuid } })
      response.should be_http_failure 403
    end
  end

  context "URL get" do
    it "should return a URL" do
      hit "/urls/" << @shortener_bert.urls[0].uuid, :get, pk_with_auth(:bert)
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @shortener_bert.urls[0].uuid
        hh["url_path"].should eql @shortener_bert.urls[0].url_path
        hh["destination"].should eql @shortener_bert.urls[0].destination
      end
    end

    it "should fail with a non-existent URL" do
      hit "/urls/" << $uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail with an unconnected URL" do
      hit "/urls/" << @shortener_fred.urls[0].uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
  
  context "URL creation" do
    it "should create a new URL" do
      hit "/urls", :post, pk_with_auth(:bert).merge({ shortener: { uuid: @shortener_bert.uuid },
                                                      url: { destination: "http://yummy.com/post" } })
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["shortener"]["uuid"].should eql @shortener_bert.uuid
        hh["destination"].should eql "http://yummy.com/post"
        hh["url_path"].should_not be_nil
        hh["version"].should eql 1
        ShortenedUrl.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should not persist a new URL within the sandbox" do
      hit "/urls", :post, pk_with_auth(:bert).merge({ shortener: { uuid: @shortener_bert.uuid },
                                                      url: { destination: "http://yummy.com/post" } }).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["shortener"]["uuid"].should eql @shortener_bert.uuid
        hh["version"].should eql 1
        ShortenedUrl.valid_uuid?(hh['uuid']).should be_false
      end
    end
    
    it "should fail for an unconnected shortener" do
      hit "/urls", :post, pk_with_auth(:bert).merge({ shortener: { uuid: @shortener_fred.uuid },
                                                      url: { destination: "http://yummy.com/post" } })
      response.should be_http_failure 403
    end
    it "should fail without a destination" do
      hit "/urls", :post, pk_with_auth(:bert).merge({ shortener: { uuid: @shortener_bert.uuid } })
      response.should be_http_failure 400
    end
    it "should fail with an invalid destination" do
    end
  end
  
  context "URL update" do
    it "should update an URL" do
      hit "/urls/" << @shortener_bert.urls[0].uuid, :put, pk_with_auth(:bert).merge({ url: { standing: "SPAM" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["shortener"]["uuid"].should eql @shortener_bert.uuid
        hh["standing"].should eql "SPAM"
        hh["version"].should eql 2
      end
    end
    it "should not persist an URL update within the sandbox" do
      hit "/urls/" << @shortener_bert.urls[0].uuid, :put, pk_with_auth(:bert).merge({ url: { standing: "SPAM" } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["shortener"]["uuid"].should eql @shortener_bert.uuid
        hh["standing"].should eql "SPAM"
        hh["version"].should eql 2
        ShortenedUrl.find_by_uuid(@shortener_bert.urls[0].uuid).standing.should_not eql "SPAM"
      end
    end

    it "should fail for a non-existent URL" do
    end
    it "should fail for an unconnected URL" do
    end
    it "should fail with an invalid title" do
    end
  end

  context "URL deletion" do
    it "should delete an URL" do
      hit "/urls/" << @shortener_bert.urls[0].uuid, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      ShortenedUrl.valid_uuid?(@shortener_bert.urls[0].uuid).should be_false
    end
    it "should not persist an URL deletion within the sandbox" do
      hit "/urls/" << @shortener_bert.urls[0].uuid, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      ShortenedUrl.valid_uuid?(@shortener_bert.urls[0].uuid).should be_true
    end

    it "should fail for a non-existent URL" do
      hit "/urls/" << $uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for an unconnected URL" do
      hit "/urls/" << @shortener_fred.urls[0].uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
