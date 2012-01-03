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

module ZedHelpers
  def app
    ZedAPI
  end

  def pk(project)
    case project
    when :bert
      @project_bert.project_keys.first.project_key
    when :fred
      @project_fred.project_keys.first.project_key      
    else
      nil end
  end
  def pk_with_auth(project)
    case project
    when :bert
      { project_key: pk(:bert), username: @bert.username, password: "AbCd" }
    when :fred
      { project_key: pk(:fred), username: @fred.username, password: "AbCd" }
    else
      {} end
  end

  def hit(path, method, params = {})
    basic_auth(params[:username], params[:password]) if params.has_key?(:username) && params.has_key?(:password)
    params.delete(:username)
    params.delete(:password)
    visit(path, method, params)
  end
  def with_parsed(body)
    yield JSON.parse(body) if block_given?
  end
end
