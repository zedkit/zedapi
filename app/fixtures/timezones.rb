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

$timezones = [
  ZedkitTimeZone.new(country: ZedkitCountry::UNITED_STATES, code: "UA", offset: "UTC -05:00", name: "eastern"),
  ZedkitTimeZone.new(country: ZedkitCountry::UNITED_STATES, code: "UB", offset: "UTC -06:00", name: "central"),
  ZedkitTimeZone.new(country: ZedkitCountry::UNITED_STATES, code: "UC", offset: "UTC -07:00", name: "mountain"),
  ZedkitTimeZone.new(country: ZedkitCountry::UNITED_STATES, code: "UD", offset: "UTC -08:00", name: "pacific"),
  ZedkitTimeZone.new(country: ZedkitCountry::UNITED_STATES, code: "UE", offset: "UTC -09:00", name: "alaska"),
  ZedkitTimeZone.new(country: ZedkitCountry::UNITED_STATES, code: "UF", offset: "UTC -10:00", name: "hawaii"),

  ZedkitTimeZone.new(country: ZedkitCountry::CANADA, code: "CA", offset: "UTC -05:00", name: "eastern"),
  ZedkitTimeZone.new(country: ZedkitCountry::CANADA, code: "CB", offset: "UTC -06:00", name: "central"),
  ZedkitTimeZone.new(country: ZedkitCountry::CANADA, code: "CC", offset: "UTC -07:00", name: "mountain"),
  ZedkitTimeZone.new(country: ZedkitCountry::CANADA, code: "CD", offset: "UTC -08:00", name: "pacific"),
  ZedkitTimeZone.new(country: ZedkitCountry::CANADA, code: "CE", offset: "UTC -04:00", name: "atlantic"),
  ZedkitTimeZone.new(country: ZedkitCountry::CANADA, code: "CF", offset: "UTC -03:30", name: "newfoundland")
].freeze
