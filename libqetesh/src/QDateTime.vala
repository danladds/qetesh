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
	
	public class QDateTime : GLib.Object {
	
		private DateTime dt;
		
		public QDateTime() {
			
			dt = new DateTime(new TimeZone.local(), 0,0,0,0,0,0);
		}
		
		public void fromString(string inVal) {
			
			// Format: 2015-11-04 00:00:00
			var mainParts = inVal.split(" ");
			var dateParts = mainParts[0].split("-");
			var timeParts = mainParts[1].split(":");
			
			dt = new DateTime(new TimeZone.local(), int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]), int.parse(timeParts[0]), int.parse(timeParts[1]), int.parse(timeParts[2]));
		}
		
		public string toString() {
			
			return dt.to_string();
		}
	}
}
