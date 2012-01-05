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

class Date
  class << self
    def zk_valid?(date_item)
      begin
        Date.strptime(date_item)
        return true
      rescue ArgumentError => e
      end
      false
    end
    def zk_invalid?(date_item)
      not valid_date?(date_item)
    end

    def earlier?(compared_date, static_date)
      static_date.to_time.to_i > compared_date.to_time.to_i
    end
  end

  def to_first_of_the_month
    self - (self.strftime("%d").to_i - 1)
  end
end

## date_to_process.strftime("%d").gsub(/^0/,"")
## date_to_process.strftime("%b")
## date_to_process.strftime("%Y")
