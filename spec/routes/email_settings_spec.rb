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
  context "email settings list" do
    it "should return a project's email settings" do
      hit "/email/settings", :get, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid } })
      response.should be_zedkit_list
      with_parsed response.body do |hh|
        hh.length.should eql @project_bert.email_settings.length
        hh.detect {|em| em["uuid"] == @project_bert.email_settings[0]["uuid"] }.should be_present
        hh.detect {|em| em["username"] == @project_bert.email_settings[0]["username"] }.should be_present
      end
    end

    it "should fail without project uuid" do
      hit "/email/settings", :get, pk_with_auth(:bert) 
      response.should be_http_failure 400
    end
    it "should fail with non-existent project" do
      hit "/email/settings", :get, pk_with_auth(:bert).merge({ project: { uuid: $uuid } })
      response.should be_http_failure 404
    end
    it "should fail without project connection" do
      hit "/email/settings", :get, pk_with_auth(:bert).merge({ project: { uuid: @project_fred.uuid } })
      response.should be_http_failure 403
    end
  end

  context "email settings get" do
    it "should return email settings" do
      hit "/email/settings/" << @project_bert.email_settings.first.uuid, :get, pk_with_auth(:bert)
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @project_bert.email_settings.first.uuid
        hh["username"].should eql @project_bert.email_settings.first.username
      end
    end

    it "should fail with non-existent email settings uuid" do
      hit "/email/settings/" << $uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for unconnected email settings" do
      hit "/email/settings/" << @project_fred.email_settings.first.uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end

  context "email settings creation" do
    it "should create email settings" do
      hit "/email/settings", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid },
                                                                settings: { provider: EmailProvider::POSTMARK,
                                                                            username: "whatever", password: "yo" } })
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["provider"]["code"].should eql EmailProvider::POSTMARK
        hh["username"].should eql "whatever"
        hh["password"].should eql "yo"
        EmailSettings.valid_uuid?(hh["uuid"]).should be_true
      end
    end
    it "should not persist a new email settings within the sandbox" do
      hit "/email/settings", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_bert.uuid },
                                                                settings: { provider: EmailProvider::POSTMARK,
                                                                            username: "whatever", password: "yo" } }).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["provider"]["code"].should eql EmailProvider::POSTMARK
        hh["username"].should eql "whatever"
        hh["password"].should eql "yo"
        EmailSettings.valid_uuid?(hh["uuid"]).should be_false
      end
    end

    it "should fail with a non-exsistent project" do
      hit "/email/settings", :post, pk_with_auth(:bert).merge({ project: { uuid: $uuid },
                                                                settings: { username: "whatever", password: "yo" } })
      response.should be_http_failure 404
    end
    it "should fail with a unconnected project" do
      hit "/email/settings", :post, pk_with_auth(:bert).merge({ project: { uuid: @project_fred.uuid },
                                                                settings: { username: "whatever", password: "yo" } })
      response.should be_http_failure 403
    end
    it "should fail without username" do
    end
    it "should fail without password" do
    end
    it "should fail with an invalid email provider" do
    end
  end

  context "email settings update" do
    it "should update email settings" do
      hit "/email/settings/" << @project_bert.email_settings.first.uuid, :put, pk_with_auth(:bert).merge({ settings: { username: "updated" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["username"].should eql "updated"
        @project_bert.reload.email_settings.first.username.should eql "updated"
      end
    end
    it "should not persist an email settings update within the sandbox" do
      hit "/email/settings/" << @project_bert.email_settings.first.uuid, :put, pk_with_auth(:bert).merge({ settings: { username: "updated" } }).sandbox
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["username"].should eql "updated"
        @project_bert.reload.email_settings.first.username.should_not eql "updated"
      end
    end

    it "should fail with non-exsistent email settings uuid" do
      hit "/email/settings/" << $uuid, :put, pk_with_auth(:bert).merge({ settings: { username: "updated" } })
      response.should be_http_failure 404
    end
    it "should fail with unconnected email settings" do
      hit "/email/settings/" << @project_fred.email_settings.first.uuid, :put, pk_with_auth(:bert).merge({ settings: { username: "updated" } })
      response.should be_http_failure 403
    end
    it "should fail with an invalid email provider" do
    end
  end

  context "email settings deletion" do
    it "should delete email settings" do
      hit "/email/settings/" << @project_bert.email_settings.first.uuid, :delete, pk_with_auth(:bert)
      response.should be_zedkit_deletion
      EmailSettings.valid_uuid?(@project_bert.email_settings.first.uuid).should be_false
    end
    it "should not persist an email settings deletion within the sandbox" do
      hit "/email/settings/" << @project_bert.email_settings.first.uuid, :delete, pk_with_auth(:bert).sandbox
      response.should be_zedkit_deletion
      EmailSettings.valid_uuid?(@project_bert.email_settings.first.uuid).should be_true
    end

    it "shoud fail for non-existent email settings" do
      hit "/email/settings/" << $uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
    it "should fail for unconnected email settings" do
      hit "/email/settings/" << @project_fred.email_settings.first.uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
