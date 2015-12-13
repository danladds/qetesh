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

		public RequestRouter (HTTPRequest req, WebServerContext cxt) throws QRouterError {
			
			context = cxt;
			Req = req;
			AppModule? mod = null;
			
			// Get the appropriate module for the request
			mod = context.Modules.GetHostModule(req.Host);
			
			if(mod == null) throw new QRouterError.MODULE("Module seek for host returned empty");
			
			// Drop privileges and taken on module user before dispatching
			/// TODO: Obviously this breaks buildability on Windows
			/// TODO: something about the module init stage
			/// TODO: verify validity of drop
			context.Err.WriteMessage("Dropping root", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			if(Posix.getuid() == 0) {
				Posix.setgid(mod.ExecGroup);
				Posix.setuid(mod.ExecUser);
				
				context.Err.WriteMessage("Dropping root", ErrorManager.QErrorClass.QETESH_DEBUG);
				
				if(Posix.getuid() == 0) {
					
					throw new QRouterError.USER("Unable to drop privilege");
				}
				else {
					context.Err.WriteMessage("Not started as root. Can't switch user. Proceeding as existing user!", ErrorManager.QErrorClass.QETESH_WARNING);
				}
			}
			

			context.Err.WriteMessage("Sending request to module for handling", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			try {
				mod.Handle(Req);
			}
			catch(QModuleError e) {
				
				throw new QRouterError.MODULE("Error during module handing:\n %s".printf(e.message));
			}
			
			try {
				Req.Respond();
			}
			catch(QResponseError e) {
				
				throw new QRouterError.RESPONSE("Error during response:\n %s".printf(e.message));
			}
			
		}
			
	}
}
