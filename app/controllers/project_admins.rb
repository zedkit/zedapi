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

ZedAPI.controllers :project_admins do
  before do
    validate_request_items
    validate_session
    validate_project_uuid(params[:uuid])
    validate_user_for_project
  end
  before :update, :deletion do
    if @project.project_admins.detect {|pk| pk.uuid == params[:pa_uuid] }.present?
      @project_admin = @project.project_admins.detect {|pa| pa.uuid == params[:pa_uuid] }.set_audit
    else
      halt 404 end
  end

  get :list, map: "/projects/:uuid/admins", provides: :js do
    json @project.project_admins.where(status: CollectionObject::ACTIVE).map {|pa| pa.to_api.without(:project) }
  end  
  post :create, map: "/projects/:uuid/admins", provides: :js do
    if params.has_key?(:user) && has_parameters?(params[:user], %w(uuid))
      if User.exists?(conditions: { uuid: params[:user]["uuid"] })

        pu = User.first(conditions: { uuid: params[:user]["uuid"] })
        pa = ProjectAdmin.new(project: @project, user_id: pu.id)
        pa[:role] = params[:user]["role"] if params[:user].has_key? "role"
        if pa.valid?
          pa.save_with_audit_trail(@project, @user.id) unless request_is_sandboxed?
        end
        if pa.errors.empty?
          status 201
          json pa.to_api
        else
          set_error_response(code: 805, errors: pa.errors) end

      else
        status 404 end
    else
      status 400 end
  end

  put :update, map: "/projects/:uuid/admins/:pa_uuid", provides: :js do
    if params.has_key?(:user)
      @project_admin[:role] = params[:user]["role"] if params[:user].has_key? "role"
    end
    audited_save(master: @project, instance: @project_admin)
  end
  delete :deletion, map: "/projects/:uuid/admins/:pa_uuid", provides: :js do
    audited_deletion(master: @project, instance: @project_admin)
  end
end
