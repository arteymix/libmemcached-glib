test('context', executable('context-test', ['context-test.vala'],
                           vala_args: ['--target-glib=2.32', '--vapidir=' + meson.current_source_dir() + '/../vapi'],
                           dependencies: [glib, gobject, gio, libmemcached_glib]))
