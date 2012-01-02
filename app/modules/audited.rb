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

module Zedkit
  module Audited
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def set_as_audited(audits = {})                                     ## :references => [], :fields => []
        class_attribute :audit_enabled, :instance_writer => false
        class_attribute :audited_fields, :instance_writer => false
        class_attribute :audited_references, :instance_writer => false

        self.audit_enabled = true
        self.audited_fields, self.audited_references = [], []
        self.audited_fields = audits[:fields] if audits.has_key? :fields
        self.audited_references = audits[:references] if audits.has_key? :references

        self.send(:include, Zedkit::Audited::InstanceMethods)
      end
    end

    module InstanceMethods
      def set_audit
        @audited_values = {}

        ## pp "Audited References: #{audited_references}"
        ## pp "Audited Fields: #{audited_fields}"

        audited_references.each do |ref_id|
          @audited_values[ref_id] = self.send(ref_id).id.to_s if self.send(ref_id).present?
        end
        audited_fields.each do |ff|
          @audited_values[ff] = self.send(ff).to_s
        end

        ## pp "Audited Values: #{@audited_values}"
        self
      end

      def save_with_audit_trail(master, user_id, &block)
        new_record? ? was_new_record = true : was_new_record = false
        tt = nil
        save
        tt = save_audit_trail(master, user_id, was_new_record) if self.errors.empty?
        yield(tt) if tt.present? && block_given?
        tt
      end
      def save_with_audit_trail!(master, user_id, &block)
        new_record? ? was_new_record = true : was_new_record = false
        tt = nil
        save!
        tt = save_audit_trail(master, user_id, was_new_record)
        yield(tt) if tt.present? && block_given?
        tt
      end

      protected
      def save_audit_trail(master, user_id, was_new_record)
        from, to = {}, {}

        if was_new_record
          audited_references.each {|fi| to[fi] = self.send(fi).id.to_s if self.send(fi).present? }
          audited_fields.each {|ff| to[ff] = self.send(ff).to_s }
        else
          audited_references.each do |fi|
            unless self.send(fi).to_s.blank? || self.send(fi).id.to_s == @audited_values[fi]
              from[fi] = @audited_values[fi]
              to[fi] = self.send(fi).id.to_s
            end
          end
          audited_fields.each do |ff|
            unless self.send(ff).to_s.blank? || self.send(ff).to_s == @audited_values[ff]
              from[ff] = @audited_values[ff]
              to[ff] = self.send(ff).to_s
            end
          end
        end

        ## pp "FROM: #{from}"
        ## pp "TO: #{to}"

        unless to.empty?
          trail = AuditTrail.new do |at|
            at[:user_id] = user_id
            at[:master_type] = master.class.to_s
            at[:master_uuid] = master.uuid
            at[:object_type] = self.class.to_s
            at[:object_uuid] = self.uuid
            at[:state_from] = from.to_json
            at[:state_to] = to.to_json
            if from.empty?
              at[:action] = "ADDITION"
            else
              if from[:status] == "ACTIVE" && to[:status] == "DELETE"
                at[:action] = "DELETION"
              else
                at[:action] = "UPDATE" end
            end
          end
          ## pp "TRAIL: #{trail}"
          trail.save!
          return trail
        end
        nil
      end
    end
  end
end
