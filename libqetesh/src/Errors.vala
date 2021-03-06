/*
 * Errors.vala
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
	
	public errordomain AppError {
		ABORT
	}
	
	public errordomain CriticalServerError {
		NOPE
	}
	
	public errordomain ParserError {
		
		INVALID_CHAR,
		INVALID_NAME,
		INVALID_VALUE
	}
	
	public errordomain QError {
		UNSPECIFIED
	}
	
	public errordomain QFileError {
		ACCESS,
		READ,
		WRITE,
		FORMAT
	}
	
	public errordomain QModuleError {
		LOAD,
		CONFIG,
		STRUCTURE,
		RUN,
		CRITICAL
	}
	
	public errordomain ManifestError {
		COMPOSE
	}
	
	public errordomain QSanityError {
		UNSPECIFIED
	}
	
	public errordomain QRouterError {
		MODULE,
		USER,
		RESPONSE
	}
	
	public errordomain QRequestError {
		CRITICAL,
		HEADERS,
		BODY,
		PATH
	}
	
	public errordomain QResponseError {
		CRITICAL
	}
}
