/**
 * Qetesh Javascript
 * ProxyFactory
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

Qetesh.ProxyFactory = {
	
	MakeProxyClass : function (name, manifest) {
		
		var proxy = Qetesh.DataObject.Obj();
		
		proxy.Obj = function () {
			
			var obj = Object.create(proxy);
				
			return obj;
		};
		
		for (var methodName in manifest) {
			  
			if(manifest.hasOwnProperty(methodName) ) {
				
				var methodDef = manifest[methodName];
				
				// Validators
				if(methodName == "Validators") {
					
					for(var fName in methodDef) {
						
						if(methodDef.hasOwnProperty(fName) ) {
							
							var vDef = methodDef[fName];
							var vdr = Qetesh.Validators[vDef.ValidatorClass].Obj();
							var tc = "";
							
							if(vDef.Tests != "") {
							
								// Validator tests
								for(var testName in vDef.Tests) {
									
									if(vDef.Tests.hasOwnProperty(testName)) {
										
										tc = vDef.Tests[testName];
										vdr[testName](tc);
									}
								}
							}
								
							// Enum allowable values
							if(vdr.Name == "EnumValidator") {
								
								vdr.AllowableValues = vDef.AllowableValues;
							}
							
							proxy.Validators[fName] = vdr;
						
						}
					}
					
					continue;
				}
				
				// Static values
				if(methodDef.HttpMethod == null) {
					
					(function (mName) {
						Object.defineProperty(proxy, mName, {
							
							get : function() {
								
								return this["_" + mName];
							},
							
							set: function(val) {
								
								this["_" + mName] = val;
								this.SetTaint(mName);
							}
						});
					})(methodName);
					
					proxy["_" + methodName] = methodDef;
					proxy.__properties.push(methodName);
					continue;
				}
				
				var httpMethod = methodDef.HttpMethod;
				var nodePath = methodDef.NodePath;
				var methodType = methodDef.MethodType;
				var returnType = methodDef.ReturnType;

			
				proxy[methodName] = (function(
					hMethod, nPath,	mType, rType, mName
				) {
					
					return function(callback = null) {
					
						var xh = new XMLHttpRequest();
						
						var _this = this;
							
						xh.onreadystatechange = function () {
							
							
							// Successful requests	
							if (xh.readyState == 4 && xh.status == 200) {
								
								var realType;
								var inData = JSON.parse(xh.responseText);
								
								// Void returns
								if (rType == "void") {
									
									if (hMethod == "POST") {
										if (inData instanceof Array) inObj = inData[0];
										else inObj = inData;
										
										if(inObj != null && inObj.Success == "Y") {
											
											_this[_this.PKeyName] = inObj[_this.PKeyName];
											
											if(_this.boundQElement != null) {
										
												_this.boundQElement.CopyDown(_this.PKeyName);
											}
											
											_this.__tainted = [];
											_this.ServerValidationSuccess();
									
											if (callback != null) callback(this);
										}
									}
								}
								// Implode returns
								else if (rType == "implode") {
									
									_this[_this.PKeyName] = _this.__proto__.PKeyName;
									_this.__deleteMe = true;
									
									if (callback != null) callback(this);
								}
								// Array returns
								else if (rType.indexOf("[]") > 1) {
									
									var returnList = [];
									var realType = rType.replace("[]", "");
									
									var arrayLen = inData.length;
									for (var i = 0; i < arrayLen; ++i) {
										
										var item = inData[i];
										var proto = null;
										
										// Iterate existing items (if there are any)
										var prevCount = 0;
										
										if(_this["__" + mName] != null) prevCount = _this["__" + mName].length;
										
										for(var y = 0; y < prevCount; ++y) {
												
											var obj = _this["__" + mName][y];
										
											// Matched existing
											if (obj[obj.PKeyName] == item[obj.PKeyName]) {
												
												proto = obj;
												obj.__tainted = [];
											}
										}
										
										if (proto == null) {
											
											proto = Qetesh.Data[realType].Obj();
										}
										
										for (var prop in item) {
			  
											if( item.hasOwnProperty(prop) ) {
											
												proto[prop] = item[prop];
											} 
										}
										
										returnList.push(proto);
									}
									
									if(
										_this["__" + mName] != null &&
										_this["__" + mName][0] != null &&
										_this["__" + mName][0].boundQElement != null &&
										_this["__" + mName][0].boundQElement.__parent != null
									) {
										_this["__" + mName][0].boundQElement.__parent.UpdateTaint();
									}
									
									_this["__" + mName] = returnList;
									
									if (callback != null) callback(returnList);
								}
								// Single returns - self
								else if (rType == "this")
								{
									var inObj;
									
									if (inData instanceof Array) inObj = inData[0];
									else inObj = inData;
									
										
									for (var prop in inObj) {
			  
										if( inData[0].hasOwnProperty(prop) ) {
										
											_this[prop] = inData[0][prop];
										} 
									}
									
									_this.__tainted = [];
									
									_this["__" + mName] = _this;
									
									if(_this.boundQElement != null) {
										
										_this.boundQElement.UpdateTaint();
									}
									
									if (callback != null) callback(this);
								}
								// Single returns - other
								else {
									
									var inObj;
									var proto = null;
									
									if (inData instanceof Array) inObj = inData[0];
									else inObj = inData;
									
									// If already loaded, this is a re-load
									if(_this["__" + mName] != null) {
										
											proto = _this["__" + mName];
									}
									
									if (proto == null) {
										proto = Qetesh.Data[realType].Obj();
									}
										
									for (var prop in inObj) {
			  
										if( inData[0].hasOwnProperty(prop) ) {
										
											proto[prop] = inData[0][prop];
										} 
									}
									
									proto.__tainted = [];
									
									if(proto.boundQElement != null) {
										
										proto.boundQElement.UpdateTaint();
									}
									
									if (callback != null) callback(this);
								}
								
							}
							
							else if (xh.readyState == 4 && xh.status == 400) {
								
								var inData = JSON.parse(xh.responseText);
								
								inObj = null;
								
								if (inData instanceof Array) inObj = inData[0];
								else inObj = inData;
								
								if(inObj == null || inObj.Errors == null) {
									
									return;
								}
								
								var errs = inObj.Errors;
								
								for(var fName in errs) {
									
									if(errs.hasOwnProperty(fName)) {
										
										var serverTests = errs[fName];
										var sTestLen = serverTests.length;

										for(var _i = 0; _i < sTestLen; _i++) {
											
											var sTestDef = serverTests[_i];
											
											var clientTestLen = _this.Validators[fName].Tests.length;
											
											for(var _y = 0; _y < clientTestLen; _y++) {
												
												if(_this.Validators[fName].Tests[_y].TestName == sTestDef.TestName) {
													
													var clientTest = _this.Validators[fName].Tests[_y];
											
													clientTest.Passed = (sTestDef.Passed == "true" ? true : false);
													clientTest.Comparator = sTestDef.Comparator;
												}
											}
										}

									}
								}
								
								_this.ShowValidationErrors();
								
							}
							
							else if (xh.readyState == 4 && xh.status == 500) {
								
								// Crap
							}
						};
						
						var actualPath = "";
					
						actualPath = nPath.replace("$n", this[this.PKeyName]);
							
						xh.open(
							hMethod, 
							Qetesh.QConf.ServerUri + actualPath, 
							true
						);
						
						if(hMethod == "POST" || hMethod == "PUT") {
							
							// Don't bother if nothing to send
							if (this.__tainted.length > 0) {
								
								var sendPassed = true;

								// Always send primary key
								this.SetTaint(this.PKeyName);
								
								var tLen = this.__tainted.length;
								var outObj = { };
								
								for(var u = 0; u < tLen; ++u) {
									
									var vfName = this.__tainted[u];
									var vtor = this.Validators[vfName];
									
									if(vfName == "PKeyName") continue;
									
									if(vtor.Validate()) {
									
										outObj[vfName] = this[vfName];
									}
									else {
										sendPassed = false;
									}
								}
								
								if(sendPassed) {
									
									var outData = JSON.stringify(outObj);
									
									xh.setRequestHeader("Content-Type", "text/json");
									xh.send(outData);
								}
								else {
									
									this.ShowValidationErrors();
								}
							}
						}
						else {
						
							xh.send();
						}
					}
				})(httpMethod, nodePath, methodType, returnType, methodName);
				
				
			} 
		} 
		
		Qetesh.Data[name] = proxy;
	}
};
