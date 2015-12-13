/*
 * InvoiceNode.vala
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
using QExample.Data;

namespace QExample {
	
	public class InvoiceNode : QWebNode {
		
		// OnBind is called on all QWebNodes when they are bound into
		// the URI tree. It's best to do most things then, because context.
		public override void OnBind() throws AppError {
			
			try {
				
				WriteMessage("Exposing Invoice class", ErrorManager.QErrorClass.MODULE_DEBUG, "QExample");
				
				// Expose CRUD (Create, Read, Update, Delete) functions of
				// the Invoice type, defined in ../data/Invoice.vala
				// Params: class type; database nick as as set in .conf file
				var exposer = ExposeCrud(typeof(Invoice), "example");
				
				WriteMessage("Exposing InvoiceItem", ErrorManager.QErrorClass.MODULE_DEBUG, "QExample");
				
				// InvoiceItem type (type of Invoice.Items) - expose on a subnode
				this["InvoiceItem"].ExposeCrud(typeof(InvoiceItem), "example");
				
				WriteMessage("Exposing Invoice.Items", ErrorManager.QErrorClass.MODULE_DEBUG, "QExample");
				
				exposer.Lazy(
				
					// Lazy() exposes the "Items" property of Invoice,
					// which is an array of InvoiceItem objects
					// Defined in ../data/InvoiceItem.vala
					// Params: Property name (as defined in class);
					// item class type; client function return type
					"Items", typeof(InvoiceItem), "InvoiceItem[]"
				);
				
				// ExposeCrud and Lazy both return a LazyLinker object
				// which can be chained with more Lazy() calls
				
				WriteMessage("Exposing AccountingType", ErrorManager.QErrorClass.MODULE_DEBUG, "QExample");
				
				// Expose AccountingCode type on a subnode
				// Just calling ExposeCrud here will overwrite
				// the existing Invoice exposure here
				this["AccountingCode"].ExposeCrud(typeof(AccountingCode), "example");
				
			} catch (ManifestError e) {
				
				throw new AppError.ABORT("Unable to expose objects: \n %s".printf(e.message));
			}
			finally {
				
				WriteMessage("InvoiceNode done its init", ErrorManager.QErrorClass.MODULE_DEBUG, "QExample");
			}
		}
	} 
}
