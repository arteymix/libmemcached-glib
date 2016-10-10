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
 * Source that emit whenever a {@link Memcached.Context} is ready to receive
 * an operation.
 *
 * To perform more complex I/O, see {@link GLib.IOSchedulerJob}.
 */
public class GMemcached.ContextSource : Source
{
	internal unowned Memcached.Context _context;

	public ContextSource (Memcached.Context context)
	{
		_context = context;
	}

	public override bool prepare (out int timeout)
	{
		timeout = -1;
		for (int i = 0; i < _context.server_count (); i++)
		{
			unowned Memcached.Instance instance = _context.server_instance_by_position (i);
			int fd = ((int[]) instance)[5]; // warning: dirty hack! (see 'instance.hpp')
			if (fd > 0)
			{
				add_unix_fd (fd, IOCondition.OUT);
			}
		}
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

