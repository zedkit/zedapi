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

RSpec.configure do |config|
  config.before(:each) do
    @project_bert = Project.create! name: "Berts BBS", locale: "en", location: "bert"
    @project_fred = Project.create! name: "Freds BBS", locale: "en", location: "fred"

    @bert = User.new project: @project_bert, first_name: "Bert", username: "bert", email: "bert@bert.me"
    @bert.set_password("AbCd")
    @bert.save!

    @ernie = User.new project: @project_bert, first_name: "Ernie", username: "ernie", email: "ernie@bert.me"
    @ernie.set_password("AbCd")
    @ernie.save!

    @fred = User.new project: @project_bert, first_name: "Fred", surname: "Flintstone", username: "fred", email: "fred@flintstone.me"
    @fred.set_password("AbCd")
    @fred.save!
  end
  config.after(:each) do
    %w(AuditTrail UserLogin User Project).each do |zkm|
      Object.const_get(zkm).delete_all
    end
  end
end

$uuid = "9e98f0c0c07b012da13958b0356a50bA".freeze
$bson = BSON::ObjectId.from_string("4cbb96ba7d966826fc00002f").freeze