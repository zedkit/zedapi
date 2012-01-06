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

ZedAPI.controllers :blog_posts do
  before do
    validate_request_items
    validate_session
  end
  before :show, :update, :deletion do
    if params[:uuid].present? && BlogPost.valid_uuid?(params[:uuid])
      @blog_post = BlogPost.find_by_uuid(params[:uuid]).set_audit 
    else
      halt 404
    end
    halt 403 unless @blog_post.blog.project.user_is_connected?(@user.id)
  end

  get :list, map: "/posts", provides: :js do
    if params.has_key?(:blog) && has_parameters?(params[:blog], %w(uuid))
      validate_blog_uuid(params[:blog]["uuid"])
      if @blog.project.user_is_connected?(@user.id)

        where = zedkit_where({ fields: [:stage], case: :up }, { fields: [:title_path], case: :down })
        limit = zedkit_limit(default: 10, maximum: 100)
        posts = @blog.posts.where(where).desc(:created_at).limit(limit)

        if params.has_key?(:option) && params[:option].has_key?(:data) && params[:option]["data"] == "SUMMARY"
          json posts.map(&:to_api_with_summary)
        else
          json posts.map {|pp| pp.to_api.without(:blog) } end

      else status 403 end
    else status 400 end
  end
  post :create, map: "/posts", provides: :js do
    if params.has_key?(:blog) && has_parameters?(params[:blog], %w(uuid))
      validate_blog_uuid(params[:blog]["uuid"])
      if @blog.project.user_is_connected?(@user.id)
        if params.has_key?(:post) && has_parameters?(params[:post], %w(author title))

          blog_post = BlogPost.new(blog_id: @blog.id, title: params[:post]["title"]) do |np|
            np[:user_id] = User.find_by_uuid(params[:post]["author"]).id if User.valid_uuid?(params[:post]["author"])
            np[:url] = params[:post]["url"] if params[:post].has_key? "url"
            np[:content] = params[:post]["content"] if params[:post].has_key? "content"
            np[:stage] = params[:post]["stage"] if params[:post].has_key? "stage"
            np[:markup] = params[:post]["markup"] if params[:post].has_key? "markup"
          end
          audited_save(master: @blog.project, instance: blog_post)
          status 201
          json blog_post.to_api

        else status 400 end
      else status 403 end
    else status 400 end
  end

  get :show, map: "/posts/:uuid", provides: :js do
    json @blog_post.to_api
  end
  put :update, map: "/posts/:uuid", provides: :js do
    if params.has_key?(:post) && has_one_of_parameters?(params[:post], %w(title url content stage markup))

      if has_parameters?(params[:post], %w(author))
        User.valid_uuid?(params[:post]["author"]) ? @blog_post[:user_id] = User.find_by_uuid(params[:post]["author"]).id
                                                  : @blog_post[:user_id] = nil
      end
      @blog_post[:title] = params[:post]["title"] if params[:post].has_key? "title"
      @blog_post[:url] = params[:post]["url"] if params[:post].has_key? "url"
      @blog_post[:content] = params[:post]["content"] if params[:post].has_key? "content"
      @blog_post[:stage] = params[:post]["stage"] if params[:post].has_key? "stage"
      @blog_post[:markup] = params[:post]["markup"] if params[:post].has_key? "markup"
      audited_save(:master => @blog_post.blog.project, :instance => @blog_post)
      json @blog_post.to_api

    else status 400 end
  end
    delete :deletion, map: "/posts/:uuid", provides: :js do
    audited_deletion(master: @blog_post.blog.project, instance: @blog_post)
  end
end
