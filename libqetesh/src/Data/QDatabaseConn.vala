/*
 * QMysqlDB.vala
 * 
 * Copyright 2014 Dan Ladds <Dan@el-topo.co.uk>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */


using Qetesh;
using Mysql;

namespace Qetesh.Data {
	
	public abstract class QDatabaseConn {

		public abstract Gee.LinkedList<Gee.TreeMap<string?, string?>>? DirectQuery(string qText) throws QDBError;
		
		public abstract void Connect () throws QDBError;

		public bool IsConnected { get; protected set; }
		
		public abstract QDataQuery NewQuery();
		
	}
}
