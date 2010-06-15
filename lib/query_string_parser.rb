require 'iconv'
require 'pr_query_parser'

module AideRSS
  module QueryStringParser
    module_function

    def qs_parse(query_string, delim = '&')
      return {} if query_string.nil? || query_string == ""

      ret = Iconv.iconv("UTF-8//IGNORE", "ISO-8859-1", (query_string + "\x20")).first[0..-2]
      pr_query_parser(ret, delim)
    end
  end
end