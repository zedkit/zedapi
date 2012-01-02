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

class ZedkitLocale < StaticObject
  ENGLISH    = "en"
  ENGLISH_CA = "en-CA"
  ENGLISH_US = "en-US"

  def name_native
    I18n.t(name.to_sym, :locale => "en", :scope => [:locale, :native])
  end

  def to_api
    {
      "code" => code, "language" => Language.find_by_code(language).to_api_as_code,
      "name" => I18n.t(name.to_sym, :scope => [:locale, :name]), "native" => name_native
    }
  end
  def to_api_as_code
    { "code" => code }
  end

  class << self
    def count
      $locales.length
    end
    def all_to_api
      $locales.map(&:to_api)
    end
    def find_by_code(code)
      $locales.detect {|lc| lc.code == code }
    end
  end
end