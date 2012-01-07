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

ZedAPI.controllers :email_settings do
  before do
    validate_request_items
    validate_session
  end
  before :show, :update, :deletion do
    if params[:uuid].present? && EmailSettings.valid_uuid?(params[:uuid])
      @email_settings = EmailSettings.find_by_uuid(params[:uuid]).set_audit 
    else
      halt 404
    end
    halt 403 unless @email_settings.project.user_is_connected?(@user.id)
  end

  get :list, map: "/email/settings", provides: :js do
    if params.has_key?(:project) && has_parameters?(params[:project], %w(uuid))
      validate_project_uuid(params[:project]["uuid"])
      if @project.user_is_connected?(@user.id)
        json @project.email_settings.where(status: CollectionObject::ACTIVE).map {|em| em.to_api.without(:project) }
      else status 403 end
    else status 400 end
  end
  post :create, map: "/email/settings", provides: :js do
    if params.has_key?(:project) && has_parameters?(params[:project], %w(uuid))
      validate_project_uuid(params[:project]["uuid"])
      if @project.user_is_connected?(@user.id)
        if params.has_key?(:settings) && has_parameters?(params[:settings], %w(username password))

          email_settings = EmailSettings.new(project_id: @project.id) do |es|
            es[:username] = params[:settings]["username"]
            es[:password] = params[:settings]["password"]
            es[:provider] = params[:settings]["provider"] if params[:settings].has_key? "provider"
          end
          audited_save(master: @project, instance: email_settings)
          status 201
          json email_settings.to_api

        else status 400 end
      else status 403 end
    else status 403 end
  end

  get :show, map: "/email/settings/:uuid", provides: :js do
    json @email_settings.to_api
  end
  put :update, map: "/email/settings/:uuid", provides: :js do
    if params.has_key?(:settings) && has_one_of_parameters?(params[:settings], %w(provider username password))

      @email_settings[:provider] = params[:settings]["provider"] if params[:settings].has_key? "provider"
      @email_settings[:username] = params[:settings]["username"] if params[:settings].has_key? "username"
      @email_settings[:password] = params[:settings]["password"] if params[:settings].has_key? "password"
      audited_save(master: @email_settings.project, instance: @email_settings)
      json @email_settings.to_api

    else status 400 end
  end
  delete :deletion, map: "/email/settings/:uuid", provides: :js do
    audited_deletion(master: @email_settings.project, instance: @email_settings)
  end
end
