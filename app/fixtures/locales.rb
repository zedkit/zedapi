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

$locales = [
  ZedkitLocale.new(code: "en", language: "en", name: "english"),
  ZedkitLocale.new(code: "fr", language: "fr", name: "french"),
  ZedkitLocale.new(code: "es", language: "es", name: "spanish"),
  ZedkitLocale.new(code: "de", language: "de", name: "german"),
  ZedkitLocale.new(code: "da", language: "da", name: "danish"),
  ZedkitLocale.new(code: "nl", language: "nl", name: "dutch"),
  ZedkitLocale.new(code: "el", language: "el", name: "greek"),
  ZedkitLocale.new(code: "it", language: "it", name: "italian"),
  ZedkitLocale.new(code: "pl", language: "pl", name: "polish"),
  ZedkitLocale.new(code: "ru", language: "ru", name: "russian"),
  ZedkitLocale.new(code: "sk", language: "sk", name: "slovak"),
  ZedkitLocale.new(code: "pt", language: "pt", name: "portuguese"),
  ZedkitLocale.new(code: "ar", language: "ar", name: "arabic")
].freeze

##
# Albanian (Albania)	  :  	sq_AL
# Albanian	            :  	sq
# Arabic (Algeria)	    :  	ar_DZ
# Arabic (Bahrain)	    :  	ar_BH
# Arabic (Egypt)	      :  	ar_EG
# Arabic (Iraq)	        :  	ar_IQ
# Arabic (Jordan)	      :  	ar_JO
# Arabic (Kuwait)	      :  	ar_KW
# Arabic (Lebanon)	    :  	ar_LB
# Arabic (Libya)	      :  	ar_LY
# Arabic (Morocco)	    :  	ar_MA
# Arabic (Oman)     	  :  	ar_OM
# Arabic (Qatar)	      :  	ar_QA
# Arabic (Saudi Arabia)	:  	ar_SA
# Arabic (Sudan)	      :  	ar_SD
# Arabic (Syria)	      :  	ar_SY
# Arabic (Tunisia)	    :  	ar_TN
# Arabic (UAE)	        :  	ar_AE
# Arabic (Yemen)	      :  	ar_YE
# Belarusian (Belarus)	:  	be_BY
# Belarusian	          :  	be
# Bulgarian (Bulgaria)	:  	bg_BG
# Bulgarian	            :  	bg
# Catalan (Spain)	      :  	ca_ES
# Catalan	              :  	ca
# Chinese (China)	            :  	zh_CN
# Chinese (Hong Kong)       	:  	zh_HK
# Chinese (Singapore)	        :  	zh_SG
# Chinese (Taiwan)	          :  	zh_TW
# Chinese	                    :  	zh
# Croatian (Croatia)	        :  	hr_HR
# Croatian	                  :  	hr
# Czech (Czech Republic)	    :  	cs_CZ
# Czech	                      :  	cs
# Danish (Denmark)          	:  	da_DK
# Dutch (Belgium)	            :  	nl_BE
# Dutch (Netherlands)	        :  	nl_NL
# English (Australia)	        :  	en_AU
# English (Canada)          	:  	en_CA
# English (India)	            :  	en_IN
# English (Ireland)	          :  	en_IE
# English (Malta)	            :  	en_MT
# English (New Zealand)	      :  	en_NZ
# English (Philippines)	      :  	en_PH
# English (Singapore)	        :  	en_SG
# English (South Africa)	    :  	en_ZA
# English (United Kingdom)	  :  	en_GB
# English (United States)	    :  	en_US
# Estonian (Estonia)	        :  	et_EE
# Estonian	                  :  	et
# Finnish (Finland)	          :  	fi_FI
# Finnish	                    :  	fi
# French (Belgium)	          :  	fr_BE
# French (Canada)	            :  	fr_CA
# French (France)	            :  	fr_FR
# French (Luxembourg)	        :  	fr_LU
# French (Switzerland)	      :  	fr_CH
# German (Austria)	          :  	de_AT
# German (Germany)	          :  	de_DE
# German (Luxembourg)	        :  	de_LU
# German (Switzerland)	      :  	de_CH
# Greek (Cyprus)	            :  	el_CY
# Greek (Greece)	            :  	el_GR
# Hebrew (Israel)	            :  	iw_IL
# Hebrew	                    :  	iw
# Hindi (India)	              :  	hi_IN
# Hungarian (Hungary)	        :  	hu_HU
# Hungarian	                  :  	hu
# Icelandic (Iceland)	        :  	is_IS
# Icelandic	                  :  	is
# Indonesian (Indonesia)    	:  	in_ID
# Indonesian	                :  	in
# Irish (Ireland)	            :  	ga_IE
# Irish	                      :  	ga
# Italian (Italy)	            :  	it_IT
# Italian (Switzerland)	      :  	it_CH
# Japanese (Japan)	          :  	ja_JP
# Japanese (Japan,JP)	        :  	ja_JP_JP
# Japanese	                  :  	ja
# Korean (South Korea)	      :  	ko_KR
# Korean	                    :  	ko
# Latvian (Latvia)	          :  	lv_LV
# Latvian	                    :  	lv
# Lithuanian (Lithuania)	    :  	lt_LT
# Lithuanian	                :  	lt
# Macedonian (Macedonia)	    :  	mk_MK
# Macedonian	                :  	mk
# Malay (Malaysia)	          :  	ms_MY
# Malay	                      :  	ms
# Maltese (Malta)	            :  	mt_MT
# Maltese	                    :  	mt
# Norwegian (Norway)	        :  	no_NO
# Norwegian (Norway,Nynorsk)	:  	no_NO_NY
# Norwegian	                  :  	no
# Polish (Poland)	            :  	pl_PL
# Portuguese (Brazil)	        :  	pt_BR
# Portuguese (Portugal)	      :  	pt_PT
# Romanian (Romania)	        :  	ro_RO
# Romanian	                  :  	ro
# Russian (Russia)	          :  	ru_RU
# Serbian (Bosnia and Herzegovina)  :  	sr_BA
# Serbian (Montenegro)	            :  	sr_ME
# Serbian (Serbia and Montenegro)	  :  	sr_CS
# Serbian (Serbia)	                :  	sr_RS
# Serbian	                          :  	sr
# Slovak (Slovakia)           	    :  	sk_SK
# Slovenian (Slovenia)	            :  	sl_SI
# Slovenian	                        :  	sl
# Spanish (Argentina)	              :  	es_AR
# Spanish (Bolivia)	                :  	es_BO
# Spanish (Chile)	                  :  	es_CL
# Spanish (Colombia)	              :  	es_CO
# Spanish (Costa Rica)	            :  	es_CR
# Spanish (Dominican Republic)	    :  	es_DO
# Spanish (Ecuador)	                :  	es_EC
# Spanish (El Salvador)	    :  	es_SV
# Spanish (Guatemala)	      :  	es_GT
# Spanish (Honduras)        :  	es_HN
# Spanish (Mexico)	        :  	es_MX
# Spanish (Nicaragua)	      :  	es_NI
# Spanish (Panama)	        :  	es_PA
# Spanish (Paraguay)	      :  	es_PY
# Spanish (Peru)	          :  	es_PE
# Spanish (Puerto Rico)	    :  	es_PR
# Spanish (Spain)	          :  	es_ES
# Spanish (United States)	  :  	es_US
# Spanish (Uruguay)	        :  	es_UY
# Spanish (Venezuela)	      :  	es_VE
# Swedish (Sweden)	        :  	sv_SE
# Swedish	                  :  	sv
# Thai (Thailand)	          :  	th_TH
# Thai (Thailand,TH)	      :  	th_TH_TH
# Thai	                    :  	th
# Turkish (Turkey)	        :  	tr_TR
# Turkish	                  :  	tr
# Ukrainian (Ukraine)	      :  	uk_UA
# Ukrainian	                :  	uk
# Vietnamese (Vietnam)	    :  	vi_VN
# Vietnamese	              :  	vi
##
