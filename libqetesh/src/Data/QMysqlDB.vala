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

	public class QMysqlDB : QDatabase {
		
		// For persistent connection
		private Gee.ConcurrentList<bool> connectionDipatched { get; set; }
		private Gee.ConcurrentList<QMysqlConn> connections { get; set; }
		
		public QMysqlDB (ConfigFile.DBConfig config, WebServerContext sc) {
			
			base(config, sc);
		}
		
		public override QDatabaseConn Connect() throws QDBError {
			
			var conn = new QMysqlConn(Conf, Context);
			conn.Connect();
			return conn;
		}
	}
}
