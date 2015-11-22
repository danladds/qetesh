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
				Children[subpath] = newNode;
				return newNode;
			}
		}
		
		public new void set (string subpath, QWebNode node) {
			
			Children[subpath] = node;
		}
		
		public Map<string, QWebNode> Children;
		
		public string Path { get; set; }
		
		/// GET request event
		public signal void GET(HTTPRequest req);
		
		/// POST request event
		public signal void POST(HTTPRequest req);
		
		/// PUT request event
		public signal void PUT(HTTPRequest req);
		
		protected QWebNode (string path = "") {
			
			Children = new HashMap<string, QWebNode>();
			Path = path;
		}
		
		protected void ExposeType (Type t) {
			
			
			// Need to update JS manifest
			
			// Read list
			GET.connect((conn) => {
				
			});
			
			// Manifest.Add(c, this.GET);
			
			// Create new
			POST.connect((conn) => {
				
			});
			
			// Read single
			this["$n"].GET.connect((conn) => {
				
			});
			
			// Update single
			this["$n"].PUT.connect((conn) => {
				
			});
		}
		
	}
}

