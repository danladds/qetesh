/*
 * DBManager.vala
 * 
 * Manages database connections and IO
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

namespace Qetesh.Data {
	
	/**
	 * Data access system
	 * 
	 * Operates at the request level
	**/ 
	public class DataManager : GLib.Object {
		
		private Gee.TreeMap<string, QDatabaseConn> handles { get; private set; }
		private DBManager manager;

		public DataManager(DBManager dbm) {
			
			handles = new Gee.TreeMap<string, QDatabaseConn>();
			manager = dbm;
		}
		
		public QDatabaseConn GetConnection(string dbNick) throws Qetesh.Data.QDBError {
			
			if (handles.has_key(dbNick)) {
				
				return handles[dbNick];
			}
			
			else {
				
				if (!manager.DBs.has_key(dbNick))
					throw new QDBError.CONNECT("Unable to find a database with nickname %s".printf(dbNick));
					
				var conn = manager.DBs[dbNick].Connect();
				handles.set(dbNick, conn);
					
				return conn;
				
			}
		}
	}
}
