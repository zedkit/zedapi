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

ZedAPI.controllers :entities do
  get :countries, map: "/entities/countries", provides: :js do
    json ZedkitCountry.all_to_api.delete_if {|x| ZedkitCountry.unknown_code?(x["code"]) }.sort {|x,y| x["name"] <=> y["name"] }
  end
  get :regions, map: "/entities/regions", provides: :js do
    if params.has_key?(:country) && has_parameters?(params[:country], %w(code))
      if ZedkitCountry.valid_code?(params[:country]["code"])
        json ZedkitRegion.in(params[:country]["code"]).collect {|region| region.to_api }.sort {|x,y| x["name"] <=> y["name"] }
      else
        set_error_response(code: 805) end
    else
      json ZedkitRegion.all_to_api.sort {|x,y| x["name"] <=> y["name"] } end
  end

  get :zedkit, map: "/entities/zedkit", provides: :js do
    json({
      languages: Language.all_to_api.sort {|x,y| x["name"] <=> y["name"] },
      locales:   ZedkitLocale.all_to_api.sort {|x,y| x["name"] <=> y["name"] },
      timezones: ZedkitTimeZone.all_to_api, stages: ZedkitStage.all_to_api,
      platforms: ZedkitPlatform.all_to_api, email_providers: EmailProvider.all_to_api {|x,y| x["name"] <=> y["name"] }
    })
  end

  get :zedlocales, map: "/entities/zedlocales", provides: :js do
    json({
      languages: Language.all_to_api.sort {|x,y| x["name"] <=> y["name"] },
      locales:   ZedkitLocale.all_to_api.sort {|x,y| x["name"] <=> y["name"] },
      timezones: ZedkitTimeZone.all_to_api
    })
  end
end
