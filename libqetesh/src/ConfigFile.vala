/*
 * ConfigFile.vala
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
	 * Configuration file interface
	 * 
	 * Provides simple access to a Qetesh configuration file.
	 * Can be used by modules for their own config file in the same
	 * format if desired.
	 *
	**/
	public class ConfigFile: GLib.Object {
		
		// Defaults
		private const uint16 DLISTEN_PORT = 8041;
		private const int DMAX_THREADS = 1000;
		private const string DLISTEN_ADDR = "0.0.0.0";
		private const string DCACHE_DIR = "/tmp/qetesh";
		public const string DCONFIG_FILE = "/usr/local/etc/qetesh.conf";
		private const string DLOG_FILE = "/var/log/qetesh.log";
		
		private WebServerContext context;
		
		/**
		 * Module configuration
		**/
		public class ModConfig {
			
			/// Path to module library
			public string LibPath;
			
			/// Name of loader class to call on init
			public string LoaderName;
			
			/// Short name for module to reference elsewhere in config
			public string Nick;
			
			/// List of hosts (inc. subhosts) to respond on for module
			public Gee.LinkedList<string> Hosts;
			
			/**
			 * Create a new, blank module config
			**/
			public ModConfig() {
				
				Hosts = new Gee.LinkedList<string>();
			}
		}
		
		/**
		 * Database configuration
		**/
		public class DBConfig {
			
			/// Modules allowed to access database
			public Gee.LinkedList <string> AllowedTypes;
			
			/// Connector to use, e.g. MySQL
			public string Connector;
			
			/// Host to connect to, e.g. localhost
			public string Host;
			
			/// TCP port
			public uint16 Port;
			
			/// DB server username
			public string Username;
			
			/// DB server password
			public string Password;
			
			/// DB server username
			public string DBName;
			
			/// Short name for DB to reference elsewhere in config
			public string Nick;
			
			/**
			 * Create a new, blank database config
			**/
			public DBConfig() {
				
				AllowedTypes = new Gee.LinkedList <string>();
			}
		}
		
		/// Full path to config file
		private string filePath;
		
		// Central server config
		
		/// Port for server to listen on
		public uint16 ListenPort { get; set; }
		
		/// Maximum number of threads for server to run
		public int MaxThreads { get; set; }
		
		/// IP address for server to listen on
		public string ListenAddr { get; set; }
		
		/// Log file to write errors and debug info to
		public string LogFile { get; set; }
		
		/// Level of logging (0 - 5)
		/// TODO: Implement
		public int LogLevel { get; set; }
		
		public Gee.LinkedList<ModConfig?> Modules { get; private set; }
		public Gee.LinkedList<DBConfig?> Databases { get; private set; }
		
		/**
		 * Load and parse a new config file
		 * 
		 * @param path Full file path to config file
		**/ 
		public ConfigFile(WebServerContext sc, string path = DCONFIG_FILE) {
			
			context = sc;
			
			// Set defaults
			ListenPort = DLISTEN_PORT;
			ListenAddr = DLISTEN_ADDR;
			MaxThreads = DMAX_THREADS;
			LogFile = DLOG_FILE;
			
			// Initialise lists
			Modules = new Gee.LinkedList<ModConfig?>();
			Databases = new Gee.LinkedList<DBConfig?>();
			
			filePath = path;
			ReParse();
		}
		
		/**
		 * Parse the current config file again to check for changes
		 * TODO: implement reload function for server
		**/
		public void ReParse() {
			
			try {
				var confFile = File.new_for_path(filePath);
				var parser = new ConfigFileParser(new DataInputStream(confFile.read()), context);
				parser.ReadInto(this);
			}
			catch (Error e) {
				context.Err.WriteMessage("Unable to open config file: %s".printf(filePath), ErrorManager.QErrorClass.QETESH_WARNING);
			}
		}
	}

}
