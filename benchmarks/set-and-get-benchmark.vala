using GMemcached;

public int main (string[] args)
{
	var ctx = new Context.from_configuration ("--SERVER=localhost");

	ctx.behavior_set (Memcached.Behavior.NO_BLOCK, 1);
	ctx.behavior_set (Memcached.Behavior.BINARY_PROTOCOL , 1);

	for (int i = 0; i < 10000; i++)
	{
		ctx.@set (i.to_string (), i.to_string ().data);
	}

	for (int i = 0; i < 10000; i++)
	{
		ctx.@get (i.to_string ());
	}

	return 0;
}
