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

ZedAPI.helpers do
  # Errors here can be any hash that responds to each(), with key/value iteration. Expected to be from ActiveModel,
  # typically.

  def set_error_response(options = {})
    raise ArgumentError unless $api_messages.has_key?(options[:code])
    options[:message] ||= nil
    options[:errors]  ||= nil
    rh = { "status" => { "result" => "ERROR", "code" => options[:code] } }
    if options[:errors].present?
      rh["status"]["message"] = I18n.translate(:general, scope: [:api, :errors])
      rh["errors"] = {
        "attributes" => collect_object_errors(options[:errors]),
        "ids" => collect_object_errors_as_ids(options[:errors])
      }
      rh["errors"]["primary"] = rh["errors"]["attributes"].to_a[0][1]
    else
      options[:message].present? ? rh["status"]["message"] = options[:message]
                                 : rh["status"]["message"] = $api_messages[options[:code]]
    end
    json rh
  end

  # Any model can define Class.attribute_conversion_for() to represent an attribute as whatever it likes to the
  # outside world. initializers/activemodel.rb makes this possible.

  def collect_object_error(errors)
    errors.empty? ? errors.shift[1] : nil
  end
  def collect_object_errors(errors)
    collection = {}
    errors.each do |attribute, message|
      if errors.class.respond_to?("attribute_conversion_for")
        collection[errors.class.attribute_conversion_for(attribute)] = message
      else
        collection[attribute] = message end
    end
    collection
  end
  def collect_object_errors_as_ids(errors)
    collection = {}
    errors.each do |attribute, message|
      model_class = errors.base.class.to_s.underscore.to_sym
      model_name  = I18n.translate(model_class, locale: :en, scope: [:mongoid, :representations]).gsub(/\s/,"_").downcase
      if errors.class.respond_to?("attribute_conversion_for")
        collection["#{model_name}_#{errors.class.attribute_conversion_for(attribute)}"] = message
      else
        collection["#{model_name}_#{attribute}"] = message end
    end
    collection
  end
end
