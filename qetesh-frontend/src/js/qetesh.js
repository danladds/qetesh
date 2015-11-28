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
				
				if(methodDef.HttpMethod == null) {
					proxy[methodName] = methodDef;
					continue;
				}
				
				var httpMethod = methodDef.HttpMethod;
				var nodePath = methodDef.NodePath;
				var methodType = methodDef.MethodType;
				var returnType = methodDef.ReturnType;

			
				proxy[methodName] = (function(
					hMethod, nPath,	mType, rType
				) {
					
					return function(callback) {
					
						var xh = new XMLHttpRequest();
						
						var _this = this;
							
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
									for (var prop in inData[0]) {
			  
										if( inData[0].hasOwnProperty(prop) ) {
										
											_this[prop] = inData[0][prop];
										} 
									} 
									
									callback();
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
		
		Show : function(name, params = {}, reload = false, clearcache = false, nocache = false) {
			
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
	},
	
	
	// Represents one or more HTML elements
	HTMLElement : {
		
		__elements : [],
		__dataBound : false,
		
		__bindData : null,
		__bindDataState : null,
		__repeaterTemplate : null,
		__repeaterContainer : null,
		__parent : null,
		__children : [],
		__fields : [],
		
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
		},
		
		Click : function (callback) {
			
			// Repeaters etc. - re-call on children
			var childCount = this.__children.length;
			
			for (var w = 0; w < childCount; ++w) {
				
				this.__children[w].Click(callback);
			}
			
			var len = this.__elements.length;
			
			for (var i = 0; i < len; ++i) {
				
				var e = this.__elements[i];
				
				(function (elem, cb, _this, x) { 
					
					elem.onclick = function() {
					
						cb(_this._getQData());
					
					};
				})(e, callback, this, i);
				
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
			
			var elem;
			var container;
			
			// Already-expanded repeaters
			if (this.__repeaterTemplate != null) {
				
				elem = this.__repeaterTemplate;
				container = this.__repeaterContainer;
			}
			
			// Arrays, repeater templates
			else {
				
				elem = this.__elements[0];
				container = elem.parentNode;
			}
			
			if (!(data instanceof Array)) {
				
				// Deep clone inc. subelements
				var e = elem.cloneNode(true);
				container.appendChild(e);
				
				var subobj = Qetesh.HTMLElement.Obj();
				subobj.addElement(e);
				
				subobj.__parent = this;
				this.__children.push(subobj);
				
				subobj.Bind(data);
			}
				
			var datalen = data.length;
			
			// Each DataObject in array
			for (var x = 0; x < datalen; ++x) {
				
				var item = data[x];
				
				// Deep clone inc. subelements
				var e = elem.cloneNode(true);
				container.appendChild(e);
				
				var subobj = Qetesh.HTMLElement.Obj();
				subobj.addElement(e);
				
				subobj.__parent = this;
				this.__children.push(subobj);
				
				subobj.Bind(item);
				
			}
			
			// Remove template item
			if (this.__repeaterTemplate == null) {
				container.removeChild(elem);
				this.__repeaterContainer = container;
				this.__repeaterTemplate = elem;
			}
			
			return this;
			
		},
		
		Show : function() {
			
			var len = this.__elements.length;
			
			for(var x = 0; x < len; ++x) {
				this.__elements[x].style.visibility = "visible";
			}
		},
		
		Hide : function() {
			
			var len = this.__elements.length;
			
			for(var x = 0; x < len; ++x) {
				this.__elements[x].style.display = "hidden";
			}
		},
		
		__bindItem : function(data, elem) {
			
			for (var propName in data) {
				
				if( data.hasOwnProperty(propName) || data.__proto__.hasOwnProperty(propName) ) {
					
					var tag;
					var propVal = data[propName];
					
					// Is it a field value
					var attr = "value=\"{" + propName + "}\"";
					tag = elem.querySelector("input[" + attr + "]");
					
					if(tag != null) {
						
						var fld = Qetesh.BindField.Obj();
						
						fld.FieldElement = tag;
						fld.FieldName = propName;
						fld.QElem = this;
						fld.ObjElem = elem;
						fld.Type = "input";
						
						tag.__qBindField = fld;
						
						tag.onchange = (function (f, t) {
								
							return function(ev) {
								
								f.UpdateState();
							};
						})(fld, tag);
						
						this.__fields.push(fld);
					}
					
					else {
						
						tag = this._findTag("{" + propName + "}", elem);
						
						if(tag != null) {
						
							var fld = Qetesh.BindField.Obj();
							
							fld.FieldElement = tag;
							fld.FieldName = propName;
							fld.QElem = this;
							fld.ObjElem = elem;
							fld.Type = "text";
							
							this.__fields.push(fld);
						}
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
		
		Transform : function(propName, inTransform, outTransform, deep = true) {
			
			var fieldCount = this.__fields.length;
			
			for(var m = 0; m < fieldCount; ++m) {
				
				if(this.__fields[m].FieldName == propName) {
					
					this.__fields[m].Transform(inTransform, outTransform);
					this.Update(false);
				}
			}
			
			if (deep) {
				
				var childLen = this.__children.length;
				
				for(var i = 0; i < childLen; ++i) {
					
					this.__children[i].Transform(propName, inTransform, outTransform);
				}
			}
		},
		
		Reset : function (deep = true) {
			
			var fieldCount = this.__fields.length;
			
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
		
		Element : function (selector) {
			
			var len = this.__elements.length;
			var subobj = Qetesh.HTMLElement.Obj();
			
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
		}
	},
	
	BindField : {
								
		FieldElement : null,
		FieldName : "",
		QElem : null,
		ObjElem : null,
		Type : "",
		Tainted : false,
		__outTransform : function (propertyValue) { return propertyValue; },
		__inTransform : function (propertyValue) { return propertyValue; },
		
		Obj : function() {
		
			var obj = Object.create(this);
			obj.Init();
				
			return obj;
		}, 
		
		Init : function () {
			
		},
		
		Transform : function (outTransform, inTransform) {
			
			if (outTransform != null) this.__outTransform = outTransform;
			if (inTransform != null) this.__inTransform = inTransform;
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
			
			if (this.Type == "input") {
				this.FieldElement.value = val;
				
			}
			else {
				
				this.FieldElement.textContent = val;
			}
			
			this.UpdateTaint();
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
		
		UpdateState : function() {
			
			if (this.Type == "input") {
				
				this.QElem.__bindDataState[this.FieldName] = this.__inTransform(this.FieldElement.value);
				this.UpdateTaint();
			}
			else {
				
				// What? It's not a form field! Why are we here?
			}
		},
		
		Commit : function() {
			
			this.QElem.__bindData[this.FieldName] = this.QElem.__bindDataState[this.FieldName];
			
			this.UpdateTaint();
		},
		
		Clear : function() {
			
			this.FieldElement.nodeValue = "";
		},
		
		Revert : function() {
			
			this.FieldName.nodeValue = this.Template;
		}
	},
	
	DataObject : {
		
		Id : 0,
		PKeyName : "Id",
		__fromMethod : null,
		
		Obj : function() {
		
			var obj = Object.create(this);
			obj.Init();
				
			return obj;
		}, 
		
		Init : function () {
			
		},
		
		Reload : function () {
			
			if (this.boundQElement != null) {
				
				var _this = this;
				
				this.Load(function() {
					
					_this.boundQElement.Update();
				});
			}
		},
	
	},
};

var $_qetesh = Qetesh.Obj();
