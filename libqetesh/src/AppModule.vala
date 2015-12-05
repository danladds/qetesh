/*
 * AppModule.vala
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
	* A single module that has been, or is to be, loaded
	**/ 
	public class AppModule : Object {
		
		[CCode (has_target = false)]
		private delegate Type ModInitFunc(WebAppContext ctx);
		
		/// The underlying Vala module
		private Module module;
		
		/// Nickname of the module
		public string Nick { get; private set; }
		
		/// Name of the module loader class
		private string loaderName;
		
		/// Path to the module .so/.dll file
		private string path;
		
		/// Actual application class once loaded
		public QWebApp WebApp { get; private set; }
		
		/// Application context for this app
		public WebAppContext Context { get; private set; }
		
		public signal void ApplicationStart();
		
		public int ExecUser { get; private set; }
		public int ExecGroup { get; private set; }

		/**
		* Create a new AppModule and load the module
		* 
		* @param modPath Path to the module .so/.dll file
		* @param module nickname, for identification
		* @param loader name of the module loader class
		**/
		public AppModule (string modPath, string nick, string loader,  WebServerContext sc, int execUser, int execGroup) throws Errors.QModuleError {
			
			Nick = nick;
			loaderName = loader;
			path = modPath;
			
			ExecUser = execUser;
			ExecGroup = execGroup;
			
			// Load the DLL
			module = Module.open(path, ModuleFlags.BIND_LAZY);
			
			// Check that it actually happened :)
			if (module == null) throw new Errors.QModuleError.LOAD("Unable to load module");
			
			// Create managers
			Context = new WebAppContext();
			Context.Server = sc;
			;
			Context.Mod = this;
			
			// Instantiate the app object
			WebApp = GetApp();
			
			ApplicationStart();
		}
		
		/**
		* Handle a request
		**/
		public void Handle(HTTPRequest req) {
			
			req.Route(Context, new JSONResponse(Context));
			
			Context.Server.Err.WriteMessage("Finding node...", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			var node = WebApp.GetNode(req);
			
			if (node != null) {
				
				Context.Server.Err.WriteMessage("Found node: %s".printf(node.Path), ErrorManager.QErrorClass.QETESH_DEBUG);
			
				if (req.Method == HTTPRequest.RequestMethod.GET) {
					node.GET(req);
				}
				else if (req.Method == HTTPRequest.RequestMethod.POST) {
					node.POST(req);
				}
				else if (req.Method == HTTPRequest.RequestMethod.PUT) {
					node.PUT(req);
				}
				else if (req.Method == HTTPRequest.RequestMethod.DELETE) {
					node.DELETE(req);
				}
			}
			else {
				Context.Server.Err.WriteMessage("Node not found (404)", ErrorManager.QErrorClass.QETESH_DEBUG);
				req.HResponse.Messages.add("Path not configured - 404");
				req.HResponse.ResponseCode = 404;
				req.HResponse.ResponseMessage = "Path not found";
			}
		}
		
		/**
		* Activate the module's loader and main class entry point
		* 
		* @returns Web app object
		**/
		
		public QWebApp GetApp() throws Errors.QModuleError {
			
			Context.Server.Err.WriteMessage("AppModule attempting to get app object", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			// Find the init function
			void* initFunc = null;
			if (!module.symbol("mod_init", out initFunc)) {
				throw new Errors.QModuleError.LOAD("Unable to get init symbol from module");
			}
			
			// Get the type from the init function and try to create it
			Context.Server.Err.WriteMessage("Attempting to create type", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			Type t = ((ModInitFunc) initFunc)(Context);
			
			Context.Server.Err.WriteMessage("Plugin type found: %s".printf(t.name ()), ErrorManager.QErrorClass.QETESH_DEBUG);
			
			// Create loader object
			QPlugin p = (QPlugin) Object.new(Type.from_name(loaderName));
			
			Context.Server.Err.WriteMessage("Created loader object", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			// Get and return the top element for the module from
			// the loader
			return p.GetModObject(Context);
		}
		
		/// Retains the loaded module until the AppModule is also gone
		~AppModule() {
			module = null;
		}
		
		public void ExposeData (Gee.List<DataObject> data) {
			
		}
	}

	/**
	* Interface that module loader classes must meet
	**/
	public interface QPlugin : Object {
		
		public abstract QWebApp GetModObject(WebAppContext ctx);
	}
}
