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

/**
 * Simple {@link GLib.Source} to setup polling on a {@link Memcached.Context}
 * for a set of I/O conditions.
 */
public class MemcachedGLib.ContextSource : Source
{
	public ContextSource (Memcached.Context context, IOCondition condition)
	{
		for (int i = 0; i < context.server_count (); i++)
		{
			unowned Memcached.Instance instance = context.server_instance_by_position (i);
			int fd = ((int[]) instance)[5]; // warning: dirty hack! (see 'instance.hpp')
			if (fd > 0)
			{
				add_unix_fd (fd, condition);
			}
		}
	}

	public override bool prepare (out int timeout)
	{
		timeout = -1;
		return false;
	}

	public override bool check ()
	{
		return true;
	}

	public override bool dispatch (SourceFunc callback)
	{
		return callback ();
	}
}

