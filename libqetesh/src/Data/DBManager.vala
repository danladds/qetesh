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
	 * DB access manager
	 * 
	 * Establishes and stores a set of database connections
	 * Operates at the server level
	**/ 
	public class DBManager : GLib.Object {
		
		private WebServerContext context;

		internal Gee.TreeMap<string?, QDatabase> DBs { get; private set; }
		
		/**
		 * Initialise a DB manager and connect to databases
		 * 
		 * @param conf Config to get connection data from
		**/ 
		public DBManager (WebServerContext sc) {
			
			context = sc;
			DBs = new Gee.TreeMap<string?, QDatabase>();
			
			// Test connections before adding
			foreach (var dbConf in context.Configuration.Databases) {
				
				QDatabase db;
				QDatabaseConn conn;
				
				if (dbConf.Connector == "MySQL") {
					
					db = new QMysqlDB(dbConf, context);
				
				
					context.Err.WriteMessage("Attempting to connect to database: %s".printf(dbConf.Nick), ErrorManager.QErrorClass.QETESH_DEBUG);
				
					try {
						conn = db.Connect();
						if (conn.IsConnected) DBs.set(dbConf.Nick, db);
					} catch (Qetesh.Data.QDBError e) {
						context.Err.WriteMessage("Failed to connect to database: %s".printf(dbConf.Nick), ErrorManager.QErrorClass.MODULE_ERROR);
					}
				
				}
				else {
					
					context.Err.WriteMessage("No valid connector for %s found".printf(dbConf.Connector), ErrorManager.QErrorClass.QETESH_DEBUG);
				}
			}
		}
	}
}
