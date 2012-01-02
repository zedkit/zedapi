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

port = Mongo::Connection::DEFAULT_PORT
host_name = case Padrino.env
  when :development then "127.0.0.1"
  when :test        then "127.0.0.1"
  when :production  then "db"
end
database_name = case Padrino.env
  when :development then "zedapi_development"
  when :test        then "zedapi_test"
  when :production  then "zedapi"
end

Mongoid.database = Mongo::Connection.new(host_name, port).db(database_name)
Mongoid.configure do |config|
  config.use_utc = true
  config.allow_dynamic_fields = false
  config.autocreate_indexes = false
  config.persist_in_safe_mode = true
  config.raise_not_found_error = false
end

MONGOID_MODELS = %w(Shortener ShortenedUrl BetaAddress)
MONGOID_MODELS.freeze

# OR
# Mongoid.configure do |config|
#   name = @settings["database"]
#   host = @settings["host"]
#   config.master = Mongo::Connection.new.db(name)
#   config.slaves = [
#     Mongo::Connection.new(host, @settings["slave_one"]["port"], :slave_ok => true).db(name),
#     Mongo::Connection.new(host, @settings["slave_two"]["port"], :slave_ok => true).db(name)
#   ]
# end
# More installation and setup notes are on http://mongoid.org/docs/
