/*
 * QWebNode.vala
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
using Qetesh.Data;

namespace Qetesh {

	/**
	 * Manifest for client side code
	 * Also potentially useful for API users
	 * 
	**/
	public class QManifest : QWebNode {
		
		private DataObject.DataNode ManifestRoot;
		
		public QManifest() {
			
			base();
			
			ManifestRoot = new DataObject.DataNode("Manifest");
		}
		
		public override void OnBind() {
			
			// Build manifest tree
			var rootNode =  Parent; 
			ManifestRoot.IsArray = false;
			
			var walker = new ManifestWalker(ManifestRoot);
			
			rootNode.WalkManifests(walker);
			
			GET.connect((req) => {
				
				// Just send the tree at request time
				req.HResponse.DataTree.IsArray = false;
				req.HResponse.DataTree.Children.add(ManifestRoot);
				
			});
		}
	}
}
