/*
 * QWebNode.vala
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

using Gee;
using Qetesh.Data;

namespace Qetesh {

	/**
	 * Base class to be inherited by web nodes (controllers)
	 * 
	**/
	public class QWebNode: GLib.Object {
		
		public int size {
			get {
				
				return 1;
			}
		}
		
		public new QWebNode? get (string subpath) {
			
			if (Children.has_key(subpath)) {
				
				return Children[subpath];
			} else {
				
				QWebNode newNode = new QWebNode();
				newNode.Path = subpath;
				newNode.Parent = this;
				Children[subpath] = newNode;
				
				newNode.OnBind();
				
				return newNode;
			}
		}
		
		public new void set (string subpath, QWebNode node) {
			
			node.Path = subpath;
			node.Parent = this;
			Children[subpath] = node;
			
			node.OnBind();
		}
		
		public Map<string, QWebNode> Children;
		public QWebNode? Parent;
		
		public string Path { get; set; }
		
		/// GET request event
		public signal void GET(HTTPRequest req);
		
		/// POST request event
		public signal void POST(HTTPRequest req);
		
		/// PUT request event
		public signal void PUT(HTTPRequest req);
		
		/// DELETE request event
		public signal void DELETE(HTTPRequest req);
		
		public ManifestObject Manifest;
		

		/// Override for activation proceedure
		/// Called when bound to a place in the tree
		/// If you think it belongs in your constructor, it probably belongs here
		public virtual void OnBind() {
			
			//
		}
		
		protected QWebNode (string path = "") {
			
			Children = new HashMap<string, QWebNode>();
			Parent = null;
			Path = path;
		}
		
		
		public string GetFullPath () {
			
			if (Parent != null) return "%s/%s".printf(Parent.GetFullPath(), Path);
			else return Path;
		}
		
		protected void ExposeProperties(string typeName, Type typ) {
			
			var proto = (DataObject) Object.new(typ);
			proto.Init();
			
			var defaults = proto.ToNode((n) => { });
			
			foreach(var node in defaults.Children) {
				
				Manifest.Prop(node.Name, node.Val);
			}
		}
		
		protected LazyExposer ExposeCrud (string typeName, Type typ, string dbName) {
			
			
			var proto = (DataObject) Object.new(typ);
			proto.Init();
			
			Manifest = new ManifestObject(typeName, proto.PKeyName);
			
			// Read list
			GET.connect((req) => {
				
				var obj = (DataObject) Object.new(typ);
				obj._init(req.Data.GetConnection(dbName));
				var list = obj.LoadAll();
				
				foreach (var item in list) {
					
					req.HResponse.DataTree.Children.add(
						item.ToNode((n) => { })
					);
				}
						
			});
			
			Manifest.Method("LoadAll", typeName + "[]", this).GET();
			
			// Create new
			POST.connect((req) => {
				
				var obj = (DataObject) Object.new(typ);
				obj._init(req.Data.GetConnection(dbName));
				
				req.ServerContext.Err.WriteMessage("POST (CREATE) method called", ErrorManager.QErrorClass.MODULE_DEBUG);
				
				var ret = new DataObject.DataNode();
				
				try {
					
					obj.FromRequest(req);
					
					req.ServerContext.Err.WriteMessage("Object loaded; trying Create()", ErrorManager.QErrorClass.MODULE_DEBUG);
					
					obj.Create();
					
					req.ServerContext.Err.WriteMessage("Create() done", ErrorManager.QErrorClass.MODULE_DEBUG);

					
					ret.Children.add(new DataObject.DataNode ("Success") { Val = "Y" });
					
					ret.Children.add(new DataObject.DataNode (obj.PKeyName) { Val = obj.getPKeyStr() });
					
					req.HResponse.DataTree.Children.add(ret);
				}
				catch(Error e) {

					ret.Children.add(new DataObject.DataNode ("Success") { Val = "N" });
					
					req.HResponse.DataTree.Children.add(ret);
					
					throw e;
				}
			});
			
			Manifest.Method("Create", "void", this).POST();
			
			// Read single
			this["$n"].GET.connect((req) => { 
				
				var obj = (DataObject) Object.new(typ);
				obj._init(req.Data.GetConnection(dbName));
				
				obj.setPKeyStr(req.PathArgs[0]);
				
				obj.Load();
				
				req.HResponse.DataTree.Children.add(obj.ToNode((n) => { }));
			});
			
			Manifest.Method("Load", "this", this["$n"]).GET();
			
			// Delete
			this["$n"].DELETE.connect((req) => { 
				
				var obj = (DataObject) Object.new(typ);
				obj._init(req.Data.GetConnection(dbName));
				
				obj.setPKeyStr(req.PathArgs[0]);
				
				obj.Delete();
			});
			
			Manifest.Method("Delete", "implode", this["$n"]).DELETE();
			
			// Update single
			this["$n"].PUT.connect((req) => {
				
				var obj = (DataObject) Object.new(typ);
				obj._init(req.Data.GetConnection(dbName));
				
				req.ServerContext.Err.WriteMessage("PUT (UPDATE) method called", ErrorManager.QErrorClass.MODULE_DEBUG);
				
				try {
					
					obj.FromRequest(req);
					
					req.ServerContext.Err.WriteMessage("Object loaded; trying Update()", ErrorManager.QErrorClass.MODULE_DEBUG);
					
					obj.Update();
					
					req.ServerContext.Err.WriteMessage("Update() done", ErrorManager.QErrorClass.MODULE_DEBUG);
					
					req.HResponse.DataTree.Children.add(
						new DataObject.DataNode(obj.PKeyName) { 
							Val = obj.getPropStr(obj.PKeyName)
						}	
					);
				
					req.HResponse.DataTree.Children.add(new DataObject.DataNode ("Update") { Val = "OK" });
				}
				catch(Error e) {
					
					req.HResponse.DataTree.Children.add(new DataObject.DataNode ("Update") { Val = "FAIL" });
					
					throw e;
				}
				
			});
			
			Manifest.Method("Update", "void", this["$n"]).PUT();
			
			ExposeProperties(typeName, typ);
			
			return new LazyExposer(typeName, typ, dbName, this["$n"]);
			
		}
		
		public class LazyExposer {
			
			private string localTypeName;
			private Type localType;
			private string dbNick;
			QWebNode node;
			
			internal LazyExposer(string typeName, Type typ, string dbName, QWebNode contextNode) {
				
				localTypeName = typeName;
				localType = typ;
				dbNick = dbName;
				node = contextNode;
			}
			
			public LazyExposer Lazy (string propertyName, Type fType, string returnType) {
				
				var path = propertyName.down();
					
				node[path].GET.connect((req) => {
						
					var proto = (DataObject) Object.new(localType);
					proto._init(req.Data.GetConnection(dbNick));
					proto.setPKeyStr(req.PathArgs[0]);
					
					var list = proto._lazyLoadList(propertyName, fType);
					
					foreach (var item in list) {
						
						req.HResponse.DataTree.Children.add(
							item.ToNode((n) => { })
						);
					}
				});
					
				node.Parent.Manifest.LazyLink(propertyName, returnType, node[path]).GET();
				
				var rCoreType = returnType;
				
				// Also expose return type
				if(returnType.has_suffix("[]")) {
					
					rCoreType = returnType.replace("[]", "");
				}
				
				
				// Todo: integrate conditions into ExposeCrud
				node["_" + path].ExposeCrud(rCoreType, fType, dbNick);
					
				return this;
			}
		}
		
		public void WalkManifests(ManifestWalker walker) {
			
			if (Manifest != null) {
				
				var objBase = walker.AddObject(Manifest.TypeName, Manifest.PKeyName);
				
				foreach(var mm in Manifest.Methods)
					objBase.Children.add(mm.GetDescriptor());
					
				foreach(var prop in Manifest.Props.keys) {
					
					objBase.Children.add(
						new DataObject.DataNode (prop) { Val = Manifest.Props[prop] }
					);
				}
			}
			
			foreach(var cld in Children.values) cld.WalkManifests(walker);
		}
		
		public class ManifestWalker {
			
			private DataObject.DataNode rootNode;
			
			public ManifestWalker(DataObject.DataNode rNode) {
				
				rootNode = rNode;
			}
			
			public DataObject.DataNode AddObject(string tName, string pKey) {
				
				var newNode = new DataObject.DataNode(tName);
				rootNode.Children.add(newNode);
					
				newNode.Children.add(
					new DataObject.DataNode ("PKeyName") { Val = pKey }
				);
				
				return newNode;
			}
		}
		
		public class ManifestObject {
			
			public string TypeName { get; private set; }
			public string PKeyName { get; private set; }
			
			public Gee.LinkedList<ManifestMethod> Methods { get; private set; }
			public Gee.HashMap<string, string> Props { get; private set; }
			
			public ManifestObject(string typeName, string pKey) {
				
				TypeName = typeName;
				PKeyName = pKey;
				Methods = new Gee.LinkedList<ManifestMethod>();
				Props = new Gee.HashMap<string, string>();
			}
			
			public void Prop(string name, string def) {
				
				Props.set(name, def);
			}
			
			public ManifestMethod Method(string mName, string mType, QWebNode node) {
				
				var method = new ManifestMethod(mName, node.GetFullPath(), "method", mType);
				
				Methods.add(method);
				return method;
			}
			
			public ManifestMethod LazyLink(string mName, string mType, QWebNode node) {
				
				var method = new ManifestMethod(mName, node.GetFullPath(), "link", mType);
				
				Methods.add(method);
				return method;
			}
			
			
			public class ManifestMethod {
				
				public string Name { get; set; }
				public string NodePath { get; set; }
				public string HttpMethod { get; private set; default = "GET"; }
				public string MethodType { get; private set; default = "method"; }
				public string ReturnType { get; private set; default = ""; }
				
				public ManifestMethod(string name, string path, string mType, string rType) {
					
					Name = name;
					NodePath = path;
					MethodType = mType;
					ReturnType = rType;
				}
				
				public DataObject.DataNode GetDescriptor() {
					
					var desc = new DataObject.DataNode(Name);
					
					desc.Children.add(
						new DataObject.DataNode ("NodePath") { Val = NodePath }
					);
					
					desc.Children.add(
						new DataObject.DataNode ("HttpMethod") { Val = HttpMethod }
					);
					
					desc.Children.add(
						new DataObject.DataNode ("MethodType") { Val = MethodType }
					);
					
					desc.Children.add(
						new DataObject.DataNode ("ReturnType") { Val = ReturnType }
					);

					return desc;
				}
				
				public void GET() {
					
					HttpMethod = "GET";
				}
				
				public void POST() {
					
					HttpMethod = "POST";
				}
				
				public void PUT() {
					
					HttpMethod = "PUT";
				}
				
				public void DELETE() {
					
					HttpMethod = "DELETE";
				}
			}
		}
		
	}
}

