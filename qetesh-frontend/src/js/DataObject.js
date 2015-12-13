/**
 * Qetesh Javascript
 * DataObject
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


Qetesh.DataObject = {
	
	Id : 0,
	PKeyName : "Id",
	__fromMethod : null,
	__tainted : [],
	__properties : [],
	__deleteMe : false,
	Validators : { },
	
	Obj : function() {
	
		var obj = Object.create(this);
		obj.Init();
			
		return obj;
	}, 
	
	Init : function () {
		
		this.__tainted = [];
		this.__properties = [];
		this.Validators = { };
	},
	
	GetPKeyVal : function() {
		
		return this[this.PKeyName];
	},
	
	GetProp : function(name) {
		
		if(this[name].ClientName != null) {
			
			// Done like this so it still works
			// when the child item is a server stub
			return this[name][this[name].PKeyName];
		}
		else {
			
			return this[name];
		}
	},
	
	ShowValidationErrors() {
		
		if(this.boundQElement == null) return;
		
		this.UpdateValidators();
		this.boundQElement.UpdateValidation();
		
	},
	
	ServerValidationSuccess() {
		
		if(this.boundQElement == null) return;
		
		this.PushValidatorSuccess();
		this.boundQElement.UpdateValidation();
		
	},
	
	UpdateValidators : function () {
		
		for(var fName in this.Validators) {
			
			if(this.Validators.hasOwnProperty(fName)) {
				
				this.Validators[fName].Update();
			}
		}
	},
	
	PushValidatorSuccess : function () {
		
		for(var fName in this.Validators) {
			
			if(this.Validators.hasOwnProperty(fName)) {
				
				this.Validators[fName].SetSuccess();
			}
		}
	},
	
	SetTaint : function (fieldName) {
		
		var len = this.__tainted.length;
		
		for(var i = 0; i < len; ++i) {
			
			if (this.__tainted[i] == fieldName) {
				
				return;
			}
		}
		
		this.__tainted.push(fieldName);
	},
	
	Reload : function (callback = null) {
		
		if (this.boundQElement != null) {
			
			var _this = this;
			
			this.Load(function() {
				
				if(callback != null) callback(this);
			});
		}
	},
	
	Save : function (createCallback = null, updateCallback = null) {
		
		if (this[this.PKeyName] == null || this[this.PKeyName] < 1) {
			
			this.Create(createCallback);
		}
		else {
			
			this.Update(updateCallback);
		}
	},
	
	SaveExisting : function (callback = null) {
		
		if (this[this.PKeyName] == null || this[this.PKeyName] < 1) {
			
			// Twiddle thumbs
			return
		}
		else {
			
			this.Update(callback);
		}
	},
	
	DeleteExisting : function (callback = null) {
		
		if (this[this.PKeyName] == null || this[this.PKeyName] < 1) {
			
			// Twiddle thumbs
		}
		else {
			
			this.Delete(callback);
		}
	},
	
	Commit : function () {
		
		if (this.boundQElement != null) {
			
			this.boundQElement.Commit();
		}
	},
	
	FromNode : function(inObj) {
		
		for (var prop in inObj) {
			  
			if( inObj.hasOwnProperty(prop) ) {
				
				if(inObj[prop].ClientName != null) {
					
					var pObj = Qetesh.Data[inObj[prop].ClientName].Obj();
					
					pObj.FromNode(inObj[prop]);
					
					this[prop] = pObj;
				}
				else {
					
					this[prop] = inObj[prop];
				}
			} 
		}
	}

};
