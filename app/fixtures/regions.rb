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

$regions = [
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "AL", name: "alabama"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "AK", name: "alaska"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "AZ", name: "arizona"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "AR", name: "arkansas"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "CA", name: "california"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "CO", name: "colorado"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "CT", name: "connecticut"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "DE", name: "delaware"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "FL", name: "florida"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "GA", name: "georgia"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "HI", name: "hawaii"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "ID", name: "idaho"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "IL", name: "illinois"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "IN", name: "indiana"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "IA", name: "iowa"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "KS", name: "kansas"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "KY", name: "kentucky"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "LA", name: "louisiana"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "ME", name: "maine"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MD", name: "maryland"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MA", name: "massachusetts"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MI", name: "michigan"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MN", name: "minnesota"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MS", name: "mississippi"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MO", name: "missouri"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MT", name: "montana"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "NE", name: "nebraska"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "NV", name: "nevada"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "NH", name: "newhampshire"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "NJ", name: "newjersey"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "NM", name: "newmexico"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "NY", name: "newyork"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "NC", name: "northcarolina"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "ND", name: "northdakota"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "OH", name: "ohio"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "OK", name: "oklahoma"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "OR", name: "oregon"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "PA", name: "pennsylvania"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "RI", name: "rhodeisland"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "SC", name: "southcarolina"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "SD", name: "southdakota"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "TN", name: "tennessee"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "TX", name: "texas"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "UT", name: "utah"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "VT", name: "vermont"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "VA", name: "virginia"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "WA", name: "washington"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "WV", name: "westvirginia"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "WI", name: "wisconsin"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "WY", name: "wyoming"),

  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "DC", name: "columbia"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "AS", name: "somoa"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "FM", name: "micronesia"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "GU", name: "guam"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MH", name: "marshallislands"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "MP", name: "marianaislands"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "PW", name: "palau"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "PR", name: "puertorico"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "UM", name: "minorislands"),
  ZedkitRegion.new(country: ZedkitCountry::UNITED_STATES, code: "VI", name: "virginislands"),

  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "BC", name: "bc"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "AB", name: "alberta"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "SK", name: "saskatchewan"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "MB", name: "manitoba"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "ON", name: "ontario"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "QC", name: "quebec"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "NB", name: "newbrunswick"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "PE", name: "pei"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "NS", name: "novascotia"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "NL", name: "newfoundland"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "YT", name: "yukon"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "NU", name: "nunavut"),
  ZedkitRegion.new(country: ZedkitCountry::CANADA, code: "NT", name: "nwt")
].freeze
