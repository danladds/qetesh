/*
 * HTMLElement.vala
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
	
	/// NOTE: Depricated!
	
	/**
	* Represents a HTML element, or set of elements, in the user interface.
	* Remember that the Vala code is flying blind - it's up to the
	* Javascript to check whether said elements actually exist
	**/  
	public class HTMLElement : GLib.Object {
		
		private LinkedList<HTMLElement> children;
		
		/// Between-the-tags content
		public string Content { get; set; }
		
		/// Form-field value (inc. textbox)
		public string Val { get; set; }
		
		public int size {
			get {
				
				return 1;
			}
		}
		
		public string Selector { get; set; }
		
		public new HTMLElement? get (string selector) {
			
			return new HTMLElement(selector);
		}

		internal HTMLElement(string selector) {
			
			Selector = selector;
			children = new LinkedList<HTMLElement>();
		}
		
		public delegate void PropogateCallback(Qetesh.Data.DataObject datum, HTMLElement elem);
		
		public HTMLElement Propogate() {
			
			return new HTMLElement("_");
		}
		
		public HTMLElement Replicate(int copies) {
			
			return new HTMLElement("_");
		}
		
		public void Attach(QEvent ev) {
			
		}
	}

}
