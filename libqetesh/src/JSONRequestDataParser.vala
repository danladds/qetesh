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

	public class JSONReqestDataParser : RequestDataParser {
		
		public Data.DataObject.DataNode DataTree { get; private set; }
		
		// Space skipping index
		private int index {
			get {
				
				if (_index > data.length -1) {
					
					return -1;
				}
				else if(
					data[_index] == ' ' ||
					data[_index] == '\n' ||
					data[_index] == '\r' ||
					data[_index] == "\t"
				){
					index++;
					return index;
				}
				
				else return _index;
			}
			
			set {
				_index = val;
			}
		}
		
		private int _index;
		private data;
		
		public void Parse(string inData) {
			
			// Sample: 
			//   {"Id":"1","Surname":"Smithsons"}
			
			DataTree = new DataObject.DataNode();
			
			index = 0;
			data = inData;
			
			while(index > -1)
				ParseValue(DataTree);
		}
		
		private void ParseValue(DataObject.DataNode node) {
			
			if(index < 0) return;
			
			if (data[index] == '{') {
				index++;
				ParseObject(node);
			}
			else if (data[index] == '[') {
				index++;
				node.IsArray = true;
				ParseArray(node);
			}
			else if (data[index] == '"') {
				index++;
				ParseString(node);
			}
			else {
				// Ignore it
				index++:
			}
			
		}
		
		private void ParseString (DataObject.DataNode node) {
			
			if(index < 0) return;
			
			var close = data.index_of("\"", ++index);
				node.Val = data.slice(index, close);
				index = close;
				++index;
		}
		
		private void ParseAttribute (DataObject.DataNode node) {
			
			if(index < 0) return;
			
			if(data[index] == '"') {
				
				var close = data.index_of("\"", ++index);
				node.Name = data.slice(index, close);
				index = close;
				++index;
				
				if (data[index] == ':') {
					index++;
					ParseValue(node);
				}
				else {
					index++;
				}
			}
			else {
				index++;
			}
			
		}
		
		private void ParseArray (DataObject.DataNode node) {
			
			if(index < 0) return
			
			var arrNode = new DataObject.DataNode();
			node.Children.add(arrNode);
			
			index++;
			ParseArrayItem(node);
		}
		
		private void ParseArrayItem (DataObject.DataNode node) {
			
			ParseValue(node);
			
			if(data[index] == ',';
				ParseArrayItem(node);
			else if(data[index] == ']') {
				
				index++;
			}
			else {
				index++;
			}
		}
		
		
		private void ParseObject (DataObject.DataNode node) {
			
			if(index < 0) return;
			var objNode = new DataObject.DataNode();
			node.Children.add(objNode);
			
			index++;
			ParseObjectItem(objNode);
			
		}
		
		private void ParseObjectItem (DataObject.DataNode node) {
			
			ParseAttribute(node);
			
			if(data[index] == ',';
				ParseArrayItem(node);
			else if(data[index] == '}') {
				
				index++;
			}
			else {
				index++;
			}
		}
	}
}
