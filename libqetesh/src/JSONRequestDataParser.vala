/*
 * RequestDataParser.vala
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

	public class JSONReqestDataParser : GLib.Object, RequestDataParser {
		
		public Data.DataObject.DataNode DataTree { get; protected set; }
		
		// Space skipping, one-way, one-pass index
		private int index {
			get {
				
				if (_index > data.length -1) {
					
					return -1;
				}
				else if (_index == -1) return -1;
				else if(
					data[_index] == ' ' ||
					data[_index] == '\n' ||
					data[_index] == '\r' ||
					data[_index] == '\t'
				){
					index++;
					return index;
				}
				
				else return _index;
			}
			
			set {
				_index = value;
			}
		}
		
		private int _index;
		private string data;
		
		public void Parse(string inData) {
			
			// Sample: 
			//   {"Id":"1","Surname":"Smithsons"}
			
			DataTree = new DataObject.DataNode();
			DataTree.IsArray = true;
			
			index = 0;
			data = inData;

			ParseArrayItem(DataTree);
		}
		
		private void ParseValue(DataObject.DataNode node, string name) {
			
			if(index < 0) return;
			
			if (data[index] == '{') {
				index++;
				ParseObject(node, name);
			}
			else if (data[index] == '[') {
				index++;
				node.IsArray = true;
				ParseArray(node, name);
			}
			else if (data[index] == '"') {
				index++;
				ParseString(node, name);
			}
			else {
				// Ignore it
				index++;
			}
			
		}
		
		private void ParseString (DataObject.DataNode node, string name) {
			
			if(index < 0) return;
			
			var strNode = new DataObject.DataNode(name);
			
			var close = data.index_of("\"", index);
				strNode.Val = data.slice(index, close);
				index = close;
				++index;
				
			node.Children.add(strNode);
		}
		
		private void ParseAttribute (DataObject.DataNode node) {
			
			if(index < 0) return;
			
			if(data[index] == '"') {
				
				var close = data.index_of("\"", ++index);
				var name = data.slice(index, close);
				index = close;
				++index;
				
				if (data[index] == ':') {
					index++;
					ParseValue(node, name);
				}
				else {
					index++;
				}
			}
			else {
				index++;
			}
			
		}
		
		private void ParseArray (DataObject.DataNode node, string name) {
			
			if(index < 0) return;
			
			var arrNode = new DataObject.DataNode(name);
			node.Children.add(arrNode);
			
			ParseArrayItem(node);
		}
		
		private void ParseArrayItem (DataObject.DataNode node) {
			
			ParseValue(node, "(Array Item)");
			
			if(data[index] == ',')
				ParseArrayItem(node);
			else if(data[index] == ']') {
				
				index++;
			}
			else {
				index++;
			}
		}
		
		
		private void ParseObject (DataObject.DataNode node, string name) {
			
			if(index < 0) return;
			var objNode = new DataObject.DataNode(name);
			node.Children.add(objNode);
			
			ParseObjectItem(objNode);
			
		}
		
		private void ParseObjectItem (DataObject.DataNode node) {
			
			ParseAttribute(node);
			
			if(data[index] == ',') {
				index++;
				ParseObjectItem(node);
			}
			else if(data[index] == '}') {
				
				index++;
			}
			else {
				index++;
			}
		}
	}
}
