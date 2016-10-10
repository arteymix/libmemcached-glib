benchmark('set-and-get', executable('set-and-get-benchmark', 'set-and-get-benchmark.vala',
                                    dependencies: [glib, gobject, gio, libmemcached_glib],
                                    vala_args: ['--target-glib=2.32', '--vapidir=' + meson.current_source_dir() + '/../vapi']))
benchmark('set-and-get-async', executable('set-and-get-async-benchmark', 'set-and-get-async-benchmark.vala',
                                    dependencies: [glib, gobject, gio, libmemcached_glib],
                                    vala_args: ['--target-glib=2.32', '--vapidir=' + meson.current_source_dir() + '/../vapi']))
benchmark('variant-storage', executable('variant-storage-benchmark', 'variant-storage-benchmark.vala',
                                        dependencies: [glib, gobject, gio, libmemcached_glib],
                                        vala_args: ['--target-glib=2.32', '--vapidir=' + meson.current_source_dir() + '/../vapi']))
