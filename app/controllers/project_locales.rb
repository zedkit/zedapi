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

ZedAPI.controllers :project_locales do
  before :list, :create, :update, :deletion do
    validate_request_items
    validate_session
    validate_project_uuid(params[:uuid])
    validate_user_for_project
  end
  before :update, :deletion do
    if ZedkitLocale.valid_code?(params[:code]) && @project.locale_is_connected?(params[:code])
      @project_locale = @project.project_locales.detect {|pl| pl.locale == params[:code] }.set_audit
    else
      halt 404 end
  end

  get :verify, map: "/projects/verify/locales", provides: :js do
    if params.has_key?(:locales_key) && Project.exists?(conditions: { locales_key: params[:locales_key] })
      json Project.first(conditions: { locales_key: params[:locales_key] }).to_api
    else
      status 403 end
  end
  
  get :list, map: "/projects/:uuid/locales", provides: :js do
    json @project.project_locales.where(status: CollectionObject::ACTIVE).map {|pl| pl.to_api.without(:project) }
  end
  post :create, map: "/projects/:uuid/locales", provides: :js do
    if params.has_key?(:locale) && has_parameters?(params[:locale], %w(code))

      project_locale = ProjectLocale.new(project: @project, locale: params[:locale]["code"])
      project_locale[:stage] = params[:locale]["stage"] if params.has_key? "stage"
      if project_locale.valid?
        project_locale.save_with_audit_trail(@project, @user.id) unless request_is_sandboxed?
      end
      if project_locale.errors.empty?
        status 201
        json project_locale.to_api
      else
        set_error_response(code: 805, errors: project_locale.errors) end

    else
      status 400 end
  end

  put :update, map: "/projects/:uuid/locales/:code", provides: :js do
    if params.has_key?(:locale) && has_parameters?(params[:locale], %w(stage))

      @project_locale[:stage] = params[:locale]["stage"]
      audited_save(master: @project_locale.project, instance: @project_locale)

    else
      status 400 end
  end
  delete :deletion, map: "/projects/:uuid/locales/:code", provides: :js do
    audited_deletion(master: @project, instance: @project_locale)
  end
end
