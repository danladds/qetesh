/*
 * QMysqlQuery.vala
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

	public class QMysqlQuery : QDataQuery {
		
		protected QMysqlConn db { get; set; }
		
		protected StringBuilder sql;
		
		private string tableName { get; set; }
		
		private Gee.LinkedList<MysqlQueryParam> whereParams { get; set; }
		private Gee.LinkedList<MysqlQueryParam> setParams { get; set; }
		
		private string baseQuery { get; set; }
		
		private enum QueryType {
			INSERT,
			SELECT,
			UPDATE,
			DELETE,
			COUNT
		}
		
		private QueryType queryType { get; set; }
		
		public QMysqlQuery(QMysqlConn conn) {
			
			db = conn;
			sql = new StringBuilder();
			whereParams = new Gee.LinkedList<MysqlQueryParam>();
			setParams = new Gee.LinkedList<MysqlQueryParam>();
		}
		
		public override QDataQuery DataSet(string setName) {
			
			tableName = setName;
			return this;
		}
		
		public override QDataQuery Create() {
			
			baseQuery = "INSERT INTO `s` ";
			queryType = QueryType.INSERT;
			return this;
		}
		
		public override QDataQuery Read() {
			
			baseQuery = "SELECT * FROM `%s` ";
			queryType = QueryType.SELECT;
			return this;
		}
		
		public override QDataQuery Update() {
			
			baseQuery = "UPDATE `%s` SET ";
			queryType = QueryType.UPDATE;
			return this;
		}
		
		public override QDataQuery Delete() {
			
			baseQuery = "DELETE FROM `%s` ";
			queryType = QueryType.DELETE;
			return this;
		}
		
		public override QDataQuery Count() {
			baseQuery = "SELECT COUNT(*) FROM `%s` ";
			queryType = QueryType.COUNT;
			return this;
		}
		
		public override QDataQuery.QueryResult Do() {

			return (QDataQuery.QueryResult) new MysqlQueryResult (Fetch());
		}
		
		public override int DoInt() {
			
			var rSet = Fetch();
			
			if(queryType == QueryType.INSERT) {
				
				return db._lastInsertId;
			}
			else {
			
				return int.parse(rSet[0]["COUNT(*)"]);
			}
		}
		
		public override QDataQuery.QueryParam Where(string fieldName) {
			
			var param = new MysqlQueryParam(fieldName, db);
			whereParams.add(param);
			
			return (QDataQuery.QueryParam) param;
		}
		
		public override QDataQuery.QueryParam Set(string fieldName) {
			
			var param = new MysqlQueryParam(fieldName, db);
			setParams.add(param);
			
			return (QDataQuery.QueryParam) param;
		}
		
		protected override Gee.LinkedList<Gee.TreeMap<string, string>> Fetch() {
			
			sql.append(baseQuery.printf(tableName));
			
			if(queryType == QueryType.INSERT || queryType == QueryType.UPDATE) {
				
				var n = 0;
				
				if (setParams.size < 1) {
					
					throw new QDBError.QUERY("Cannot perform insert or update with no parameters");
				}
				
				foreach (var param in setParams) {
					
					sql.append("`%s`.%s".printf(tableName, param.getQueryText()));
					if (++n != setParams.size) sql.append(", ");
				}
			}
			
			if(queryType != QueryType.INSERT) {
				
				if (whereParams.size > 0) {
					sql.append(" WHERE ");
				}
				
				var i = 0;
				
				foreach (var param in whereParams) {
					
					sql.append(param.getQueryText());
					if (++i != whereParams.size) sql.append(", AND ");
				}
			}
			
			if(queryType == QueryType.DELETE) {
				
				sql.append(" LIMIT 1");
			}
			
			return db.DirectQuery(sql.str);
		}
		
		public class MysqlQueryParam : QDataQuery.QueryParam {
			
			private QMysqlConn db;
			
			public override QDataQuery.QueryParam Equal(string val) {
				
				FieldValue = val;
				FieldComparator = "=";
				return this;
			}
			
			public override QDataQuery.QueryParam Like(string val) {
				
				FieldValue = val;
				FieldComparator = "LIKE";
				return this;
			}
			
			public override QDataQuery.QueryParam GreaterThan(string val) {
				
				FieldValue = val;
				FieldComparator = ">";
				return this;
			}
			
			public override QDataQuery.QueryParam LessThan(string val) {
				
				FieldValue = val;
				FieldComparator = "<";
				return this;
			}
			
			public string FieldName { get; private set; }
			public string FieldValue { get; private set; }
			public string FieldComparator { get; private set; }
			
			internal MysqlQueryParam(string fieldName, QMysqlConn dbh) {
				
				FieldName = fieldName;
				db = dbh;
			}
			
			internal string getQueryText() {
				
				string encVal = "";
				
				db.db.real_escape_string(encVal, FieldValue, FieldValue.length);
				
				return "`%s` %s \"%s\"".printf(FieldName, FieldComparator, encVal);
			}
		}
		
		public class MysqlQueryResult : QDataQuery.QueryResult {
			
			internal MysqlQueryResult (Gee.LinkedList<Gee.TreeMap<string, string>> items) {
				
				Items = items;
			}
			
			public override Gee.LinkedList<Gee.TreeMap<string, string>> Items { get; protected set; }
		}
	}
}
