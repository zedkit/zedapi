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

class Hash
  def sandbox
    self.merge!({ environment: "sandbox" })
  end
  def without(kk)
    delete_if {|k| k == kk }
    delete_if {|k| k == kk.to_s } unless kk.is_a?(String)
  end
  def has_all_as_zedkit_keys?(items)
    items.each {|item| return false unless self.has_key?(item) }
    true
  end

  ## http://snippets.dzone.com/posts/show/4706

  ## Merges self with another hash, recursively. This code was lovingly stolen from some random gem:
  ## http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
  ## Thanks to whoever made it.

  def deep_merge(hash)
    target = dup
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      target[key] = hash[key]
    end
    target
  end

  ## From: http://www.gemtacular.com/gemdocs/cerberus-0.2.2/doc/classes/Hash.html
  ## File lib/cerberus/utils.rb, line 42

  def deep_merge!(second)
    second.each_pair do |k,v|
      if self[k].is_a?(Hash) and second[k].is_a?(Hash)
        self[k].deep_merge!(second[k])
      else
        self[k] = second[k] end
    end
  end
end
