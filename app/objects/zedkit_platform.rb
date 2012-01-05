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

class ZedkitPlatform < StaticObject
  WWW = "WWW"
  OSX = "OSX"
  IPAD = "IPAD"
  IPHONE = "IPHONE"
  UNKNOWN = "UNKNOWN"

  def to_api
    { "code" => code, name: I18n.t(code.downcase.to_sym, scope: [:platform]) }
  end
  def to_api_as_code
    { "code" => code }
  end

  class << self
    def all_to_api
      $zedkit_platforms.map(&:to_api)
    end
    def find_by_code(code)
      $zedkit_platforms.detect {|platform| platform.code == code }
    end
  end
end
