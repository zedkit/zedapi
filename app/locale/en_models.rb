# encoding: utf-8
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

{ :"en" => { :mongoid => { :errors => { :models => {

:project => {
  :attributes => {
    :locale  => { :invalid => "The locale is invalid." },
    :locales => { :invalid => "One of the locales is invalid." },
    :name => {
      :blank => "A project name is required.",
      :too_short => "The project name is too short. A project name must be at least 2 characters.",
      :too_long => "The project name is too long. A project name cannot exceed 48 characters."
    },
    :location => {
      :blank => "A project location is required.",
      :invalid => "The project location is invalid.",
      :exclusion => "The project location is reserved and cannot be used.",
      :taken => "The project location is already in use.",
      :too_short => "The project location is too short. A project location must be at least 2 characters.",
      :too_long => "The project location is too long. A project location cannot exceed 32 characters."
    },
    :locales_key => {
      :invalid => "The project locales key is invalid.",
      :taken => "The project locales key is already in use.",
      :wrong_length => "The project locales key must be 18 characters."
    }
  }
},

:user => {
  :attributes => {
    :project => {
      :blank => "The project does not exist or its use is not available.",
      :invalid => "The project does not exist or its use is not available."
    },
    :locale => {
      :blank => "A locale is required.",
      :invalid => "The locale does not exist or its use is not available."
    },
    :first_name => {
      :too_long  => "The first can be no more than 24 characters."
    },
    :initials => {},
    :surname  => {},
    :username => {
      :blank => "A username is required.",
      :invalid => "The username can only be letters and numbers.",
      :taken => "The username is already in use.",
      :too_short => "The username must be between 2 and 18 characters.",
      :too_long  => "The username must be between 2 and 18 characters."
    },
    :email => {
      :blank => "An email address is required.",
      :invalid => "The email address is not a valid email address.",
      :taken => "The email address is already in use.",
      :too_short => "The email address must be between 5 and 128 characters.",
      :too_long  => "The email address must be between 5 and 128 characters."
    },
    :salt => {},
    :password => {
      :invalid => "The password is too weak.",
      :too_short => "The password is too short. It must be at least 2 characters.",
      :exclusion => "The password and password confirmation do not match."
    },
    :user_key => {
      :invalid => "A user API key can only be 18 alphanumeric characters.",
      :wrong_length => "A user API key can only be 18 alphanumeric characters."
    }
  }
},

:audit_trail => {
  :attributes => {
    :user => {
      :blank => "The user does not exist or its use is not available.",
      :invalid => "The user does not exist or its use is not available."
    },
    :master_type => {
      :blank => "The master object type is a required data item.",
      :invalid => "The master object type is invalid.",
      :too_short => "The master object's type must be between 4 and 32 characters.",
      :too_long  => "The master object's type must be between 4 and 32 characters."
    },
    :master_uuid => {
      :blank => "The master object does not exist or its use is not available.",
      :invalid => "The master object does not exist or its use is not available.",
      :wrong_length => "An master object's unique UUID must be 32 characters."
    },
    :object_type => {
      :blank => "The audited object's type is a required data item.",
      :invalid => "The audited object's type is invalid.",
      :too_short => "The audited object's type must be between 4 and 32 characters.",
      :too_long  => "The audited object's type must be between 4 and 32 characters."
    },
    :object_uuid => {
      :blank => "The audited object does not exist or its use is not available.",
      :invalid => "The audited object does not exist or its use is not available.",
      :wrong_length => "An audited object's unique UUID must be 32 characters."
    },
    :state_from => {
      :blank => "Before state information is a required data item for UPDATE and DELETION operations.",
      :invalid => "Before state information is invalid JSON."
    },
    :state_to => {
      :blank => "After state information is a required data item.",
      :invalid => "After state information is invalid JSON."
    },
    :action => {
      :blank => "The audit action is a required data item.",
      :inclusion => "The audit action is invalid."
    }
  }
}

} } } } }
