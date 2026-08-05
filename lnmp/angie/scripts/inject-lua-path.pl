#!/usr/bin/env perl

use 5.006;
use strict;
use warnings;

@ARGV == 2 or die "invalid arguments\n";

my ($ngx_lua_dir, $ngx_stream_lua_dir) = @ARGV;

my $prefix = '/usr/local/angie';
my $lualib_prefix = "$prefix/lualib";
my $site_lualib_prefix = "$prefix/site/lualib";

{
    my $outfile = "$ngx_lua_dir/config";

    -f $outfile
        or die "cannot find $outfile\n";

    open my $in, '>>', $outfile
        or die "cannot open $outfile: $!\n";

    print {$in} <<"EOC";
echo '
#ifndef LUA_DEFAULT_PATH
#define LUA_DEFAULT_PATH "$site_lualib_prefix/?.ljbc;$site_lualib_prefix/?/init.ljbc;$lualib_prefix/?.ljbc;$lualib_prefix/?/init.ljbc;$site_lualib_prefix/?.lua;$site_lualib_prefix/?/init.lua;$lualib_prefix/?.lua;$lualib_prefix/?/init.lua"
#endif
#ifndef LUA_DEFAULT_CPATH
#define LUA_DEFAULT_CPATH "$site_lualib_prefix/?.so;$lualib_prefix/?.so"
#endif
' >> "\$ngx_addon_dir/src/ngx_http_lua_autoconf.h"
EOC

    close $in
        or die "cannot close $outfile: $!\n";
}

{
    my $outfile = "$ngx_stream_lua_dir/config";

    -f $outfile
        or die "cannot find $outfile\n";

    open my $in, '>>', $outfile
        or die "cannot open $outfile: $!\n";

    print {$in} <<"EOC";
echo '
#ifndef LUA_DEFAULT_PATH
#define LUA_DEFAULT_PATH "$site_lualib_prefix/?.ljbc;$site_lualib_prefix/?/init.ljbc;$lualib_prefix/?.ljbc;$lualib_prefix/?/init.ljbc;$site_lualib_prefix/?.lua;$site_lualib_prefix/?/init.lua;$lualib_prefix/?.lua;$lualib_prefix/?/init.lua"
#endif
#ifndef LUA_DEFAULT_CPATH
#define LUA_DEFAULT_CPATH "$site_lualib_prefix/?.so;$lualib_prefix/?.so"
#endif
' >> "\$ngx_addon_dir/src/ngx_stream_lua_autoconf.h"
EOC

    close $in
        or die "cannot close $outfile: $!\n";
}
