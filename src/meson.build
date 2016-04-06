memcached_glib_sources = [
    'libmemcached-glib.vala',
    'libmemcached-glib-context.vala',
    'libmemcached-glib-context-source.vala',
    'libmemcached-glib-error.vala'
]
memcached_glib_lib = shared_library('memcached-glib', memcached_glib_sources,
                                    vala_args: ['--target-glib=2.32', '--vapidir=' + meson.current_source_dir() + '/../vapi'],
                                    dependencies: [glib, gobject, gio, memcached],
                                    install: true)

memcached_glib = declare_dependency(dependencies: memcached,
                                    link_with: memcached_glib_lib,
                                    include_directories: include_directories('.'))

pkg_config = import('pkgconfig')
pkg_config.generate(name: 'libmemcached-glib',
                    description: 'GLib wrapper around libmemcached and libmemcachedutil',
                    libraries: memcached_glib_lib)
