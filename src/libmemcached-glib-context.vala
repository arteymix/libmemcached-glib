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

public class MemcachedGLib.Context : Object, Initable
{
	/**
	 * The configuration if this has been initialized by {@link Context.from_configuration},
	 * otherwise 'null' and servers are expected to be attached manually.
	 */
	public string? configuration { construct; get; default = null; }

	private Memcached.Context _context;

	public Context (string configuration)
	{
		_context = new Memcached.Context ();
	}

	public Context.from_configuration (string str) throws GLib.Error
	{
		Object (configuration: str);
		init ();
	}

	/**
	 * Initialize the cache context if a configuration is provided.
	 */
	public bool init (Cancellable? cancellable = null) throws GLib.Error
	{
		if (configuration == null || _context != null)
			return true;
		uint8 err_buf[512];
		_handle_return_code (Memcached.check_configuration (configuration.data, err_buf), (string) err_buf);
		_context = new Memcached.Context.from_configuration (configuration.data);
		return true;
	}

	/**
	 * Wrap an existing {@link Memcached.Context} object.
	 */
	public Context.take_memcached_context (owned Memcached.Context ctx)
	{
		_context = (owned) ctx;
	}

	internal inline void _handle_return_code (Memcached.ReturnCode return_code, string? message = null) throws MemcachedGLib.Error
	{
		if (return_code.failed () || return_code.fatal ())
		{
			var error = new MemcachedGLib.Error.FAILURE ("%s", message ?? _context.last_error_message ());
			error.code = return_code;
			throw error;
		}
	}

	/**
	 * Helper to poll the context for readiness.
	 */
	internal async void _wait_for_condition_async (int priority)
	{
		var source = create_source ();
		source.set_priority (priority);
		source.set_callback (_wait_for_condition_async.callback);
		yield;
	}

	/**
	 * Steal the wrapped {@link Memcached.Context} object.
	 */
	[DestroysInstance]
	public Memcached.Context steal_memcached_context () {
		return (owned) _context;
	}

	/**
	 * Create a {@link GLib.Source} that emit whenever an instance meets the
	 * provided {@link GLib.IOCondition}.
	 */
	public Source create_source ()
	{
		var source = new ContextSource (_context);
		source.attach (MainContext.@default ());
		return source;
	}

	public void servers_reset ()
	{
		_context.servers_reset ();
	}

	public void reset ()
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.reset ());
	}

	public void reset_last_disconnected_server ()
	{
		_context.reset_last_disconnected_server ();
	}

	public void set_user_data<T> (T data)
	{
		_context.set_user_data<T> (data);
	}

	public T get_user_data<T> ()
	{
		return _context.get_user_data<T> ();
	}

	public uint32 server_count ()
	{
		return _context.server_count ();
	}

	public Memcached.Analysis? analyze (Memcached.Stat memc_stat)
		throws MemcachedGLib.Error
	{
		Memcached.ReturnCode return_code;
		var ret = _context.analyze (memc_stat, out return_code);
		_handle_return_code (return_code);
		return ret;
	}

	public uint64 query_id ()
	{
		return _context.query_id ();
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
		yield _wait_for_condition_async (priority);
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
		yield _wait_for_condition_async (priority);
		return decrement (key, offset);
	}

	public uint64 increment_by_key (string group_key, string key, uint32 offset) throws MemcachedGLib.Error
	{
		uint64 result;
		_handle_return_code (_context.increment_by_key (group_key.data, key.data, offset, out result));
		return result;
	}

	/**
	 * @see MemcachedGLib.Context.increment_by_key
	 */
	public async uint64 increment_by_key_async (string group_key,
	                                            string key,
	                                            uint32 offset,
	                                            int    priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return increment_by_key (group_key, key, offset);
	}

	public uint64 decrement_by_key (string group_key, string key, uint32 offset) throws MemcachedGLib.Error
	{
		uint64 result;
		_handle_return_code (_context.decrement_by_key (group_key.data, key.data, offset, out result));
		return result;
	}

	/**
	 * @see MemcachedGLib.Context.decrement_by_key
	 */
	public async uint64 decrement_by_key_async (string group_key,
	                                            string key,
	                                            uint32 offset,
	                                            int    priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return decrement_by_key (group_key, key, offset);
	}

	public uint64 increment_with_initial (string   key,
	                                      uint64   offset,
	                                      uint64   initial    = 0,
	                                      TimeSpan expiration = 0) throws MemcachedGLib.Error
	{
		uint64 result;
		_handle_return_code (_context.increment_with_initial (key.data,
		                                                      offset,
		                                                      initial,
		                                                      (time_t) (expiration / TimeSpan.SECOND),
		                                                      out result));
		return result;
	}

	/**
	 * @see MemcachedGLib.Context.increment_with_initial
	 */
	public async uint64 increment_with_initial_async (string   key,
	                                                  uint64   offset,
	                                                  uint64   initial    = 0,
	                                                  TimeSpan expiration = 0,
	                                                  int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return increment_with_initial (key, offset, initial, expiration);
	}

	public uint64 decrement_with_initial (string   key,
	                                      uint64   offset,
	                                      uint64   initial    = 0,
	                                      TimeSpan expiration = 0) throws MemcachedGLib.Error
	{
		uint64 result;
		_handle_return_code (_context.decrement_with_initial (key.data,
		                                                      offset,
		                                                      initial,
		                                                      (time_t) (expiration / TimeSpan.SECOND),
		                                                      out result));
		return result;
	}

	/**destroy_functiondestroy_function
	 * @see MemcachedGLib.Context.increment_with_initial
	 */
	public async uint64 decrement_with_initial_async (string   key,
	                                                  uint64   offset,
	                                                  uint64   initial    = 0,
	                                                  TimeSpan expiration = 0,
	                                                  int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return decrement_with_initial (key, offset, initial, expiration);
	}

	public uint64 increment_with_initial_by_key (string   group_key,
	                                             string   key,
	                                             uint64   offset,
	                                             uint64   initial    = 0,
	                                             TimeSpan expiration = 0)
		throws MemcachedGLib.Error
	{
		uint64 result;
		_handle_return_code (_context.increment_with_initial_by_key (group_key.data,
		                                                             key.data,
		                                                             offset,
																	 initial,
		                                                             (time_t) (expiration / TimeSpan.SECOND),
		                                                             out result));
		return result;
	}

	/**
	 * @see MemcachedGLib.Context.increment_with_initial_by_key
	 */
	public async uint64 increment_with_initial_by_key_async (string group_key,
	                                                         string key,
	                                                         uint64 offset,
	                                                         uint64 initial      = 0,
	                                                         TimeSpan expiration = 0,
	                                                         int    priority     = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return increment_with_initial_by_key (group_key, key, offset, initial, expiration);
	}

	public uint64 decrement_with_initial_by_key (string   group_key,
	                                             string   key,
	                                             uint64   offset,
	                                             uint64   initial    = 0,
	                                             TimeSpan expiration = 0)
		throws MemcachedGLib.Error
	{
		uint64 result;
		_handle_return_code (_context.decrement_with_initial_by_key (group_key.data,
		                                                             key.data,
		                                                             offset,
		                                                             initial,
		                                                             (time_t) (expiration / TimeSpan.SECOND),
		                                                             out result));
		return result;
	}

	/**
	 * @see MemcachedGLib.Context.increment_with_initial_by_key
	 */
	public async uint64 decrement_with_initial_by_key_async (string   group_key,
	                                                         string   key,
	                                                         uint64   offset,
												             uint64   initial    = 0,
	                                                         TimeSpan expiration = 0,
	                                                         int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return decrement_with_initial_by_key (group_key, key, offset, initial, expiration);
	}

	public void behavior_set (Memcached.Behavior flag, uint64 data)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.behavior_set (flag, data));
	}

	public uint64 behavior_get (Memcached.Behavior flag)
	{
		return _context.behavior_get (flag);
	}

	public void behavior_set_distribution (Memcached.ServerDistribution type)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.behavior_set_distribution (type));
	}

	public Memcached.ServerDistribution behavior_get_distribution ()
	{
		return _context.behavior_get_distribution ();
	}

	public void bucket_set (uint32[] host_map, uint32[] forward_map, uint32 buckets, uint32 replicas)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.bucket_set (host_map, forward_map, buckets, replicas));
	}

	public new void @delete (string key)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@delete (key.data, 0));
	}

	public async void delete_async (string key, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		@delete (key);
	}

	public void delete_by_key (string group_key, string key)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.delete_by_key (group_key.data, key.data, 0));
	}

	public async void delete_by_key_async (string group_key,
	                                       string key,
	                                       int    priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		delete_by_key (group_key, key);
	}

	public void dump (owned MemcachedGLib.DumpCallback function)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.dump ((ctx, key) =>
		{
			try
			{
				function ((string) key);
				return Memcached.ReturnCode.SUCCESS;
			}
			catch (MemcachedGLib.Error err)
			{
				return (Memcached.ReturnCode) err.code;
			}
		}));
	}

	public async void dump_async (owned MemcachedGLib.DumpCallback function, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		MemcachedGLib.Error? error = null;
		IOSchedulerJob.push ((job) =>
		{
			try
			{
				dump ((owned) function);
			}
			catch (MemcachedGLib.Error _error)
			{
				error = _error;
			}
			finally
			{
				job.send_to_mainloop_async (dump_async.callback);
			}
			return false;
		}, priority);
		yield;
		if (error != null)
			throw error;
	}

	public void set_encoding_key (string str)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.set_encoding_key (str.data));
	}

	public bool exist (string key)
		throws MemcachedGLib.Error
	{
		try
		{
			_handle_return_code (_context.exist (key.data));
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{
			return false;
		}

		return true;
	}

	public async bool exist_async (string key, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return exist (key);
	}

	public bool exist_by_key (string group_key, string key)
		throws MemcachedGLib.Error
	{
		try
		{
			_handle_return_code (_context.exist_by_key (group_key.data, key.data));
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{
			return false;
		}

		return true;
	}

	public async bool exist_by_key_async (string group_key, string key, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return exist_by_key (group_key, key);
	}

	public void fetch_execute (owned MemcachedGLib.ExecuteCallback callback)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.fetch_execute ((ctx, result) =>
		{
			try
			{
				callback (result);
				return Memcached.ReturnCode.SUCCESS;
			}
			catch (MemcachedGLib.Error err)
			{
				return (Memcached.ReturnCode) err.code;
			}
		}));
	}

	public async void fetch_execute_async (owned MemcachedGLib.ExecuteCallback callback, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		fetch_execute ((owned) callback);
	}

	public void flush_buffers ()
	{
		_context.flush_buffers ();
	}

	public void flush (TimeSpan expiration)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.flush ((time_t) (expiration / TimeSpan.SECOND)));
	}

	public async void flush_async (TimeSpan expiration, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		flush (expiration);
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
		yield _wait_for_condition_async (priority);
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
		yield _wait_for_condition_async (priority);
		return get_by_key (group_key, key, out flags);
	}

	public uint8[] get_or_compute (string key, owned ComputeCallback compute, out uint32? flags = null)
		throws MemcachedGLib.Error
	{
		try
		{
			return @get (key, out flags);
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{
			TimeSpan expiration;
			var @value = compute (out expiration, out flags);
			@set (key, @value, expiration, flags);
			return @value;
		}
	}

	public async uint8[] get_or_compute_async (string                key,
	                                           owned ComputeCallback compute,
	                                           int                   priority = GLib.Priority.DEFAULT,
	                                           out uint32?           flags    = null)
		throws MemcachedGLib.Error
	{
		try
		{
			return yield @get_async (key, priority, out flags);
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{
			TimeSpan expiration;
			var @value = compute (out expiration, out flags);
			yield @set_async (key, @value, expiration, flags);
			return @value;
		}
	}

	public uint8[] get_or_compute_by_key (string                group_key,
	                                      string                key,
	                                      owned ComputeCallback compute,
	                                      out uint32?           flags = null)
		throws MemcachedGLib.Error
	{
		try
		{
			return @get_by_key (group_key, key, out flags);
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{
			TimeSpan expiration;
			var @value = compute (out expiration, out flags);
			@set_by_key (group_key, key, @value, expiration, flags);
			return @value;
		}
	}

	public async uint8[] get_or_compute_by_key_async (string                group_key,
	                                                  string                key,
	                                                  owned ComputeCallback compute,
	                                                  int                   priority = GLib.Priority.DEFAULT,
	                                                  out uint32?           flags    = null)
		throws MemcachedGLib.Error
	{
		try
		{
			return yield @get_by_key_async (group_key, key, priority, out flags);
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{
			TimeSpan expiration;
			var @value = compute (out expiration, out flags);
			yield @set_by_key_async (group_key, key, @value, expiration, flags, priority);
			return @value;
		}
	}

	public uint8[]? lookup (string key, out uint32? flags = null)
		throws MemcachedGLib.Error
	{
		try
		{
			return @get (key, out flags);
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{
			return null;
		}
	}

	public async uint8[]? lookup_async (string      key,
	                                    int         priority = GLib.Priority.DEFAULT,
	                                    out uint32? flags    = null)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return lookup (key, out flags);
	}

	public uint8[]? lookup_by_key (string group_key, string key, out uint32? flags = null)
		throws MemcachedGLib.Error
	{
		try
		{
			return @get_by_key (group_key, key, out flags);
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{
			return null;
		}
	}

	public async uint8[]? lookup_by_key_async (string group_key,
	                                           string key,
	                                           int    priority      = GLib.Priority.DEFAULT,
	                                           out    uint32? flags = null)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return lookup_by_key (group_key, key, out flags);
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
		yield _wait_for_condition_async (priority);
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
		yield _wait_for_condition_async (priority);
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
		yield _wait_for_condition_async (priority);
		return fetch_result ();
	}

	public void mget_execute (string[] keys, owned MemcachedGLib.ExecuteCallback callback)
		throws MemcachedGLib.Error
	{
		var keys_length = new size_t[keys.length];
		for (int i = 0; i < keys.length; i++)
			keys_length[i] = keys[i].length;
		_handle_return_code (_context.mget_execute ((uint8*[]) keys, keys_length, (ctx, result) =>
		{
			try
			{
				callback (result);
				return Memcached.ReturnCode.SUCCESS;
			}
			catch (MemcachedGLib.Error err)
			{
				return (Memcached.ReturnCode) err.code;
			}
		}));
	}

	public async void mget_execute_async (owned string[]                      keys,
	                                      owned MemcachedGLib.ExecuteCallback callback,
	                                      int                                 priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		MemcachedGLib.Error? error = null;
		IOSchedulerJob.push ((job) =>
		{
			try
			{
				mget_execute (keys, (owned) callback);
			}
			catch (MemcachedGLib.Error _error)
			{
				error = _error;
			}
			finally
			{
				job.send_to_mainloop_async (mget_execute_async.callback);
			}
			return false;
		}, priority);
		yield;
		if (error != null)
			throw error;
	}

	public void mget_execute_by_key (string group_key, string[] keys, owned MemcachedGLib.ExecuteCallback callback)
		throws MemcachedGLib.Error
	{
		var keys_length = new size_t[keys.length];
		for (int i = 0; i < keys.length; i++)
			keys_length[i] = keys[i].length;
		_handle_return_code (_context.mget_execute_by_key (group_key.data, (uint8*[]) keys, keys_length, (ctx, result) =>
		{
			try
			{
				callback (result);
				return Memcached.ReturnCode.SUCCESS;
			}
			catch (MemcachedGLib.Error err)
			{
				return (Memcached.ReturnCode) err.code;
			}
		}));
	}

	public async void mget_execute_by_key_async (owned string                        group_key,
	                                             owned string[]                      keys,
	                                             owned MemcachedGLib.ExecuteCallback callback,
	                                             int                                 priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		MemcachedGLib.Error? error = null;
		IOSchedulerJob.push ((job) => {
			try
			{
				mget_execute_by_key (group_key, keys, (owned) callback);
			}
			catch (MemcachedGLib.Error _error)
			{
				error = _error;
			}
			finally
			{
				job.send_to_mainloop_async (mget_execute_by_key_async.callback);
			}
			return false;
		}, priority);
		yield;
		if (error != null)
			throw error;
	}

	/*
	public uint32 generate_hash_value (string key, Memcached.Hash hash_algorithm = Memcached.Hash.DEFAULT)
	{
		return _context.generate_hash_value (key.data, hash_algorithm);
	}

	public uint32 generate_hash (string key)
	{
		return _context.generate_hash (key.data);
	}
	*/

	public void autoeject ()
	{
		_context.autoeject ();
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

	public void server_cursor (owned Memcached.ServerCallback callback)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.server_cursor (callback));
	}

	public unowned Memcached.Instance? server_by_key (string key)
		throws MemcachedGLib.Error
	{
		Memcached.ReturnCode return_code;
		unowned Memcached.Instance ret = _context.server_by_key (key.data, out return_code);
		_handle_return_code (return_code);
		return ret;
	}

	public unowned Memcached.Instance? server_get_last_disconnect ()
	{
		return _context.server_get_last_disconnect ();
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

	public Memcached.Stat? stat (string args)
		throws MemcachedGLib.Error
	{
		//Memcached.ReturnCode return_code;
		Memcached.Stat ret = {};//_context.stat (args, out return_code);
		//_handle_return_code (return_code);
		return ret;
	}

	public async Memcached.Stat? stat_async (string args, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		return stat (args);
	}

	public string stat_get_value (Memcached.Stat memc_stat, string key)
		throws MemcachedGLib.Error
	{
		Memcached.ReturnCode return_code;
		var ret = _context.stat_get_value (memc_stat, key, out return_code);
		_handle_return_code (return_code);
		return ret;
	}

	public string[] stat_get_keys (Memcached.Stat memc_stat)
		throws MemcachedGLib.Error
	{
		Memcached.ReturnCode return_code;
		var ret = _context.stat_get_keys (memc_stat, out return_code);
		_handle_return_code (return_code);
		return ret;
	}

	public void stat_execute (string args, owned Memcached.StatCallback callback)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.stat_execute (args, callback));
	}

	public async void stat_execute_async (owned string                 args,
	                                      owned Memcached.StatCallback callback,
	                                      int                          priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		MemcachedGLib.Error error = null;
		IOSchedulerJob.push ((job) =>
		{
			try
			{
				stat_execute (args, (owned) callback);
			}
			catch (MemcachedGLib.Error _error)
			{
				error = _error;
			}
			finally
			{
				job.send_to_mainloop_async (stat_execute_async.callback);
			}
			return false;
		}, priority);
		yield;
		if (error != null)
			throw error;
	}

	public new void @set (string key, uint8[] @value, TimeSpan expiration = 0, uint32 flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@set (key.data, @value, (time_t) (expiration / TimeSpan.SECOND), flags));
	}

	/**
	 * @see MemcachedGLib.Context.set
	 */
	public async void set_async (string   key,
	                             uint8[]  @value,
	                             TimeSpan expiration = 0,
	                             uint32   flags      = 0,
	                             int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		@set (key, @value, expiration, flags);
	}

	public new void add (string key, uint8[] @value, TimeSpan expiration = 0, uint32 flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.add (key.data, @value, (time_t) (expiration / TimeSpan.SECOND), flags));
	}

	/**
	 * @see MemcachedGLib.Context.add
	 */
	public async void add_async (string   key,
	                             uint8[]  @value,
	                             TimeSpan expiration = 0,
	                             uint32   flags      = 0,
	                             int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		add (key, @value, expiration, flags);
	}

	public new void replace (string key, uint8[] @value, TimeSpan expiration = 0, uint32 flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.replace (key.data, @value, (time_t) (expiration / TimeSpan.SECOND), flags));
	}

	/**
	 * @see MemcachedGLib.Context.replace
	 */
	public async void replace_async (string   key,
	                                 uint8[]  @value,
	                                 TimeSpan expiration = 0,
	                                 uint32   flags      = 0,
	                                 int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		replace (key, @value, expiration, flags);
	}

	public new void append (string key, uint8[] @value, TimeSpan expiration = 0, uint32 flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.append (key.data, @value, (time_t) (expiration / TimeSpan.SECOND), flags));
	}

	/**
	 * @see MemcachedGLib.Context.append
	 */
	public async void append_async (string   key,
	                                uint8[]  @value,
	                                TimeSpan expiration = 0,
	                                uint32   flags      = 0,
	                                int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		append (key, @value, expiration, flags);
	}

	public new void prepend (string key, uint8[] @value, TimeSpan expiration = 0, uint32 flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@prepend (key.data, @value, (time_t) (expiration / TimeSpan.SECOND), flags));
	}

	/**
	 * @see MemcachedGLib.Context.prepend
	 */
	public async void prepend_async (string   key,
	                                 uint8[]  @value,
	                                 TimeSpan expiration = 0,
	                                 uint32   flags      = 0,
	                                 int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		@prepend (key, @value, expiration, flags);
	}

	public void cas (string key, uint8[] @value, uint64 cas, TimeSpan expiration = 0, uint32 flags = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.cas (key.data, @value, (time_t) (expiration / TimeSpan.SECOND), flags, cas));
	}

	/**
	 * @see MemcachedGLib.Context.cas
	 */
	public async void cas_async (string   key,
	                             uint8[]  @value,
	                             uint64   cas,
	                             TimeSpan expiration = 0,
	                             uint32   flags      = 0,
	                             int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		this.cas (key, @value, cas, expiration, flags);
	}

	/**
	 *
	 */
	public void set_by_key (string   group_key,
	                        string   key,
	                        uint8[]  @value,
	                        TimeSpan expiration = 0,
	                        uint32   flags      = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.@set_by_key (group_key.data,
		                                           key.data,
					                               @value,
					                               (time_t) (expiration / TimeSpan.SECOND),
					                               flags));
	}

	/**
	 * @see MemcachedGLib.Context.@set_by_key
	 */
	public async void set_by_key_async (string   group_key,
	                                    string   key,
	                                    uint8[]  @value,
	                                    TimeSpan expiration = 0,
	                                    uint32   flags      = 0,
	                                    int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		set_by_key (group_key, key, @value, expiration, flags);
	}

	/**
	 *
	 */
	public void add_by_key (string   group_key,
	                        string   key,
	                        uint8[]  @value,
	                        TimeSpan expiration = 0,
	                        uint32   flags      = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.add_by_key (group_key.data,
		                                          key.data,
		                                          @value,
		                                          (time_t) (expiration / TimeSpan.SECOND),
		                                          flags));
	}

	/**
	 * @see MemcachedGLib.Context.add_by_key
	 */
	public async void add_by_key_async (string   group_key,
	                                    string   key,
	                                    uint8[]  @value,
	                                    TimeSpan expiration = 0,
	                                    uint8    flags      = 0,
	                                    int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		add_by_key (group_key, key, @value, expiration, flags);
	}

	/**
	 *
	 */
	public void append_by_key (string   group_key,
	                           string   key,
	                           uint8[]  @value,
	                           TimeSpan expiration = 0,
	                           uint32   flags      = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.append_by_key (group_key.data,
		                                             key.data,
		                                             @value,
		                                             (time_t) (expiration / TimeSpan.SECOND),
		                                             flags));
	}

	/**
	 * @see MemcachedGLib.Context.append_by_key
	 */
	public async void append_by_key_async (string   group_key,
	                                       string   key,
	                                       uint8[]  @value,
	                                       TimeSpan expiration = 0,
	                                       uint8    flags      = 0,
	                                       int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		append_by_key (group_key, key, @value, expiration, flags);
	}

	/**
	 *
	 */
	public void prepend_by_key (string   group_key,
	                            string   key,
	                            uint8[]  @value,
	                            TimeSpan expiration = 0,
	                            uint32   flags      = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.prepend_by_key (group_key.data,
		                                              key.data,
		                                              @value,
		                                              (time_t) (expiration / TimeSpan.SECOND),
		                                              flags));
	}

	/**
	 * @see MemcachedGLib.Context.prepend_by_key
	 */
	public async void prepend_by_key_async (string   group_key,
	                                        string   key,
	                                        uint8[]  @value,
	                                        TimeSpan expiration = 0,
	                                        uint8    flags      = 0,
	                                        int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		prepend_by_key (group_key, key, @value, expiration, flags);
	}

	public void cas_by_key (string   group_key,
	                        string   key,
	                        uint8[]  @value,
	                        uint64   cas,
	                        TimeSpan expiration = 0,
	                        uint32   flags      = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.cas_by_key (group_key.data,
		                                          key.data,
		                                          @value,
		                                          (time_t) (expiration / TimeSpan.SECOND),
		                                          flags,
		                                          cas));
	}

	/**
	 * @see MemcachedGLib.Context.cas_by_key
	 */
	public async void cas_by_key_async (string   group_key,
	                                    string   key,
	                                    uint8[]  @value,
	                                    uint64   cas,
	                                    TimeSpan expiration = 0,
	                                    uint32   flags      = 0,
	                                    int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		cas_by_key (group_key, key, @value, cas, expiration, flags);
	}

	public void touch (string key, TimeSpan expiration = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.touch (key.data, (time_t) (expiration / TimeSpan.SECOND)));
	}

	public async void touch_async (string key, TimeSpan expiration = 0, int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		touch (key, expiration);
	}

	public void touch_by_key (string group_key, string key, TimeSpan expiration = 0)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.touch_by_key (group_key.data, key.data, (time_t) (expiration / TimeSpan.SECOND)));
	}

	public async void touch_by_key_async (string   group_key,
	                                      string   key,
	                                      TimeSpan expiration = 0,
	                                      int      priority   = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		touch_by_key (group_key, key, expiration);
	}

	public void quit ()
	{
		_context.quit ();
	}

	public void verbosity (uint32 verbosity)
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.verbosity (verbosity));
	}

	public void version ()
		throws MemcachedGLib.Error
	{
		_handle_return_code (_context.version ());
	}

	public async void version_async (int priority = GLib.Priority.DEFAULT)
		throws MemcachedGLib.Error
	{
		yield _wait_for_condition_async (priority);
		version ();
	}
}
