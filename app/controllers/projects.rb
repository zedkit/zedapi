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

ZedAPI.controllers :projects do
  before except: :verify do
    validate_request_items
    validate_session
  end
  before :snapshot, :show, :update, :deletion do
    validate_project_uuid(params[:uuid])
    validate_user_for_project
  end

  get :verify, map: "/projects/verify", provides: :js do
    if params.has_key?(:project_key) && Project.exists?(conditions: { "project_keys.project_key" => params[:project_key] })
      json Project.where("project_keys.project_key" => params[:project_key]).first.to_api
    else
      status 403 end
  end

  get :snapshot, map: "/projects/:uuid/snapshot", provides: :js do
    json({ "project" => @project.to_api })
  end
  get :trail, map: "/projects/:uuid/trail", provides: :js do
    status 403
  end

  get :list, map: "/projects", provides: :js do
    json(@user.projects.where(status: CollectionObject::ACTIVE).order_by(:name.asc).collect {|pts|
      { "project" => pts.to_api.without(:project), "permissions" => @user.project_permissions(pts.id) }
    })
  end
  post :create, map: "/projects", provides: :js do
    if params.has_key?(:project) && has_parameters?(params[:project], %w(name))

      project = Project.new(:name => params[:project]["name"])
      project[:locale] = params[:project]["locale"] if params[:project].has_key? "locale"
      project[:location] = params[:project]["location"] if params[:project].has_key? "location"
      if request_is_sandboxed?
        project.valid?
      else
        project.project_admins << ProjectAdmin.new(user_id: @user.id, role: AdminRole::ADMIN)
        project.save
      end
      if project.errors.empty?
        status 201
        json project.to_api
      else
        set_error_response(code: 805, errors: project.errors) end

    else
      status 400 end
  end

  get :show, map: "/projects/:uuid", provides: :js do
    json @project.to_api
  end
  put :update, map: "/projects/:uuid", provides: :js do
    if @project.user_is_admin?(@user.id)
      if params.has_key?(:project) && has_one_of_parameters?(params[:project], %w(name location))

        @project.set_audit
        @project[:name] = params[:project]["name"] if params[:project].has_key? "name"
        @project[:location] = params[:project]["location"] if params[:project].has_key? "location"
        audited_save(master: @project, instance: @project)

      else status 400 end
    else status 403 end
  end
  delete :deletion, map: "/projects/:uuid", provides: :js do
    if @project.user_is_admin?(@user.id)
      audited_deletion(master: @project, instance: @project)
    else
      status 403 end
  end
end
