test('memcached-glib-test', executable('memcached-glib-test', ['memcached-glib-test.vala'],
                                       vala_args: ['--target-glib=2.32', '--vapidir=' + meson.current_source_dir() + '/../vapi'],
                                       dependencies: [glib, gobject, gio, memcached_glib]))
