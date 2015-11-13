/*
 * RequestRouter.vala
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

namespace Qetesh.WebServer {

	/**
	* Handles routing a HTTPRequest
	* 
	* Routes HTTPRequest to appropriate module
	* and triggers event execution
	**/  
	public class RequestRouter : GLib.Object {

		public HTTPRequest Req { get; private set; }
		private WebServerContext context;

		public RequestRouter (HTTPRequest req, WebServerContext cxt) {
			
			context = cxt;
			Req = req;
			AppModule? mod = null;
			
			// Get the appropriate module for the request
			mod = context.Modules.GetHostModule(req.Host);
			
			if (mod != null) {

				context.Err.WriteMessage("Sending request to module for handling", ErrorManager.QErrorClass.QETESH_DEBUG);
				
				mod.Handle(Req);
				
				Req.Respond();
			}
			else context.Err.WriteMessage("Module seek for host returned empty", ErrorManager.QErrorClass.MODULE_CRITICAL);
			
		}
			
	}
}
