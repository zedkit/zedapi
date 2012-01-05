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

class EmailProvider < StaticObject
  SENDGRID = "SENDGRID"
  POSTMARK = "POSTMARK"

  def to_api
    { "code" => code, "name" => name, "hostname" => hostname, "port" => 25 }
  end
  def to_api_as_code
    { "code" => code }
  end
  
  class << self
    def deliver!(email_settings, email_message, options = {})               ## options => { :to => "whatever@whatever.com",
      mail = Mail.new do                                                    ##              :environment => "sandbox" }
           from email_message.from
             to options[:to]
        subject email_message.subject
           body email_message.content_text
      end
      unless options[:environment].present? && options[:environment] == "sandbox"
        smtp = Mail::SMTP.new(settings_for_mail(email_settings.provider, email_settings.username, email_settings.password))
        smtp.deliver!(mail)
      end
      true
    end
    def settings_for_mail(code, username, password)
      pp = find_by_code(code)
      {
        address: pp.hostname, port: pp.port, domain: "api.zedapi.com",
        user_name: username, password: password, authentication: "plain", enable_starttls_auto: true, openssl_verify_mode: false
      }
    end

    def count
      $email_providers.length
    end
    def all_to_api
      $email_providers.map(&:to_api)
    end
    def find_by_code(code)
      $email_providers.detect {|ep| ep.code == code }
    end
  end
end
