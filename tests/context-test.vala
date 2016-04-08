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
using MemcachedGLib;

public int main (string[] args)
{
	Test.init (ref args);

	Test.add_func ("/basic", () =>
	{
		try
		{
			var ctx = new Context.from_configuration ("--SERVER=localhost:11211");

			ctx.@set ("somekey", "some value".data, 0, 27);

			assert (ctx.exist ("somekey"));

			uint32 flags;
			assert ("some value" == (string) ctx.@get ("somekey", out flags));
			assert (27 == flags);

			ctx.@delete ("somekey");

			assert (!ctx.exist ("somekey"));

			try
			{
				ctx.@get ("somekey");
				assert_not_reached ();
			}
			catch (MemcachedGLib.Error.NOTFOUND err)
			{

			}
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}
	});

	Test.add_func ("/mget", () =>
	{
		try
		{
			var ctx = new Context.from_configuration ("--SERVER=localhost:11211");

			ctx.set ("a", "1".data, 0);
			ctx.set ("ab", "2".data, 0);
			ctx.set ("abc", "3".data, 0);

			ctx.mget ({"a", "ab", "abc"});

			assert ("1" == (string) ctx.fetch_result ().value ());
			assert ("2" == (string) ctx.fetch_result ().value ());
			assert ("3" == (string) ctx.fetch_result ().value ());
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}
	});

	Test.add_func ("/mget_execute", () =>
	{
		try
		{
			var ctx = new Context.from_configuration ("--SERVER=localhost:11211");

			ctx.behavior_set (Memcached.Behavior.BINARY_PROTOCOL, 1);

			ctx.set ("a", "1".data, 0);
			ctx.set ("ab", "2".data, 0);
			ctx.set ("abc", "3".data, 0);

			var pass = 0;
			ctx.mget_execute ({"a", "ab", "abc"}, (result) =>
			{
				pass++;
			});

			assert (3 == pass);
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}
	});

	Test.add_func ("/mget_execute_async", () =>
	{
		var loop = new MainLoop ();
		try
		{
			var ctx = new Context.from_configuration ("--SERVER=localhost:11211");

			ctx.set ("a", "1".data, 0);
			ctx.set ("ab", "2".data, 0);
			ctx.set ("abc", "3".data, 0);

			ctx.mget_execute_async.begin ({"a", "ab", "abc"},
			                              (result) => {},
			                              GLib.Priority.DEFAULT,
			                              (obj, result) =>
			{
				try
				{
					ctx.mget_execute_async.end (result);
				}
				catch (MemcachedGLib.Error err)
				{
					assert_not_reached ();
				}
				finally
				{
					loop.quit ();
				}
			});
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}

		loop.run ();
	});

	Test.add_func ("/async", () =>
	{
		try
		{
			var ctx  = new Context.from_configuration ("--SERVER=localhost");
			var loop = new MainLoop ();

			ctx.@set_async.begin ("somekey", "some value".data, 0, 27, Priority.DEFAULT, (obj, result) =>
			{
				try
				{
					ctx.@set_async.end (result);
				}
				catch (MemcachedGLib.Error err)
				{
					assert_not_reached ();
				}

				ctx.@get_async.begin ("somekey", Priority.DEFAULT, (obj, result) =>
				{
					uint32 flags;
					try
					{
						var data = ctx.@get_async.end (result, out flags);
						assert ("some value" == (string) data);
						assert (27 == flags);
					}
					catch (MemcachedGLib.Error err)
					{
						assert_not_reached ();
					}
					finally
					{
						loop.quit ();
					}
				});
			});

			loop.run ();
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}
	});

	Test.add_func ("/dump", () => {
		try
		{
			var ctx = new MemcachedGLib.Context.from_configuration ("--SERVER=localhost:11211");

			ctx.set ("a", "b".data);

			ctx.dump ((key) => {});
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}
	});

	Test.add_func ("/server_cursor", () =>
	{
		try
		{
			var ctx = new MemcachedGLib.Context.from_configuration ("--SERVER=localhost");

			ctx.server_cursor ((ctx, instance) => {
				assert ("localhost" == instance.name ());
				return Memcached.ReturnCode.SUCCESS;
			});
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}
	});

	return Test.run ();
}
