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

describe UserLogin do
  let(:project) { Project.create! name: "created project" }
  let(:user) { project.users.create! first_name: "Steve", surname: "Wozniak", email: "woz@apple.com" }
  let(:login) { user.logins.new address: "67.68.69.70" }

  context "when new" do
    it "is valid with valid default attributes" do
      login.should be_valid
      login.uuid.should be_valid_uuid
      login.address.should eql "67.68.69.70"
    end
    
    it "is invalid with an invalid country" do
      ## TBD
    end

    it "is invalid without an IP address" do
      ## TBD
    end
    it "is invalid with an invalid IP address" do
      ## TBD
    end
  end
end
