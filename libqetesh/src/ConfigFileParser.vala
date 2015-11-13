/*
 * ConfigFileParser.vala
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

	public class ConfigFileParser : GLib.Object {

		private ConfigFile.ModConfig? currentMod = null;
		private ConfigFile.DBConfig? currentDB = null;
		
		private WebServerContext context;
		private DataInputStream file;
		
		
		public ConfigFileParser(DataInputStream confFile, WebServerContext sc) {
			
			context = sc;
			file = confFile;
		}
		
		public void ReadInto(ConfigFile cfg) {
			
			try {
				
				string line;
				
				while ((line = file.read_line (null)) != null) {
					
					// Skip empty lines
					if (line.strip() == "") continue;
					
					// Disregard comments
					var statement = line.split("#", 1)[0].strip().replace("	", "");
					
					// Skip lines that are only comments
					if (statement == "") continue;
					
					var parts = statement.split(" ", 2);
					
					// Check if it's a closing }
					if (parts[0] == "}") {
						
						if (currentMod != null) {
							
							cfg.Modules.add(currentMod);
							currentMod = null;
						}
						
						else if (currentDB != null) {
						
							cfg.Databases.add(currentDB);
							currentDB = null;
						}
					}
					
					// Check that there's a directive and an argument
					if (parts.length != 2) continue;

					// Directive, argument
					var dir = parts[0];
					var arg = parts[1];
					
					if (currentMod != null) {
						ParseModule(dir, arg);
						continue;
					}
					
					if (currentDB != null) {
						
						ParseDatabase(dir, arg);
						continue;
					}
					
					switch(dir) {
						
						case "BindAddress":
							cfg.ListenAddr = arg;
							break;
						
						case "ListenPort":
							cfg.ListenPort = (uint16) int.parse(arg);
							break;
							
						case "MaxThreads":
							cfg.MaxThreads = int.parse(arg);
							break;
							
						case "Module":
							currentMod = new ConfigFile.ModConfig();
							break;
							
						case "Database":
							currentDB = new ConfigFile.DBConfig();
							break;
					}
					
				}
			}
			catch (Error e) {
				context.Err.WriteMessage("Error reading HTML line", ErrorManager.QErrorClass.QETESH_WARNING);
			}
		}
		
		private void ParseModule(string dir, string arg) {
			
			switch(dir) {
						
				case "LibPath":
					currentMod.LibPath = arg;
					break;
				
				case "Nick":
					currentMod.Nick = arg;
					break;
					
				case "LoaderName":
					currentMod.LoaderName = arg;
					break;
					
				case "Host":
					currentMod.Hosts.add(arg);
					break;
			}
		}
		
		private void ParseDatabase(string dir, string arg) {
			
			switch(dir) {
						
				case "Allow":
					currentDB.AllowedTypes.add(arg);
					break;
				
				case "Connector":
					currentDB.Connector = arg;
					break;
					
				case "Host":
					currentDB.Host = arg;
					break;
					
				case "Port":
					currentDB.Port = (uint16) int.parse(arg);
					break;
					
				case "Username":
					currentDB.Username = arg;
					break;
					
				case "Password":
					currentDB.Password = arg;
					break;
				
				case "DBName":
					currentDB.DBName = arg;
					break;
				case "Nick":
					currentDB.Nick = arg;
					break;
			}
		}
	}

}
