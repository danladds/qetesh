/**
 * Qetesh Javascript
 * HTMLElement
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


// Represents one or more HTML elements
Qetesh.HTMLElement = {
	
	__elements : [],
	__dataBound : false,
	
	__bindData : null,
	__bindDataState : null,
	__repeaterTemplate : null,
	__repeaterContainer : null,
	__parent : null,
	__children : [],
	__fields : [],
	__clickCallback : null,
	__displayType : null,
	__populateValues : { },
	__populateLabels : { },
	
	addElement : function(elem) {
		
		this.__elements.push(elem);
	},
	
	Obj : function() {
	
		var obj = Object.create(this);
		obj.Init();
			
		return obj;
	}, 
	
	Init : function () {
		
		this.__elements = [];
		this.__children = [];
		this.__fields = [];
		this.__populateValues = { };
		this.__populateLabels = { };
	},
	
	Click : function (callback) {
		
		this.__clickCallback = callback;
		
		// Repeaters etc. - re-call on children
		if(this.__repeaterTemplate != null || this.__elements.length == 0) {
			var childCount = this.__children.length;
		
			for (var w = 0; w < childCount; ++w) {
				
				this.__children[w].Click(callback);
			}
			
			return;
		}
		
		var len = this.__elements.length;
		
		for (var i = 0; i < len; ++i) {
			
			var e = this.__elements[i];
			
			(function (elem, cb, _this, x) { 
				
				elem.onclick = function() {
					
					// Passing 'this' context of bound HTMLElement
					_this.__clickCallback(_this._getQData());
				
				};
			})(e, callback, this, i);
			
		}
	},
	
	UpdateValidation : function (deep = false) {
		
		var fieldCount = this.__fields.length;
		
		for(var m = 0; m < fieldCount; ++m) {
			
			this.__fields[m].UpdateValidation();
		}
		
		if (deep) {
			
			var childLen = this.__children.length;
			
			for(var i = 0; i < childLen; ++i) {
				
				this.__children[i].UpdateValidation(true);
			}
		}
	},
	
	Filter : function (objFilter) {
		
		// Repeater - just send to children
		if(this.__repeaterTemplate != null || this.__elements.length == 0) {
			
			var childCount = this.__children.length;
		
			for (var w = 0; w < childCount; ++w) {
				
				this.__children[w].Filter(objFilter);
			}
			
			return;
		}
		else {
			
			var match = true;
			
			var fieldCount = this.__fields.length;
			
			for(var fName in objFilter) {
				
				if(objFilter.hasOwnProperty(fName)) {
					
					if(this.__bindData[fName] != objFilter[fName]) {
						
						match = false;
					}
				}
			}
			
			if(!match) this.Disappear();
			else this.Appear();
		}
	},
	
	_getQDataState : function() {
		
		if (this.__dataBound) {
			
			return this.__bindDataState;
		}
		else if (this.__parent != null) {
			
			return this.__parent._getQDataState();
		}
		
		return null;
	},
	
	_getQData : function() {
		
		if (this.__dataBound) {
			
			return this.__bindData;
		}
		else if (this.__parent != null) {
			
			return this.__parent._getQData();
		}
		
		return null;
	},

	Bind : function (data) {
		
		var len = this.__elements.length;
		this.__dataBound = true;
		
		if (!this.__dataBound || !(this.__bindData instanceof Array)) {
			this.__bindData = data;
			this.__bindDataState = Object.create(data);
		}
		else if (data instanceof Array) {
			this.__bindData = this.__bindData.concat(data);
			this.__bindDataState = this.__bindDataState.concat(data);
		}
		else {
			this.__bindData.push(data);
			this.__bindDataState.push(data);
		}
		
		// Single objects
		if (!(data instanceof Array) && !(this.__bindData instanceof Array)) {
			
			// Bind to all matches
			for (var i = 0; i < len; ++i) {
				
				var elem = this.__elements[i];
				elem = this.__bindItem(data, elem);
				
			}
			
			return this;
		}
		
		// Repeaters - grab and remove template if not already expanded
		if (this.__repeaterTemplate == null) {
			
			var elem;
			var container;
			
			elem = this.__elements[0];
			container = elem.parentNode;
			
			container.removeChild(elem);
			this.__repeaterContainer = container;
			this.__repeaterTemplate = elem;
		}
		
		this.Reset();
		
		return this;
		
	},
	
	Populate : function(fieldName, labelName, values, deep = true) {
		
		if(this.__populateValues[fieldName] == null) {
			
			this.__populateValues[fieldName] = [];
		}
		
		this.__populateValues[fieldName].push(values);
		this.__populateLabels[fieldName] = labelName;
		
		var fieldCount = this.__fields.length;
		
		for(var m = 0; m < fieldCount; ++m) {
			
			if(this.__fields[m].FieldName == fieldName) {
				
				this.__fields[m].Populate(labelName, values);
			}
		}
		
		if (deep) {
			
			var childLen = this.__children.length;
			
			for(var i = 0; i < childLen; ++i) {
				
				this.__children[i].Populate(fieldName, labelName, values);
			}
		}
	},
	
	Show : function() {
		
		var len = this.__elements.length;
		
		for(var x = 0; x < len; ++x) {
			this.__elements[x].style.visibility = "visible";
		}
	},
	
	Disappear : function() {
		
		var len = this.__elements.length;
		
		for(var x = 0; x < len; ++x) {
			
			this.displayType = this.__elements[x].style.display;
			this.__elements[x].style.display = "none";
		}
	},
	
	Appear : function() {
		
		var len = this.__elements.length;
		
		for(var x = 0; x < len; ++x) {
			
			this.__elements[x].style.display = this.displayType;
		}
	},
	
	Hide : function() {
		
		var len = this.__elements.length;
		
		for(var x = 0; x < len; ++x) {
			this.__elements[x].style.display = "hidden";
		}
	},
	
	Remove : function () {
		
		
		var len = this.__elements.length;
		
		for(var x = 0; x < len; ++x) {
			this.__elements[x].parentNode.removeChild(this.__elements[x]);
		}
	},
	
	__bindItem : function(data, elem) {
		
		var propLen = data.__properties.length;
		for (var di = 0; di < propLen; ++di) {
			
			var propName = data.__properties[di];

			var tag;
			var propVal = data[propName];
			
			// Get any tag that has the {Tag} as its class
			tag = this._findTag("{" + propName + "}", elem);
			
			if(tag != null) {
				
				var fld;
				
				var tName = tag.tagName.toLowerCase();
				
				if(tName == "input") {
					
					var tType = tag.type.toLowerCase();
					
					if(tType == "checkbox") {
						
						fld = Qetesh.CheckboxField.Obj();
						fld.Type = "checkbox";
					}
					else if(tType == "text") {
						
						fld = Qetesh.TextField.Obj();
						fld.Type = "text";
					}
					
					fld.Validator = data.Validators[propName];
				}
				else if(tName == "select") {
					
					fld = Qetesh.SelectField.Obj();
					fld.Type = "select";
					fld.Validator = data.Validators[propName];
				}
				else if(tName == "textarea") {
					
					fld = Qetesh.TextField.Obj();
					fld.Type = "textarea";
					fld.Validator = data.Validators[propName]
				}
				else {
					
					// Static text replacements
					fld = Qetesh.BindField.Obj();
					fld.Type = "label";
				}
				
				fld.FieldElement = tag;
				fld.FieldName = propName;
				fld.QElem = this;
				fld.ObjElem = elem;
				tag.__qBindField = fld;
				
				tag.className = tag.className.replace("{" + propName + "}", data.ClientName + "_" + data.GetPKeyVal() + "_" + propName + " " + data.ClientName + "_" + propName);
				
				fld.Init();
				
				this.__fields.push(fld);
				
				if(this.__populateLabels[propName] != null) {
					
					fld.Populate(this.__populateLabels[propName], this.__populateValues[propName]);
				}
			}
		}
		
		data.boundElement = elem;
		data.boundQElement = this;
		
		this.Reset(false);
		
		return elem;
	},
	
	_findTag : function (tagName, elem) {
		
		if(elem.className != null && elem.className.indexOf(tagName) > -1) {
			
			return elem;
		}
		
		if(elem.childNodes != null && elem.childNodes.length > 0) {
			
			var cLen = elem.childNodes.length;
			
			for(var u = 0; u < cLen; ++u) {
				
				var rtn = this._findTag(tagName, elem.childNodes[u]);
				if(rtn != null) return rtn;
			}
		}

		
		return null;
	},
	
	Transform : function(propName, outTransform, inTransform, deep = true) {
		
		var fieldCount = this.__fields.length;
		
		for(var m = 0; m < fieldCount; ++m) {
			
			if(this.__fields[m].FieldName == propName) {
				
				this.__fields[m].Transform(outTransform, inTransform);
				this.Reset(false);
			}
		}
		
		if (deep) {
			
			var childLen = this.__children.length;
			
			for(var i = 0; i < childLen; ++i) {
				
				this.__children[i].Transform(propName, outTransform, inTransform, true);
			}
		}
	},
	
	PrettyNames : function(propName, valueNames, deep = true) {
		
		var inFunc = function(val) {
			
			// Don't need to do anything, as form inputs
			// that use enums (e.g. dropdown lists) have their
			// value set to the int value
			return val;
		};
		
		var outFunc = function(val) {
			
			return valueNames[val];
		}
		
		
		this.Transform(propName, outFunc, inFunc, deep);
	},
	
	CopyDown : function(fieldname) {
		
		if(fieldname == null || fieldname == "") return;
		
		this.__bindDataState[fieldname] = this.__bindData[fieldname];
		
		this.Update();
	},
	
	Reset : function (deep = true) {
		
		var fieldCount = this.__fields.length;
		
		// Update child items to reflect data
		if (this.__bindData instanceof Array) {
			
			var bindC = this.__bindData.length;
			var elemC = this.__children.length;
			
			var deletes = [];
			
			for(var dataIndex = 0; dataIndex < bindC; dataIndex++) {
				
				if(this.__bindData[dataIndex].__deleteMe == true) {
					
					deletes.push(dataIndex);
				}
				
				var matchedIndex = -1;
				
				for(var childIndex = 0; childIndex < elemC; childIndex++) {
					
					var keyName = this.__bindData[dataIndex].PKeyName;
					
					if(this.__bindData[dataIndex][keyName] == this.__children[childIndex].__bindData[keyName]) {
						
						matchedIndex = childIndex;
					}
				}
				
				if (matchedIndex == -1) {
					
					// Item doesn't currently exist
					var item = this.__bindData[dataIndex];
			
					// Deep clone inc. subelements
					var e = this.__repeaterTemplate.cloneNode(true);
					this.__repeaterContainer.appendChild(e);
					
					var subobj = Qetesh.HTMLElement.Obj();
					subobj.addElement(e);
					
					subobj.__parent = this;
					this.__children.push(subobj);
					
					subobj.__populateLabels = this.__populateLabels; 
					subobj.__populateValues = this.__populateValues;
					
					subobj.Bind(item);
					
					if(this.__clickCallback != null) {
						
						subobj.Click(this.__clickCallback);
					}
				}
			}
			
			var deleteCount = deletes.length;
			
			for(var y = 0; y < deleteCount; ++y) {
				
				this.__bindData.splice(deletes[y], 1);
				var deletedChild = this.__children.splice(deletes[y], 1);
				deletedChild[0].Remove();
			}
			
			bindC = this.__bindData.length;
			elemC = this.__children.length;
			var adds = [];
			
			// Now iterate the other way
			for(var childIndex = 0; childIndex < elemC; childIndex++) {
				
				var matchedIndex = -1;
				
				for(var dataIndex = 0; dataIndex < bindC; dataIndex++) {
					
					var keyName = this.__bindData[dataIndex].PKeyName;
					
					if(this.__bindData[dataIndex][keyName] == this.__children[childIndex].__bindData[keyName]) {
						
						matchedIndex = childIndex;
					}
				}
				
				if(matchedIndex == -1) {
					
					// Flag for add
					adds.push(childIndex)
					
				}
			}
			
			var addCount = adds.length;
			
			for(var a = 0; a < addCount; ++a) {
				
				this.__bindData.push(this.__children[adds[a]].__bindData);
			}
		}
		
		for(var m = 0; m < fieldCount; ++m) {
			
			this.__fields[m].Reset();
		}
		
		if (deep) {
			
			var childLen = this.__children.length;
			
			for(var i = 0; i < childLen; ++i) {
				
				this.__children[i].Reset(true);
			}
		}
	},
	
	Commit : function (deep = true) {
		
		var fieldCount = this.__fields.length;
		
		for(var m = 0; m < fieldCount; ++m) {
			
			this.__fields[m].Commit();
		}
		
		if (deep) {
			
			var childLen = this.__children.length;
			
			for(var i = 0; i < childLen; ++i) {
				
				this.__children[i].Commit(true);
			}
		}
	},
	
	Update : function (deep = true) {
		
		var fieldCount = this.__fields.length;
		
		for(var m = 0; m < fieldCount; ++m) {
			
			this.__fields[m].Update();
		}
		
		if (deep) {
			
			var childLen = this.__children.length;
			
			for(var i = 0; i < childLen; ++i) {
				
				this.__children[i].Update(true);
			}
		}
	},
	
	UpdateState : function (deep = true) {
		
		var fieldCount = this.__fields.length;
		
		for(var m = 0; m < fieldCount; ++m) {
			
			this.__fields[m].UpdateState();
		}
		
		if (deep) {
			
			var childLen = this.__children.length;
			
			for(var i = 0; i < childLen; ++i) {
				
				this.__children[i].UpdateState(true);
			}
		}
	},
	
	UpdateTaint : function (deep = true) {
		
		var fieldCount = this.__fields.length;
		
		for(var m = 0; m < fieldCount; ++m) {
			
			this.__fields[m].UpdateTaint();
		}
		
		if (deep) {
			
			var childLen = this.__children.length;
			
			for(var i = 0; i < childLen; ++i) {
				
				this.__children[i].UpdateTaint(true);
			}
		}
	},
	
	Element : function (selector) {
		
		
		
		var len = this.__elements.length;
		var subobj = Qetesh.HTMLElement.Obj();
		
		// Repeaters - get from each child and add to new element collection
		if(this.__repeaterTemplate != null) {
			
			var childLen = this.__children.length;
			
			for(var x = 0; x < childLen; ++x) {
				
				subobj.__children.push(this.__children[x].Element(selector));
			}
			
			return subobj;
		}
		
		for (var i = 0; i < len; ++i) {
			
			var elem = this.__elements[i];
			
			var subelem = elem.querySelector(selector);
			
			if (subelem == null) return null;
			
			subobj.addElement(subelem);
			subelem._qElement = subobj;
			
		}
		
		subobj.__parent = this;
		this.__children.push(subobj);
		
		return subobj;
	},
	
	Field : function(name) {
		
		var fieldCount = this.__fields.length;
		
		for(var m = 0; m < fieldCount; ++m) {
			
			if (this.__fields[m].FieldName == name)
				return this.__fields[m];
		}
	}
};
