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

describe UserPreferences do
  let(:project) { Project.create! name: "Created Project" }
  let(:user) { project.users.create! first_name: "Steve", surname: "Wozniak", email: "woz@apple.com" }
  let(:prefs) { user.create_user_preferences }

  context "when new" do
    it "is valid with valid default attributes" do
      prefs.should be_valid
      prefs.user.uuid.should eql user.uuid
      prefs.uuid.should be_valid_uuid
      prefs.remember.should eql CollectionObject::YES
    end

    it "is invalid with invalid remember value" do
      prefs.remember = "JUNK"
      prefs.should validate_with("The automatic login preference is invalid.").on(:remember)
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
end
