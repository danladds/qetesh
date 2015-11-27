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
				var methodType = methodDef.MethodType;
				var returnType = methodDef.ReturnType;
				
				if(methodName == "PKeyName") {
					proxy[methodName] = methodDef;
					continue;
				}

			
				proxy[methodName] = (function(
					hMethod, nPath,	mType, rType
				) {
					
					return function(callback) {
					
						var xh = new XMLHttpRequest();
							
						xh.onreadystatechange = function () {
								
							if (xh.readyState == 4 && xh.status == 200) {
								
								var realType;
								var inData = JSON.parse(xh.responseText);
								
								// Array returns
								if (rType.indexOf("[]") > 1) {
									
									var returnList = [];
									var realType = rType.replace("[]", "");
									
									var arrayLen = inData.length;
									for (var i = 0; i < arrayLen; ++i) {
										
										var proto = Qetesh.Data[realType].Obj();
										
										for (var prop in inData[i]) {
				  
											if( inData[i].hasOwnProperty(prop) ) {
											
												proto[prop] = inData[i][prop];
											} 
										}
										
										returnList.push(proto);
									}
									
									callback(returnList);
								}
								// Single returns
								else
								{
									var proto = Qetesh.Data[rType].Obj();
									
									for (var prop in inData[0]) {
			  
										if( inData[0].hasOwnProperty(prop) ) {
										
											proto[prop] = inData[0][prop];
										} 
									} 
									
									callback(proto);
								}
								
							}
						};
						
						var actualPath = "";
					
						actualPath = nPath.replace("$n", this[this.PKeyName]);
							
						xh.open(
							hMethod, 
							Qetesh.QConf.ServerUri + actualPath, 
							true
						);
						xh.send();
						
					}
				})(httpMethod, nodePath, methodType, returnType);
				
				
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
		ActiveView : 0,
		
		
		Obj : function(paneId) {
		
			var obj = Object.create(this);
			obj.Init(paneId);
			
			return obj;
		}, 
		
		Init : function (paneId) {
			
			this.PaneId = paneId;
			this.pane = document.getElementById(paneId);
			this.pane.innerHTML = "";
		},
		
		View : function(name, tpl, defaultOperator) {
			
			var view = Qetesh.HTMLView.Obj();
			view.Name = name;
			view.TplUri = tpl;
			view.Operators.push(defaultOperator);
			view.Manager = this;
			
			var container = document.createElement("div");
			container.id = "_q-view-container-" + this.PaneId + "-" + name;
			
			view.container = container;
			
			this.pane.appendChild(container);
			
			this.Views.push(view);
			
			return view;
		},
		
		Show : function(name, params = {}, reload = true, clearcache = false, nocache = false) {
			
			this.Views[this.ActiveView].Hide();
			
			var vc = this.Views.length;
			for (var i = 0; i < vc; ++i) {
				
				if (this.Views[i].Name == name) {
					
					if(reload || !this.Views[i].beenLoaded) {
						this.Views[i].Reload(params, clearcache, nocache, true);
						
					}
					else {
						this.Views[i].Show();
					}
					
					this.ActiveView = i;
				}
			}
		}
	},
	
	HTMLView : {
		
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
	},
	
	
	// Represents one or more HTML elements
	HTMLElement : {
		
		__elements : [],
		__dataBound : false,
		__qdata : {},
		__qdatastate : {},
		__repeaterTemplate : null,
		__repeaterContainer : null,
		__parent : null,
		
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
				
				(function (elem, cb, _this, x) { 
					
					elem.onclick = function() {
					
						cb(_this._getQData(x));
					
					};
				})(e, callback, this, i);
				
			}
		},
		
		_getQData : function(i) {
			
			if (this.__dataBound) {
				
				return this.__elements[i].__qdata;
			}
			else if (this.__parent != null) {
				
				return this.__parent._getQData(i);
			}
			
			return null;
		},
	
		Bind : function (data, transform) {
			
			var len = this.__elements.length;
			this.__dataBound = true;
			
			// Single objects
			if (!(data instanceof Array)) {
				
				// Bind to all matches
				for (var i = 0; i < len; ++i) {
					
					var elem = this.__elements[i];
					var realData = (transform == null) ? data : transform(data);
					elem = this.__bindItem(realData, elem);
					
				}
				
				return this;
			}
			
			var elem;
			var container;
			
			// Already-expanded repeaters
			if (this.__repeaterTemplate != null) {
				
				this.__elements = [];
				elem = this.__repeaterTemplate;
				container = this.__repeaterContainer;
			}
			
			// Arrays, repeater templates
			else {
				
				elem = this.__elements[0];
				container = elem.parentNode;
				this.__elements.splice(0, 1);
			}
				
			var datalen = data.length;
			
			// Each DataObject in array
			for (var x = 0; x < datalen; ++x) {
				
				var item = data[x];
				
				// Deep clone inc. subelements
				var e = elem.cloneNode(true);
				
				item = (transform == null) ? item : transform(item);
				e = this.__bindItem(item, e);
				
				container.appendChild(e);
				this.addElement(e);
			}
			
			// Remove template item
			if (this.__repeaterTemplate == null) {
				container.removeChild(elem);
				this.__repeaterContainer = container;
				this.__repeaterTemplate = elem;
			}
			
			return this;
			
		},
		
		__bindItem : function(data, elem) {
			
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
			elem.__qdata = data;
			elem.__qdatastate = Object.create(data);
			data.boundElement = elem;
			data.boundQElement = this;
			
			return elem;
		},
		
		Reset : function (deep = true) {
			
			
			
			if (deep) {
				
				var childLen = this.__children.lenth;
				
				for(var i = 0; i < childLen; ++i) {
					
					this.__children[i].Reset(true);
				}
			}
		},
		
		Element : function (selector) {
			
			var len = this.__elements.length;
			var subobj = Qetesh.HTMLElement.Obj();
			
			for (var i = 0; i < len; ++i) {
				
				var elem = this.__elements[i];
				
				var subelem = elem.querySelector(selector);
				subelem.__qdata = null;
				subobj.addElement(subelem);
				
			}
			
			subobj.__parent = this;
			
			return subobj;
		}
	},
	
	DataObject : {
		
		Id : 0,
		PKeyName : "Id",
		
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
