/*
 * EventManager.vala
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

namespace Qetesh {
	
	
	/**
	* Manages events for clients within and across requests
	**/ 
	public class EventManager : GLib.Object {
		
		/// List of managed events
		private ConcurrentList<QEvent> EventList;
		
		/// Create a new EventManager
		internal EventManager () {
			
			EventList = new ConcurrentList<QEvent>();
		}
		
		public string GetEventCode () {
			
			var code = new StringBuilder();
			
			foreach (var ev in EventList) {
				code.append(ev.ClientEventType);
			}
			
			return code.str;
		}
		
		/**
		* Register an event
		* 
		* If called with a clientID, the event will be registered for
		* that client only. Otherwise it is registered for all clients
		* 
		* @param ev The event itself
		* @param clientId ID of the client to bind for
		**/ 
		
		public void RegisterEvent(QEvent ev, string? clientId = null) {
			
			 EventList.add(ev);
		}
		
		/**
		* Call events for the current client
		* 
		* If clientID is provided, call all global events plus all
		* client-specific events; otherwise, just call all global events
		* 
		* @param clientID ID of the client
		**/
		public void CallEvents (string? clientId = null) {
			
			// Client-specific events
			if (clientId != null) {
				
				
			}
			
			// Global events
			foreach (var ev in EventList) {
				
			}
		}
	}
	
}
