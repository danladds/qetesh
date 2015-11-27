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

	public abstract class DataObject<TImp> : GLib.Object {
		
		private QDatabaseConn db;
		
		// ID map for lazy loading (single objects)
		private Gee.HashMap<string, int> lazySingleMap;
		
		private Gee.HashMap<string, Gee.LinkedList<DataObject>> lazyCache;
		
		protected string TableName { get; set; }
		
		/// Primary key name
		public string PKeyName { get; protected set; default="Id"; }
		
		private Gee.LinkedList<InheritInfo> ClassParents { get; private set; }
		private Gee.LinkedList<LinkInfo> Links { get; private set; }
		
		private string _queryTarget;
		protected string QueryTarget { 
			
			get {
				
				if (_queryTarget != null &&
					_queryTarget != "") {
				
					return _queryTarget;
				}
				
				var tName = new StringBuilder();
				
				tName.append_printf("`%s`", TableName);
				
				
				foreach(InheritInfo li in ClassParents) {
					
					tName.append_printf(
						", `%s`", 						
						li.ParentTableName
					);
				}
				
				tName.append(" WHERE 1");
				
				foreach(InheritInfo li in ClassParents) {
					
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
			
			_init(dbh);
		}
		
		public abstract void Init ();
		
		internal void _init(QDatabaseConn dbh) {
		
			db = dbh;
			lazySingleMap = new Gee.HashMap<string, int>();
			lazyCache = new Gee.HashMap<string, Gee.LinkedList<DataObject>>();
			
			// Defaults
			TableName = this.get_type().to_string();
			PKeyName = "Id";
			
			// List of linked objects (i.e. joins in SQL)
			ClassParents = new Gee.LinkedList<InheritInfo>();
			Links = new Gee.LinkedList<LinkInfo>();
			
			Init();
		}

		public void Create() {
			
		}
		
		public void Delete() {
			
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
		
		internal string getPKeyStr() {
			
			return getPropStr(PKeyName);
		}
		
		internal void setPKeyStr(string val) {
			
			setPropStr(PKeyName, val);
			
		}
		
		internal string getPropStr(string propName) {
			
			var classObj = (ObjectClass) this.get_type().class_ref();
			
			var propSpec = classObj.find_property(propName);
			
			if (propSpec == null) return "";
			
			return _getPropStr(propName, propSpec.value_type);
		}
		
		private void setPropStr(string propName, string val) {
			
			var classObj = (ObjectClass) this.get_type().class_ref();
			
			var propSpec = classObj.find_property(propName);
			
			if (propSpec == null) return;
			
			_setPropStr(propName, val, propSpec.value_type);
		}
		
		private string _getPropStr(string pName, Type propertyType) {
			
			string strVal = "";
			
			if (propertyType == typeof(string)) {
				var val = Value(typeof(string));
				this.get_property(pName, ref val);
				strVal = val.get_string();
			}
			
			else if (propertyType == typeof(int)) {
				var val = Value(typeof(int));
				this.get_property(pName, ref val);
				strVal = val.get_int().to_string();
			}
			
			else if (propertyType == typeof(bool)) {
				var val = Value(typeof(bool));
				this.get_property(pName, ref val);
				strVal = val.get_boolean().to_string();
			}
			
			else if (propertyType == typeof(float)) {
				var val = Value(typeof(float));
				this.get_property(pName, ref val);
				strVal = val.get_float().to_string();
			}
			
			else if (propertyType == typeof(double)) {
				var val = Value(typeof(double));
				this.get_property(pName, ref val);
				strVal = val.get_double().to_string();
			}
			
			else if (propertyType.is_a(typeof(QDateTime))) {
				var val = Value(typeof(QDateTime));
				this.get_property(pName, ref val);
				var dObj = (QDateTime) val.get_object();
				strVal = dObj.toString();
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
			
			return strVal;
		}
		
		private void _setPropStr(string pName, string inVal, Type propertyType) {
			
			if (propertyType == typeof(string)) {
				var val = Value(typeof(string));
				val.set_string(inVal);
				this.set_property(pName, val);
			}
			
			else if (propertyType == typeof(int)) {
				var val = Value(typeof(int));
				val.set_int(int.parse(inVal));
				this.set_property(pName, val);
			}
			
			else if (propertyType == typeof(bool)) {
				var val = Value(typeof(bool));
				val.set_boolean(bool.parse(inVal));
				this.set_property(pName, val);
			}
			
			else if (propertyType == typeof(float)) {
				var val = Value(typeof(float));
				val.set_float((float) double.parse(inVal));
				this.set_property(pName, val);
			}
			
			else if (propertyType == typeof(double)) {
				var val = Value(typeof(double));
				val.set_double(double.parse(inVal));
				this.set_property(pName, val);
			}
			
			else if (propertyType.is_a(typeof(QDateTime))) {
				
				var dt = new QDateTime();
				dt.fromString(inVal);
				
				var val = Value(typeof(QDateTime));
				val.set_object((Object) dt);
				this.set_property(pName, val);
			}
			
			else {
				
				if (propertyType.is_a(typeof(DataObject))) {
					
					
				}
			}
		}
		
		//public static Gee.ArrayList<DataObject> ReadTree() {
		//	
		//}
		
		// Why no Read or Update? Read is called (by ID) the first time
		// Id is set while another property is accessed.
		// Update is called on destruct if changes have been made and Id
		// is set
		
		// TODO: Latch onto Notify signal
		
		public Gee.LinkedList<DataObject> LoadAll() throws Qetesh.Data.QDBError {
			
			Gee.LinkedList<DataObject> returnList;
			
			string sql = "SELECT * FROM %s".printf(QueryTarget);
			
			returnList = MapObjectList(db.Q(sql));
			
			return returnList;
		}
		
		internal Gee.LinkedList<DataObject> _lazyLoadList(string propertyName, Type fType) {
			return LazyLoadList(propertyName, fType);
		}
		
		/**
		 * Server side lazy loading
		 * 
		**/
		protected Gee.LinkedList<DataObject> LazyLoadList(string propertyName, Type fType) {
			
			var proto = (DataObject) Object.new(fType);
			proto._init(db);
			
			// Set criteron field, default first property of own type			
			var fClassObj = (ObjectClass) fType.class_ref();
			var fieldName = "";
			
			foreach (var prop in fClassObj.list_properties()) {
			
				if (prop.value_type.is_a(this.get_type())) {
					
					/// TODO: Error
					fieldName = prop.get_name();	
					break;
				}
			}
			
			var colName = proto.NameTransform(fieldName);
			
			Gee.LinkedList<DataObject> returnList;
			
			string sql = "SELECT * FROM %s AND `%s`.`%s` = %s".printf(
				proto.QueryTarget,
				proto.TableName,
				colName,
				getPKeyStr()
			);
			
			returnList = proto.MapObjectList(db.Q(sql));
			
			foreach(var obj in returnList) {
				
				var val = Value(typeof(Object));
				val.set_object(this);
				obj.set_property(fieldName, val);
			}
			
			return returnList;
		}
		
		/*
		protected DataObject LazyLoad(string propertyName) {
			
			
		}
		* */
		
		public void Load() {
			
			
			
			string sql = "SELECT * FROM %s AND `%s`.`%s` = %s".printf(
				QueryTarget,
				TableName,
				NameTransform(PKeyName),
				getPropStr(PKeyName)
			);
			
			var result = db.Q(sql);
			
			if (result.size == 0) {
				
				// Todo: throw exception
			}
			else {
			
				// Map into self
				MapObject(result[0]);
			}
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
			obj._init(db);
			
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
						
					_setPropStr(pName, datum[tName], propertyType);
					
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
				
				if(propertyType.is_a(typeof(Gee.AbstractList))) {
					
					continue;
				}
				
				var childNode = new DataNode(pName);
				childNode.Val = _getPropStr(pName, propertyType);
					
				dn.Children.add(childNode);
			}
			
			transform(dn);
			
			return dn;
		}
		
		public class LazyNode : QWebNode {
			
			
		}
		
		public void LazyLink(string localProp, string remoteProp = "") {
			
			var info = new LinkInfo();
			info.Lazy = true;
			info.LocalPropertyName = localProp;
			info.LinkedProperyName = remoteProp;
		}
		
		private class LinkInfo {
			
			public bool Lazy { get; set; }
			public Type LinkedType { get; set; }
			public string LocalPropertyName { get; set; }
			public string LinkedProperyName { get; set; }
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
		
		public class InheritInfo {
			
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
