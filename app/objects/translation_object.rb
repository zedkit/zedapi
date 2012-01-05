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

require "iconv"

class TranslationObject < CollectionObject
  STRING = "STRING"
  LITERAL = "LITERAL"
  INTEGER = "INTEGER"
  BOOLEAN = "BOOLEAN"
  PLURALIZED = "PLURALIZED"

  BOOLEAN_TRUE = "true"
  BOOLEAN_FALSE = "false"

  EMPTY_VALUE = "[[empty]]"
  SPACE_VALUE = "[[space]]"

  PERIOD_BABOSA_OVERRIDE = "dddooottt"

  def has_zero?
    zero.present?
  end
  def has_other?
    other.present?
  end

  def string_value?
    value_type == STRING
  end
  def literal_value?
    value_type == LITERAL
  end
  def integer_value?
    value_type == INTEGER
  end
  def boolean_value?
    value_type == BOOLEAN
  end
  def pluralized_value?
    value_type == PLURALIZED
  end

  class << self
    def value_to_locale_hash(content_value, content_type, other = nil, zero = nil)
      case content_type
      when STRING
        return ""  if content_value == EMPTY_VALUE
        return " " if content_value == SPACE_VALUE
      when LITERAL
        tmps = content_value.gsub(/ /,"").gsub(/\[/,"").gsub(/\]/,"").split(",")
        tmps.collect! {|i| i.gsub(/:/,"").to_sym } if tmps[0].is_a?(String) && tmps[0].starts_with?(":")
        return tmps
      when INTEGER
        return content_value.to_i
      when BOOLEAN
        return content_value == BOOLEAN_TRUE
      when PLURALIZED
        ts = {}
        ts["one"] = content_value.encode("UTF-8") if content_value.present?
        ts["other"] = other.encode("UTF-8") if other.present?
        ts["zero"] = zero.encode("UTF-8") if zero.present?
        return ts
      end
      content_value.encode("UTF-8")
    end
  end
end
