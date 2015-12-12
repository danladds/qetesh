/**
 * Qetesh Javascript
 * HTMLView
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


Qetesh.HTMLView = {
	
	Name : "",
	TplUri : "",
	Operators : [],
	ActiveOperator : 0,
	Manager : null,
	paneElem : null,
	container : null,
	beenLoaded : false,
	
	
	__cache : "",
	
	Obj : function() {
	
		var obj = Object.create(this);
		obj.Init();
		
		return obj;
	}, 
	
	Init : function () {
		
		this.Operators = [];
	},
	
	RunFunc : function (view, args) {
		
		this.Operators[this.ActiveOperator](view, args);
	},
	
	Show : function() {
		
		if (this.paneElem != null) {
			this.paneElem.Reset();
		}
		
		this.container.style.display = "block";
	},
	
	Hide : function() {
		
		this.container.style.display = "none";
	},
	
	// Args!
	Reload : function(params = {}, clearcache = false, nocache = false, andShow = false) {
		
		if (clearcache) this.__cache = "";
		
		if (!nocache && this.__cache != null && this.__cache != "") {
			
			this.container.innerHTML = this.__cache;
			this.RunFunc(this, params);
			if (andShow) this.Show();
			return;
		}
		
		var xh = new XMLHttpRequest();
		var _view = this;
		var pane = this.container;
			
		xh.onreadystatechange = function () {
				
			if (xh.readyState == 4 && xh.status == 200) {
				
				pane.innerHTML = xh.responseText;
				_view.RunFunc(_view, params);
				_view.beenLoaded = true;
				if (andShow) _view.Show();
			}
		};
			
		// TODO: use setting
		xh.open("GET", '/tpl/' + this.TplUri, true);
		xh.send();
	},
	
	Element : function(selector) {
		
		if (this.paneElem == null) {
			
			this.paneElem = Qetesh.HTMLElement.Obj();
			this.paneElem.addElement(this.container);
		}
		
		return this.paneElem.Element(selector);
	}
};
