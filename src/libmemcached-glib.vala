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

namespace MemcachedGLib
{
	public delegate void ExecuteCallback (Memcached.Result result) throws MemcachedGLib.Error;

	public delegate void ServerCallback (Memcached.Instance server) throws MemcachedGLib.Error;

	public delegate void StatCallback (string key, uint8[] @value) throws MemcachedGLib.Error;

	public delegate void DumpCallback (string key) throws MemcachedGLib.Error;
}
