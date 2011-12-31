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

{ :"en" => { :mongoid => {

:representations => {
  :audit_trail => "Audit Trail",
  :blog => "Blog",
  :blog_post => "BlogPost",
  :content => "Content",
  :content_scope => "Content Scope",
  :content_section => "Content Section",
  :email_message => "Email Message",
  :email_provider => "Email Provider",
  :email_settings => "Email Settings",
  :email_translation => "Email Translation",
  :guid => "GUID",
  :project => "Project",
  :project_key => "Project Key",
  :project_locale => "Project Locale",
  :project_log => "Project Log",
  :project_log_entry => "Project Log Entry",
  :project_model => "Model",
  :project_model_association => "Model Association",
  :project_model_item => "Model Item",
  :project_model_transformer => "Model Transformer",
  :project_model_validation => "Model Validation",
  :project_settings => "Project Settings",
  :project_shelf => "Project Shelf",
  :project_user => "Project User",
  :server => "Server",
  :translation => "Translation",
  :user => "User",
  :user_login => "User Login",
  :user_preferences => "User Preferences"
},
:models => {
  :audit_trail => "Audit Trail",
  :blog => "Blog",
  :blog_post => "BlogPost",
  :content => "Content",
  :content_scope => "Content Scope",
  :content_section => "Content Section",
  :email_message => "Email Message",
  :email_provider => "Email Provider",
  :email_settings => "Email Settings",
  :email_translation => "Email Translation",
  :guid => "GUID",
  :project => "Project",
  :project_key => "Project Key",
  :project_locale => "Project Locale",
  :project_log => "Project Log",
  :project_log_entry => "Project Log Entry",
  :project_model => "Model",
  :project_model_association => "Model Association",
  :project_model_item => "Model Item",
  :project_model_transformer => "Model Transformer",
  :project_model_validation => "Model Validation",
  :project_shelf => "Project Shelf",
  :project_user => "Project User",
  :server => "Server",
  :translation => "Translation",
  :user => "User",
  :user_login => "User Login",
  :user_preferences => "User Preferences"
},

:errors => { :models => {
  :project => {
    :attributes => {
      :locale  => { :invalid => "The locale is invalid." },
      :locales => { :invalid => "One of the locales is invalid." },
      :name => {
        :blank => "The project name is a required data item.",
        :too_short => "The project name is too short. A project name must be at least 2 characters.",
        :too_long => "The project name is too long. A project name cannot exceed 48 characters."
      },
      :zeddb => {
        :blank => "The database name is a required data item.",
        :invalid => "The database name is invalid.",
        :taken => "The database name is already in use by another project.",
        :too_short => "The database name is too short. A project location must be at least 4 characters.",
        :too_long => "The database name is too long. A project location cannot be longer than 18 characters.",
        :wrong_length => "A database name must be 12 characters."
      },
      :location => {
        :blank => "The project location is a required data item.",
        :invalid => "The project location is invalid.",
        :exclusion => "The project location is reserved.",
        :taken => "The project location is already in use by another project.",
        :too_short => "The project location is too short. A project location must be at least 2 characters.",
        :too_long => "The project location is too long. A project location cannot exceed 32 characters."
      },
      :locales_key => {
        :invalid => "The project locales key is invalid.",
        :taken => "The project locales key is already in use.",
        :wrong_length => "The project locales key must be 18 characters."
      },
      :project_type => {
        :inclusion => "The project type is invalid."
      }
    }
  },
  :project_key => {
    :attributes => {
      :platform => {
        :blank => "The platform is a required data item.",
        :invalid => "The platform is invalid."
      },
      :name => {
        :blank   => "The project API key's name is a required data item.",
        :invalid => "The project API key name is invalid.",
        :too_short => "The project API key's name must be between 2 and 32 characters.",
        :too_long  => "The project API key's name must be between 2 and 32 characters."
      },
      :project_key => {
        :blank   => "The project API key is a required data item.",
        :invalid => "The project API key is invalid.",
        :taken => "The project API key is already in use.",
        :wrong_length => "The project API key is not 18 characters."
      }
    }
  },
  :project_user => {
    :attributes => {
      :user => {
        :blank => "The user does not exist or its use is not available.",
        :invalid => "The user does not exist or its use is not available.",
        :taken => "The user is already attached to the project."
      },
      :role => {
        :blank => "The user role is a required data item.",
        :invalid => "The user role is invalid."
      }
    }
  },
  :project_locale => {
    :attributes => {
      :locale => {
        :blank => "The locale is a required data item.",
        :invalid => "The locale is invalid.",
        :taken => "The locale already set for this project."
      },
      :stage => {
        :blank => "The project locale's stage is a required data item.",
        :inclusion => "The project locale's stage is invalid."
      }
    }
  },
  :project_shelf => {
    :attributes => {
      :shelf => {
        :blank => "The project shelf is a required data item.",
        :invalid => "The project shelf is invalid.",
        :taken => "The project shelf already attached to this project."
      }
    }
  },
  :project_settings => {
    :attributes => {
      :email => {
        :inclusion => "The user email address setting is invalid."
      }
    }
  },
  :email_settings => {
    :attributes => {
      :project => {
        :blank => "The project does not exist or its use is not available.",
        :invalid => "The project does not exist or its use is not available."
      },
      :provider => {
        :invalid => "The email provider is invalid.",
        :taken => "Email settings already exist for the email provider."
      },
      :username => {
        :blank => "The username is a required data item.",
        :invalid => "The username is invalid.",
        :too_long => "The username is too long. The username cannot exceed 48 characters."
      },
      :password => {
        :blank => "The password is a required data item.",
        :invalid => "The password is invalid.",
        :too_long => "The password is too long. The password cannot exceed 48 characters."
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
        :blank => "The locale is a required data item.",
        :invalid => "The locale does not exist or its use is not available."
      },
      :first_name => {
        :blank => "The first name is a required information.",
        :too_long  => "The first can be no more than 24 characters."
      },
      :initials => {
      },
      :surname => {
      },
      :username => {
        :blank => "The username is a required data item.",
        :invalid => "The username can only be letters and numbers.",
        :taken => "The username is already in use.",
        :too_short => "The username must be between 2 and 18 characters.",
        :too_long  => "The username must be between 2 and 18 characters."
      },
      :email => {
        :blank => "The email address is a required data item.",
        :invalid => "The email address is not a valid email address.",
        :taken => "The email address is already in use.",
        :too_short => "The email address must be between 5 and 128 characters.",
        :too_long  => "The email address must be between 5 and 128 characters."
      },
      :salt => {
      },
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
  :user_preferences => {
    :attributes => {
      :remember => { :inclusion => "The automatic login preference is invalid." }
    }
  },

  :beta_address => {
    :attributes => {
      :project => {
        :blank => "The project does not exist or its use is not available.",
        :invalid => "The project does not exist or its use is not available."
      },
      :email => {
        :blank   => "The email address is a required data item.",
        :invalid => "The email address is invalid.",
        :taken => "The email address is already regstered for early access.",
        :too_short => "An email address must be at least 5 characters.",
        :too_long  => "An email address cannot exceed 128 characters."
      },
      :invited => {
        :blank => "The invitation status is required.",
        :inclusion => "The invitation status submitted is invalid."
      }
    }
  },

  :blog => {
    :attributes => {
      :project => {
        :blank => "The project does not exist or its use is not available.",
        :invalid => "The project does not exist or its use is not available."
      },
      :name => {
        :blank   => "The blog name is a required data item.",
        :invalid => "The blog name is invalid.",
        :too_short => "A blog's name must be between 2 and 24 characters.",
        :too_long  => "A blog's name must be between 2 and 24 characters."
      }                   
    },
  },
  :blog_post => {
    :attributes => {
      :blog => {
        :blank => "The blog does not exist or its use is not available.",
        :invalid => "The blog does not exist or its use is not available."
      },
      :user => {
        :blank => "The user does not exist or its use is not available.",
        :invalid => "The user does not exist or its use is not available."
      },
      :markup => {
        :blank => "The content markup type is a required data item.",
        :invalid => "The content markup type is invalid."
      },
      :title => {
        :blank   => "The post title is a required data item.",
        :invalid => "The post title is invalid.",
        :too_short => "A post's title must be between 2 and 128 characters.",
        :too_long  => "A post's title must be between 2 and 128 characters."
      },
      :url => {
        :invalid => "The external URL is invalid.",
        :exclusion => "A external URL can only be an HTTP endpoint.",
        :too_short => "The external URL is too short. It must be at least 12 characters.",
        :too_long => "The external URL is too long. It cannot exceed 128 characters."
      },
      :content => {
        :too_long  => "A post's content size cannot exceed 5,000 characters."
      },
      :stage => {
        :blank => "The blog post's stage is a required data item.",
        :invalid => "The blog post's stage is invalid.",
        :inclusion => "The blog post's stage is invalid."
      }
    },
  },

  :shortener => {
    :attributes => {
      :project => {
        :blank => "The project does not exist or its use is not available.",
        :invalid => "The project does not exist or its use is not available."
      },
      :domain => {
        :blank   => "The domain name is a required data item.",
        :invalid => "The domain name is invalid.",
        :taken => "The domain name is already in use.",
        :too_short => "A domain must be at least 5 characters.",
        :too_long  => "A domain cannot exceed 48 characters."
      }                   
    },
  },
  :shortened_url => {
    :attributes => {
      :shortener => {
        :blank => "The shortener does not exist or its use is not available.",
        :invalid => "The shortener does not exist or its use is not available."
      },
      :user => {
        :blank => "The user does not exist or its use is not available.",
        :invalid => "The user does not exist or its use is not available."
      },
      :destination => {
        :blank => "The destination URL is a required data item.",
        :invalid => "The destination URL is invalid.",
        :too_short => "The destination URL must be at least 12 characters.",
        :too_long  => "The destination URL cannot exceed 1024 characters."
      },
      :standing => {
        :blank => "The shortened URL's standing is a required data item.",
        :inclusion => "The shortened URL's standing is invalid."
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

} }

} } }
