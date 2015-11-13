/*
 * Qetesh Web Interface
 * A tiny webserver that runs Qetesh applications,
 * written in Vala
 * 
 * Quick note:
 *  - Most stuff that developers will care about is actually in
 * libqetesh. The server itself does a small number of things: loads
 * the framework library (libqetesh), loads application modules,
 * and runs a very simple web server to funnel requests through the
 * framework to the application and responses back again.
 * 
 *  - Qetesh has few web server features inbuilt. It cannot even serve
 * files at this stage. It doesn't have request rate limiting. Its 
 * purpose is entirely to serve the data and events layers of the 
 * framework. For everything else, there's Apache.
 * 
 * - The server package also contains the frontend files for the
 * framework.
 * 
 * -----------------------------------------
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

using Qetesh;

namespace Qetesh.WebServer {
	
	/** 
	 * The main Qetesh web server class
	 * 
	 * An instance of this class represents a server instance.
	 * Contains a static main() method which creates a single server.
	 * This class handles listening for requests and assigning them to worker threads.
	**/
	public class Server : GLib.Object {
		
		/**
		 * Represents the source of an individual request.
		 * 
		 * Currently stores just the source port.
		**/
		public class Source : Object {
			
			/// Port Number
			public uint16 port { private set; get; }
			
			/// Token constructor
			public Source (uint16 port) {
				this.port = port;
			}
		}
		
		private WebServerContext context;
		
		/// Server instance
		public static Server Current { get; private set; }

		/** 
		 * This is where it all begins...
		 * Start the program and create the server.
		 * Instruct the server to listen.
		 * 
		 * @param args Command line arguments
		 * @return 0
		 * 
		*/
		public static int main(string[] args) {
			
			Current = new Server();
			Current.Listen();
				
			return 0;
		}
		
		/**
		 * Start a server.
		 * 
		 * Create an instance of the Server class, which will proceed
		 * to load modules and read its config file
		**/
		private Server () {
			
			context = new WebServerContext();
			
			// Set up error management first
			context.Err = new ErrorManager();
			
			// Log start - with some space between start-ups!
			context.Err.WriteMessage("------------------------\n\n\n", ErrorManager.QErrorClass.QETESH_DEBUG);
			context.Err.WriteMessage("Starting server :)", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			// Read config file
			context.Err.WriteMessage("Loading config file...", ErrorManager.QErrorClass.QETESH_DEBUG);
			context.Configuration = new ConfigFile(context);
			
			// Test databases
			context.Err.WriteMessage("Loading databases...", ErrorManager.QErrorClass.QETESH_DEBUG);
			context.Databases = new Data.DBManager(context);
			
			// Load modules
			context.Err.WriteMessage("Loading modules...", ErrorManager.QErrorClass.QETESH_DEBUG);
			context.Modules = new ModuleManager(context);
			context.Modules.LoadModules();
		}
		
		/** 
		 * Listen on a TCP port for HTTP connections
		 * 
		 * Listens on a specified port for HTTP connections, which are
		 * dispatched to child threads for processing and response
		 * 
		 * @param port Port to listen on
		 * 
		**/
		public void Listen() {
			
			// ThreadedSocketService is a stock Vala class
			var service = new ThreadedSocketService(context.Configuration.MaxThreads);
			
			/// TODO: actually implement thread limit!
			context.Err.WriteMessage("Starting with %d max threads".printf(context.Configuration.MaxThreads), ErrorManager.QErrorClass.QETESH_DEBUG);
			
			try {
				context.Err.WriteMessage("Listening on port %d".printf(context.Configuration.ListenPort), ErrorManager.QErrorClass.QETESH_DEBUG);
				
				service.add_inet_port(context.Configuration.ListenPort, new Source(context.Configuration.ListenPort));
			
			
				// Dispatch to thread
				// FORK WARNING \|/
				//               |
				//               |
				service.run.connect(DispatchRequest);
			
				// Start listening
				service.start();
			
			}
			catch (Error e) {
				context.Err.WriteMessage("Error while trying to listen on port: %s".printf(e.message), ErrorManager.QErrorClass.QETESH_CRITICAL);
				return;
			}
			
			// Run a main loop to stop the main thread from closing while we're listening
			context.Err.WriteMessage("Starting main loop...", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			// This thread can just sit here until told to close
			var loop = new MainLoop();
			loop.run();
		}
		
		/** 
		 * Dispatch an incoming connection and handle
		 * 
		 * Creates a new {@link HTTPRequest} to handle an incoming request
		 * 
		 * First function called in individual request threads
		 * 
		 * @param c Socket connection to inbound client
		 * @param s Source object
		 * @return false
		 * 
		**/
		public bool DispatchRequest(SocketConnection c, Object s) {

			context.Err.WriteMessage("\n\n\nServer Dispatching Request", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			var req = new HTTPRequest(c, context);
			req.Handle();
			
			context.Err.WriteMessage("\n\n\nServer Routing Request", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			// Route request
			var router = new RequestRouter(req, context);

			return false;
		}
	}
}
