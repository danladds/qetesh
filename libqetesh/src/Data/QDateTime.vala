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
			
			dt = new DateTime.now(new TimeZone.local());
		}
		
		public void fromString(string? inVal) throws ValidationError {
			
			if(inVal == null)
				throw new ValidationError.INVALID_DATETIME_STRING("Null date");
			
			// Format: 2015-11-04 00:00:00
			// or:     2011-10-05T14:48:00.000Z
			var mainParts = inVal.split_set(" T.");
			
			if(mainParts.length < 1 || mainParts.length > 3)
				throw new ValidationError.INVALID_DATETIME_STRING("Invalid format");
				
			int year = -1;
			int month = -1;
			int day = -1;
			
			int hour = 0;
			int minute = 0;
			int second = 0;
			string zone = "";
			
			if(mainParts.length == 3) {
				
				zone = mainParts[2];
			}
			
			var dateParts = mainParts[0].split("-");
			
			if(mainParts.length == 2) {
				var timeParts = mainParts[1].split(":");
				
				if(timeParts.length != 3)
					throw new ValidationError.INVALID_DATETIME_STRING("Invalid time format");
				
				hour = int.parse(timeParts[0]);
				minute = int.parse(timeParts[1]);
				second = int.parse(timeParts[2]);
			}
			
			if(dateParts.length != 3)
				throw new ValidationError.INVALID_DATETIME_STRING("Invalid date format");
				
			year = int.parse(dateParts[0]);
			month = int.parse(dateParts[1]);
			day = int.parse(dateParts[2]);
			
			
			
			if(
				year < 0 ||
				year > 60000 ||
				month < 1 ||
				month > 12 ||
				day < 0 ||
				day > 31 ||
				hour < 0 ||
				hour > 24 ||
				minute < 0 ||
				minute > 60 ||
				second < 0 ||
				second > 60
			) {
				
				throw new ValidationError.INVALID_DATETIME_STRING("Invalid value: %s".printf(inVal));
			}
			
			try {
				
				if(zone != "") {
					dt = new DateTime(new TimeZone(zone), year, month, day, hour, minute, second);
				}
				else {
					dt = new DateTime(new TimeZone.local(), year, month, day, hour, minute, second);
				}
			}
			catch(Error e) {
				
				throw new ValidationError.INVALID_DATETIME_STRING("Native DateTime conversion failed");
			}
		}
		
		public string toString() {
			
			return dt.to_string();
		}
	}
}
