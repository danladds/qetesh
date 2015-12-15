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
		public bool NullOut { get; protected set; default = false; }
		
		public string InValue { get; set; }
		public TField OutValue { get; set; }
			
		public Gee.LinkedList<ValidationTest> Tests;
		
		public Validator() {
			
			Tests = new Gee.LinkedList<ValidationTest>();
		}
		
		public bool Validate() {
						
			Passed = true;
			
			foreach(ValidationTest<TField> t in Tests) {
				
				if(NullOut) {
					t.Passed = true;
				}
				else if(!t.Run()) {
					
					Passed = false;
				}
			}
			
			return Passed;
		}
		
		public string DumpResult() {
			
			var res = new StringBuilder();
			
			res.append(this.Name);
			res.append(" : ");
			
			foreach(var t in Tests) {
				res.append(t.TestName);
				res.append(": ");
				res.append((t.Passed ? "Passed" : "Failed"));
				res.append(" (%s) \n".printf(t.Comparator));
			}
			
			res.append("  [%s] \n".printf(InValue));
			
			return res.str;
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
		
		public bool Run() {
			
			if (Func != null) {
				Passed = Func();
				
			}
			else {
				
				// Pre-done tests like Convert()
			}
			
			return Passed;
		}
	}
	
	public class IntValidator : Validator<int?> {
		
		protected bool ValidInt { get; private set; default = false; }
		
		public IntValidator() {
			
			Name = "IntValidator";
		}
		
		public IntValidator GreaterThan(int comp) {
			
			var test = new ValidationTest<int?>() { 
				
				TestName = "GreaterThan",
				Comparator = comp.to_string()
			};
			
			test.Func = () => {
					
				test.Passed = (this.OutValue > comp);
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public IntValidator LessThan (int comp) {
			
			var test = new ValidationTest<int?>() { 
				
				TestName = "LessThan",
				Comparator = comp.to_string()
			};
			
			test.Func = () => {
						
				test.Passed = (this.OutValue < comp);
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public IntValidator Equals (int comp) {
			
			var test = new ValidationTest<int?>() { 
				
				TestName = "Equals",
				Comparator = comp.to_string()
			};
			
			test.Func = () => {
				
				test.Passed = (this.OutValue == comp);
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public override void Convert() {
			
			var t = new ValidationTest<int?>();
			t.TestName = "Convert";
			
			if(InValue == null || InValue == "") {
				
				if(Mandatory) {
					t.Passed = false;
				}
				else {
					t.Passed = true;
					OutValue = null;
					NullOut = true;
				}
				
				return;
			}
			
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
			ValidInt = t.Passed;
		}
	}
	
	public class EnumValidator : IntValidator {
		
		public Gee.HashMap<int, string> AllowableValues { get; private set; }
		public bool ValidEnum { get; private set; default = false; }
		
		public EnumValidator(Type enumType) {
			
			base();
			
			Name = "EnumValidator";
			
			AllowableValues = new Gee.HashMap<int, string>();
			
			var enumProps = (EnumClass) enumType.class_ref();
			
			foreach(unowned EnumValue val in enumProps.values) {
				
				var intVal = val.value;
				var strVal = val.value_nick;
				
				AllowableValues.set(intVal, strVal);
			}
		}
		
		public override void Convert() {
			
			base.Convert();
			
			// Int in
			if(ValidInt && OutValue != null && OutValue > -1 &&  AllowableValues.has_key(OutValue)) {
				
				ValidEnum = true;
			}
			
			// Name in
			else {
				
				foreach(int intVal in AllowableValues.keys) {
					
					if(AllowableValues[intVal] == InValue) {
						
						OutValue = intVal;
						ValidEnum = true;
					}
				}
			}
		}
	}
	
	public class StringValidator : Validator<string> {
		
		public StringValidator() {
			
			Name = "StringValidator";
		}
		
		public StringValidator Contains(string comp) {
			
			var test = new ValidationTest<string>() { 
				
				TestName = "Contains",
				Comparator = comp
			};
			
			test.Func = () => {
				
				test.Passed = (this.OutValue.contains(comp));
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public StringValidator DoesntContain(string comp) {
			
			var test = new ValidationTest<string>() { 
				
				TestName = "DoesntContain",
				Comparator = comp
			};
			
			test.Func = () => {
				
				test.Passed = (!this.OutValue.contains(comp));
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public StringValidator Equals(string comp) {
			
			var test = new ValidationTest<string>() { 
				
				TestName = "Equals",
				Comparator = comp
			};
			
			test.Func = () => {
					
				test.Passed = (this.OutValue == comp);
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public StringValidator Matches(string regex) {
			
			var test = new ValidationTest<string>() { 
				
				TestName = "Matches",
				Comparator = regex
			};
			
			test.Func = () => {
					
				if(regex == null || regex == "" || this.OutValue == null) {
					
					test.Passed = false;
					return test.Passed;
				}
				
				test.Passed = Regex.match_simple(
					regex, this.OutValue,
					RegexCompileFlags.JAVASCRIPT_COMPAT
				);
				
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public override void Convert() {
			
			var t = new ValidationTest<string>();
			t.TestName = "Convert";
			
			if(InValue != null || !Mandatory) {
				OutValue = InValue;
				t.Passed = true;
				
				if(!Mandatory) NullOut = true;
				
				return;
			} 
			else {
				t.Passed = false;
				return;
			}
			
			Tests.add(t);
		}
	}
	
	public class DoubleValidator : Validator<double?> {
		
		public DoubleValidator() {
			
			Name = "DoubleValidator";
		}
		
		public DoubleValidator GreaterThan(double? comp) {
			
			var test = new ValidationTest<double?>() { 
				
				TestName = "GreaterThan",
				Comparator = comp.to_string()
			};
			
			test.Func = () => {
				
				test.Passed = (this.OutValue > comp);
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public DoubleValidator LessThan (double? comp) {
			
			var test = new ValidationTest<double?>() { 
				
				TestName = "LessThan",
				Comparator = comp.to_string()
			};
			
			test.Func = () => {
					
				test.Passed = (this.OutValue < comp);
				return test.Passed;
			};
			
			Tests.add(test);
			
			return this;
		}
		
		public DoubleValidator Equals (double? comp) {
			
			var test = new ValidationTest<double?>() { 
				
				TestName = "Equals",
				Comparator = comp.to_string()
			};
			
			test.Func = () => {
					
				test.Passed = (this.OutValue > comp);
				return test.Passed;
			};
			
			return this;
		}
		
		public override void Convert() {
			
			var t = new ValidationTest<double?>();
			t.TestName = "Convert";
			
			if(InValue == null || InValue == "") {
				
				if(Mandatory) {
					t.Passed = false;
				}
				else {
					t.Passed = true;
					OutValue = null;
					NullOut = true;
				}
				
				return;
			}
			
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
			
			Name = "BoolValidator";
		}
		
		public override void Convert() {
		
			var val = InValue;
			val = val.down();
			
			var t = new ValidationTest<bool?>();
			t.TestName = "Convert";
			
			if(InValue == null || InValue == "") {
				
				if(Mandatory) {
					t.Passed = false;
				}
				else {
					t.Passed = true;
					OutValue = null;
					NullOut = true;
				}
				
				return;
			}
			
			if(val == "true") {
				
				OutValue = true;
				t.Passed = true;
				
			}
			else if(val == "false") {
				
				OutValue = false;
				t.Passed = true;
			}
			else if(val == "0") {
				
				OutValue = false;
				t.Passed = true;
			}
			else if(val == "1") {
				
				OutValue = true;
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
			
			Name = "QDateTimeValidator";
		}
		
		public override void Convert() {
		
			var val = InValue;
			
			var t = new ValidationTest<QDateTime>();
			t.TestName = "Convert";
			
			if(InValue == null || InValue == "") {
				
				if(Mandatory) {
					t.Passed = false;
				}
				else {
					t.Passed = true;
					OutValue = null;
					NullOut = true;
				}
				
				return;
			}
			
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
