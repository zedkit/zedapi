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
  def has_parameters?(collection, needed, options = {})
    return false unless collection.is_a?(Hash) && needed.is_a?(Array)
    options[:strings] ||= true
    options[:present] ||= false
    needed.each do |n|
      return false unless n.is_a? String
      return false unless collection.has_key?(n)
      return false if options[:strings] && !collection[n].is_a?(String)
      return false if options[:present] &&  collection[n].empty?
    end
    true
  end
  def has_one_of_parameters?(collection, needed, options = {})
    return false unless collection.is_a?(Hash) && needed.is_a?(Array)
    options[:strings] ||= true
    options[:present] ||= false
    needed.each do |n|
      return false unless n.is_a? String
      if collection.has_key?(n)
        return true if options[:strings] && collection[n].is_a?(String)
        return true if options[:strings] && collection[n].is_a?(String) && collection[n].length >= 1
        return true unless options[:strings] || options[:present]
      end
    end
    false
  end

  def request_has_project_key?
    params.has_key? :project_key
  end
  def request_has_user_key?
    params.has_key? :user_key
  end
  def request_is_sandboxed?
    params.has_key?(:environment) && params[:environment].downcase == "sandbox"
  end
  def request_without_project_key?
    not request_has_project_key?
  end

  def set_request_items
    set_project_key
    set_user
    set_user_key
    set_ip_address
  end
  def set_project_key
    @project_key = nil
    if request_has_project_key? && Project.exists?(conditions: { "project_keys.project_key" => params[:project_key] })
      @project_from_project_key = Project.where("project_keys.project_key" => params[:project_key]).first
      @project_key = @project_from_project_key.project_keys.where(project_key: params[:project_key]).first
      @project_key.project.reload
    end
    @project_key.freeze
  end
  def set_user
    @auth = Rack::Auth::Basic::Request.new(request.env)
    @user = nil
    if @auth.provided? && @auth.basic? && @auth.credentials.length == 2
      username = @auth.credentials[0]
      password = @auth.credentials[1]
      if @project_key.present? && username.present? && username.present?
        username.downcase!
        if User.where(project_id: @project_key.project.id, username: username).exists?
          u = User.first(conditions: { project_id: @project_key.project.id, username: username })
        elsif username.include?("@")
          if User.where(project_id: @project_key.project.id, email: username).exists?
            u = User.first(conditions: { project_id: @project_key.project.id, email: username })
          end
        end
        @user = u if u.is_a?(User) && u.valid_password?(password)
      end
    end
  end
  def set_user_key
    @user_from_key = nil
    if request_has_user_key? && User.exists?(conditions: { user_key: params[:user_key] })
      @user_from_key = User.first(conditions: { user_key: params[:user_key] }) 
      if @user_from_key.present? && @user_from_key.is_a?(User)     ## If we were sent both HTTP authentication *and*
        if @user.present? && @user.is_a?(User)                     ## a user API key they must reference the same user record.
          if @user.id != @user_from_key.id
            @user = nil
            @user_from_key = nil
          end
        else
          @user = @user_from_key end
      end
    end
  end
  def set_ip_address
    if request.env["HTTP_X_FORWARDED_FOR"].present?
      @remote_address = request.env["HTTP_X_FORWARDED_FOR"].split(",")[0].strip
    else
      @remote_address = request.env["REMOTE_ADDR"]
    end
    @remote_address.freeze
  end
end
