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

class ZedkitStage < StaticObject
  DEVELOPMENT = "development"
  STAGE = "stage"
  PRODUCTION = "production"

  def name_english
    code.capitalize
  end
  def name_translated
    I18n.t(code.to_sym, locale: "en", scope: [:stage])
  end

  def to_api
    { "code" => code, "name" => name_english, "translated" => name_translated }
  end
  def to_api_as_code
    { "code" => code }
  end

  class << self
    def all_to_api
      $stages.map(&:to_api)
    end
    def find_by_code(code)
      $stages.detect {|stage| stage.code == code }
    end
  end
end
