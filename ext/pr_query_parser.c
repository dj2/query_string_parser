#include "ruby.h"

#include <stdio.h>
#include <ctype.h>
#include <curl/curl.h>

static void
pr_set_param(VALUE params, char *key, char *value)
{
    VALUE rkey, rvalue, cur;
    char *v;

    /* no key do nothing */
    if (key == NULL || *key == 0) return;

    /* strip [] from the key name */
    v = curl_easy_unescape(NULL, key, 0, NULL);
    if (strlen(v) > 2)
    {
        char *t = v;
        char *open_bracket = NULL;

        while (*(t + 1) != 0)
        {
            if (*t == '[') open_bracket = t;
            t++;
        }

        if ((*t == ']') && (open_bracket != NULL))
        {
            char *pos = (open_bracket + 1);
            int is_digit = 1;

            while (pos != t)
            {
                if (!isdigit(*pos))
                {
                    is_digit = 0;
                    break;
                }
                pos ++;
            }

            if ((*t == ']') && (*(t - 1) == '['))
            {
                *(t - 1) = 0;
            }
            else if ((*t == ']') && (*open_bracket == '[') && is_digit)
            {
                *open_bracket = 0;
            }
        }
    }

    /* key was only [], do nothing */
    if (v == NULL || *v == 0) return;

    rkey = rb_str_new2(v);
    free(v);

    v = curl_easy_unescape(NULL, value, 0, NULL);
    rvalue = rb_str_new2(v);
    free(v);

    cur = rb_hash_aref(params, rkey);
    if (NIL_P(cur))
    {
        rb_hash_aset(params, rkey, rvalue);
    }
    else
    {
        VALUE arry;
        if (rb_obj_is_kind_of(cur, rb_cArray)  == Qtrue)
        {
            arry = cur;
        }
        else
        {
            arry = rb_ary_new();
            rb_ary_push(arry, cur);
            rb_hash_aset(params, rkey, arry);
        }
        rb_ary_push(arry, rvalue);
    }
}

VALUE
pr_query_parser(VALUE self, VALUE query_string, VALUE delim)
{
    VALUE params = Qnil;
    char *qs, *p, *s, *key = NULL;
    char delimiter = RSTRING_PTR(delim)[0];

    params = rb_hash_new();
    qs = strdup(RSTRING_PTR(query_string));
    for (s = qs, p = qs; *p != 0; p++)
    {
        if (*p == delimiter)
        {
            *p = 0;
            if (key != NULL)
            {
                pr_set_param(params, key, s);
                key = NULL;
            }
            else
            {
                pr_set_param(params, s, s);
            }
            s = (p + 1);
        }
        else if ((*p == '=') && (key == NULL))
        {
            *p = 0;
            key = s;
            s = (p + 1);
        }
    }

    if (s != NULL)
    {
        if (key != NULL) pr_set_param(params, key, s);
        else pr_set_param(params, s, s);
    }
    free(qs);

    return params;
    self = self;
}

void
Init_pr_query_parser(void)
{
    VALUE QueryStringParser = rb_define_module("QueryStringParser");

    rb_define_module_function(QueryStringParser, "pr_query_parser", pr_query_parser, 2);
}
