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
		
		protected Gee.HashMap<string, Validator> Validators;
		
		/// Primary key name
		public string PKeyName { get; protected set; default="Id"; }
		
		private Gee.LinkedList<string> TaintedProperties { get; set; }
		
		public DataObject (QDatabaseConn dbh) {
			
			_init(dbh);
		}
		
		public abstract void Init ();
		
		internal void _init(QDatabaseConn dbh) {
		
			db = dbh;
			lazySingleMap = new Gee.HashMap<string, int>();
			lazyCache = new Gee.HashMap<string, Gee.LinkedList<DataObject>>();
			
			__init();
			Init();
		}
		
		internal void __init() {
			
			// Defaults
			TableName = this.get_type().to_string();
			PKeyName = "Id";
			
			TaintedProperties = new Gee.LinkedList<string>();
			Validators = new Gee.HashMap<string, Validator>();
		}
		
		public void Validate() throws ValidationError {
			
			bool valid = true;
			
			foreach(string key in Validators.keys) {
				
				if(!Validators[key].Validate()) {
					
					valid = false;
				}
			}
			
			if(valid == false) throw new ValidationError.INVALID_VALUE("Validate() failed");
		}

		public void Create() {
			
			var query = db.NewQuery().DataSet(TableName).Create();
			
			if(TaintedProperties.size == 0) {
				
				throw new QDBError.QUERY("Cannot create %s with no values".printf(TableName));
			}
			
			foreach(var prop in TaintedProperties) {
				
				if(prop == PKeyName) continue;
				if(prop == "PKeyName") continue;
				
				query.Set(prop).Equal(getPropStr(prop));
			}
			
			
			this.setPKeyStr(query.DoInt().to_string());
		}
		
		public void Delete() {
			
			var query = db.NewQuery().DataSet(TableName).Delete();
			
			query.Where(PKeyName).Equal(getPKeyStr());
			query.Do();
		}
		
		
		public Gee.LinkedList<DataObject> LoadAll() throws Qetesh.Data.QDBError {
			
			Gee.LinkedList<DataObject> returnList;
			
			var query = db.NewQuery().DataSet(TableName).Read();
			var res = query.Do();
			
			returnList = MapObjectList(res.Items);
			
			return returnList;
		}
		
		internal Gee.LinkedList<DataObject> _lazyLoadList(string propertyName, Type fType) {
			return LazyLoadList(propertyName, fType);
		}
		
		/**
		 * Server side lazy loading
		 * 
		**/
		protected Gee.LinkedList<DataObject> LazyLoadList(string propertyName, Type fType)  {
			
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
			
			var query = db.NewQuery().DataSet(proto.TableName).Read();
			
			query.Where(colName).Equal(getPKeyStr());
			
			var res = query.Do();
			
			returnList = proto.MapObjectList(res.Items);
			
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
			
			var query = db.NewQuery().DataSet(TableName).Read();
			
			query.Where(PKeyName).Equal(getPKeyStr());
			
			var res = query.Do();
			
			if (res.Items.size == 0) {
				
				// Todo: throw exception
			}
			else {
			
				// Map into self
				MapObject(res.Items[0]);
			}
		}
		
		public void Update() {
			
			var query = db.NewQuery().DataSet(TableName).Update();
			
			query.Where(PKeyName).Equal(getPKeyStr());
			
			if(TaintedProperties.size == 0) {
				
				// No need to error, just nothing to do. What we're being
				// asked is legal but will have zero effect.
				return;
			}
			
			foreach(var prop in TaintedProperties) {
				
				if(prop == PKeyName) continue;
				if(prop == "PKeyName") continue;
				query.Set(prop).Equal(getPropStr(prop));
			}
		}
		
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
				
				if(dObj != null) {
					strVal = dObj.toString();
				}
			}
			
			else {
				
				if (propertyType.is_a(typeof(DataObject))) {
					var val = Value(typeof(DataObject));
					this.get_property(pName, ref val);
					var dObj = (DataObject) val.get_object();
					dObj.__init();
					
					if(dObj != null) {
						strVal = dObj.getPropStr(dObj.PKeyName);
					}
				}
			}
			
			if(strVal == null) return "";
			
			return strVal;
		}
		
		private void _setPropStr(string pName, string inVal, Type propertyType) {
			
			if(Validators == null) new Gee.HashMap<string, Validator>();
			
			if (propertyType == typeof(string)) {
				
				if(Validators[pName] == null) {
					
					Validators[pName] = new StringValidator();
				}
				
				var vdr = (StringValidator) Validators[pName];
					
				vdr.InValue = inVal;
				vdr.Convert();
				
				var val = Value(typeof(string));
				val.set_string(vdr.OutValue);
				this.set_property(pName, val);
				
			}
			
			else if (propertyType == typeof(int)) {
				
				if(Validators[pName] == null) {
					
					Validators[pName] = new IntValidator();
				}
				
				var vdr = (IntValidator) Validators[pName];
				
				vdr.InValue = inVal;
				vdr.Convert();
				
				var val = Value(typeof(int));
				val.set_int(vdr.OutValue);
				this.set_property(pName, val);
				
			}
			
			else if (propertyType == typeof(bool)) {
				
				if(Validators[pName] == null) {
					
					Validators[pName] = new BoolValidator();
				}
				
				var vdr = (BoolValidator) Validators[pName];
				
				vdr.InValue = inVal;
				vdr.Convert();
				
				var val = Value(typeof(bool));
				val.set_boolean(vdr.OutValue);
				this.set_property(pName, val);
			}
			
			else if (propertyType == typeof(float)) {
				
				if(Validators[pName] == null) {
					
					Validators[pName] = new DoubleValidator();
				}
				
				var vdr = (DoubleValidator) Validators[pName];
				
				vdr.InValue = inVal;
				vdr.Convert();
				
				var val = Value(typeof(float));
				val.set_float((float) vdr.OutValue);
				this.set_property(pName, val);
			}
			
			else if (propertyType == typeof(double)) {
				
				if(Validators[pName] == null) {
					
					Validators[pName] = new DoubleValidator();
				}
				
				var vdr = (DoubleValidator) Validators[pName];
				
				vdr.InValue = inVal;
				vdr.Convert();
				
				var val = Value(typeof(double));
				val.set_double(vdr.OutValue);
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
					
					var dObj = (DataObject) Object.new(propertyType);
					dObj.__init();
					dObj.setPropStr(dObj.PKeyName, inVal);
					
					var val = Value(typeof(DataObject));
					val.set_object((Object) dObj);
					this.set_property(pName, val);
				}
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
		
		public void FromRequest(HTTPRequest req) {
			
			FromNode(req.RequestData.DataTree);
		}
		
		public void FromNode(DataNode data) throws ValidationError {
			
			if (data.Children.size > 0) {
				
				Validate();
			
				foreach(var child in data.Children[0].Children) {
					 
					if(
						child.Name != null && child.Name != "" &
						child.Val != null & child.Val != ""
					){
						this.TaintedProperties.add(child.Name);
						setPropStr(child.Name, child.Val);
					}
				}
			}
		}
		
		public class LazyNode : QWebNode {
			
			
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
