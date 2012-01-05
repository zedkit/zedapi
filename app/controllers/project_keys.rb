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

ZedAPI.controllers :project_keys do  
  before do
    validate_request_items
    validate_session
    validate_project_uuid(params[:uuid])
    validate_user_for_project
  end
  before :update, :deletion do
    validate_project_key_uuid(params[:key_uuid])
  end

  get :index, map: "/projects/:uuid/keys", provides: :js do
    json @project.project_keys.where(status: CollectionObject::ACTIVE).map {|pp| pp.to_api.without(:project) }
  end

  post :index, map: "/projects/:uuid/keys", provides: :js do
    if params.has_key?(:key) && has_parameters?(params[:key], %w(name))

      pk = ProjectKey.new(project: @project, name: params[:key]["name"])
      pk[:platform] = params[:key]["platform"] if params[:key].has_key? "platform"
      if pk.valid?
        pk.save_with_audit_trail(@project, @user.id) unless request_is_sandboxed?
      end
      if pk.errors.empty?
        status 201
        json pk.to_api
      else
        set_error_response(code: 805, errors: pk.errors) end

    else
      status 400 end
  end

  put :update, map: "/projects/:uuid/keys/:key_uuid", provides: :js do
    if params.has_key?(:key) && has_one_of_parameters?(params[:key], %w(name platform))

      @project_key[:name] = params[:key]["name"] if params[:key].has_key? "name"
      @project_key[:platform] = params[:key]["platform"] if params[:key].has_key? "platform"
      audited_save(master: @project, instance: @project_key)

    else
      status 400 end
  end

  delete :deletion, map: "/projects/:uuid/keys/:key_uuid", provides: :js do
    audited_deletion(master: @project, instance: @project_key)
  end
  
  helpers do
    def validate_project_key_uuid(uuid)
      if @project.project_keys.detect {|pk| pk.uuid == uuid }.present?
        @project_key = @project.project_keys.detect {|pk| pk.uuid == uuid }.set_audit
      else
        halt 404 end
    end
  end
end
