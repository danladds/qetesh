/*
 * ErrorManager.vala
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
	 * Error Manager class
	 * 
	 * Centralises error and debug messages and controls
	 * output sources
	**/
	public class ErrorManager : GLib.Object {
		
		/**
		 * Error class
		 * 
		 * Enumeration of error levels
		**/
		public enum QErrorClass {
			QETESH_ERROR,
			QETESH_CRITICAL,
			QETESH_DEBUG,
			QETESH_WARNING,
			QETESH_INTERNAL,
			MODULE_ERROR,
			MODULE_CRITICAL,
			MODULE_DEBUG,
			MODULE_WARNING;
			
			public string to_string() {
				
				switch (this) {
					case QETESH_ERROR:
						return "Error";

					case QETESH_CRITICAL:
						return "Critical";

					case QETESH_DEBUG:
						return "Debug";

					case QETESH_WARNING:
						return "Warning";

					case MODULE_ERROR:
						return "Module Error";

					case MODULE_CRITICAL:
						return "Module Critical";

					case MODULE_DEBUG:
						return "Module Debug";
						
					case MODULE_WARNING:
						return "Module Warning";

					default:
						assert_not_reached();
				}
			}
		}
		
		/// Stream handle for stderr
		private static unowned FileStream consoleErr;
		
		/// Write to stderr (as well as added streams)?
		public bool ErrToConsole { get; set; }
		
		// Defaults
		
		// Default file to log to
		private const string FILE_PATH = "/var/log/qetesh.log";
		
		// Default value for ErrToConsole
		private const bool LOG_TO_CONSOLE = true;
		
		// Current list of output stream handles
		private Gee.ArrayList<DataOutputStream> outputs;
		
		/**
		 * Create a new error manager with no outputs, except stderr
		 * if LOG_TO_CONSOLE is true in defaults above and not 
		 * subsequently changed.
		**/
		public ErrorManager() {
			
			// Default to true unless someone turns it off
			ErrToConsole = LOG_TO_CONSOLE;
			
			outputs = new Gee.ArrayList<DataOutputStream>();
			consoleErr = stderr;
		}
		
		
		/**
		 * Add a stream for text error output
		 * @param outStr Stream to write to
		**/
		public void AddErrorStream(DataOutputStream outStr) {
			
			outputs.add(new DataOutputStream(outStr));
		}
		
		/**
		 * Add a file for text error output
		 * @param path Full path to file
		**/
		
		public void AddErrorFile(string path) {
			
			if (path == "") {
				WriteMessage("Unable to open error log: file path not specified");
			}
				
			try {
				var errFile = File.new_for_path(path);
				AddErrorStream(new DataOutputStream(errFile.append_to(FileCreateFlags.NONE)));
			}
			catch (Error e) {
				WriteMessage("Unable to open error log: %s".printf(path));
			}
		}
		
		/**
		 * Write an error message to current output streams
		 * @param message Message to write
		 * @param errorClass Error classification
		 * @param modName Module name (optional)
		**/
		
		public void WriteMessage(string message, QErrorClass errorClass = QErrorClass.MODULE_CRITICAL, string? modName = null) {
			
			var err = new StringBuilder();
			var dt = new DateTime.now_local();
			
			err.append(dt.format("[%F %R]"));
			
			if(modName != null) err.append(" [%s]".printf(modName));
			
			err.append(" [%s] ".printf(errorClass.to_string()));
			
			err.append(message);
			err.append("\n");
			
			try {
				foreach(var str in outputs) str.write(err.str.data);
			}
			catch {
				WriteMessage("Error writing to log file", QErrorClass.QETESH_ERROR);
			}
			
			if (ErrToConsole) consoleErr.printf(err.str);
			
		}
	}

}
