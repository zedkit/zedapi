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

class ProjectLocale < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  embedded_in :project, inverse_of: :project_locales
  field :locale
  field :uuid
  field :stage,  default: CollectionObject::STAGE_DEVELOPMENT
  field :status, default: CollectionObject::ACTIVE

  index :uuid
  index :status

  set_as_audited fields: [ :locale, :stage, :status ]
  
  before_validation :set_uuid, :set_stage
  validate :valid_associations?, :default_locale?, :unique_locale?
  validates :locale, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :stage, presence: true, inclusion: { in: %w(DEVELOPMENT STAGE PRODUCTION) }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def to_api
    { "project" => { "uuid" => project.uuid }, "locale" => { "code" => locale }, "stage" => stage }
  end

  protected
  def valid_associations?
    errors.add :locale if error_free?(:locale) && ZedkitLocale.invalid_code?(locale)
  end
  def default_locale?
    errors.add(:locale, :taken) if error_free?(:locale) && project.locale == locale
  end
  def unique_locale?                                                                            ## Array.count() DOES NOT WORK!
    errors.add(:locale, :taken) if error_free?(:locale) && project.project_locales.select {|u| u.locale == locale }.length >= 2
  end

  def set_stage
    self.stage.upcase! unless stage.blank?
  end
end
