using GLib;
using MemcachedGLib;

public int main (string[] args)
{
	Test.init (ref args);

	Test.add_func ("/context", () =>
	{
		var ctx = new Context.from_configuration ("--SERVER=localhost:11211");

		try
		{
			ctx.@set ("somekey", "some value".data, 0, 27);
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}

		try
		{
			uint32 flags;
			assert ("some value" == (string) ctx.@get ("somekey", out flags));
			assert (27 == flags);
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}

		try
		{
			ctx.@delete ("somekey");
		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}

		try {
			ctx.@get ("somekey");
			assert_not_reached ();
		}
		catch (MemcachedGLib.Error.NOTFOUND err)
		{

		}
		catch (MemcachedGLib.Error err)
		{
			assert_not_reached ();
		}
	});

	Test.add_func ("/context/async", () =>
	{
	/*
		var ctx     = new Context.from_configuration ("--SERVER=localhost");
		var reached = false;
		var loop    = new MainLoop ();

		ctx.@set_async.begin ("some key", "some value".data, 0, 0);

		, (obj, result) =>
		{
			try
			{
				ctx.@set_async.end (result);
			}
			catch (MemcachedGLib.Error err)
			{
				assert_not_reached ();
			}

			ctx.@get_async.begin ("some key", Priority.DEFAULT, (obj, result) =>
			{
				uint32 flags;
				ctx.@get_async.end (result, out flags);
				assert ("some value" == (string) data);
				assert (27 == flags);
				reached = true;
				loop.quit ();
			});
		});

		loop.run ();

		assert (reached);

*/
	});

	return Test.run ();
}
