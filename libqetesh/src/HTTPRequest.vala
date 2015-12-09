/*
 * HTTPRequest.vala
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
	* Represents a single HTTP request made to the server
	* 
	* Populates itself from raw request data
	* Belongs firmly in one thread
	* 
	* This is the one class that moves all the way through the
	* request pipeline and interacts on server, application and
	* request levels.
	* 
	* Also serves as the main context object for the request
	**/ 
	public class HTTPRequest : GLib.Object {

		// Servery bits
		private SocketConnection conn;
		private DataInputStream httpIn;
		private DataOutputStream httpOut;
		
		// AppContext actually contains ServerContext,
		// but we don't get AppContext until routed to an app,
		// hence the duplication. Only here because this class
		// moves through the full pipeline.
		
		/// Server Context
		public WebServerContext ServerContext { get; private set; }
		
		/// Application Context
		public WebAppContext AppContext { get; private set; }
				
		/// Data access manager
		public DataManager Data { get; private set; }
		
		// Informationery bits
		public enum RequestMethod {
			GET, POST, PUT, HEAD, DELETE, INVALID
		}
		
		// Individual bits of request data
		
		/// Request method e.g. GET, POST
		public RequestMethod Method { get; private set; }
		
		/// Full request path
		public string FullPath { get; private set; }
		
		/// Local part of request path
		public string Path { get; private set; }
		
		/// Request port, as provided by the server
		public uint16 ServerRequestPort { get; set; }
		
		/// Request port, as provided by the user
		public uint16 RequestPort { get; private set; }
		
		/// Hostname requested of us
		public string Host { get; private set; }
		
		/// User's browser, according to itself
		public string UserAgent { get; private set; }
		
		/// $n 
		public Gee.LinkedList<string> PathArgs { get; private set; }
		
		/// Map of request key: value
		public Map<string,string> Headers { get; private set; }
		
		/// The response to the request
		public HTTPResponse HResponse { get; private set; }
		
		/// Data tree built from request
		public RequestDataParser RequestData { get; private set; }
		
		// Could make these next few configurable in future
		/// Max header lines to process
		public int MaxHeaderLines { get; private set; default = 40; }
		
		public int MaxContentLength { get; private set; default = 65000; }
		
		public int MaxRequestTime { get; private set; default = 60; }
		
		public int MaxResponseTime { get; private set; default = 300; }
		
		/**
		 * Recieve a new request
		 * 
		 * @param c Socket with incoming request data
		 * @param sc Populated context from server
		 * 
		**/ 
		public HTTPRequest (SocketConnection c, WebServerContext sc) throws QRequestError {
			
			conn = c;
			ServerContext = sc;
			
			PathArgs = new Gee.LinkedList<string>();
			
			
			// We don't get the App context until we're routed to
			// an application
			
			try {
				httpIn = new DataInputStream(c.input_stream);
				httpOut = new DataOutputStream(c.output_stream);
			}
			catch(Error e) {
				
				throw new QRequestError.CRITICAL("Unable to get data streams: %s".printf(e.message));
			}
		}
		
		
		/**
		 * Read headers into self
		 * 
		 *  @param headers Header text lines
		**/
		private void ReadHeaders(ArrayList<string> headers) throws QRequestError {
			
			ServerContext.Err.WriteMessage("Processing header lines...", ErrorManager.QErrorClass.QETESH_DEBUG);

			ServerRequestPort = ServerContext.Configuration.ListenPort;
			Headers = new HashMap<string, string>();
			
			var firstLine = headers[0]; // TODO: err
			var parts = firstLine.split(" ", 3);
			
			// Check if it's a listed method
			switch (parts[0]) {
				case "GET":
				Method = RequestMethod.GET; break;
				case "POST":
				Method = RequestMethod.POST; break;
				case "PUT":
				Method = RequestMethod.PUT; break;
				case "HEAD":
				Method = RequestMethod.HEAD; break;	
				case "DELETE":
				Method = RequestMethod.DELETE; break;
				default:
				Method = RequestMethod.INVALID; break;
			}
					
			// Path, including query string
			// TODO: check length and err
			FullPath = parts[1];
			Path = FullPath; /// TODO: NOT LIKE THIS
			
			// Go through all header lines except the first
			for(int _i = 1; _i < headers.size; ++_i) {
				
				var line = headers[_i];
				var lineparts = line.split(": ", 2);
				Headers.set(lineparts[0], lineparts[1]);
				
				// Specific headers that we're looking for
				if (lineparts[0] == "Host") {
					
					var hostParts = lineparts[1].split(":", 2);
					Host = hostParts[0];
					if (hostParts.length > 1) RequestPort = (uint16) int.parse(hostParts[1]);
				}
				
				if (lineparts[0] == "User-Agent") {
					UserAgent = lineparts[1];
				}

			}
			
			ServerContext.Err.WriteMessage("Done processing header lines...", ErrorManager.QErrorClass.QETESH_DEBUG);
			
		}
		
		/**
		* Handle the request
		* Process request headers and data
		**/
		 
		public void Handle() throws QRequestError {
			
			/* 
			 * Here's an example of what we're expecting in the input stream:
			 * 	GET / HTTP/1.1
			 *	Host: 127.0.0.1:8041
			 *	User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:29.0) Gecko/20100101 Firefox/29.0
			 *	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,* /*;q=0.8 (no space before last /)
			 *	Accept-Language: en-US,en;q=0.5
			 *	Accept-Encoding: gzip, deflate
			 *	Connection: keep-alive
			 *	Cache-Control: max-age=0
			 * 
			 * */
			 
			ServerContext.Err.WriteMessage("HTTPRequest Handling Request...", ErrorManager.QErrorClass.QETESH_DEBUG);

			// Read lines from input
			string line;
			ArrayList<string> headerLines =  new ArrayList<string>();
			
			try {
				
				int c = 0;
				
				// Headers
				while ((line = httpIn.read_line (null)) != null
					&& c++ < MaxHeaderLines) {
					
					ServerContext.Err.WriteMessage("H: %s".printf(line), ErrorManager.QErrorClass.QETESH_DEBUG);
					
					headerLines.add(line);
					if (line.strip () == "") break;
				}
			}
			catch (Error e) {
				ServerContext.Err.WriteMessage("Error reading input", ErrorManager.QErrorClass.QETESH_CRITICAL);
				return;
			}
			
			// Process headers from input
			ReadHeaders(headerLines);
			
			string requestData = "";
			
			if(Headers.has_key("Content-Length")) {
				
				int cl = int.parse(Headers["Content-Length"]);
					
				if(cl < 1 || cl > MaxContentLength)
					throw new QRequestError.HEADERS("Invalid request content length: %s".printf(Headers["Content-Length"]));
				
				try {
					Bytes rd = httpIn.read_bytes ((size_t) cl, null);
					
					requestData = (string) rd.get_data();
					
					ServerContext.Err.WriteMessage("B: %s".printf(requestData), ErrorManager.QErrorClass.QETESH_DEBUG);
			
			
					ServerContext.Err.WriteMessage("Parsing request data structure...", ErrorManager.QErrorClass.QETESH_DEBUG);
				
					RequestData = new JSONReqestDataParser();

					RequestData.Parse(requestData);
				}
				catch (ParserError e) {
					
					throw new QRequestError.HEADERS("Error parsing request body:\n %s".printf(e.message));
					
				} catch (Error e) {
					
					throw new QRequestError.HEADERS("Error reading input body: \n%s");
				}
			}
			
			ServerContext.Err.WriteMessage("Done...", ErrorManager.QErrorClass.QETESH_DEBUG);
		}
	
	
	/**
	 * Route the request to an application
	 * 
	 * Thread-global variables in Qetesh.ThreadContext are set
	 * at this point, as well as application context.
	 * 
	**/ 
		public void Route(WebAppContext cxt, HTTPResponse resp) {
			
			AppContext = cxt;
			HResponse = resp;
			Data = new DataManager(ServerContext.Databases);
		}
		
		/**
		 * Trigger a response
		**/ 
		
		public void Respond() {
			
			
			if (HResponse != null) {
				
				// Echo back request tree - cheap debug hack!
				//HResponse.DataTree.Children.add(RequestData.DataTree);
				
				HResponse.Respond(httpOut);
			}
				
			//else
				/// TODO: write error
		}
	}
}
