/*
 * JSONResponse.vala
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

	public class JSONResponse : HTTPResponse {
		
		private int tabDepth;

		public JSONResponse (WebAppContext ctx) {
			
			base(ctx);
			
			// Event segment[], transform segment[], data segment[]
			
			ContentType = "text/javascript";
			tabDepth = 0;
		}
		
		public void Tab() {
			
			Content.append("\r\n");
			
			for(var i = 0; tabDepth > i; i++)
				Content.append("\t");
		}
		
		public override void ComposeContent() {
			
			Context.Server.Err.WriteMessage(
					"JSONResponse composing output content",
					ErrorManager.QErrorClass.QETESH_DEBUG);
			
			AddJson(this.DataTree, true);
		}
		
		public void AddJson(Data.DataObject.DataNode node, bool parentIsArray = false) {
			
			/*
			Context.Server.Err.WriteMessage(
					"JSONResponse adding node: %s = %s".printf(node.Name, node.Val),
					ErrorManager.QErrorClass.QETESH_DEBUG);
			*/
			
			if (!parentIsArray) {
				
				Content.append("\"");
				Content.append(node.Name);
				Content.append("\"");
				Content.append(" : ");
			}
			
			if (node.Val != null && node.Val != "") {
				
				Content.append("\"");
				Content.append(node.Val);
				Content.append("\"");
			}
			else if(node.Children.size > 0) {
				
				if(!node.IsArray) {
					Content.append(" { ");
				}
				else {
					Content.append(" [ ");
				}
				
				tabDepth++;
				bool first = true;
			
				foreach (var cn in node.Children) {
					
					if (!first) Content.append(",");
					Tab();
					AddJson(cn, node.IsArray);
					first = false;
				}
				
				tabDepth--;
				Tab();
				
				if(!node.IsArray) {
					Content.append(" } ");
				}
				else {
					Content.append(" ] ");
				}
			}
			else {
				Content.append("\"\", ");
			}
		}
	}

}
