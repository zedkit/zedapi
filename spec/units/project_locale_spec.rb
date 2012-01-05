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

describe ProjectKey do
  let(:project) { Project.create! name: "existing project" }
  let(:user) { User.create! project: project, :email => "gargamel@whatever.com" }
  let(:locale) { ProjectLocale.new project: project, locale: $locales[5].code }
  let(:created) { project.project_locales.create locale: $locales[5].code, stage: CollectionObject::STAGE_PRODUCTION }

  context "when new" do
    it "is valid with valid attributes" do
      locale.should be_valid
      locale.uuid.should be_valid_uuid
      locale.locale.should eql $locales[5].code
      locale.stage.should eql CollectionObject::STAGE_DEVELOPMENT
    end

    it "is invalid without the locale" do
      locale.locale = nil
      locale.should validate_with("The locale is invalid.").on(:locale)
    end
    it "is invalid with an invalid locale" do
      locale.locale = "zz"
      locale.should validate_with("The locale is invalid.").on(:locale)
    end
    it "is invalid with the project default locale" do
      locale.locale = locale.project.locale
      locale.should validate_with("The locale already set for this project.").on(:locale)
    end
    it "is invalid with an already set locale" do
      locale.locale = created.locale
      locale.should validate_with("The locale already set for this project.").on(:locale)
    end

    it "is invalid with an invalid stage" do
      locale.stage = "HUH"
      locale.should validate_with("The project locale's stage is invalid.").on(:stage)
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

  context "when deleted" do
    it "with audit has a deletion audit trail" do
    end
  end
end
