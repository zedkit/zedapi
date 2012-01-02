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

class ZedkitBoolean
  attr_accessor :value

  VALID_STRINGS = %w(true false YES NO)

  def initialize(items = {})
    @value = ZedkitBoolean.boolean_value(items[:value]) 
  end

  def to_i
    true? ? 1 : 0
  end
  def to_s
    @value.to_s
  end

  def true?
    @value
  end
  def false?
    not @value
  end

  class << self
    def valid_value?(val)
      return true if val.is_a?(TrueClass) || val.is_a?(FalseClass)
      return true if val.is_a?(String) && (VALID_STRINGS.include?(val.downcase) || VALID_STRINGS.include?(val.upcase))
      return true if val.is_a?(Integer) && (val == 0 || val == 1)
      false
    end
    def boolean_value(val)
      raise Exception unless valid_value?(val)
      if (val.is_a?(String) && ((val.downcase == "true") || (val.upcase == "YES"))) || (val.is_a?(Integer) && val == 1)
        true
      else
        false end
    end
  end
end
