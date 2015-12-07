/*
 * QDataQuery.vala
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


using Qetesh;

namespace Qetesh.Data {

	public abstract class QDataQuery : GLib.Object {
		
		public abstract QDataQuery Create();
		public abstract QDataQuery Read();
		public abstract QDataQuery Update();
		public abstract QDataQuery Delete();
		public abstract QDataQuery Count();
		
		public abstract QDataQuery DataSet(string setName);
		
		public abstract QueryResult Do() throws QDBError;
		public abstract int DoInt() throws QDBError;
		
		public abstract QueryParam Where(string fieldName);
		public abstract QueryParam Set(string fieldName);
		
		protected abstract Gee.LinkedList<Gee.TreeMap<string, string>> Fetch() throws QDBError;
		
		public abstract class QueryParam {
			
			public abstract QueryParam Equal(string val);
			public abstract QueryParam Like(string val);
			public abstract QueryParam GreaterThan(string val);
			public abstract QueryParam LessThan(string val);
		}
		
		public abstract class QueryResult {
			
			public abstract Gee.LinkedList<Gee.TreeMap<string, string>> Items { get; protected set; }
		}
	}
}
