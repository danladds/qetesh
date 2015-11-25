/*
 * QWebApp.vala
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

using Qetesh.Data;

namespace Qetesh {

	/**
	 * Base class to be inherited by module entry classes
	 * 
	**/
	public class QWebApp: GLib.Object {
		
		protected QWebNode RootNode;
		
		protected WebAppContext appContext;
		
		public QWebApp (WebAppContext ctx) {
			
			appContext = ctx;
			RootNode = new QWebNode("");
		}
		
		/**
		 * 
		 * NB: This is called at request time, so be careful
		 * with properties used at app load
		 * 
		**/
		internal QWebNode? GetNode(HTTPRequest req) {
		
			QWebNode node = null;			
			string path = req.Path;
			
			// Easy special case - /
			if (path == "/" || path == "") return RootNode;
			
			// Strip starting and trailing spaces and slashes
			path = path.strip();
			
			if(path.has_prefix("/")) path = path.substring(1);
			
			if(path.has_suffix("/")) {
				
				appContext.Server.Err.WriteMessage("Stripping trailing slash", ErrorManager.QErrorClass.QETESH_DEBUG);
				path = path.substring(0, path.char_count() - 1);
			}
			
			appContext.Server.Err.WriteMessage("Trying to find node for %s"
				.printf(path), ErrorManager.QErrorClass.QETESH_DEBUG);
			
			var parts = path.split("/");
			
			appContext.Server.Err.WriteMessage("Node should be %d deep"
				.printf(parts.length), ErrorManager.QErrorClass.QETESH_DEBUG);
			
			node = RootNode;
				
			foreach (var sp in parts) {
				
				appContext.Server.Err.WriteMessage("Searching children of %s (%d) for %s"
				.printf(node.Path, node.Children.size, sp), ErrorManager.QErrorClass.QETESH_DEBUG);
				
				if (node.Children.size > 0) {
					foreach (var c in node.Children.values) {
						
						appContext.Server.Err.WriteMessage("Child node: %s"
					.printf(c.Path), ErrorManager.QErrorClass.QETESH_DEBUG);
					}
				}
				
				if (node.Children.has_key(sp)) {
					
					node = node.Children[sp];
				}
				else if (node.Children.has_key("$n")) {
					
					node = node.Children["$n"];
					req.PathArgs.add(sp);
					
				}
				else {
					return null;
				}
			}
			
			return node;
		}
		
		protected void WriteMessage(string message, ErrorManager.QErrorClass errorClass = ErrorManager.QErrorClass.MODULE_CRITICAL, string? modName = null) {
			
			appContext.Server.Err.WriteMessage(message, errorClass, modName);
		}
	}
}
