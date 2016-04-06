project('libmemcached-glib', ['c', 'vala'])

add_global_arguments(['-Wno-deprecated-declarations',
                      '-Wno-unused',
                      '-Wno-pointer-sign'], language: 'c')

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
gio = dependency('gio-2.0')
memcached = dependency('libmemcached')

subdir('src')
subdir('benchmarks')
subdir('tests')
subdir('vapi')
