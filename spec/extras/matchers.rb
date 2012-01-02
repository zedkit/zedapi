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

RSpec::Matchers.define :be_valid_content do
  match do |response|
    not response.body.include?("translation missing:")
  end
end
RSpec::Matchers.define :be_valid_uuid do
  match do |uuid|
    uuid.is_a?(String) && uuid.length == CollectionObject::LENGTH_UUID
  end
end

RSpec::Matchers.define :be_zedkit_snapshot do
  chain(:with) do |items|
    @items = items
  end
  match do |response|
    @items ||= []
    json = JSON.parse(response.body)
    response.status == 200 && (response.should be_valid_content) && json.is_a?(Hash) && json.has_all_as_zedkit_keys?(@items)
  end
end
RSpec::Matchers.define :be_zedkit_list do
  match do |response|
    response.status == 200 && (response.should be_valid_content) && JSON.parse(response.body).is_a?(Array)
  end
end
RSpec::Matchers.define :be_zedkit_object do
  chain(:with_http_code) do |code|
    @code = code
  end
  match do |response|
    @code ||= 200
    json = JSON.parse(response.body)
    response.status == @code && (response.should be_valid_content) && json.is_a?(Hash) \
      && json.has_key?("uuid") \
      && json["uuid"].length == CollectionObject::LENGTH_UUID
  end
end
RSpec::Matchers.define :be_zedkit_deletion do
  match do |response|
    response.status == 200 && response.body.blank?
  end
end

RSpec::Matchers.define :be_http_failure do |code|
  match do |response|
    response.status == code && response.body.blank?
  end
end
RSpec::Matchers.define :be_zedapi_status do |code|
  chain(:with) do |message|
    @message = message
  end
  match do |response|
    json = JSON.parse(response.body)
    response.status == 200 && (response.should be_valid_content) && json.is_a?(Hash) \
      && json["status"].present? \
      && json["status"]["code"] == code && json["status"]["message"] == @message
  end
end

RSpec::Matchers.define :validate_with do |message|
  chain(:on) do |attribute|
    @attribute = attribute
  end
  match do |pm|
    pm.valid?
    pm.errors[@attribute].length == 1 && pm.errors[@attribute] == [message]
  end
  failure_message_for_should do |pm|
    "Validation for #{@attribute.to_s.inspect} is #{pm.errors[@attribute].inspect}."
  end
end
RSpec::Matchers.define :be_validation_failure_on do |attribute|
  chain(:with) do |message|
    @message = message
  end
  match do |response|
    json = JSON.parse(response.body)
    (response.should be_zedapi_status(805).with("Errors Detected on Submitted Data Item(s)")) \
      && json["errors"].present? \
      && json["errors"]["attributes"].present? && json["errors"]["attributes"][attribute.to_s] == @message
  end
end
