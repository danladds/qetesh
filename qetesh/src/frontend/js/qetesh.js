/*
 * Qetesh Javascript
 * Framework + Bootstrap
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

"use strict";

/* Start out with definitions */


/* The main object */
var Qetesh = {


	Settings : {
		ServerUri : "/qfw",
		ManifestUri: "/manifest"
	},

	Init : function () {
		
		window.onload = function() {
			
			var xh = new XMLHttpRequest();
			var q = this;
				
			xh.onreadystatechange = function () {
					
				if (xh.readystate == 4 && xh.status == 200) {
					
					q.__data = eval(xh.responseText);
					q.__callReady();
				}
			};
				
			xh.open(this.Settings.ServerUri + this.Settings.ManifestUri);
			xh.send();
		}
	},
	
	__ready : [],
	
	__data : {},
	
	__views : [],
	
	__callReady : function () {
		
		for(c in this.__ready) c(this.__data);
	},

	Data : function() {},
	
	Create : function() {
		
		var obj = Object.create(this);
		obj.Init();
		
		return obj;
	}, 
	
	Ready : function (func) {
		
		this.__data.push(func);
		
	},
	
	HMTLView : {
			
		__templateUri : "",
		
		Create : function() {
		
			var obj = Object.create(this);
			obj.Init();
			
			return obj;
		}, 
		
		Init : function () {
			
		},
		
		Bind : function (object) {
			
		}  
	},
	
	DataObject : {
		
		Create : function() {
		
			var obj = Object.create(this);
			obj.Init();
				
			return obj;
		}, 
		
		Init : function () {
			
		},
		
		__callServerFunc : function (name, args) {
			
			
		}
	
	},
};

var _qsh = Qetesh.Create();
