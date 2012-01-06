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
  context "user verification" do
    it "should verify a user with username via http basic authentication" do
      hit "/users/verify", :get, { project_key: pk(:bert), username: @bert.username, password: "AbCd" }
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @bert.uuid
        hh["email"].should eql @bert.email
      end
    end
    it "should verify a user with email address via http basic authentication" do
      hit "/users/verify", :get, { project_key: pk(:bert), username: @bert.email, password: "AbCd" }
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @bert.uuid
        hh["email"].should eql @bert.email
      end
    end
    it "should verify a user with user key" do
      hit "/users/verify", :get, { project_key: pk(:bert), user_key: @bert.user_key }
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @bert.uuid
        hh["email"].should eql @bert.email
      end
    end

    it "should fail without a project key" do
      hit "/users/verify", :get, { username: "bert", password: "AbCd" }
      response.should be_zedapi_status(801).with("Project or Service Access Key Required")
    end
    it "should fail with an invalid project key" do
      hit "/users/verify", :get, { project_key: "notaprojectkey", username: "bert", password: "AbCd" }
      response.should be_zedapi_status(800).with("Invalid Project or Service Access Key Submitted")
    end
    it "should fail without http basic authentication or user key" do
      visit "/users/verify", :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with an invalid username and password" do
      hit "/users/verify", :get, { project_key: pk(:bert), username: "wilma", password: "AbCd" }
      response.should be_http_failure 401
    end
    it "should fail with an invalid user key" do
      visit "/users/verify", :get, { project_key: pk(:bert), user_key: "notavalidkey" }
      response.should be_http_failure 401
    end
  end

  context "login" do
    it "should save a login record with email address via basic http authentication" do
      hit "/users/login", :get, { project_key: pk(:bert), username: @bert.email, password: "AbCd" }
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["user"]["uuid"].should eql @bert.uuid
        UserLogin.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should save a login record with username via basic http authentication" do
      hit "/users/login", :get, { project_key: pk(:bert), username: @bert.username, password: "AbCd" }
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["user"]["uuid"].should eql @bert.uuid
        UserLogin.valid_uuid?(hh['uuid']).should be_true
      end
    end
    it "should not save a login record in the sandbox" do
      hit "/users/login", :get, pk_with_auth(:bert).sandbox
      response.should be_zedkit_object.with_http_code 201
      with_parsed response.body do |hh|
        hh["user"]["uuid"].should eql @bert.uuid
        UserLogin.valid_uuid?(hh['uuid']).should be_false
      end
    end

    it "should fail without a project key" do
      hit "/users/login", :get, { username: @bert.username, password: "AbCd" }
      response.should be_zedapi_status(801).with("Project or Service Access Key Required")
    end
    it "should fail with an invalid project key" do
      hit "/users/login", :get, { project_key: "notaprojectkey", username: @bert.username, password: "AbCd" }
      response.should be_zedapi_status(800).with("Invalid Project or Service Access Key Submitted")
    end
    it "should fail without http basic authentication or user key" do
      visit "/users/login", :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail with an invalid username and password" do
      hit "/users/login", :get, { project_key: pk(:bert), username: "wilma", password: "AbCd" }
      response.should be_http_failure 401
    end
    it "should fail with an invalid user key" do
      visit "/users/login", :get, { project_key: pk(:bert), user_key: "notavalidkey" }
      response.should be_http_failure 401
    end
  end

  context "user get" do
    it "should return a user" do
      hit "/users/" << @bert.uuid, :get, pk_with_auth(:bert)
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @bert.uuid
        hh["email"].should eql @bert.email
      end
    end

    it "should fail without authentication" do
      visit "/users/" << @bert.uuid, :get, { project_key: pk(:bert) }
      response.should be_http_failure 401
    end
    it "should fail for non-existent user" do
      hit "/users/" << $uuid, :get, pk_with_auth(:bert)
      response.should be_http_failure 404
    end
  end
  
  context "user creation" do
    it "should create a user" do
    end
    it "should create a user without authentication" do
    end
    it "should not persist a user in the sandbox" do
    end

    it "should fail without parameters" do
    end
    it "should fail without a required parameter" do
    end
    it "should fail with a username already in use" do
    end
    it "should fail with an email address already in use" do
    end
    it "should fail with a single character password" do
    end
    it "should fail with a password and password confirmation that do not match" do
    end
  end
  
  context "user update" do
    it "should update an user" do
      hit "/users/" << @bert.uuid, :put, pk_with_auth(:bert).merge({ user: { email: "new@apple.com" } })
      response.should be_zedkit_object
      with_parsed response.body do |hh|
        hh["uuid"].should eql @bert.uuid
        hh["email"].should eql "new@apple.com"
        hh["version"].should eql 2
      end
    end
    it "should not persist an user update in the sandbox" do
    end
  
    it "should fail without user data item values" do
      hit "/users/" << @bert.uuid, :put, pk_with_auth(:bert)
      response.should be_http_failure 400
    end
    it "should fail without a required data item value" do
      hit "/users/" << @bert.uuid, :put, pk_with_auth(:bert).merge({ user: { pointless: "not used" } })
      response.should be_http_failure 400
    end
    it "should fail for username already in use" do
      hit "/users/" << @bert.uuid, :put, pk_with_auth(:bert).merge({ user: { username: @ernie.username } })
      response.should be_validation_failure_on(:username).with("The username is already in use.")
    end
    it "should fail for email address already in use" do
      hit "/users/" << @bert.uuid, :put, pk_with_auth(:bert).merge({ user: { email: @ernie.email } })
      response.should be_validation_failure_on(:email).with("The email address is already in use.")
    end
    it "should fail with password and password confirmation that do not match" do
      hit "/users/" << @bert.uuid, :put, pk_with_auth(:bert).merge({ user: { password: "test", password_again: "nottest" } })
      response.should be_validation_failure_on(:password).with("The password and password confirmation do not match.")
    end
  end
  
  context "user deletion" do
    it "should fail" do
      hit "/users/" << @bert.uuid, :delete, pk_with_auth(:bert)
      response.should be_http_failure 403
    end
  end
end
