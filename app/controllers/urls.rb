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

ZedAPI.controllers :urls do
  before do
    validate_request_items
    validate_session
  end
  before :show, :update, :deletion do
    if params[:uuid].present? && ShortenedUrl.valid_uuid?(params[:uuid])
      @shortened_url = ShortenedUrl.find_by_uuid(params[:uuid]).set_audit 
    else
      halt 404
    end
    halt 403 unless @shortened_url.shortener.project.user_is_connected?(@user.id)
  end

  get :list, map: "/urls", provides: :js do
    if params.has_key?(:shortener) && has_parameters?(params[:shortener], %w(uuid))
      validate_shortener_uuid(params[:shortener]["uuid"])
      if @shortener.project.user_is_connected?(@user.id)

        where = zedkit_where({ fields: [:url_path] })
        limit = zedkit_limit(default: 50, maximum: 100)
        json @shortener.urls.where(where).desc(:created_at).limit(limit).map {|uu| uu.to_api.without(:shortener) }

      else status 403 end
    else status 400 end
  end
  post :create, map: "/urls" do
    if params.has_key?(:shortener) && has_parameters?(params[:shortener], %w(uuid))
      validate_shortener_uuid(params[:shortener]["uuid"])
      if @shortener.project.user_is_connected?(@user.id)
        if params.has_key?(:url) && has_parameters?(params[:url], %w(destination))

          url = ShortenedUrl.new(shortener_id: @shortener.id, destination: params[:url]["destination"]) do |uu|
            uu[:user_id] = User.find_by_uuid(params[:user]["uuid"]).id if params[:url].has_key?(:user) && User.valid_uuid?(params[:user]["uuid"])
            uu[:standing] = params[:url]["standing"] if params[:url].has_key? "standing"
          end
          audited_save(master: @shortener.project, instance: url)
          status 201
          json url.to_api

        else status 400 end
      else status 403 end
    else status 400 end
  end

  get :show, map: "/urls/:uuid", provides: :js do
    json @shortened_url.to_api
  end
  put :update, map: "/urls/:uuid", provides: :js do
    if params.has_key?(:url) && has_one_of_parameters?(params[:url], %w(standing))

      @shortened_url[:standing] = params[:url]["standing"] if params[:url].has_key? "standing"
      audited_save(master: @shortened_url.shortener.project, instance: @shortened_url)
      json @shortened_url.to_api

    else
      status 400 end
  end
  delete :deletion, map: "/urls/:uuid", provides: :js do
    audited_deletion(master: @shortened_url.shortener.project, instance: @shortened_url)
  end
end
