
using MemcachedGLib;

public int main (string[] args)
{
	var ctx           = new Context.from_configuration ("--SERVER=localhost");
	var loop          = new MainLoop ();
	var remaining_ops = 20000;

	ctx.behavior_set (Memcached.Behavior.NO_BLOCK, 1);
	ctx.behavior_set (Memcached.Behavior.BINARY_PROTOCOL , 1);

	for (int i = 0; i < 10000; i++)
	{
		ctx.set_async.begin (i.to_string (), i.to_string ().data, Priority.DEFAULT, 0, 0, (_, result) => {
			ctx.set_async.end (result);
			if (--remaining_ops == 0)
				loop.quit ();
		});
	}

	for (int i = 0; i < 10000; i++)
	{
		ctx.get_async.begin (i.to_string (), Priority.DEFAULT, (_, result) => {
			ctx.get_async.end (result);
			if (--remaining_ops == 0)
				loop.quit ();
		});
	}

	loop.run ();

	return 0;
}
