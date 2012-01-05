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

class BlogPost < CollectionObject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Zedkit::Audited
  
  STAGE_DRAFT  = "DRAFT"
  STAGE_POSTED = "POSTED"

  belongs_to :blog, index: true, inverse_of: :posts
  belongs_to :user, index: true, inverse_of: :posts
  field :uuid
  field :markup, default: ContentMarkup::HTML
  field :title
  field :title_path
  field :url
  field :content
  field :processed
  field :posted_at, type: Time
  field :stage,     default: STAGE_DRAFT
  field :version,   type: Integer, default: 0
  field :status,    default: ACTIVE

  index :uuid
  index :stage
  index :status
  index :title_path
  index :created_at

  set_as_audited fields: [ :markup, :title, :content, :stage, :status ], references: [ :user ]

  before_validation :set_uuid, on: :create
  before_validation :set_title_path, :set_processed_content, :set_stage, :set_posted_at, :set_version
  validate :valid_associations?, :valid_url?
  validates :blog, presence: true
  validates :user, presence: true
  validates :uuid, presence: true, uniqueness: true, length: { is: LENGTH_UUID }
  validates :markup, presence: true
  validates :title, presence: true, length: { minimum: 2, maximum: 128 }
  validates :title_path, presence: true
  validates :url, length: { minimum: 12, maximum: 248 }, allow_nil: true
  validates :content, length: { maximum: 100000 }, allow_nil: true
  validates :processed, length: { maximum: 100000 }, allow_nil: true
  validates :stage, presence: true, inclusion: { in: %w(DRAFT POSTED) }
  validates :version, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :status, presence: true, inclusion: { in: %w(ACTIVE DELETE) }
  after_validation :compress_messages

  def draft?
    stage == BlogPost::STAGE_DRAFT
  end
  def posted?
    stage == BlogPost::STAGE_POSTED
  end

  def has_content?
    content.present? && content.length > 0
  end

  def to_api
    ts = { 
      "blog" => { "uuid" => blog.uuid },
      "uuid" => uuid,
      "author" => { "uuid" => user.uuid, "full_name" => user.full_name },
      "title" => title, "title_path" => title_path, "markup" => { "code" => markup }
    }
    ts["url"] = url if url.present?
    if has_content?
      ts.merge!({ "content" => content })
      ts.merge!({ "processed" => processed }) if processed.present?
    end
    ts.merge!({ "posted_at" => posted_at.to_api }) unless posted_at.blank?
    ts.merge({ "stage" => stage, "version" => version, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api })
  end
  def to_api_with_summary
    ts = {
      "uuid" => uuid,
      "author" => { "uuid" => user.uuid, "full_name" => user.full_name }, "title" => title, "title_path" => title_path
    }
    ts.merge!({ "posted_at" => posted_at.to_api }) unless posted_at.blank?
    ts.merge({ "stage" => stage, "created_at" => created_at.to_api, "updated_at" => updated_at.to_api })
  end

  class << self
    def valid_title_path?(title_path)
      return true if exists?(conditions: { title_path: title_path }) && first(conditions: { title_path: title_path }).active?
      false
    end
    def find_by_title_path(title_path)
      me = first(conditions: { title_path: title_path })
      return me if me.present? && me.active?
      nil
    end
  end

  protected
  def valid_associations?
    errors.add :blog if error_free?(:blog) && Blog.invalid_id?(blog_id)
    errors.add :user if error_free?(:user) && User.invalid_id?(user_id)
    errors.add :markup if error_free?(:markup) && ContentMarkup.invalid_code?(markup)
  end
  def valid_url?
    if error_free?(:url) && url.present?
      # TBD
    end
  end

  def set_title_path
    self.title_path = title.rstrip.gsub(/\s+/,"-").parameterize.downcase if title.present?
  end
  def set_stage
    self.stage = BlogPost::STAGE_DRAFT if stage == "FINAL"
  end
  def set_posted_at
    self.posted_at = Time.now if posted_at.blank? && posted?
  end
  def set_processed_content
    case markup
    when ContentMarkup::HAML
      self.processed = content      # TBD Haml::Engine.new(post.content).render
    when ContentMarkup::MARKDOWN
      self.processed = content      # TBD
    else                            # HTML and ??
      self.processed = content end
  end
end
