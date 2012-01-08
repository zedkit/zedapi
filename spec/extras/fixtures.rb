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
    
    @project_bert.project_keys.create! platform: ZedkitPlatform::WWW, name: "Bert's BBS Website"
    @project_fred.project_keys.create! platform: ZedkitPlatform::WWW, name: "Fred's BBS Website"

    @project_bert.project_locales.create! locale: "fr", stage: CollectionObject::STAGE_PRODUCTION
    @project_bert.project_locales.create! locale: "es", stage: CollectionObject::STAGE_DEVELOPMENT
    @project_fred.project_locales.create! locale: "fr", stage: CollectionObject::STAGE_PRODUCTION
    @project_fred.project_locales.create! locale: "es", stage: CollectionObject::STAGE_DEVELOPMENT

    @project_bert.project_admins.create! user_id: @bert.id, role: AdminRole::ADMIN
    @project_fred.project_admins.create! user_id: @fred.id, role: AdminRole::ADMIN

    @project_bert.email_settings.create! provider: EmailProvider::SENDGRID, username: "whatever", password: "pwd"
    @project_fred.email_settings.create! provider: EmailProvider::SENDGRID, username: "whatever", password: "pwd"

    @blog_bert = @project_bert.blogs.create! name: "Bert's BBS Blog"
    @blog_fred = @project_fred.blogs.create! name: "Fred's BBS Blog"
    @blog_bert.posts.create! user: @bert, title: "Ernie", content: "Ernie needs to do the dishes more often.", stage: "POSTED"
    @blog_bert.posts.create! user: @bert, title: "Elmo", content: "Elmo is a great inspiration.", stage: "FINAL"
    @blog_fred.posts.create! user: @fred, title: "Bam Bam", content: "Bam bam might be dyslexic.", stage: "POSTED"
    @blog_fred.posts.create! user: @fred, title: "Let's Help", content: "Barney has a drinking problem.", stage: "FINAL"

    @shortener_bert = @project_bert.shorteners.create! domain: "bert.im"
    @shortener_fred = @project_fred.shorteners.create! domain: "fred.im"
    @shortener_bert.urls.create! destination: "http://ericwoodward.com/"
    @shortener_fred.urls.create! destination: "http://ericwoodward.com/"

    @project_bert.beta_addresses.create! email: "sad@elmo.com"
    @project_fred.beta_addresses.create! email: "happy@elmo.com"
  end
  config.after(:each) do
    %w(AuditTrail BetaAddress ShortenedUrl Shortener BlogPost Blog EmailSettings UserLogin User Project).each do |zkm|
      Object.const_get(zkm).delete_all
    end
  end
end

$uuid = "9e98f0c0c07b012da13958b0356a50bA".freeze
$bson = BSON::ObjectId.from_string("4cbb96ba7d966826fc00002f").freeze
