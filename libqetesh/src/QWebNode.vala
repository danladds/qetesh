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
		
		protected LazyExposer ExposeCrud (string typeName, Type typ, string dbName) {
			
			
			// Need to update JS manifest
			Manifest = new ManifestObject(typeName);
			
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
			
			Manifest.Method("LoadAll", this).GET();
			
			// Create new
			POST.connect((req) => {
				
			});
			
			Manifest.Method("Create", this).POST();
			
			// Read single
			this["$n"].GET.connect((req) => { 
				
			});
			
			Manifest.Method("Load", this["$n"]).GET();
			
			// Update single
			this["$n"].PUT.connect((req) => { 
				
			});
			
			Manifest.Method("Update", this["$n"]).PUT();
			
			var proto = (DataObject) Object.new(typ);
			
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
			
			public LazyExposer Lazy (string propertyName, Type fType) {
				
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
					
				node.Parent.Manifest.Method(propertyName, node[path]).GET();
					
				return this;
			}
		}
		
		public void WalkManifests(ManifestWalker walker) {
			
			if (Manifest != null) {
				
				var objBase = walker.AddObject(Manifest.TypeName);
				
				foreach(var mm in Manifest.Methods)
					objBase.Children.add(mm.GetDescriptor());
			}
			
			foreach(var cld in Children.values) cld.WalkManifests(walker);
		}
		
		public class ManifestWalker {
			
			private DataObject.DataNode rootNode;
			
			public ManifestWalker(DataObject.DataNode rNode) {
				
				rootNode = rNode;
			}
			
			public DataObject.DataNode AddObject(string tName) {
				
				var newNode = new DataObject.DataNode(tName);
				rootNode.Children.add(newNode);
				
				return newNode;
			}
		}
		
		public class ManifestObject {
			
			public string TypeName { get; private set; }
			
			public Gee.LinkedList<ManifestMethod> Methods;
			
			public ManifestObject(string typeName) {
				
				TypeName = typeName;
				Methods = new Gee.LinkedList<ManifestMethod>();
			}
			
			public ManifestMethod Method(string mName, QWebNode node) {
				
				var method = new ManifestMethod(mName, node.GetFullPath());
				
				Methods.add(method);
				return method;
			}
			
			
			public class ManifestMethod {
				
				public string Name { get; set; }
				public string NodePath { get; set; }
				public string HttpMethod { get; private set; default = "GET"; }
				
				public ManifestMethod(string name, string path) {
					
					Name = name;
					NodePath = path;
				}
				
				public DataObject.DataNode GetDescriptor() {
					
					var desc = new DataObject.DataNode(Name);
					
					desc.Children.add(
						new DataObject.DataNode ("NodePath") { Val = NodePath }
					);
					
					desc.Children.add(
						new DataObject.DataNode ("HttpMethod") { Val = HttpMethod }
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
			}
		}
		
	}
}

