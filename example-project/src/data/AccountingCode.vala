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
	
	public class AccountingCode : DataObject<AccountingCode> {
		
		public int Id { get; set; }
		public string Name { get; set; }
		public string Code { get; set; }
		
		public AccountingCode(QDatabaseConn db) {
			
			base(db);
		}
		
		public override void Init () {
				
				TableName = "accountingcode";
				ClientName = "AccountingCode";
				
				Validators["Name"] = new StringValidator().Matches("^[A-Za-z0-9]+$");
				Validators["Code"] = new StringValidator().Matches("^[A-Za-z0-9]{4}$");
		}
		
		public override string NameTransform(string fieldName) {
			
			return fieldName.down();
		}
	}
}
