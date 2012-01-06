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

ZedAPI.helpers do
  def valid_project_key?
    @project_key.is_a? ProjectKey
  end
  def invalid_project_key?
    not valid_project_key?
  end
  def valid_session?
    @user.present? && @user.is_a?(User)
  end
  def invalid_session?
    not valid_session?
  end

  def validate_request_items(options = {})
    options[:require_project_key] ||= true
    set_request_items
    halt 200, set_error_response(code: 800) if request_has_project_key? && invalid_project_key?
    halt 200, set_error_response(code: 801) if options[:require_project_key] && request_without_project_key?
  end
  def validate_session
    halt 401 unless valid_session?
  end

  def validate_project_uuid(uuid)
    if uuid.present? && Project.valid_uuid?(uuid)
      @project = Project.find_by_uuid(uuid).set_audit
    else
      halt 404 end
  end
  def validate_user_uuid
    if params.has_key?(:uuid) && User.valid_uuid?(params[:uuid])
      @user_to_process = User.find_by_uuid(params[:uuid]).set_audit 
    else
      halt 404 end
  end
  def validate_user_for_project
    halt 403 unless @project.user_is_connected?(@user.id)
  end
  def validate_blog_uuid(uuid)
    if uuid.present? && Blog.valid_uuid?(uuid)
      @blog = Blog.find_by_uuid(uuid).set_audit
    else
      halt 404 end
  end
  def validate_shortener_uuid(uuid)
    if uuid.present? && Shortener.valid_uuid?(uuid)
      @shortener = Shortener.find_by_uuid(uuid).set_audit 
    else
      halt 404 end
  end
end
