/*
 * QExample.vala
 * 
 * Copyright 2015 Dan Ladds <Dan@el-topo.co.uk>
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

// Using both core and data (ORM)
using Qetesh;
using Qetesh.Data;

// This is where the Qetesh server will try to load our load
// Following line needs to be as-is, as the server looks for this
// name and type
Type mod_init (WebAppContext ctx) {
	
	// Return the type of our loader class
	return typeof(ExampleLoader);
}

// Note interface
public class ExampleLoader : QPlugin, Object {

	public QWebApp GetModObject (WebAppContext ctx) {
		
		// Create our main object
		// Can potentially do some early pre-init
		// stuff here if required
		return new QExample.QExample(ctx);
	}
}

// Things above need to be in global namespace
// Our normal namespace starts here
namespace QExample {

	// The class is your main client to the Qetesh server
	// Note inherit
	public class QExample : QWebApp {
		
		// Constructor format as parent
		// Passed server context
		public QExample(WebAppContext ctx) {
			
			// This is being called at module load time
			// We're not serving a request yet
			
			// Note
			base(ctx);
			
			// Write a simple message to the server log
			// Things like DB errors should always be logged rather
			// than outputted to the user
			WriteMessage("QExample is go!", ErrorManager.QErrorClass.MODULE_DEBUG, "QExample");
			
			// Set up a QWebNode that we've defined in /api/InvoiceNode.vala
			// QWebNodes form a tree that prepresents a URI structure
			// They also provide binding points for classes we want to
			// expose to the client-side
			RootNode["invoice"] = new InvoiceNode();
			
			// Set up a manifest node. QManifest is a built-in QWebNode
			// This allows for the client JS object interfece
			// Not needed if you're just using Qetesh as a JSON
			// API server
			RootNode["manifest"] = new QManifest();
		}
	}

}
