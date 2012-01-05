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

require "digest/sha2"
require "bcrypt"

class User < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  attr_accessor :password_submitted, :password_again, :password_valid

  BCRYPT_COST = 5

  belongs_to :project, index: true, inverse_of: :users
  field :locale, default: ZedkitLocale::ENGLISH
  field :uuid
  field :first_name
  field :surname
  field :username
  field :email
  field :password
  field :user_key
  field :version, type: Integer, default: 0
  field :status,  default: CollectionObject::ACTIVE

  index :uuid
  index :user_key, unique: true
  index [[:project_id, Mongo::ASCENDING], [:username, Mongo::ASCENDING]]
  index [[:project_id, Mongo::ASCENDING], [:email,    Mongo::ASCENDING]]

  embeds_one :user_preferences, class_name: "UserPreferences"
  
  has_many :audits, class_name: "AuditTrail"
  has_many :logins, class_name: "UserLogin"
  has_many :posts, class_name: "BlogPost"
  has_many :urls, class_name: "ShortenedUrl"

  set_as_audited fields: [ :locale, :first_name, :surname, :username, :email, :password, :user_key, :status ]

  before_validation :set_uuid, :set_username, :set_email, :set_user_key, :set_version
  validate :valid_associations?, :unique_username?, :unique_email?, :requires_email?, :valid_valid?
  validate :valid_password_confirmation?
  validates :project, presence: true
  validates :locale, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :first_name, length: { maximum: 24 }
  validates :surname, length: { maximum: 32 }
  validates :username, presence: true, length: { minimum: 2, maximum: 18 }, format: { with: /^\w*$/ }
  validates :email, length: { maximum: 64 }, format: { with: /@/i }
  validates :password, length: { is: LENGTH_PASSWORD }, :allow_nil => true
  validates :user_key, presence: true, uniqueness: true, length: { is: LENGTH_USER_KEY }, format: { with: /^\w*$/ }
  validates :version, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :status, presence: true, inclusion: { :in => %w(ACTIVE DELETE) }
  after_validation :compress_messages
  
  def has_first_name?
    first_name.present?
  end
  def has_surname?
    surname.present?
  end
  def has_email?
    email.present?
  end

  def has_full_name?
    full_name.present?
  end
  def full_name
    fn = ""
    fn << first_name if has_first_name?
    if has_surname?
      fn << " " if has_first_name?
      fn << surname 
    end
    fn
  end

  def has_preferences?
    user_preferences.present?
  end
  def preferences
    if has_preferences?
      return user_preferences
    else
      return UserPreferences.new(user: self) end
  end

  def has_a_project?
    not projects.empty?
  end
  def has_multiple_projects?
    projects.length > 1
  end
  def is_admin_of_project?(project_id)
    Project.exists?(conditions: { id: project_id }) && Project.first(project_id).user_is_admin?(id)
  end
  def is_connected_to_project?(project_id)
    Project.exists?(conditions: { id: project_id }) && Project.first(project_id).user_is_connected?(id)
  end

  def projects
    Project.where("project_admins.user_id" => self.id)
  end
  def project_permissions(project_id)
    #is_connected_to_project?(project_id) ? projects.find(project_id).first.permissions : {} 
    {}
  end

  def to_api_for_sandbox
    ts = { 
      "project" => { "uuid" => project.uuid, "name" => project.name },
      "uuid" => uuid, "locale" => locale, "username" => username, "user_key" => user_key
    }
    ts["first_name"] = first_name if has_first_name?
    ts["surname"] = surname if has_surname?
    ts["full_name"] = full_name if has_full_name?
    ts["email"] = email if has_email?
    ts.merge({ "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api })
  end
  def to_api(include_projects = true, include_companies = true)
    ts = to_api_for_sandbox.merge({ "preferences" => preferences.to_api })
    ts["projects"] = projects.map(&:uuid) if include_projects && has_a_project?
    ts
  end
  def to_api_as_uuid_and_name
    { "uuid" => uuid, "full_name" => full_name }
  end
  def to_api_for_project(project_id)
    projects.id(project_id).empty? ? { "uuid" => uuid } : { "uuid" => uuid, "permissions" => project_permissions(project_id) }
  end

  def set_password(password_to_set)
    @password_submitted = password_to_set
    @password_valid = CollectionObject::NO
    if project.present? && project.valid_user_password?(password_to_set)
      @password_valid = CollectionObject::YES
      self.password = BCrypt::Password.create(password_to_set, cost: BCRYPT_COST)
    end
  end
  def valid_password?(password_to_check)
    unless password.nil? || password_to_check.blank?
      return BCrypt::Password.new(self.password) == password_to_check
    else
      return false end
  end

  class << self
    def valid_key?(key)
      exists?(conditions: { user_key: key, status: CollectionObject::STATUS_ACTIVE })
    end
    def find_by_key(key)
      first(conditions: { user_key: key, status: CollectionObject::STATUS_ACTIVE })
    end
  end

  protected
  def valid_associations?
    errors.add :project if error_free?(:project) && Project.invalid_id?(project_id)
    errors.add :locale if error_free?(:locale) && ZedkitLocale.invalid_code?(locale)
  end
  def unique_username?
    if error_free? :username
      if new_record?
        errors.add(:username, :taken) if User.active_exists?(project_id: project_id, username: username)
      else
        User.each_active(project_id: project_id, username: username) {|u| errors.add(:username, :taken) if id != u.id } end
    end
  end
  def unique_email?
    if has_email? && error_free?(:email)
      if new_record?
        errors.add(:email, :taken) if User.active_exists?(project_id: project_id, email: email)
      else
        User.each_active(project_id: project_id, email: email) {|uu| errors.add(:email, :taken) if id != uu.id } end
    end
  end
  def requires_email?
    errors.add(:email, :blank) if error_free?(:email) && email.blank? && project.present? && project.settings.email_required?
  end
  def valid_valid?
    if project.present? && error_free?(:password) && password_valid == CollectionObject::NO
      errors.add :password, project.user_password_error_code(password_submitted)
    end
  end
  def valid_password_confirmation?
    if password_submitted.present? && password_again.present?
      errors.add(:password, :exclusion) if error_free?(:password) && password_submitted != password_again
    end
  end

  def set_username
    self.username = RandomCode.new(length: LENGTH_GENERATED_USERNAME).code if username.blank?
    self.username.downcase!
  end
  def set_user_key
    self.user_key = RandomCode.new(length: LENGTH_USER_KEY).code if user_key.blank?
  end
  def set_email
    self.email.downcase! if email.present?
  end
end
