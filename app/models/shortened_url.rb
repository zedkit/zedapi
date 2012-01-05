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

class ShortenedUrl < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited

  STANDING_OK = "OK"
  STANDING_SPAM = "SPAM"

  belongs_to :shortener, index: true, inverse_of: :urls
  belongs_to :user, index: true, inverse_of: :urls
  field :uuid
  field :destination
  field :url_path
  field :redirects, type: Integer, default: 0
  field :standing,  default: STANDING_OK
  field :version, type: Integer, default: 0
  field :status,  default: CollectionObject::ACTIVE

  index :uuid
  index :url_path
  index :status
  index [[:shortener_id, Mongo::ASCENDING], [:url_path, Mongo::ASCENDING]]

  set_as_audited fields: [ :destination, :standing, :status ], references: [ :user ]

  before_validation :set_uuid, :set_url_path, on: :create
  before_validation :set_standing, :set_version
  validate :valid_associations?, :valid_destination?, :unique_url_path?
  validates :shortener, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :destination, presence: true, length: { minimum: 12, maximum: 1024 }
  validates :url_path, presence: true
  validates :redirects, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :standing, presence: true, inclusion: { in: %w(OK SPAM) }
  validates :version, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def ok?
    standing == BlogPost::STANDING_OK
  end
  def spam?
    standing == BlogPost::STANDING_SPAM
  end

  def to_api
    ts = { "shortener" => { "uuid" => shortener.uuid } }
    ts["user"] = { "uuid" => user.uuid } if user.present?
    ts.merge({
      "uuid" => uuid, "destination" => destination, "url_path" => url_path, "redirects" => redirects,
      "standing" => standing, "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api
    })
  end
  
  class << self
    def new_url_path(shortener_id)
      fm = { query: { "_id" => shortener_id }, update: { "$inc" => { "sequence" => 1 } }, new: false }
      BasemadeValue.new(i: Mongoid.master.collection("shorteners").find_and_modify(fm)["sequence"]).value
    end
  end

  protected
  def valid_associations?
    errors.add :shortener if error_free?(:shortener) && Shortener.invalid_id?(shortener_id)
    errors.add :user if error_free?(:user) && user.present? && User.invalid_id?(user_id)
  end
  def valid_destination?
    if error_free?(:destination) && destination.present?
      # TBD
    end
  end
  def unique_url_path?
    if error_free?(:url_path)
      if new_record?
        errors.add(:url_path, :taken) if ShortenedUrl.active_exists?(shortener_id: shortener_id, url_path: url_path)
      else
        ShortenedUrl.each_active(shortener_id: shortener_id, url_path: url_path) {|su| errors.add(:url_path, :taken) if id != su.id } end
    end
  end

  def set_url_path
    if url_path.blank? && error_free?(:shortener) && shortener.present? && shortener.is_a?(Shortener)
      self.url_path = ShortenedUrl.new_url_path(shortener.id)
    end
  end
  def set_standing
    self.standing.upcase! if standing.present?
  end
end
