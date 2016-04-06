using GLib;
using MemcachedGLib;

public int main (string[] args)
{
	var ctx = new Context.from_configuration ("--SERVER=localhost:11211");

	for (int i = 0; i < 20000; i++)
		ctx.@set (i.to_string (), new Variant.@int32 (i).get_data_as_bytes ().get_data ());

	for (int i = 0; i < 20000; i++)
		ctx.@get (i.to_string ());

	return 0;
}

