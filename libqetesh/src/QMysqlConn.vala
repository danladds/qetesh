
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
	
	class QMysqlConn : QDatabaseConn {
		
		private ConfigFile.DBConfig conf;
		private WebServerContext context;
		private Mysql.Database db;
		
		public QMysqlConn (ConfigFile.DBConfig config, WebServerContext sc) {
			
			conf = config;
			context = sc;
		}

		public override void Connect() throws QDBError {
			
			db = new Mysql.Database();
			
			var connected = db.real_connect(
				conf.Host,
				conf.Username,
				conf.Password,
				conf.DBName,
				conf.Port
			);
			
			if (!connected) {
				context.Err.WriteMessage("Unable to connect to database: %s (%s)".printf(conf.Nick, db.error()), ErrorManager.QErrorClass.QETESH_WARNING);
				
				context.Err.WriteMessage("(details) Host: %s, Username: %s, DBName: %s, Port: %d".printf(conf.Host, conf.Username, conf.DBName, conf.Port), ErrorManager.QErrorClass.QETESH_WARNING);
			}
			else {
				IsConnected = true;
			}
		}
		
		public override Gee.LinkedList<Gee.TreeMap<string?, string?>>? Q(string qText) throws QDBError {
			
			context.Err.WriteMessage("MySQL Connector attempting query: %s".printf(qText), ErrorManager.QErrorClass.QETESH_DEBUG);
			
			var resultStatus = db.query(qText);
			var result = new Gee.LinkedList<Gee.TreeMap<string?, string?>>();
			
			if (resultStatus != 0) {
				
				throw new QDBError.QUERY("MySQL error performing query: %s; %s".printf(qText, db.error()));
			}
			
			Result res = db.use_result();
			
			var fieldList = new Gee.LinkedList<string>();
			
			foreach (var fld in res.fetch_fields()) {
				
				fieldList.add(fld.name);
			}
			
			while (true) {
				
				var row = res.fetch_row();
				if (row == null) break;
				
				var hash = new Gee.TreeMap<string?, string?>();
				
				for (int x = 0; x < fieldList.size; ++x) {
					
					hash.set(fieldList[x], row[x]);
				}
				
				result.add(hash);
			}
			
			return result;
		}
	}
}
