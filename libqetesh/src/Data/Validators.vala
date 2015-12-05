/*
 * Validators.vala
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
	
	public abstract class Validator<TField> : Object {
		
		public string Name { get; set; }
		
		public bool Passed { get; set; default = false; }
		public bool Mandatory { get; set; default = true; }
		
		public string InValue { get; set; }
		public TField OutValue { get; set; }
			
		public Gee.LinkedList<ValidationTest> Tests;
		
		public Validator() {
			
			Tests = new Gee.LinkedList<ValidationTest>();
		}
		
		public bool Validate() {
						
			Passed = true;
			
			foreach(ValidationTest<TField> t in Tests) {
				
				if(!t.Run(InValue)) {
					
					Passed = false;
				}
			}
			
			return Passed;
		}
		
		// Read from string input to output type
		public abstract void Convert();
	}
	
	public class ValidationTest<T> : Object {
			
		public string TestName { get; set; }
		public bool Passed { get; set; default = false; }
		
		public abstract delegate bool TestFunc();
		
		public TestFunc Func;
		
		public string Comparator { get; set; default=""; }
		
		public bool Run(T val) {
			
			if (Func != null) {
				Passed = Func();
				
			}
			else {
				Passed = false;
			}
			
			return Passed;
		}
	}
	
	public class IntValidator : Validator<int?> {
		
		public IntValidator() {
			
			Name = "INT";
		}
		
		public IntValidator GreaterThan(int comp) {
			
			Tests.add(new ValidationTest<int?>() { 
				
				TestName = "GT",
				Comparator = comp.to_string(),
				Func = () => {
					
					this.Passed = (this.OutValue > comp);
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public IntValidator LessThan (int comp) {
			
			Tests.add(new ValidationTest<int?>() { 
				
				TestName = "LT",
				Comparator = comp.to_string(),
				Func = () => {
						
					this.Passed = (this.OutValue < comp);
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public IntValidator Equals (int comp) {
			
			Tests.add(new ValidationTest<int?>() { 
				
				TestName = "EQUALS",
				Comparator = comp.to_string(),
				Func = () => {
					
					this.Passed = (this.OutValue == comp);
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public override void Convert() {
			
			var t = new ValidationTest<int?>();
			t.TestName = "IS";
			
			if(InValue == "0") {
				OutValue = 0;
				t.Passed = true;
			}
			else {
				
				var val = int.parse(InValue);
				
				if(val != 0) {
					
					t.Passed = true;
					OutValue = val;
				}
			}
			
			Tests.add(t);
			
		}
	}
	
	public class StringValidator : Validator<string> {
		
		public StringValidator() {
			
			Name = "STRING";
		}
		
		public StringValidator Contains(string comp) {
			
			Tests.add(new ValidationTest<string>() { 
				
				TestName = "CONTAINS",
				Comparator = comp,
				Func = () => {
					
					this.Passed = (this.OutValue.contains(comp));
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public StringValidator DoesntContain(string comp) {
			
			Tests.add(new ValidationTest<string>() { 
				
				TestName = "NOCONTAIN",
				Comparator = comp,
				Func = () => {
					
					this.Passed = (!this.OutValue.contains(comp));
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public StringValidator Equals(string comp) {
			
			Tests.add(new ValidationTest<string>() { 
				
				TestName = "EQUALS",
				Comparator = comp,
				Func = () => {
					
					this.Passed = (this.OutValue == comp);
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public StringValidator Matches(string regex) {
			
			Tests.add(new ValidationTest<string>() { 
				
				TestName = "MATCHES",
				Comparator = regex,
				Func = () => {
					
					this.Passed = (Regex.match_simple(regex, this.OutValue));
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public override void Convert() {
			
			var t = new ValidationTest<string>();
			t.TestName = "IS";
					
			t.Passed = true;
			OutValue = InValue;
			
			Tests.add(t);
		}
	}
	
	public class DoubleValidator : Validator<double?> {
		
		public DoubleValidator() {
			
			Name = "DOUBLE";
		}
		
		public DoubleValidator GreaterThan(double? comp) {
			
			Tests.add(new ValidationTest<double?>() { 
				
				TestName = "GT",
				Comparator = comp.to_string(),
				Func = () => {
					
					this.Passed = (this.OutValue > comp);
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public DoubleValidator LessThan (double? comp) {
			
			Tests.add(new ValidationTest<double?>() { 
				
				TestName = "LT",
				Comparator = comp.to_string(),
				Func = () => {
					
					this.Passed = (this.OutValue < comp);
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public DoubleValidator Equals (double? comp) {
			
			Tests.add(new ValidationTest<double?>() { 
				
				TestName = "GT",
				Comparator = comp.to_string(),
				Func = () => {
					
					this.Passed = (this.OutValue > comp);
					return this.Passed;
				}
			});
			
			return this;
		}
		
		public override void Convert() {
			
			var t = new ValidationTest<double?>();
			t.TestName = "IS";
			
			double res;
			
			t.Passed = double.try_parse(InValue, out res);
			
			if(t.Passed) {
				
				OutValue = res;
			}
			
			Tests.add(t);
			
		}
	}
	
	public class BoolValidator : Validator<bool?> {
		
		public BoolValidator() {
			
			Name = "BOOL";
		}
		
		public override void Convert() {
		
			var val = InValue;
			val = val.down();
			
			var t = new ValidationTest<bool?>();
			t.TestName = "IS";
			
			if(val == "true") {
				
				OutValue = true;
				t.Passed = true;
				
			}
			else if(val == "false") {
				
				OutValue = false;
				t.Passed = true;
			}
			else {
				
				t.Passed = false;
			}
			
			Tests.add(t);
		}
	}
	
	public class QDateTimeValidator : Validator<QDateTime> {
		
		
		public QDateTimeValidator() {
			
			Name = "QDATETIME";
		}
		
		public override void Convert() {
		
			var val = InValue;
			
			var t = new ValidationTest<QDateTime>();
			t.TestName = "IS";
			
			var dt = new QDateTime();
			
			try {
				dt.fromString(InValue);
			}
			catch(ValidationError e) {
				
				t.Passed = true;
			}
			
			OutValue = dt;
			t.Passed = true;
			
			Tests.add(t);
		}
	}
}
