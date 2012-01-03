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

class CollectionObject
  LENGTH_UUID = 32
  LENGTH_PASSWORD = 60
  LENGTH_USER_KEY = 18
  LENGTH_LOCALES_KEY = 18
  LENGTH_GENERATED_USERNAME = 10

  YES = "YES"
  NO = "NO"
  ACTIVE = "ACTIVE"
  DELETE = "DELETE"

  STAGE_DEVELOPMENT = "DEVELOPMENT"
  STAGE_STAGE = "STAGE"
  STAGE_PRODUCTION = "PRODUCTION"
  STAGES = ["DEVELOPMENT","STAGE","PRODUCTION"]

  ACCESS_MANAGE = "MANAGE"
  ACCESS_READ = "READ"
  ACCESS_NONE = "NONE"
  ACCESSES = ["MANAGE","READ","NONE"]

  PREFIX_CURRENT = "CURRENT"
  PREFIX_RETIRED = "RETIRED"

  def active?
    status == ACTIVE
  end
  def delete?
    status == DELETE
  end

  def has_audits?
    audits.length > 1
  end
  def audits
    AuditTrail.where(object_uuid: uuid).limit(100).to_a
  end

  def has_errors?(item)
    errors[item].any?
  end
  def error_free?(item)
    not has_errors?(item)
  end

  # Mongo indexing is an issue not fully addressed here. To avoid having to maintain compound indexes on these queries
  # when UUIDs that are set to DELETE wont really be requested very often, we pull the record for the UUID, but only
  # return it if its status is set ACTIVE. We do not use a compound index here.

  class << self
    def valid_stage?(stage)
      STAGES.include?(stage.upcase)
    end

    def invalid_id?(the_id)
      not valid_id?(the_id)
    end
    def valid_id?(the_id)
      return false unless the_id.is_a? BSON::ObjectId
      return true if exists?(conditions: { id: the_id }) && first(conditions: { id: the_id }).active?
      false
    end
    def find_by_id(the_id)
      ## TBD
    end

    def valid_uuid?(uuid)
      return false if uuid.nil? || uuid.length != LENGTH_UUID
      return true if exists?(conditions: { uuid: uuid }) && first(conditions: { uuid: uuid }).active?
      false
    end
    def find_by_uuid(uuid)
      if uuid.present? && uuid.length == LENGTH_UUID
        me = first(conditions: { uuid: uuid })
        return me if me.present? && me.active?
      end
      nil
    end

    def active_exists?(conditions)
      where(conditions).detect {|me| me.active? }.present?
    end
    def each_active(conditions, &block)
      where(conditions).select {|me| me.active? }.each {|ma| yield ma if block_given? }
    end
  end

  protected
  def compress_messages
    self.errors.messages.each {|kk,vv| self.errors.messages[kk].pop if vv.length > 1 }
  end
  def set_uuid
    self.uuid = (UUID.new).generate(:compact) if self.uuid.blank?
  end
  def set_version
    self.version += 1
  end

  def key_to_normalized_value(key, overrides = :defaults)
    key.rstrip.downcase.to_slug.normalize(transliterations: overrides).to_s.gsub(/-/,"_").gsub(/#{TranslationObject::PERIOD_BABOSA_OVERRIDE}/,".")
  end
end
