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

ZedAPI.controllers :blogs do
  before do
    validate_request_items
    validate_session
  end
  before :show, :update, :deletion do
    validate_blog_uuid(params[:uuid])
    halt 403 unless @blog.project.user_is_connected?(@user.id)
  end

  get :list, map: "/blogs", provides: :js do
    if params.has_key?(:project) && has_parameters?(params[:project], %w(uuid))
      validate_project_uuid(params[:project]["uuid"])
      if @project.user_is_connected?(@user.id)
        json @project.blogs.where(status: CollectionObject::ACTIVE).map {|pp| pp.to_api.without(:project) }.sort_by do |m|
          m["name"]
        end
      else status 403 end
    else status 400 end
  end
  post :create, map: "/blogs", provides: :js do
    if params.has_key?(:project) && has_parameters?(params[:project], %w(uuid))
      validate_project_uuid(params[:project]["uuid"])
      if @project.user_is_connected?(@user.id)

        blog = Blog.new(project_id: @project.id) do |nb|
          if params.has_key?(:blog) && has_parameters?(params[:blog], %w(name))
            nb[:name] = params[:blog]["name"]
          else
            nb[:name] = @project.name end
        end
        audited_save(master: @project, instance: blog)
        status 201
        json blog.to_api

      else status 403 end
    else status 400 end
  end

  get :show, map: "/blogs/:uuid", provides: :js do
    json @blog.to_api
  end
  put :update, map: "/blogs/:uuid", provides: :js do
    if params.has_key?(:blog) && has_parameters?(params[:blog], %w(name))

      @blog[:name] = params[:blog]["name"]
      audited_save(master: @blog.project, instance: @blog)
      json @blog.to_api

    else
      status 400 end
  end
  delete :deletion, map: "/blogs/:uuid", provides: :js do
    audited_deletion(master: @blog.project, instance: @blog)
  end
end
