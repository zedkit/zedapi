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

PADRINO_ENV = "development" unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

namespace :db do
  desc "Seed the database with starting fixtures"
  task :seed do

    # Zedkit
    p = Project.create! name: "Zedkit"
    p.project_keys.create! platform: ZedkitPlatform::WWW, name: "Zedkit"

    u = User.new project: p, first_name: "Eric", surname: "Woodward", username: "ejw", email: "ejw@zedkit.com"
    u.set_password("init")
    u.save!
    p.project_admins.create! user_id: u.id, role: AdminRole::ADMIN


    # Zedkit Gems
    p = Project.create! name: "Zedkit Gems", locale: "en", location: "gems", :locales_key => "6yca7DsnBvaDVupKEZ"
    p.project_keys.create! platform: ZedkitPlatform::WWW, name: "Zedkit Gems", :project_key => "BE1OZog8gJogtQTosh"

    u = User.new project: p, first_name: "Gems", username: "gems", email: "gems@zedkit.com"
    u.set_password("NGIaDhr5vDlXo1tDs6bW3Gd")
    u.save!
    l = User.new project: p, first_name: "Lacky", username: "lacky", email: "lacky@zedkit.com"
    l.set_password("NGIaDhr5vDlXo1tDs6bW3Gd")
    l.save!

    p.project_admins.create! user_id: u.id, role: AdminRole::ADMIN
    p.project_admins.create! user_id: l.id, role: AdminRole::ADMIN

    b = p.blogs.create! name: "Blog"

  end
end
