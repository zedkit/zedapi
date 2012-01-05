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
  let(:bert_locale_path) { "/projects/#{@project_bert.uuid}/locales/#{@project_bert.project_locales.first.locale}" }
  let(:fred_locale_path) { "/projects/#{@project_fred.uuid}/locales/#{@project_fred.project_locales.first.locale}" }

  context "project locales key verification" do
    it "should verify a locales key" do
      visit "/projects/verify/locales", :get, { locales_key: @project_bert.locales_key }
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.uuid
        hh["name"].should eql @project_bert.name
      end
    end

    it "should fail for an invalid locales key" do
      visit "/projects/verify/locales", :get, { locales_key: "abcd" }
      response.should be_http_failure 403
    end
  end
  
  context "project's locales list" do
    it "should return a project's locales" do
      hit "/projects/#{@project_bert.uuid}/locales", :get, pk_with_auth(:bert)
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql 2
        hh.detect {|pk| pk["locale"]["code"] == @project_bert.project_locales.first.locale }.should be_present
      end
    end

    it "should fail without authentication" do
      hit "/projects/#{@project_bert.uuid}/locales", :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/locales", :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/projects/#{@project_fred.uuid}/locales", :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end

  context "project locale creation" do
    it "should create a new project locale" do
      hit "/projects/#{@project_bert.uuid}/locales", :post, pk_with_auth(:bert).merge({ locale: { code: "de" } })
      response.status.should eql 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["locale"]["code"].should eql "de"
        @project_bert.reload.project_locales.detect {|pl| pl.locale == hh["locale"]["code"] }.should be_present
      end
    end
    it "should not persist a new project locale within the sandbox" do
      hit "/projects/#{@project_bert.uuid}/locales", :post, pk_with_auth(:bert).merge({ locale: { code: "de" } }).sandbox
      response.status.should eql 201
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["locale"]["code"].should eql "de"
        @project_bert.reload.project_locales.detect {|pl| pl.locale == hh["locale"]["code"] }.should_not be_present
      end
    end

    it "should fail without authentication" do
      hit "/projects/#{@project_bert.uuid}/locales", :get, { project_key: pk(:bert) }.merge({ locale: { code: "de" } })
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/locales", :get, pk_with_auth(:bert).merge({ locale: { code: "de" } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/projects/#{@project_fred.uuid}/locales", :get, pk_with_auth(:bert).merge({ locale: { code: "de" } })
      response.should be_http_failure 403
    end
  end

  context "project locale update" do
    it "should update a project locale" do
      hit bert_locale_path, :put, pk_with_auth(:bert).merge({ locale: { stage: ProjectLocale::STAGE_STAGE } })
      response.status.should eql 200
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["stage"].should eql ProjectLocale::STAGE_STAGE
        @project_bert.reload.project_locales.detect {|pl| pl.stage == hh["stage"] }.should be_present
      end
    end
    it "should not persist a project key update within the sandbox" do
      hit bert_locale_path, :put, pk_with_auth(:bert).merge({ locale: { stage: ProjectLocale::STAGE_STAGE } }).sandbox
      response.status.should eql 200
      with_parsed response.body do |hh|
        hh["project"]["uuid"].should eql @project_bert.uuid
        hh["stage"].should eql ProjectLocale::STAGE_STAGE
        @project_bert.reload.project_locales.detect {|pl| pl.stage == hh["stage"] }.should_not be_present
      end
    end

    it "should fail without authentication" do
      hit bert_locale_path, :put, { project_key: pk(:bert) }.merge({ locale: { stage: ProjectLocale::STAGE_STAGE } })
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/locales/es", :put, pk_with_auth(:bert).merge({ locale: { stage: ProjectLocale::STAGE_STAGE } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit fred_locale_path, :put, pk_with_auth(:bert).merge({ locale: { stage: ProjectLocale::STAGE_STAGE } })
      response.should be_http_failure 403
    end
  end

  context "project locale deletion" do
    it "should delete a project locale" do
      hit bert_locale_path, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      @project_bert.reload.project_locales.first.should be_delete
    end
    it "should not persist a project locale deletion within the sandbox" do
      hit bert_locale_path, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      @project_bert.reload.project_locales.first.should be_active
    end

    it "should fail without authentication" do
      hit bert_locale_path, :delete, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with an non-existent project" do
      hit "/projects/#{$uuid}/keys/#{$uuid}", :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail with an unconnected project" do
      hit fred_locale_path, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
