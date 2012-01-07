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

ZedAPI.controllers :beta_addresses do
  before do
    validate_request_items
    validate_session
  end
  before :show, :update, :deletion do
    if params.has_key?(:uuid) && BetaAddress.valid_uuid?(params[:uuid])
      @beta_address = BetaAddress.find_by_uuid(params[:uuid]).set_audit
    else
      halt 404
    end
    halt 403 unless @beta_address.project.user_is_connected?(@user.id)
  end

  get :list, map: "/betas", provides: :js do
    if params.has_key?(:project) && has_parameters?(params[:project], %w(uuid))
      validate_project_uuid(params[:project]["uuid"])
      if @project.user_is_connected?(@user.id)
        json @project.beta_addresses.where(status: CollectionObject::ACTIVE).map {|bb| bb.to_api.without(:project) }
      else status 403 end
    else status 400 end
  end
  post :create, map: "/betas", provides: :js do
    if params.has_key?(:project) && has_parameters?(params[:project], %w(uuid))
      validate_project_uuid(params[:project]["uuid"])
      if @project.user_is_connected?(@user.id)
        if params.has_key?(:beta) && has_parameters?(params[:beta], %w(email))

          ba = BetaAddress.new(project_id: @project.id)
          ba[:email] = params[:beta]["email"]
          ba[:invited] = params[:beta]["invited"] if params[:beta].has_key? "invited"

          audited_save(master: @project, instance: ba)
          status 201
          json ba.to_api

        else status 400 end
      else status 403 end
    else status 400 end
  end

  get :show, map: "/betas/:uuid", provides: :js do
    json @beta_address.to_api
  end
  put :update, map: "/betas/:uuid", provides: :js do
    if params.has_key?(:beta) && has_one_of_parameters?(params[:beta], %w(email invited))

      @beta_address[:email] = params[:beta]["email"] if params[:beta].has_key? "email"
      @beta_address[:invited] = params[:beta]["invited"] if params[:beta].has_key? "invited"
      audited_save(master: @beta_address.project, instance: @beta_address)
      json @beta_address.to_api

    else status 400 end
  end
  delete :deletion, map: "/betas/:uuid", provides: :js do
    audited_deletion(master: @beta_address.project, instance: @beta_address)
  end
end
