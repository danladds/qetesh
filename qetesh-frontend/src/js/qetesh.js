/**
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
 **/

"use strict";

/* Start out with definitions */


/* The main object */
var Qetesh = {


	QConf : {
		ServerUri : "/qwf",
		ManifestUri: "/manifest"
	},

	Init : function () {
		
		var q = this;
		
		window.onload = function() {
			
			// Get manifest structure
			var xh = new XMLHttpRequest();
				
			xh.onreadystatechange = function () {
					
				if (xh.readyState == 4 && xh.status == 200) {
					
					q.__data = JSON.parse(xh.responseText);
					
					q.__makeProxyClasses();
					
					q.__callReady();
				}
				
				// Todo: error handling and other fun evening activities
			};
				
			xh.open("GET", q.QConf.ServerUri + q.QConf.ManifestUri, true);
			xh.send();
		}
	},
	
	__ready : [],
	
	__data : {},
	
	__views : [],
	
	__callReady : function () {
		
		var len = this.__ready.length;
		
		for (var i = 0; i < len; ++i) {
			
			this.__ready[i](this);
		}
	},

	Data : {},
	
	Obj : function() {
		
		var obj = Object.create(this);
		obj.Init();
		
		return obj;
	}, 
	
	Ready : function (func) {
		
		this.__ready.push(func);
		
	},
	
	__makeProxyClasses : function () {
		
		  for (var k in this.__data.Manifest) {
			  
			if( this.__data.Manifest.hasOwnProperty(k) ) {
			
				this.MakeProxyClass(k, this.__data.Manifest[k]);
			} 
		  } 
	},
	
	MakeProxyClass : function (name, manifest) {
		
		var proxy = Qetesh.DataObject.Obj();
		
		proxy.Obj = function () {
			
			var obj = Object.create(proxy);
				
			return obj;
		};
		
		for (var methodName in manifest) {
			  
			if(manifest.hasOwnProperty(methodName) ) {
				
				var methodDef = manifest[methodName];
				var httpMethod = methodDef.HttpMethod;
				var nodePath = methodDef.NodePath;
				
				
			
				proxy[methodName] = (function(hMethod, nPath) {
					
					return function(callback) {
					
						var xh = new XMLHttpRequest();
							
						xh.onreadystatechange = function () {
								
							if (xh.readyState == 4 && xh.status == 200) {
								
								callback(JSON.parse(xh.responseText));
							}
						};
							
						xh.open(
							hMethod, 
							Qetesh.QConf.ServerUri + nPath, 
							true
						);
						xh.send();
						
					}
				})(httpMethod, nodePath);
				
				
			} 
		} 
		
		this.Data[name] = proxy;
	},
	
	ViewManage : function (paneId) {
		
		
		return Qetesh.ViewManager.Obj(paneId);
	},
	
	ViewManager : {
		
		PaneId : '',
		pane : null,
		Views : [],
		
		
		Obj : function(paneId) {
		
			var obj = Object.create(this);
			obj.Init(paneId);
			
			return obj;
		}, 
		
		Init : function (paneId) {
			
			this.PaneId = paneId;
			this.pane = document.getElementById(paneId);
		},
		
		View : function(name, tpl, defaultOperator) {
			
			var view = Qetesh.HTMLView.Obj();
			view.Name = name;
			view.TplUri = tpl;
			view.Operators.push(defaultOperator);
			view.Manager = this;
			
			this.Views.push(view);
			
			return view;
		},
		
		Show : function(name, clearcache = false, nocache = false) {
			
			var vc = this.Views.length;
			for (var i = 0; i < vc; ++i) {
				
				if (this.Views[i].Name == name) this.Views[i].Show(name, clearcache, nocache);
			}
		}
	},
	
	HTMLView : {
		
		Name : "",
		TplUri : "",
		Operators : [],
		ActiveOperator : 0,
		Manager : null,
		
		
		__cache : "",
		
		Obj : function() {
		
			var obj = Object.create(this);
			obj.Init();
			
			return obj;
		}, 
		
		Init : function () {
			
			this.Operators = [];
			
		},
		
		// Args!
		Show : function(name, params = {}, clearcache = false, nocache = false) {
			
			params._qclearcache = clearcache;
			params._qnocache = nocache;
			
			if (clearcache) this.__cache = "";
			
			if (!nocache && this.__cache != null && this.__cache != "") {
				
				pane.innerHTML = this.__cache;
				this.Operators[this.ActiveOperator]();
				return;
			}
			
			var xh = new XMLHttpRequest();
			var _view = this;
			var pane = this.Manager.pane;
				
			xh.onreadystatechange = function () {
					
				if (xh.readyState == 4 && xh.status == 200) {
					
					pane.innerHTML = xh.responseText;
					_view.Operators[_view.ActiveOperator](_view, params);
				}
			};
				
			// TODO: use setting
			xh.open("GET", '/tpl/' + this.TplUri, true);
			xh.send();
		},
		
		Bind : function (data, selector) {
			
			var bind = Qetesh.HTMLElement.Obj();
			var elem = this.Manager.pane.querySelector(selector);
			var container = elem.parentNode;
			
			if (!(data instanceof Array)) {
				
				elem = this.__bindItem(data, elem);
				bind.addElement(elem);
				return bind;
			}
			
			var len = data.length;
			
			
			for (var i = 0; i < len; ++i) {
				
				var item = data[i];
				
				// Deep clone inc. subelements
				var e = elem.cloneNode(true);
				
				e = this.__bindItem(item, e);
				
				container.appendChild(e);
				bind.addElement(e);
			}
			
			// Remove template item
			container.removeChild(elem);
			
			return bind;
			
		},
		
		Element : function (selector) {
			
			var bind = Qetesh.HTMLElement.Obj();
			var elem = this.Manager.pane.querySelector(selector);
			elem._qdata = null;
			bind.addElement(elem);
			
			return bind;
		},
		
		__bindItem(data, elem) {
			
			var content = elem.innerHTML;
			
			for (var propName in data) {
				
				if( data.hasOwnProperty(propName) ) {
					
					var propVal = data[propName];
					var tag = "{" + propName + "}";
					
					content = content.replace(tag, propVal);
				}
			}
			
			elem.innerHTML = content;
			
			// Link data and element
			elem._qdata = data;
			data.boundElement = elem;
			
			return elem;
		}
	},
	
	
	// Represents one or more HTML elements
	HTMLElement : {
		
		__elements : [],
		
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
		},
		
		Click : function (callback) {
			
			var len = this.__elements.length;
			
			
			for (var i = 0; i < len; ++i) {
				
				var e = this.__elements[i];
				
				(function (elem, cb) { 
					
					elem.onclick = function() {
					
						cb(elem._qdata);
					
					};
				})(e, callback);
				
			}
		}
	},
	
	DataObject : {
		
		Obj : function() {
		
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

var $_qetesh = Qetesh.Obj();
