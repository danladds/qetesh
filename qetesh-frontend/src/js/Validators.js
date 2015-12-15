/**
 * Qetesh Javascript
 * Validators
 * 
 * Copyright 2014 Dan Ladds <dan@danladds.com>
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
 **/

"use strict";

Qetesh.Validator = {
		
	Name : "UNNAMED VALIDATOR!",
	Passed : false,
	Mandatory : true,
	Tests : [],
	Value : "",
	InValue : null,
	OutValue : null,
	NullOut : false,
	
	Obj : function() {
	
		var obj = Object.create(this);
		obj.Init();
			
		return obj;
	}, 
	
	Init : function () {
		
		this.Tests = [];
		this.Passed = false;
		
	},
	
	Update : function () {
		
		this.Passed = true;
		
		var tLen = this.Tests.length;
		
		for(var i = 0; i < tLen; i++) {
			
			if(this.Tests[i].Passed != true) {
				
				this.Passed = false;
			}
		}
	},
	
	SetSuccess : function () {
		
		this.Passed = true;
		
		var tLen = this.Tests.length;
		
		for(var i = 0; i < tLen; i++) {
			
			this.Tests[i].Passed == true;
		}
	},
	
	Validate : function () {
		
		this.Passed = true;
		
		if(this.InValue == null && !this.Mandatory) {
			
			this.OutValue = null;
			return this.Passed;
		}
		
		var tLen = this.Tests.length;
		
		for(var i = 0; i < tLen; ++i) {
			
			if(this.Tests[i].Run() != true) {
				
				this.Passed = false;
			}
		}
		
		return this.Passed;
	},
	
	Convert : function () {
		
		throw Qetesh.Errors.ValidationError.Obj("Convert function must be overridden by validators");
	}
};
	
Qetesh.ValidationTest = {
		
	TestName : "UNNAMED VALIDATION TEST!",
	Passed : false,
	Func : null,
	Comparator : "",
	
	Obj : function() {
	
		var obj = Object.create(Qetesh.ValidationTest);
		obj.Init();
			
		return obj;
	}, 
	
	Init : function () {
		
		
	},
	
	Run : function() {
		
		if (this.Func != null) {
			this.Passed = this.Func();
			
		}
		else {
			
			this.Passed = true;
		}
		
		return this.Passed;
	}
};
	
Qetesh.Validators = {
	
	IntValidator : {
		
		Obj : function () {
			
			var _this = Qetesh.Validator.Obj();
			
			_this.GreaterThan = this.GreaterThan;
			_this.LessThan = this.LessThan;
			_this.Equals = this.Equals;
			_this.Convert = this.Convert;
			
			_this.Name = "IntValidator";
			
			return Object.create(_this);
		},
		
		GreaterThan : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "GreaterThan";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue > this.Comparator);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		LessThan : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "LessThan";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue < this.Comparator);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		Equals : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "Equals";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue == this.Comparator);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		Convert : function() {
			
			var test = new Qetesh.ValidationTest.Obj();
			test.TestName = "Convert";
			//this.Tests.push(test);
			
			if(!this.Mandatory && this.InValue == null) {
				
				this.OutValue = null;
				this.Passed = true;
				test.Passed = true;
				this.NullOut = true;
				return;
			}
			
			var valRet = parseInt(this.InValue, 10);
			
			if(isNaN(valRet)) {
				
				test.Passed = false;
			}
			else {
				test.Passed = true;
				this.Passed = true;
				this.OutValue = valRet;
			}
		}
	},
	
	EnumValidator : {
		
		AllowableValues : {},
		ValidEnum : false,
		
		Obj : function () {
			
			var _this = Qetesh.Validators.IntValidator.Obj();
			
			_this._Convert = _this.Convert;
			_this.Convert = this.Convert;
			_this.AllowableValues = { };
			
			_this.Name = "EnumValidator";
			
			return Object.create(_this);;
		},
		
		Convert : function() {
			
			this._Convert();
			
			// Int in
			if(this.AllowableValues[this.OutValue] != null) {
				
				this.ValidEnum = true;
			}
			
			else {
				
				for(var intVal in this.AllowableValues) {
					
					if(this.AllowableValues.hasOwnProperty(intVal)) {
						
						if (this.AllowableValues[intVal] == this.InValue) {
							
							this.OutValue = intVal;
							this.ValidEnum = true;
						}
					}
				}
			}
		}
	},

	StringValidator : {
		
		Obj : function () {
			
			var _this = Qetesh.Validator.Obj();
			
			_this.Contains = this.Contains;
			_this.DoesntContain = this.DoesntContain;
			_this.Matches = this.Matches;
			_this.Equals = this.Equals;
			_this.Convert = this.Convert;
			
			_this.Name = "StringValidator";
			
			return Object.create(_this);;
		},
		
		Equals : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "Equals";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue == this.Comparator);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		Contains : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "Contains";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue.indexOf(this.Comparator) != -1);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		DoesntContain : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "DoesntContain";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue.indexOf(this.Comparator) == -1);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		Equals : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "Equals";
			test.Comparator = comp;
			test.Func = function() {
				
				test.Passed = (_this.OutValue == test.Comparator);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		Matches : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "Matches";
			test.Comparator = comp;
			test.Func = function() {
				
				var rx = new RegExp(test.Comparator);
				
				test.Passed = rx.test(_this.OutValue);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		Convert : function() {
			
			var test = new Qetesh.ValidationTest.Obj();
			test.TestName = "Convert";
			//this.Tests.push(test);
			
			if(!this.Mandatory && this.InValue == null) {
				
				this.OutValue = null;
				this.Passed = true;
				test.Passed = true;
				this.NullOut = true;
				return;
			}

			test.Passed = true;
			this.OutValue = this.InValue;
			this.Passed = true;
		}
	},
	
	DoubleValidator : {
		
		Obj : function () {
			
			var _this = Qetesh.Validator.Obj();
			
			_this.GreaterThan = this.GreaterThan;
			_this.LessThan = this.LessThan;
			_this.Equals = this.Equals;
			_this.Convert = this.Convert;
			
			_this.Name = "DoubleValidator";
			
			return Object.create(_this);
		},
		
		GreaterThan : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "GreaterThan";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue > this.Comparator);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		LessThan : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "LessThan";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue < this.Comparator);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		Equals : function(comp) {
			
			var test = new Qetesh.ValidationTest.Obj();
			var _this = this;
			
			test.TestName = "Equals";
			test.Comparator = comp;
			test.Func = function() {
				
				this.Passed = (_this.OutValue == this.Comparator);
				return this.Passed;
			}
			
			this.Tests.push(test);
		},
		
		Convert : function() {
			
			var test = new Qetesh.ValidationTest.Obj();
			test.TestName = "Convert";
			//this.Tests.push(test);
			
			if(!this.Mandatory && this.InValue == null) {
				
				this.OutValue = null;
				this.Passed = true;
				test.Passed = true;
				this.NullOut = true;
				return;
			}
			
			var valRet = parseFloat(this.InValue, 10);
			
			if(isFinite(valRet)) {
				
				test.Passed = false;
			}
			else {
				test.Passed = true;
				this.OutValue = valRet;
			}
		}
	},
	
	BoolValidator : {
		
		Obj : function () {
			
			var _this = Qetesh.Validator.Obj();
			_this.Convert = this.Convert;
			
			_this.Name = "BoolValidator";
			
			return Object.create(_this);
		},
		
		Convert : function() {
			
			var test = new Qetesh.ValidationTest.Obj();
			test.TestName = "Convert";
			//this.Tests.push(test);
			
			if(!this.Mandatory && this.InValue == null) {
				
				this.OutValue = null;
				this.Passed = true;
				test.Passed = true;
				this.NullOut = true;
				return;
			}
			
			if(this.InValue == "true" || this.InValue ===  true) {
				
				test.Passed = true;
				this.Passed = true;
				this.OutValue = true;
			}
			else if (this.InValue == "false" || this.InValue === false){
				
				test.Passed = true;
				
				this.Passed = true;
				this.OutValue = false;
			}
			else {
				test.Passed = false;
			}
		}
	},
	
	QDateTimeValidator : {
		
		Obj : function () {
			
			var _this = Qetesh.Validator.Obj();
			_this.Convert = this.Convert;
			
			_this.Name = "QDateTimeValidator";
			
			return Object.create(_this);
		},
		
		Convert : function() {
			
			var test = new Qetesh.ValidationTest.Obj();
			
			try {
				var dt = new Date(InValue);
			} catch (e) {
				test.Passed = false;
				return;
			}
			
			if(dt == null) {
				
				test.Passed = false;
				return;
			}
			
			test.TestName = "Convert";
			
			test.Passed = true;
			this.Passed = true;
			this.OutValue = dt.toISOString();
		}
	}
};
	
