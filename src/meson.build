libmemcached_glib_sources = [
    'gmemcached.vala',
    'gmemcached-context.vala',
    'gmemcached-context-source.vala',
    'gmemcached-error.vala']
libmemcached_glib_lib = library('memcached-glib', libmemcached_glib_sources,
                                vala_args: '--vapidir=' + meson.current_source_dir() + '/../vapi',
                                dependencies: [glib, gobject, gio, libmemcached])

libmemcached_glib = declare_dependency(dependencies: libmemcached,
                                       link_with: libmemcached_glib_lib,
                                       include_directories: include_directories('.'))
