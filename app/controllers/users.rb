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

ZedAPI.controllers :users do
  before do
    validate_request_items
    validate_session
  end
  before :show, :update, :deletion do
    validate_user_uuid
  end

  get :verify, map: "/users/verify", provides: :js do
    json @user.to_api
  end
  get :login, map: "/users/login", provides: :js do
    user_login = UserLogin.new(user: @user, address: @remote_address)
    request_is_sandboxed? ? user_login.valid? : user_login.save!
    status 201
    json user_login.to_api
  end

  post :create, map: "/users", provides: :js do
    status 403 # TBD
  end
  get :show, map: "/users/:uuid", provides: :js do
    @user.id == @user_to_process.id || @user.is_admin_of_user?(@user_to_process.id) ? json(@user_to_process.to_api)
                                                                                    : status(403)
  end
  put :update, map: "/users/:uuid", provides: :js do
    if @user.id == @user_to_process.id
      if params.has_key?(:user) && has_one_of_parameters?(params[:user], %w(first_name surname initials username email password))

        @user_to_process[:first_name] = params[:user]["first_name"] if params[:user].has_key? "first_name"
        @user_to_process[:surname] = params[:user]["surname"] if params[:user].has_key? "surname"
        @user_to_process[:initials] = params[:user]["initials"] if params[:user].has_key? "initials"
        @user_to_process[:username] = params[:user]["username"] if params[:user].has_key? "username"
        @user_to_process[:email] = params[:user]["email"] if params[:user].has_key? "email"
        @user_to_process.set_password(params[:user]["password"]) if params[:user].has_key? "password"
        @user_to_process.password_again = params[:user]["password_again"] if params[:user].has_key? "password_again"
        audited_save(master: @user_to_process, instance: @user_to_process)

      else status 400 end
    else status 403 end
  end
  delete :deletion, map: "/users/:uuid", provides: :js do
    status 403 # TBD
  end
end
