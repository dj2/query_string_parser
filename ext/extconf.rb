require 'mkmf'

#$CFLAGS = "-Wall -Werror -Wextra"

extension_name = 'pr_query_parser'
dir_config(extension_name)

have_library('curl', 'curl_easy_unescape')
create_makefile(extension_name)
