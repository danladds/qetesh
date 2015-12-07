/*
 * ModuleManager.vala
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
namespace Qetesh {
	
	/**
	* Manages the loading of modules
	**/
	public class ModuleManager : GLib.Object {
		
		/// List of all currently loaded modules
		private Gee.ArrayList<AppModule> loadedModules;
		
		/// Mapping of events to hosts
		private Gee.TreeMap<string, AppModule> hostModules;
		
		private WebServerContext context;
		
		public ModuleManager(WebServerContext c) {
			
			context = c;
			
			// Initialise loaded module list
			loadedModules = new Gee.ArrayList<AppModule>();
			hostModules = new Gee.TreeMap<string, AppModule>();
		}
	
		/**
		* Load appropriate modules
		**/
		public void LoadModules () throws QModuleError {
			
			context.Err.WriteMessage("ModuleManager loading modules", ErrorManager.QErrorClass.QETESH_DEBUG);
			
			if(context.Configuration.Modules.size == 0) {
				
				throw new QModuleError.CONFIG("No modules configured");
			}
			
			foreach(var mod in context.Configuration.Modules) {
				
				context.Err.WriteMessage("Loading module: %s %s %s".printf(mod.Nick, mod.LoaderName, mod.LibPath), ErrorManager.QErrorClass.QETESH_DEBUG);
				
				loadModule(mod);
			}
			
			if(loadedModules.size == 0) {
				
				throw new QModuleError.LOAD("Unable to successfully load any modules");
			}
		}
		
		/**
		* Load a specified module
		* 
		* @param path File path to module library file
		* @param name Type name of the primary element class
		**/
		private void loadModule(ConfigFile.ModConfig mod) {
			
			try {
				
				context.Err.WriteMessage("Loading module: %s".printf(mod.Nick), ErrorManager.QErrorClass.QETESH_DEBUG);
				
				var loadedMod = new AppModule(
					mod.LibPath, mod.Nick, mod.LoaderName, context,
					mod.ExecUser, mod.ExecGroup
				);
				
				loadedModules.add(loadedMod);
				
				context.Err.WriteMessage("Loaded module: %s".printf(mod.Nick), ErrorManager.QErrorClass.QETESH_DEBUG);
				
				// Add to host mapping
				foreach(string host in mod.Hosts) {
					
					if (hostModules.has_key(host)) {
						context.Err.WriteMessage("Host %s already assigned to another module (%s)".printf(host, hostModules[host].Nick), ErrorManager.QErrorClass.MODULE_WARNING);
					} else {
						hostModules[host] = loadedMod;
					}
				}
			}
			catch (QModuleError e) {
					
				context.Err.WriteMessage("Unable to load module %s (%s)".printf(mod.Nick, e.message), ErrorManager.QErrorClass.QETESH_WARNING);
			}
			catch (Error e) {
				context.Err.WriteMessage("Unable to load module %s (%s)".printf(mod.Nick, e.message), ErrorManager.QErrorClass.QETESH_WARNING);
			}
		}
		
		/**
		* Get a module based on provided host
		* 
		* @param host Hostname to look up
		**/
		public AppModule? GetHostModule(string host) {
			
			context.Err.WriteMessage("Attempting to get module for host: %s".printf(host), ErrorManager.QErrorClass.QETESH_DEBUG);
			
			if (hostModules.has_key(host)) {
				
				return hostModules[host];
			}
			else return null;
		}

	}
	
}
