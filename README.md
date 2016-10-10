# Memcached-GLib

GLib wrapper around libMemcached.

```vala
using GLib;
using GMemcached;

var context = new Context.from_configuration ("--SERVER=localhost");

context.@set ("some_key", "some value".data, TimeSpan.HOUR);

var @value = context.@get ("some_key");
```

## Features

 - handle status code properly with error domains
 - synchronous and asynchronous APIs
 - closures for callback API (eg. `dump`, `fetch_execute`)
 - express expiration with `GLib.TimeSpan`
 - `lookup` and `get_or_compute` utilities

## Extensions

If a key is missing in the cache, `get` calls will raise an error. To provide
a default value, use the `lookup` utilities.

```vala
var @value = cache.lookup ("some_key") ?? "default value".data;
```

The `get_or_compute` utilities makes it comfortable to compute a default value
when a key is missing in the cache. The computed value is assigned to the key
and returned.

```vala
var @value = cache.get_or_compute ("key", (out expiration) => {
  expiration = 15 * TimeSpan.MINUTE;
  return new uint8[1024];
});
```

## Cache pool

It is recommended to use the context in combination of a resource pool like the
one provided by [Bump](https://github.com/nemequ/bump).

```vala
using Bump;
using GLib;
using GMemcached;

var cache_pool = new ResourcePool<Context> ();

cache_pool.construct_properties = {
    Parameter () {name = "configuration", @value = "--SERVER=localhost"}
};

cache_pool.execute ((cache) => {
  cache.@get ("some_key")
});
```



