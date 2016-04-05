/*
 * This file is part of Memcached-GLib.
 *
 * Memcached-GLib is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Memcached-GLib is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Memcached-GLib.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;

public class MemcachedGLib.Context : Object
{
	private Memcached.Context _context;

	public Context ()
	{
		_context = new Memcached.Context ();
	}

	public Context.from_configuration (string str) throws MemcachedGLib.Error
	{
		_context = new Memcached.Context.from_configuration (str.data);
		uint8 err_buf[512];
		var return_code = Memcached.check_configuration (str.data, err_buf);
		if (return_code.failed () || return_code.fatal ())
		{
			throw new MemcachedGLib.Error.FAILURE ("%s: %s",  _context.strerror (return_code), (string) err_buf);
		}
	}

	/**
	 * Wrap an existing {@link Memcached.Context} object.
	 */
	public Context.take_memcached_context (owned Memcached.Context ctx)
	{
		_context = (owned) ctx;
	}

	internal inline void _handle_return_code (Memcached.ReturnCode return_code) throws MemcachedGLib.Error
	{
		if (return_code.failed () || return_code.fatal ())
		{
			var error = new MemcachedGLib.Error.FAILURE ("%s: %s", _context.strerror (return_code), _context.last_error_message ());
			error.code = return_code;
			throw error;
		}
	}

	/**
	 * Steal the wrapped {@link Memcached.Context} object.
	 */
	[DestroysInstance]
	public Memcached.Context steal_memcached_context () {
		return (owned) _context;
	}

	/**
	 * Create a {@link GLib.Source} that emit whenever an instance is meet the
	 * requested {@link GLib.IOCondition}.
	 */
	public Source create_source (IOCondition condition)
	{
		var source = new IdleSource ();

		lock (_context)
		{
			for (int i = 0; i < _context.server_count (); i++)
			{
				unowned Memcached.Instance instance = _context.server_instance_by_position (i);
				int fd = ((int[]) instance)[5]; // warning: dirty hack! (see 'instance.hpp')
				if (fd > 0)
				{
					source.add_unix_fd (fd, condition);
				}
			}
		}

		source.attach (MainContext.@default ());

		return source;
	}

	public void servers_reset ()
	{
		lock (_context)
		{
			_context.servers_reset ();
		}
	}

	public uint64 increment (string key, uint32 offset) throws MemcachedGLib.Error
	{
		uint64 result;
		_handle_return_code (_context.increment (key.data, offset, out result));
		return result;
	}

	/**
	 * @see MemcachedGLib.Context.increment
	 */
	public async uint64 increment_async (string key,
	                                     uint32 offset,
	                                     int    priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (increment_async.callback);
		yield;
		return increment (key, offset);
	}

	public uint64 decrement (string key, uint32 offset) throws MemcachedGLib.Error
	{
		uint64 result;
		_handle_return_code (_context.decrement (key.data, offset, out result));
		return result;
	}

	/**
	 * @see MemcachedGLib.Context.increment
	 */
	public async uint64 decrement_async (string key,
	                                     uint32 offset,
	                                     int    priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (decrement_async.callback);
		yield;
		return decrement (key, offset);
	}

	public new uint8[] @get (string key, out uint32? flags = null) throws MemcachedGLib.Error
	{
		Memcached.ReturnCode return_code;
		var ret = _context.@get (key.data, out flags, out return_code);
		_handle_return_code (return_code);
		return ret;
	}

	public async uint8[] get_async (string      key,
	                                int         priority = GLib.Priority.DEFAULT,
	                                out uint32? flags    = null)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (get_async.callback);
		yield;
		return @get (key, out flags);
	}

	public uint8[] get_by_key (string group_key, string key, out uint32? flags = null)
		throws MemcachedGLib.Error
	{
		Memcached.ReturnCode return_code;
		var ret = _context.get_by_key (group_key.data, key.data, out flags, out return_code);
		_handle_return_code (return_code);
		return ret;
	}

	public async uint8[] get_by_key_async (string group_key,
	                                       string key,
	                                       int    priority          = GLib.Priority.DEFAULT,
	                                       out    uint32? flags     = null)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (get_by_key_async.callback);
		yield;
		return get_by_key (group_key, key, out flags);
	}

	public void mget (string[] keys)
		throws MemcachedGLib.Error
	{
		var keys_length = new size_t[keys.length];
		for (int i = 0; i < keys.length; i++)
			keys_length[i] = keys[i].length;
		_handle_return_code (_context.mget ((uint8*[]) keys, keys_length));
	}

	/**
	 * @see MemcachedGLib.Context.mget
	 */
	public async void mget_async (string[] keys, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (mget_async.callback);
		yield;
		mget (keys);
	}

	public void mget_by_key (string group_key, string[] keys)
		throws MemcachedGLib.Error
	{
		var keys_length = new size_t[keys.length];
		for (int i = 0; i < keys.length; i++)
			keys_length[i] = keys[i].length;
		_handle_return_code (_context.mget_by_key (group_key.data, (uint8*[]) keys, keys_length));
	}

	public async void mget_by_key_async (string group_key, string[] keys, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (mget_by_key_async.callback);
		yield;
		mget_by_key (group_key, keys);
	}

	public Memcached.Result? fetch_result ()
		throws MemcachedGLib.Error
	{
		Memcached.ReturnCode return_code;
		var result = _context.fetch_result (null, out return_code);
		_handle_return_code (return_code);
		return result;
	}

	public async Memcached.Result? fetch_result_async (int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.IN);
		source.set_priority (priority);
		source.set_callback (fetch_result_async.callback);
		yield;
		return fetch_result ();
	}

	public void set_sasl_auth_data (string username, string password)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.set_sasl_auth_data (username, password));
	}

	public void destroy_sasl_auth_data ()
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.destroy_sasl_auth_data ());
	}

	public void server_add_udp (string hostname, Memcached.in_port_t port = Memcached.DEFAULT_PORT)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.server_add_udp (hostname, port));
	}

	public void server_add_unix_socket (string filename)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.server_add_unix_socket (filename));
	}

	public void server_add (string hostname, Memcached.in_port_t port = Memcached.DEFAULT_PORT)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.server_add (hostname, port));
	}

	public void server_add_udp_with_weight (string hostname, uint32 weight, Memcached.in_port_t port = Memcached.DEFAULT_PORT)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.server_add_udp_with_weight (hostname, port, weight));
	}

	public void server_add_unix_socket_with_weight (string filename, uint32 weight)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.server_add_unix_socket_with_weight (filename, weight));
	}

	public void server_add_with_weight (string hostname, uint32 weight, Memcached.in_port_t port = Memcached.DEFAULT_PORT)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.server_add_with_weight (hostname, port, weight));
	}

	public new void @set (string key, uint8[] @value, time_t expiration, uint32 flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@set (key.data, @value, expiration, flags));
	}

	/**
	 * @see MemcachedGLib.Context.set
	 */
	public async void @set_async (string  key,
	                              uint8[] @value,
	                              time_t  expiration,
	                              uint32  flags    = 0,
	                              int     priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (set_async.callback);
		yield;
		@set (key, @value, expiration, flags);
	}

	/**
	 *
	 */
	public void set_by_key (string  group_key,
	                        string  key,
	                        uint8[] @value,
	                        time_t  expiration,
	                        uint32  flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.set_by_key (group_key.data, key.data, @value, expiration, flags));
	}

	/**
	 * @see MemcachedGLib.Context.set_by_key
	 */
	public async void set_by_key_async (string  group_key,
	                                    string  key,
	                                    uint8[] @value,
	                                    time_t  expiration,
	                                    uint8   flags,
	                                    int     priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (set_by_key_async.callback);
		yield;
		set_by_key (group_key, key, @value, expiration, flags);
	}

	public void cas (string key, uint8[] @value, time_t expiration, uint64 cas, uint32 flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.cas (key.data, @value, expiration, flags, cas));
	}

	/**
	 * @see MemcachedGLib.Context.cas
	 */
	public async void cas_async (string  key,
	                             uint8[] @value,
	                             time_t  expiration,
	                             uint64  cas,
	                             uint32  flags    = 0,
	                             int     priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (cas_async.callback);
		yield;
		this.cas (key, @value, expiration, cas, flags);
	}

	public void cas_by_key (string  group_key,
	                        string  key,
	                        uint8[] @value,
	                        time_t  expiration,
	                        uint64  cas,
	                        uint32  flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.cas_by_key (group_key.data, key.data, @value, expiration, flags, cas));
	}

	/**
	 * @see MemcachedGLib.Context.cas_by_key
	 */
	public async void cas_by_key_async (string  group_key,
	                                    string  key,
	                                    uint8[] @value,
	                                    time_t  expiration,
	                                    uint64  cas,
	                                    uint32  flags    = 0,
	                                    int     priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (cas_by_key_async.callback);
		cas_by_key (group_key, key, @value, expiration, cas, flags);
	}

	public new void @delete (string key)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@delete (key.data, 0));
	}

	public async void delete_async (string key, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (delete_async.callback);
		yield;
		@delete (key);
	}

	public void @delete_by_key (string group_key, string key)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@delete_by_key (group_key.data, key.data, 0));
	}

	public async void delete_by_key_async (string group_key,
	                                       string key,
	                                       int    priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		var source = create_source (IOCondition.OUT);
		source.set_priority (priority);
		source.set_callback (delete_by_key_async.callback);
		yield;
		@delete_by_key (group_key, key);
	}
}
