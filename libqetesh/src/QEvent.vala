/*
 * QEvent.vala
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

	/**
	* A framework event
	* 
	* Represents an event occuring on the client side
	* and passed back to the server via JS/XHR, to be abstracted as
	* an event on the server side, as seen by modules.
	* 
	* Modules should create a new QEvent and bind their handler to its
	* EventFire signal (.EventFire.connect(f)).
	**/ 
	public class QEvent {
		
		/// Vala event to which modules can attach handlers
		public signal void EventFire(QEvent ev);
		
		/// Request context
		public HTTPRequest Request { get; private set; }
		
		/**
		* The type of event that occurred
		* 
		* Text form of the event, as used by client-side Javascript.
		* N.B. This is a string rather than an enum because we can't --
		* nor do we need to -- know what events future browsers are
		* capable of; it's the module's responsiblity to set and respond
		* to appropriate events.
		**/
		public string ClientEventType { get; set; }
		
		/**
		* Fire the event
		**/
		public void Fire(HTTPRequest req) {
			
			Request = req;
			EventFire(this);
		}
		
		/**
		* Create a new event
		* 
		* @param type Client-side event type (e.g. onclick)
		**/
		public QEvent(string type) {
			
			ClientEventType = type;
		}
	}
	
}
