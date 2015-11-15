/*
 * DataObject.vala
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

	public class DataObject<TImp> : GLib.Object {
		
		private QDatabaseConn db;
		
		// ID map for lazy loading - stores 
		// ID values for objects to lazy load on access
		private Gee.HashMap<string, int> IdMap;
		
		protected string TableName { get; set; }
		
		protected Gee.LinkedList<LinkInfo> Links { get; private set; }
		
		private string _queryTarget;
		protected string QueryTarget { 
			
			get {
				
				if (_queryTarget != null &&
					_queryTarget != "") {
				
					return _queryTarget;
				}
				
				var tName = new StringBuilder();
				
				tName.append_printf("`%s`", TableName);
				
				
				foreach(LinkInfo li in Links) {
					
					tName.append_printf(
						", `%s`", 						
						li.ParentTableName
					);
				}
				
				tName.append(" WHERE 1");
				
				foreach(LinkInfo li in Links) {
					
					tName.append_printf(
						" AND `%s`.`%s` = `%s`.`%s`",
						li.ParentTableName,
						li.ParentTableKey,
						li.LocalTableName,
						li.LocalTableKey
					);
				}
				
				_queryTarget = tName.str;
				
				return _queryTarget;
			}
			private set {
				
				_queryTarget = value;
			} 
		}
		
		public DataObject (QDatabaseConn dbh) {
			
			db = dbh;
			IdMap = new Gee.HashMap<string, int>();
			
			// This can be added to by subclasses in their constructor
			// Will get added in reverse order, as subclasses should
			// be calling base() first
			Links = new Gee.LinkedList<LinkInfo>();
		}

		public void Create() {
			
		}
		
		public void Delete() {
			
		}
		
		public void Discard() {
			
			// Discard changes before they are saved; kill object
		}
		
		public Gee.LinkedList<TImp> Children { 
			
			get {
				return children;
			}
			
		}
		
		public Gee.LinkedList<TImp> Parents { 
			
			get {
				return parents;
			} 
			
		}
		
		private Gee.LinkedList<TImp> parents;
		private Gee.LinkedList<TImp> children;
		
		//public static Gee.ArrayList<DataObject> ReadTree() {
		//	
		//}
		
		// Why no Read or Update? Read is called (by ID) the first time
		// Id is set while another property is accessed.
		// Update is called on destruct if changes have been made and Id
		// is set
		
		// TODO: Latch onto Notify signal
		
		public Gee.LinkedList<TImp> LoadAll() throws Qetesh.Data.QDBError {
			
			Gee.LinkedList<DataObject> returnList;
			
			string sql = "SELECT * FROM %s".printf(QueryTarget);
			
			returnList = MapObjectList(db.Q(sql));
			
			return returnList;
		}
		
		public Gee.LinkedList<DataObject> MapObjectList(Gee.LinkedList<Gee.TreeMap<string?, string?>> rows) {
			
			Gee.LinkedList<DataObject> returnList = new Gee.LinkedList<DataObject>();
			
			foreach (var row in rows) {
				
				returnList.add(CreateObject(row));
			}
			
			return returnList;
		}
		
		public DataObject CreateObject(Gee.TreeMap<string?, string?> datum) {
			
			var obj = (DataObject) Object.new(this.get_type());
			
			obj.MapObject(datum);
			
			return obj;
		}
		
		/**
		 * Transform Vala property name into data source field name
		 * 
		 * By default, does nothing but return the original string.
		 * Can be overridden (use 'new') to apply a transformation
		 * to field names, e.g. to lower case
		**/
		protected virtual string NameTransform(string fieldName) {
			
			return fieldName;
		}
		
		public void MapObject(Gee.TreeMap<string?, string?> datum) {
			
			var classObj = (ObjectClass) this.get_type().class_ref();
			
			foreach (var prop in classObj.list_properties()) {

				string pName = prop.get_name();
				string tName = NameTransform(pName);
				Type propertyType = prop.value_type;
				
				if (datum.has_key(tName)) {
						
					if (propertyType == typeof(string)) {
						var val = Value(typeof(string));
						val.set_string(datum[tName]);
						this.set_property(pName, val);
					}
					
					else if (propertyType == typeof(int)) {
						var val = Value(typeof(int));
						val.set_int(int.parse(datum[tName]));
						this.set_property(pName, val);
					}
					
					else if (propertyType == typeof(bool)) {
						var val = Value(typeof(bool));
						val.set_boolean(bool.parse(datum[tName]));
						this.set_property(pName, val);
					}
					
					else if (propertyType == typeof(float)) {
						var val = Value(typeof(float));
						val.set_float((float) double.parse(datum[tName]));
						this.set_property(pName, val);
					}
					
					else if (propertyType == typeof(double)) {
						var val = Value(typeof(double));
						val.set_double(double.parse(datum[tName]));
						this.set_property(pName, val);
					}
					
					else if (propertyType.is_a(typeof(DateTime))) {
						
						// Todo: handle
					}
					
					else {
						
						if (propertyType.is_a(typeof(DataObject))) {
							
							IdMap.set(tName, int.parse(datum[tName]));
						}
					}
					
				}
			}
		}
		
		public delegate void DataNodeTransform(DataNode n);
		
		public DataNode ToNode(DataNodeTransform transform) {
			
			var classObj = (ObjectClass) this.get_type().class_ref();
			
			var dn = new DataNode(this.get_type().name());
			
			foreach (var prop in classObj.list_properties()) {
				
				string pName = prop.get_name();
				
				if(
					pName == "timp-type" ||
					pName == "timp-dup-func" ||
					pName == "timp-destroy-func" ||
					pName == "t-type" ||
					pName == "t-dup-func" ||
					pName == "t-destroy-func" ||
					pName == "QueryTarget" ||
					pName == "Links" ||
					pName == "TableName"
				){
					continue;
				}
				
				/// Todo - exclude all non-public fields
				
				Type propertyType = prop.value_type;
				
				var childNode = new DataNode(pName);
				childNode.Val = "null";
				
				if (propertyType == typeof(string)) {
						var val = Value(typeof(string));
						this.get_property(pName, ref val);
						childNode.Val = val.get_string();
					}
					
					else if (propertyType == typeof(int)) {
						var val = Value(typeof(int));
						this.get_property(pName, ref val);
						childNode.Val = val.get_int().to_string();
					}
					
					else if (propertyType == typeof(bool)) {
						var val = Value(typeof(bool));
						this.get_property(pName, ref val);
						childNode.Val = val.get_boolean().to_string();
					}
					
					else if (propertyType == typeof(float)) {
						var val = Value(typeof(float));
						this.get_property(pName, ref val);
						childNode.Val = val.get_float().to_string();
					}
					
					else if (propertyType == typeof(double)) {
						var val = Value(typeof(double));
						this.get_property(pName, ref val);
						childNode.Val = val.get_double().to_string();
					}
					
					else {
						
						if (propertyType.is_a(typeof(DataObject))) {
							
							// Don't lazy load
							// for automatic iterations
							// Risk of creating an infinite loop
							// if database references loop
							// Just provide ID instead
							// Client application can load by 
							// trivial access, or using lambda
							
						}
					}
					
					dn.Children.add(childNode);
				}
			
			transform(dn);
			
			return dn;
		}
		
		public void ExposeType (bool exposeAll, string[] whitelist = []) {
			
			
		}
		
		public class DataNode {
			
			public string Name { get; set; }
			public string Val { get; set; }
			public Gee.LinkedList<DataNode> Children { get; private set; }
			public bool IsArray { get; set; }
			
			public DataNode (string name = "Data", bool isArray = false) {
				
				IsArray = isArray;
				Name = name;
				Children = new Gee.LinkedList<DataNode>();
			}
		}
		
		public class LinkInfo {
			
			// Local table name is needed for cases
			// of multiple generations, since TableName is
			// always overridden by the most junior class
			public string ParentTableName { get; set; }
			public string ParentTableKey { get; set; }
			public string LocalTableName { get; set; }
			public string LocalTableKey { get; set; }
			
			public enum LinkJoinType {
				LEFT,
				INNER,
				OUTER,
				RIGHT;
			}
		}	
	}
}
