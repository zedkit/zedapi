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
  def audited_save(options = {})
    raise ArgumentError unless options.has_key?(:master) && options.has_key?(:instance)
    master   = options[:master]
    instance = options[:instance]
    was_new_record = instance.new_record? ? true : false
    if request_is_sandboxed?
      instance.valid?
    else
      if @user.present?
        instance.save_with_audit_trail(master, @user.id)
      else
        instance.save end
    end
    if master.errors.empty?
      if options.has_key?(:force_status)
        status options[:force_status]
      else
        was_new_record ? status(201) : status(200)
      end
      json instance.to_api
    else
      set_error_response(code: 805, errors: instance.errors) end
  end
  def audited_deletion(options = {})
    raise ArgumentError unless options.has_key?(:master) && options.has_key?(:instance)
    master   = options[:master]
    instance = options[:instance]
    unless request_is_sandboxed?
      instance.set_audit
      instance.status = CollectionObject::DELETE
      instance.save_with_audit_trail!(master, @user.id)
    end
    nil
  end
end
