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
		
		public Data.DataNode DataTree { get; protected set; }
		
		// Space skipping, one-way, one-pass index
		private int index {
			get {
				
				if (_index > data.length -1 || data[_index] == '\0') {
					
					return -1;
				}
				else if (_index == -1) return -1;
				else if(
					data[_index] == ' ' ||
					data[_index] == '\n' ||
					data[_index] == '\r' ||
					data[_index] == '\t'
				){
					_index++;
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
		
		public void Parse(string inData) throws ParserError {
			
			// Samples: 
			//   {"Id":"1","Surname":"Smithsons"}
			//   {"Price":499,"Description":"Camels","Id":"0"}
			
			DataTree = new DataNode();
			DataTree.IsArray = true;
			
			index = 0;
			data = inData;

			ParseArrayItem(DataTree, true);
		}
		
		private void ParseValue(DataNode node, string name) throws ParserError {
			
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
			else if (data[index].isdigit()) {
				ParseNumber(node, name);
			}
			else if (data[index] == 't' && data.index_of("true", index) == index) {
				AddBool(node, name, true);
			}
			else if (data[index] == 'f' && data.index_of("false", index) == index) {
				AddBool(node, name, false);
			}
			else {
				throw new ParserError.INVALID_CHAR("Unxpected char at index %d ; expected value (%c)".printf(_index, data[_index]));
			}
			
		}
		
		private void ParseNumber (DataNode node, string name) throws ParserError {
			
			var start = index;
			
			if(index < 0) return;
			
			do {
				++index;
				
			} while (data[index].isdigit());
			
			var strNode = new DataNode(name);
			
			// We just set string values here because
			// the validators on the DataObject deal with
			// converting and checking values
			
			strNode.Val = data.slice(start, index);				
			node.Children.add(strNode);
		}
		
		private void AddBool (DataNode node, string name, bool val) throws ParserError {
			
			if(index < 0) return;
			
			var strNode = new DataNode(name);
			
			strNode.Val = val ? "true" : "false";				
			node.Children.add(strNode);
			
			index = index + (val ? 4 : 5);
		}
		
		private void ParseString (DataNode node, string name) throws ParserError {
			
			if(index < 0) return;
			
			var strNode = new DataNode(name);
			
			var close = data.index_of("\"", index);
				strNode.Val = data.slice(index, close);
				index = close;
				++index;
				
			node.Children.add(strNode);
		}
		
		private void ParseAttribute (DataNode node) throws ParserError {
			
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
					throw new ParserError.INVALID_CHAR("Unxpected char at index %d ; expected : (%c)".printf(_index, data[_index]));
				}
			}
			else {
				throw new ParserError.INVALID_CHAR("Unxpected char at index %d ; expected \" (%c)".printf(_index, data[_index]));
			}
			
		}
		
		private void ParseArray (DataNode node, string name) throws ParserError {
			
			if(index < 0) return;
			
			var arrNode = new DataNode(name);
			node.Children.add(arrNode);
			
			ParseArrayItem(node);
		}
		
		private void ParseArrayItem (DataNode node, bool top = false) throws ParserError {
			
			if(index < 0) return;
			
			ParseValue(node, "(Array Item)");
			
			if(data[index] == ',')
				ParseArrayItem(node, top);
			else if(data[index] == ']') {
				
				index++;
			}
			else if(top) {
				return;
			}
			else if(data[index] == '\0') {
				throw new ParserError.INVALID_CHAR("Unxpected end of input at index %d; expected , or ]".printf(_index));
			}
			else {
				throw new ParserError.INVALID_CHAR("Unxpected char at index %d; expected , or ] (%c)".printf(_index, data[_index]));
			}
		}
		
		
		private void ParseObject (DataNode node, string name) throws ParserError {
			
			if(index < 0) return;
			var objNode = new DataNode(name);
			node.Children.add(objNode);
			
			ParseObjectItem(objNode);
			
		}
		
		private void ParseObjectItem (DataNode node) throws ParserError {
			
			if(index < 0) return;
			
			ParseAttribute(node);
			
			if(data[index] == ',') {
				index++;
				ParseObjectItem(node);
			}
			else if(data[index] == '}') {
				
				index++;
			}
			else {
				throw new ParserError.INVALID_CHAR("Unxpected char  at index %d; expected , or } (%c)".printf(_index, data[_index]));
			}
		}
	}
}
