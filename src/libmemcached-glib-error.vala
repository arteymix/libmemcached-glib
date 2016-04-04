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

public errordomain MemcachedGLib.Error
{
    SUCCESS                          = Memcached.ReturnCode.SUCCESS,
    FAILURE                          = Memcached.ReturnCode.FAILURE,
    HOST_LOOKUP_FAILURE              = Memcached.ReturnCode.HOST_LOOKUP_FAILURE,
    CONNECTION_FAILURE               = Memcached.ReturnCode.CONNECTION_FAILURE,
    WRITE_FAILURE                    = Memcached.ReturnCode.WRITE_FAILURE,
    READ_FAILURE                     = Memcached.ReturnCode.READ_FAILURE,
    UNKNOWN_READ_FAILURE             = Memcached.ReturnCode.UNKNOWN_READ_FAILURE,
    PROTOCOL_ERROR                   = Memcached.ReturnCode.PROTOCOL_ERROR,
    CLIENT_ERROR                     = Memcached.ReturnCode.CLIENT_ERROR,
    SERVER_ERROR                     = Memcached.ReturnCode.SERVER_ERROR,
    DATA_EXISTS                      = Memcached.ReturnCode.DATA_EXISTS,
    DATA_DOES_NOT_EXIST              = Memcached.ReturnCode.DATA_DOES_NOT_EXIST,
    NOTSTORED                        = Memcached.ReturnCode.NOTSTORED,
    STORED                           = Memcached.ReturnCode.STORED,
    NOTFOUND                         = Memcached.ReturnCode.NOTFOUND,
    MEMORY_ALLOCATION_FAILURE        = Memcached.ReturnCode.MEMORY_ALLOCATION_FAILURE,
    PARTIAL_READ                     = Memcached.ReturnCode.PARTIAL_READ,
    SOME_ERRORS                      = Memcached.ReturnCode.SOME_ERRORS,
    NO_SERVERS                       = Memcached.ReturnCode.NO_SERVERS,
    END                              = Memcached.ReturnCode.END,
    DELETED                          = Memcached.ReturnCode.DELETED,
    VALUE                            = Memcached.ReturnCode.VALUE,
    STAT                             = Memcached.ReturnCode.STAT,
    ITEM                             = Memcached.ReturnCode.ITEM,
    ERRNO                            = Memcached.ReturnCode.ERRNO,
    NOT_SUPPORTED                    = Memcached.ReturnCode.NOT_SUPPORTED,
    FETCH_NOTFINISHED                = Memcached.ReturnCode.FETCH_NOTFINISHED,
    TIMEOUT                          = Memcached.ReturnCode.TIMEOUT,
    BUFFERED                         = Memcached.ReturnCode.BUFFERED,
    BAD_KEY_PROVIDED                 = Memcached.ReturnCode.BAD_KEY_PROVIDED,
    INVALID_HOST_PROTOCOL            = Memcached.ReturnCode.INVALID_HOST_PROTOCOL,
    SERVER_MARKED_DEAD               = Memcached.ReturnCode.SERVER_MARKED_DEAD,
    UNKNOWN_STAT_KEY                 = Memcached.ReturnCode.UNKNOWN_STAT_KEY,
    E2BIG                            = Memcached.ReturnCode.E2BIG,
    INVALID_ARGUMENTS                = Memcached.ReturnCode.INVALID_ARGUMENTS,
    KEY_TOO_BIG                      = Memcached.ReturnCode.KEY_TOO_BIG,
    AUTH_PROBLEM                     = Memcached.ReturnCode.AUTH_PROBLEM,
    AUTH_FAILURE                     = Memcached.ReturnCode.AUTH_FAILURE,
    AUTH_CONTINUE                    = Memcached.ReturnCode.AUTH_CONTINUE,
    PARSE_ERROR                      = Memcached.ReturnCode.PARSE_ERROR,
    PARSE_USER_ERROR                 = Memcached.ReturnCode.PARSE_USER_ERROR,
    DEPRECATED                       = Memcached.ReturnCode.DEPRECATED,
    IN_PROGRESS                      = Memcached.ReturnCode.IN_PROGRESS,
    SERVER_TEMPORARILY_DISABLED      = Memcached.ReturnCode.SERVER_TEMPORARILY_DISABLED,
    SERVER_MEMORY_ALLOCATION_FAILURE = Memcached.ReturnCode.SERVER_MEMORY_ALLOCATION_FAILURE,
    MAXIMUM_RETURN                   = Memcached.ReturnCode.MAXIMUM_RETURN
}
