libmemcached_glib_sources = [
    'gmemcached.vala',
    'gmemcached-context.vala',
    'gmemcached-context-source.vala',
    'gmemcached-error.vala']
libmemcached_glib_lib = library('libmemcached-glib', libmemcached_glib_sources,
                                name_prefix: '',
                                vala_args: '--vapidir=' + meson.current_source_dir() + '/../vapi',
                                dependencies: [glib, gobject, gio, libmemcached],
                                install: true)

libmemcached_glib = declare_dependency(dependencies: libmemcached,
                                       link_with: libmemcached_glib_lib,
                                       include_directories: include_directories('.'))

pkg_config = import('pkgconfig')
pkg_config.generate(name: 'libmemcached-glib',
                    description: 'GLib wrapper around libMemcached',
                    requires: 'glib-2.0 gobject-2.0 gio-2.0 libmemcached',
                    libraries: libmemcached_glib_lib)
