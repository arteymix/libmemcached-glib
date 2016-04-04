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

public class MemcachedGLib.Context
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
			var error = new MemcachedGLib.Error.FAILURE (_context.strerror (return_code));
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

	public uint8[] @get (string key, out uint32? flags = null) throws MemcachedGLib.Error
	{
		Memcached.ReturnCode return_code;
		var ret = _context.@get (key.data, out flags, out return_code);
		_handle_return_code (return_code);
		return ret;
	}

	public async uint8[] get_async (string key, int priority = GLib.Priority.DEFAULT, out uint32? flags = null)
		throws MemcachedGLib.Error
	{
		GLib.Idle.add (get_async.callback, priority);
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
	                                       int    priority      = GLib.Priority.DEFAULT,
	                                       out    uint32? flags = null)
		throws MemcachedGLib.Error
	{
		GLib.Idle.add (get_by_key_async.callback, priority);
		yield;
		return get_by_key (group_key, key, out flags);
	}

	public void @set (string key, uint8[] @value, time_t expiration, uint32 flags = 0)
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
		GLib.Idle.add (@set_async.callback, priority);
		yield;
		@set (key, @value, expiration, flags);
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
		GLib.Idle.add (cas_async.callback, priority);
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
		GLib.Idle.add (cas_by_key_async.callback, priority);
		yield;
		cas_by_key (group_key, key, @value, expiration, cas, flags);
	}

	/**
	 *
	 */
	public void set_by_key (string group_key, string key, uint8[] @value, time_t expiration, uint32 flags = 0)
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
		GLib.Idle.add (set_by_key_async.callback, priority);
		yield;
		set_by_key (group_key, key, @value, expiration, flags);
	}

	public void @delete (string key)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@delete (key.data, 0));
	}

	public async void delete_async (string key, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		GLib.Idle.add (delete_async.callback, priority);
		yield;
		@delete (key);
	}

	public void @delete_by_key (string group_key, string key)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@delete_by_key (group_key.data, key.data, 0));
	}

	public async void delete_by_key_async (string group_key, string key, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		GLib.Idle.add (delete_by_key_async.callback, priority);
		yield;
		@delete_by_key (group_key, key);
	}
}
