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

class ZedkitCountry < StaticObject
  UNITED_STATES = "US"
  CANADA = "CA"
  UNKNOWABLE = "YY"
  UNKNOWN = "ZZ"

  def actual_country?
    not unknown_code?(code)
  end
  def has_regions?
    false
  end

  def to_api
    {
      "code" => code,
      "name" => I18n.t(name.to_sym, :scope => [:country]), "locale" => { "code" => code }, "currency" => { "code" => code }
    }
  end
  def to_api_as_code
    { "code" => code }
  end

  class << self
    def unknown_code?(code_to_check)
      [UNKNOWABLE, UNKNOWN].include?(code_to_check)
    end

    def count
      $countries.length
    end
    def all_to_api
      $countries.map(&:to_api)
    end
    def find_by_code(code)
      $countries.detect {|country| country.code == code }
    end
  end
end
