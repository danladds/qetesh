/*
 * QExample.vala
 * 
 * Copyright 2015 Dan Ladds <Dan@el-topo.co.uk>
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


using Qetesh;
using Qetesh.Data;

Type mod_init (WebAppContext ctx) {
	
	return typeof(ExampleLoader);
}

public class ExampleLoader : QPlugin, Object {

	public QWebApp GetModObject (WebAppContext ctx) {
		
		return new QExample.QExample(ctx);
	}
}

namespace QExample {

	public class QExample : QWebApp {
		
		public QExample(WebAppContext ctx) {
			
			base(ctx);
			
			WriteMessage("QExample is go!", ErrorManager.QErrorClass.MODULE_DEBUG, "QExample");
			
			
			RootNode["invoice"] = new InvoiceNode();
			RootNode["manifest"] = new QManifest();
		}
	}

}
