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

require "ipaddr"

class LocationObject
  def has_country?
    country_code != "-" && country_name != "-"
  end
  def has_region?
    region != "-"
  end
  def has_city?
    city != "-"
  end

  class << self
    def number_from_ip(ip_address)
      (16777216 * ip_address.split(".")[0].to_i) + (65536 * ip_address.split(".")[1].to_i) +
                                                   (256 * ip_address.split(".")[2].to_i) + (ip_address.split(".")[3].to_i)
    end

    def valid_ip_address?(address)
      begin
        IPAddr.new(address)
        return true
      rescue ArgumentError
      end
      false
    end
    def invalid_ip_address?(address)
      not valid_ip_address?(address)
    end
  end

  protected
  def set_region
    self.region = "-" if (not region.blank?) && region.include?("REPUBLIC OF")
  end
end
