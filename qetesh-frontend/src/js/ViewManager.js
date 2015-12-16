/**
 * Qetesh Javascript
 * ViewManager
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


Qetesh.ViewManager = {
	
	PaneId : '',
	pane : null,
	Views : [],
	ActiveView : 0,
	DefaultContent : "",
	
	
	Obj : function(paneId) {
	
		var obj = Object.create(this);
		obj.Init(paneId);
		
		return obj;
	}, 
	
	Init : function (paneId) {
		
		this.PaneId = paneId;
		this.pane = document.getElementById(paneId);
		this.DefaultContent = this.pane.innerHTML;
		this.pane.innerHTML = "";
	},
	
	View : function(name, tpl, defaultOperator) {
		
		var view = Qetesh.HTMLView.Obj();
		view.Name = name;
		view.TplUri = tpl;
		view.Operators.push(defaultOperator);
		view.Manager = this;
		
		if(tpl != null) {
		
			var container = document.createElement("div");
			container.id = "_q-view-container-" + this.PaneId + "-" + name;
			
			view.container = container;
			
			this.pane.appendChild(container);
		
		}
		else {
			
			view.container = this.pane;
			view.__cache = this.DefaultContent;
		}
		
		this.Views.push(view);
		
		if(tpl == null) {
			
			this.Show(name);
		}
		
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
};
