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

PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development" unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path("../..", __FILE__) unless defined?(PADRINO_ROOT)

require "rubygems" unless defined?(Gem)
require "bundler/setup"
Bundler.require(:default, PADRINO_ENV)

$: << File.expand_path(File.join(File.dirname(__FILE__), "..", "app", "objects"))
require "static_object"

Dir[File.join(File.dirname(__FILE__), "..", "app", "objects",  "*.rb")].each do |ff|
  require ff
end
Dir[File.join(File.dirname(__FILE__), "..", "app", "fixtures", "*.rb")].each do |ff|
  require ff
end
Dir[File.join(File.dirname(__FILE__), "..", "app", "modules",  "*.rb")].each do |ff|
  require ff
end

Padrino.before_load do
  I18n.default_locale = :en
  I18n.locale = :en
  I18n.load_path << Dir[File.join(File.dirname(__FILE__), "..", "app", "locale", "*.rb")].entries
end

Padrino.after_load do
end

Padrino.load!
