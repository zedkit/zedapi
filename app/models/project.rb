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

class Project < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  RESERVED_LOCATIONS = %w(api blog content corp db dns email project rest zedbeans zedblogs zeddb zedkit zedlocales)

  field :locale, :default => ZedkitLocale::ENGLISH
  field :uuid
  field :name
  field :location
  field :locales_key
  field :version, :type => Integer, :default => 0
  field :status,  :default => CollectionObject::ACTIVE

  index :uuid
  index :name
  index :location, :unique => true
  index :locales_key
  index :status
  index [[:location, Mongo::ASCENDING], [:status, Mongo::ASCENDING]]

  embeds_one :project_settings, :class_name => "ProjectSettings"

  # embeds_many :project_keys
  # embeds_many :project_users
  # embeds_many :project_locales
  # embeds_many :project_shelves, :class_name => "ProjectShelf"

  has_many :users
  # has_many :email_messages
  # has_many :email_settings, :class_name => "EmailSettings"
  # has_many :beta_addresses
  # has_many :shorteners
  # has_many :blogs
  # has_many :logs
  # has_many :queues
  # has_many :servers
  # has_many :content_sections

  set_as_audited :fields => [ :locale, :name, :location, :locales_key, :status ]

  before_validation :set_uuid, :set_locales_key, :set_location, :on => :create
  before_validation :set_locale, :set_version
  validate :valid_associations?, :reserved_location?
  validates :uuid, :presence => true, :uniqueness => true, :length => { :is => LENGTH_UUID }
  validates :name, :presence => true, :length => { :minimum => 2, :maximum => 48 }
  validates :location, :presence => true, :uniqueness => true,
                       :length => { :minimum => 2, :maximum => 32 }, :format => { :with => /\A[\sA-Za-z0-9_-]+\Z/ }
  validates :locales_key, :presence => true, :uniqueness => true,
                          :length => { :is => LENGTH_LOCALES_KEY }, :format => { :with => /\A[A-Za-z0-9]+\Z/ }
  validates :version, :presence => true, :numericality => { :greater_than_or_equal_to => 1, :only_integer => true }
  validates :status, :presence => true, :inclusion => { :in => %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def has_settings?
    project_settings.present?
  end
  def settings
    return project_settings if has_settings?
    ProjectSettings.new(project: self)
  end

  def has_locales?
    not project_locales.empty?
  end
  def locale_is_connected?(locale)
    not project_locales.where(locale: locale).empty?
  end

  def valid_user_password?(user_pwd)
    user_pwd.length >= 2
  end
  def user_password_error_code(user_pwd)
    user_pwd.length < 2 ? :too_short : :invalid
  end

  def has_admins?
    project_users.present?
  end
  def user_is_admin?(user_id)
    user_is_connected?(user_id) && UserRole.find_by_code(project_users.where(user_id: user_id).first.role).is_admin?
  end
  def user_is_connected?(user_id)
    project_users.where(user_id: user_id).length > 0
  end

  def to_api
    ts = {
      "uuid" => uuid, "name" => name, "location" => "http://#{location}.zedapi.com", "locales" => locales_lists,
      "admins" => project_users.map {|pa| User.find(pa.user_id).to_api_as_uuid_and_name },
      "keys" => project_keys.where(status: CollectionObject::ACTIVE).map(&:uuid),
      "email_settings" => email_settings.where(status: CollectionObject::ACTIVE).map(&:uuid),
      "shelves" => project_shelves.map(&:shelf),
      "blogs" => blogs.where(status: CollectionObject::ACTIVE).map(&:uuid),
      "shorteners" => shorteners.where(status: CollectionObject::ACTIVE).map(&:uuid)
    }
    if has_settings?
      ts["settings"] = project_settings.to_api
    else
      ts["settings"] = ProjectSettings.to_api_with_defaults(self)
    end
    ts.merge({ "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api })
  end
  def models_to_api
    ts  = project_models.where(status: CollectionObject::ACTIVE).map(&:to_api_without_project)
    ts << ProjectModel.system_model_to_api(:user, self, false)
    ts.flatten.sort {|x,y| x["name"] <=> y["name"] }
  end

  def locales_lists
    ts = { "default" => locale, "development" => [locale], "stage" => [locale], "production" => [locale] }
    project_locales.each do |wloc|
      ts["development"] << wloc.locale
      ts["stage"] << wloc.locale if wloc.stage == STAGE_STAGE || wloc.stage == STAGE_PRODUCTION
      ts["production"] << wloc.locale if wloc.stage == STAGE_PRODUCTION
    end
    ts
  end

  class << self
    def reserved_location?(location_to_check)
      RESERVED_LOCATIONS.include?(location_to_check.downcase)
    end

    def valid_locales_key?(key)
      exists?(:conditions => { locales_key: key }) && first(:conditions => { locales_key: key }).active?
    end
    def find_by_locales_key(key)
      me = first(:conditions => { locales_key: key })
      return me if me.present? && me.active?
      nil
    end
  end

  def reset_locales_key
    self.locales_key = nil
    while locales_key.blank?
      kk = RandomCode.new(length: LENGTH_LOCALES_KEY).code
      self.locales_key = kk unless Project.exists?(:conditions => { :locales_key => kk })
    end
  end

  protected
  def valid_associations?
    errors.add :locale if error_free?(:locale) && ZedkitLocale.invalid_code?(locale)
  end
  def reserved_location?
    errors.add(:location, :exclusion) if error_free?(:location) && location.present? && Project.reserved_location?(location)
  end

  def set_location
    while location.blank? do
      wps = $project_prefixes.select {|pp| pp[:stage] == PREFIX_CURRENT }
      ppp = "#{wps.at(rand(wps.length))[:prefix]}_#{wps.at(rand(wps.length))[:prefix]}_#{rand(1000)}".downcase
      self.location = ppp unless Project.exists?(:conditions => { :location => ppp })
    end
    location.downcase!
  end
  def set_locales_key
    reset_locales_key if locales_key.blank?
  end

  def set_locale
    self.locale.downcase! if locale.present? && (not locale.include?("-"))
  end
end
