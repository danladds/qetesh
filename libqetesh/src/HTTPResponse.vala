/*
 * HTTPResponse.vala
 * 
 * Base class for HTTP responses
 * Exend to respond with HTML, JSON, XML, &c
 * Can also be used as a bare HTTP responder
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

namespace Qetesh {

	public abstract class HTTPResponse : GLib.Object {

		public int ResponseCode { get; set; }
		public string ResponseMessage { get; set; }
		public string ContentType { get; set; }
		public StringBuilder Content;
		
		public const int DEFAULT_CODE = 200;
		public const string DEFAULT_CT = "text/html";
		
		protected WebAppContext Context { get; private set; }
		
		public Data.DataObject.DataNode DataTree { get; private set; }
		public Gee.LinkedList<string> Messages { get; private set; }
		
		public HTTPResponse(WebAppContext ctx) {
			
			ResponseCode = DEFAULT_CODE;
			ContentType = DEFAULT_CT;
			Content = new StringBuilder();
			Context = ctx;
			
			DataTree = new Data.DataObject.DataNode();
			DataTree.IsArray = true;
			Messages = new Gee.LinkedList<string>();
		}
		
		public virtual void Respond(DataOutputStream httpOut) {
			
			ComposeContent();
			
			var content = Content.str;
			
			// Output headers and content
			var header = new StringBuilder ();
			header.append ("HTTP/1.0 %d %s\r\n".printf(ResponseCode, ResponseMessage));
			header.append ("Content-Type: %s\r\n".printf(ContentType));
			header.append_printf ("Content-Length: %lu\r\n\r\n", content.length);

			try {
				httpOut.write (header.str.data);
				httpOut.write (content.data);
				httpOut.flush ();
			} catch (Error e) {
				Context.Server.Err.WriteMessage("Unable to send response to client: %s".printf(e.message), ErrorManager.QErrorClass.QETESH_WARNING);
			}
		}
		
		/**
		 * Implement depending on format, e.g. JSON, XML, HTML 
		**/
		public abstract void ComposeContent();
		
	}

}
