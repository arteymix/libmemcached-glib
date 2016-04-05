using GLib;
using MemcachedGLib;

public int main (string[] args)
{
	Test.init (ref args);

	Test.add_func ("/context", () =>
	{
		try
		{
			var ctx = new Context.from_configuration ("--SERVER=localhost:11211");

			ctx.@set ("somekey", "some value".data, 0, 27);

			uint32 flags;
			assert ("some value" == (string) ctx.@get ("somekey", out flags));
			assert (27 == flags);

			ctx.@delete ("somekey");

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

	Test.add_func ("/context/async", () =>
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

	return Test.run ();
}
