/*
 * Invoice.vala
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

namespace QExample.Data {
	
	// Class representing and handing "invoice" database table
	// Note inherit with generic
	public class Invoice : DataObject<Invoice> {
		
		// Regular fields
		public int Id { get; set; }
		public string Forename { get; set; }
		public string Surname { get; set; }
		public QDateTime Issued { get; set; }
		public int Total { get; set; }
		
		// Lazy property with database lazy-load call
		public Gee.LinkedList<InvoiceItem> Items { 
			
			get { 
					if (_items == null) {
						
						// LazyLoadList returns a list of DataObject, which
						// needs casting to this type (which it really is)
						// Params: This property's name, foreign class type
						_items = (Gee.LinkedList<InvoiceItem>) LazyLoadList("Items", typeof(InvoiceItem));
					}
					
					return _items;
				}
			private set{  }
		}
		
		// Store for lazy property
		private Gee.LinkedList<InvoiceItem>? _items { get; set; }
		
		// Always chain up to base with db connection
		public Invoice(QDatabaseConn db) {
			
			base(db);
		}
		
		// Configure data object on Init() rather than constructor
		public override void Init() {
			
			TableName = "invoice";
			Issued = new QDateTime();
			
			Validators["Forename"] = new StringValidator().Matches("^[A-Za-z0-9 ]+$");
			Validators["Surname"] = new StringValidator().Matches("^[A-Za-z0-9 ]+$");
			Validators["Issued"] = new QDateTimeValidator();
			Validators["Total"] = new IntValidator().GreaterThan(0).LessThan(99999999);
		}
		
		// Override NameTransform as here, which is called as a transform
		// on field names between object and database
		// i.e. this class has the property "Forename", database has "forename"
		public override string NameTransform(string fieldName) {
			
			return fieldName.down();
		}
		
	}
}
