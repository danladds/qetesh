/**
 * Qetesh Javascript
 * Bind Field
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


Qetesh.BindField = {
							
	FieldElement : null,
	FieldName : "",
	QElem : null,
	ObjElem : null,
	Type : "",
	Tainted : false,
	__outTransform : function (propertyValue) { return propertyValue; },
	__inTransform : function (propertyValue) { return propertyValue; },
	Validator : null,
	__updateFunc : null,
	
	Obj : function() {
	
		var obj = Object.create(this);
			
		return obj;
	}, 
	
	Init : function () {
		
		if(this.Type != "label") {
		
			this.FieldElement.onchange = (function (f) {
							
				return function(ev) {
					
					f.__onUpdate();
				};
				
			})(this);
		}
		
		this.InitOptions();
	},
	
	Transform : function (outTransform, inTransform) {
		
		if (outTransform != null) this.__outTransform = outTransform;
		if (inTransform != null) this.__inTransform = inTransform;
	},
	
	WhenUpdated : function(callback) {
		
		this.__updateFunc = callback;
	},
	
	Show : function() {
		
		this.FieldElement.style.visibility = "visible";
	},
	
	Hide : function() {
		
		this.FieldElement.style.display = "hidden";
	},
	
	Reset : function() {
		
		this.QElem.__bindDataState[this.FieldName] = this.QElem.__bindData[this.FieldName];
		this.Update();
	},
	
	Update : function() {
		
		var val = this.__outTransform(this.QElem.__bindDataState[this.FieldName]);
			
		this.FieldElement.textContent = val;
		
		this.UpdateTaint();
	},
	
	UpdateValidation : function() {
		
		this.Validator.Validate();
		
		if(this.Validator.Passed == true) {
			this.Valid = true;
			this.FieldElement.className = this.FieldElement.className.replace(/q-invalid/g, "");
		}
		else {
			this.Valid = false;
			this.FieldElement.className += " q-invalid";
			
		}
	},
	
	UpdateTaint : function() {
		
		if(this.QElem.__bindDataState[this.FieldName] != this.QElem.__bindData[this.FieldName]) {
			this.Taint = true;
			this.FieldElement.className += " q-taint";
		}
		else if (this.FieldElement.className != null) {
			this.Taint = false;
			this.FieldElement.className = this.FieldElement.className.replace(/q-taint/g, "");
		}
	},
	
	__onUpdate : function() {
		
		this.UpdateState();
	},
	
	UpdateState : function() {
		
		// Doesn't apply to output-only fields
		// Override in input fields
	},
	
	Commit : function() {
			
		if(this.Validator.OutValue == null) {
			
			this.Validator.InValue = this.QElem.__bindDataState[this.FieldName];
			this.Validator.Convert();
			this.UpdateValidation();
		}
		
		if(this.Taint == true && this.Validator.Passed) {
			this.QElem.__bindData[this.FieldName] = this.Validator.OutValue;
			this.Taint = false;
		}
		
		this.UpdateTaint();
	},
	
	Clear : function() {
		
		this.FieldElement.nodeValue = "";
	},
	
	Revert : function() {
		
		this.FieldName.nodeValue = this.Template;
	},
	
	InitOptions : function() {
		
		// Override for things like selects to initialise their options
	}
};

Qetesh.TextField = {
	
	Obj : function () {
			
		var _this = Qetesh.BindField.Obj();
		
		_this.Update = this.Update;
		_this.UpdateState = this.UpdateState;
		
		return _this;
	},
	
	Update : function() {
		
		var val = this.__outTransform(this.QElem.__bindDataState[this.FieldName]);
		
		this.FieldElement.value = val;		
		this.UpdateTaint();
	},
	
	UpdateState : function() {
			
		this.QElem.__bindDataState[this.FieldName] = this.__inTransform(this.FieldElement.value);
		this.UpdateTaint();
		
		this.Validator.InValue = this.QElem.__bindDataState[this.FieldName];
		this.Validator.Convert();
		this.UpdateValidation();
		
		if(this.__updateFunc != null) {
			var rObj = { };
			rObj[this.FieldName] = this.Validator.OutValue;
			this.__updateFunc(rObj);
		}
	},
};
	
Qetesh.CheckboxField = {
	
	Obj : function () {
			
		var _this = Qetesh.BindField.Obj();
		
		_this.Update = this.Update;
		_this.UpdateState = this.UpdateState;
		
		return _this;
	},
	
	Update : function() {
		
		var val = this.QElem.__bindDataState[this.FieldName];

		this.FieldElement.checked = val;

		this.UpdateTaint();
	},
	
	UpdateState : function() {
			
		this.QElem.__bindDataState[this.FieldName] = this.FieldElement.checked;
		this.UpdateTaint();
		
		this.Validator.InValue = this.QElem.__bindDataState[this.FieldName];
		this.Validator.Convert();
		this.UpdateValidation();
		
		if(this.__updateFunc != null) {
			var rObj = { };
			rObj[this.FieldName] = this.Validator.OutValue;
			this.__updateFunc(rObj);
		}
	},
};
	
Qetesh.SelectField = {
	
	__resetsToAll : false,
	Items : { },
	
	Obj : function () {
			
		var _this = Qetesh.BindField.Obj();
		
		_this.Update = this.Update;
		_this.UpdateState = this.UpdateState;
		_this.InitOptions = this.InitOptions;
		_this.AddUnfilter = this.AddUnfilter;
		_this.__resetsToAll = this.__resetsToAll;
		_this.Populate = this.Populate;
		_this.__addItem = this.__addItem;
		_this.Reset = this.Reset;
		_this.Items = [];
		
		return _this;
	},
	
	Reset : function() {
		
		if(this.__resetsToAll) {
			
			this.FieldElement.selectedIndex = 0;
			this.UpdateTaint();
		}
		else {
		
			this.QElem.__bindDataState[this.FieldName] = this.QElem.__bindData[this.FieldName];
			this.Update();
		}
	},
	
	Update : function() {
		
		var val = this.QElem.__bindDataState.GetProp(this.FieldName);

		this.FieldElement.value = val;

		this.UpdateTaint();
	},
	
	UpdateState : function() {
		
		if(this.FieldElement.value != "__ALL__") {
			
			if(this.Items[this.FieldElement.value] != null) {
				
				this.QElem.__bindDataState[this.FieldName] = this.Items[this.FieldElement.value];
				this.Validator.InValue = this.QElem.__bindDataState[this.FieldName].GetPKeyVal();
			}
			else {
				this.QElem.__bindDataState[this.FieldName] = this.FieldElement.value;
				this.Validator.InValue = this.QElem.__bindDataState[this.FieldName];
			}
			
			this.UpdateTaint();
			this.Validator.Convert();
			this.UpdateValidation();
			
			if(this.__updateFunc != null) {
				var rObj = { };
				rObj[this.FieldName] = this.Validator.OutValue;
				this.__updateFunc(rObj);
			}
		}
		else {
			if(this.__updateFunc != null) this.__updateFunc( { } );
		}
	},
	
	AddUnfilter : function(name) {
		
		var opt = document.createElement("option");
		opt.text = name;
		opt.value = "__ALL__";
		
		this.FieldElement.add(opt, 0);
		this.FieldElement.selectedIndex = 0;
		this.__resetsToAll = true;
	},
	
	InitOptions : function() {
		
		if(this.Validator.Name == "EnumValidator") {
		
			for(var intVal in this.Validator.AllowableValues) {
				
				if(this.Validator.AllowableValues.hasOwnProperty(intVal)) {
					
					var strVal = this.Validator.AllowableValues[intVal];
					
					var opt = document.createElement("option");
					opt.text = strVal;
					opt.value = intVal;
					
					this.FieldElement.add(opt);
				}
			}
		}
	},
	
	// Expects DataObject or DataObject[]
	Populate : function(labelName, opts) {
		
		if(opts instanceof Array) {
			
			var len = opts.length;
			
			for(var x = 0; x < len; ++x) {
				
				this.__addItem(labelName, opts[x]);
			}
		}
		
		else {
			this.__addItem(labelName, opts);
		}
		
		this.Update();
		this.UpdateState();
	},
	
	// Expects DataObject
	__addItem : function(labelName, obj) {
		
		var opt = document.createElement("option");
		opt.text = obj[labelName];
		opt.value = obj[obj.PKeyName];
		
		this.Items[obj.PKeyName] = obj;
		
		this.FieldElement.add(opt);
	}
};
