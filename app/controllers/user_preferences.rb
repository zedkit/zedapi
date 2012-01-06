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

ZedAPI.controllers :user_preferences do
  before do
    validate_request_items
    validate_session
  end
  before :show, :update do
    validate_user_uuid
  end

  get :show, map: "/users/:uuid/preferences", provides: :js do
    if @user_to_process.uuid == @user.uuid
      json @user.preferences.to_api.without(:user)
    else
      status 403 end
  end
  put :update, map: "/users/:uuid/preferences", provides: :js do
    if @user_to_process.uuid == @user.uuid
      if params.has_key?(:preferences) && has_one_of_parameters?(params[:preferences], %w(remember))

        if @user.has_preferences?
          preferences = @user.user_preferences
          preferences[:remember] = params[:preferences]["remember"] if params[:preferences].has_key? "remember"
          audited_save(:master => @user, :instance => preferences)
        else
          preferences = UserPreferences.new(:user => @user)
          preferences[:remember] = params[:preferences]["remember"] if params[:preferences].has_key? "remember"
          if preferences.valid?
            preferences.save_with_audit_trail(@user, @user.id) unless request_is_sandboxed?
            json preferences.to_api
          else
            set_error_response(code: 805, errors: preferences.errors) end
        end

      else status 400 end
    else status 403 end
  end
end
