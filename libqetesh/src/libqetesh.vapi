/* libqetesh.vapi generated by valac 0.22.1, do not modify. */

namespace Qetesh {
	namespace Data {
		[CCode (cheader_filename = "libqetesh.h")]
		public class DBManager : GLib.Object {
			public DBManager (Qetesh.WebServerContext sc);
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class DataManager : GLib.Object {
			public DataManager (Qetesh.Data.DBManager dbm);
			public Qetesh.Data.QDatabaseConn GetConnection (string dbNick) throws Qetesh.Data.QDBError;
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public abstract class DataObject<TImp> : GLib.Object {
			public class DataNode {
				public DataNode (string name = "Data", bool isArray = false);
				public Gee.LinkedList<Qetesh.Data.DataObject.DataNode> Children { get; private set; }
				public bool IsArray { get; set; }
				public string Name { get; set; }
				public string Val { get; set; }
			}
			public class InheritInfo {
				public enum LinkJoinType {
					LEFT,
					INNER,
					OUTER,
					RIGHT
				}
				public InheritInfo ();
				public string LocalTableKey { get; set; }
				public string LocalTableName { get; set; }
				public string ParentTableKey { get; set; }
				public string ParentTableName { get; set; }
			}
			public class LazyNode : Qetesh.QWebNode {
				public LazyNode ();
			}
			public delegate void DataNodeTransform (Qetesh.Data.DataObject.DataNode n);
			public DataObject (Qetesh.Data.QDatabaseConn dbh);
			public void Create ();
			public Qetesh.Data.DataObject CreateObject (Gee.TreeMap<string?,string?> datum);
			public void Delete ();
			public abstract void Init ();
			public void LazyLink (string localProp, string remoteProp = "");
			protected Gee.LinkedList<Qetesh.Data.DataObject> LazyLoadList (string propertyName, GLib.Type fType);
			public void Load ();
			public Gee.LinkedList<Qetesh.Data.DataObject> LoadAll () throws Qetesh.Data.QDBError;
			public void MapObject (Gee.TreeMap<string?,string?> datum);
			public Gee.LinkedList<Qetesh.Data.DataObject> MapObjectList (Gee.LinkedList<Gee.TreeMap<string?,string?>> rows);
			protected virtual string NameTransform (string fieldName);
			public Qetesh.Data.DataObject.DataNode ToNode (Qetesh.Data.DataObject.DataNodeTransform transform);
			public Gee.LinkedList<TImp> Children { get; }
			protected string PKeyName { get; set; }
			public Gee.LinkedList<TImp> Parents { get; }
			protected string QueryTarget { get; private set; }
			protected string TableName { get; set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public abstract class QDatabase : GLib.Object {
			public QDatabase (Qetesh.ConfigFile.DBConfig config, Qetesh.WebServerContext sc);
			public abstract Qetesh.Data.QDatabaseConn Connect () throws Qetesh.Data.QDBError;
			protected Qetesh.ConfigFile.DBConfig Conf { get; private set; }
			protected Qetesh.WebServerContext Context { get; private set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public abstract class QDatabaseConn {
			public QDatabaseConn ();
			public abstract void Connect () throws Qetesh.Data.QDBError;
			public abstract Gee.LinkedList<Gee.TreeMap<string?,string?>>? Q (string qText) throws Qetesh.Data.QDBError;
			public bool IsConnected { get; protected set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class QMysqlDB : Qetesh.Data.QDatabase {
			public QMysqlDB (Qetesh.ConfigFile.DBConfig config, Qetesh.WebServerContext sc);
			public override Qetesh.Data.QDatabaseConn Connect () throws Qetesh.Data.QDBError;
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public errordomain QDBError {
			CONNECT,
			QUERY
		}
	}
	namespace Errors {
		[CCode (cheader_filename = "libqetesh.h")]
		public errordomain QError {
			UNSPECIFIED
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public errordomain QFileError {
			ACCESS,
			READ,
			WRITE,
			FORMAT
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public errordomain QModuleError {
			LOAD,
			CONFIG,
			STRUCTURE
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public errordomain QSanityError {
			UNSPECIFIED
		}
	}
	namespace Webserver {
		[CCode (cheader_filename = "libqetesh.h")]
		public class libqetesh {
			public libqetesh ();
		}
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class AppModule : GLib.Object {
		public AppModule (string modPath, string nick, string loader, Qetesh.WebServerContext sc, int execUser, int execGroup) throws Qetesh.Errors.QModuleError;
		public void ExposeData (Gee.List<Qetesh.Data.DataObject> data);
		public Qetesh.QWebApp GetApp () throws Qetesh.Errors.QModuleError;
		public void Handle (Qetesh.HTTPRequest req);
		public Qetesh.WebAppContext Context { get; private set; }
		public int ExecGroup { get; private set; }
		public int ExecUser { get; private set; }
		public string Nick { get; private set; }
		public Qetesh.QWebApp WebApp { get; private set; }
		public signal void ApplicationStart ();
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class ConfigFile : GLib.Object {
		public class DBConfig {
			public Gee.LinkedList<string> AllowedTypes;
			public string Connector;
			public string DBName;
			public string Host;
			public string Nick;
			public string Password;
			public uint16 Port;
			public string Username;
			public DBConfig ();
		}
		public class ModConfig {
			public int ExecGroup;
			public int ExecUser;
			public Gee.LinkedList<string> Hosts;
			public string LibPath;
			public string LoaderName;
			public string Nick;
			public ModConfig ();
		}
		public string dirPath;
		public const string DCONFIG_DIR;
		public const string DCONFIG_FILE;
		public ConfigFile (Qetesh.WebServerContext sc);
		public void ReParse ();
		public Gee.LinkedList<Qetesh.ConfigFile.DBConfig?> Databases { get; private set; }
		public string ListenAddr { get; set; }
		public uint16 ListenPort { get; set; }
		public string LogFile { get; set; }
		public int LogLevel { get; set; }
		public int MaxThreads { get; set; }
		public Gee.LinkedList<Qetesh.ConfigFile.ModConfig?> Modules { get; private set; }
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class ConfigFileParser : GLib.Object {
		public ConfigFileParser (GLib.DataInputStream confFile, Qetesh.WebServerContext sc);
		public void ReadInto (Qetesh.ConfigFile cfg);
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class ErrorManager : GLib.Object {
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
			public string to_string ();
		}
		public ErrorManager ();
		public void AddErrorFile (string path);
		public void AddErrorStream (GLib.DataOutputStream outStr);
		public void WriteMessage (string message, Qetesh.ErrorManager.QErrorClass errorClass = QErrorClass.MODULE_CRITICAL, string? modName = null);
		public bool ErrToConsole { get; set; }
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class EventManager : GLib.Object {
		public void CallEvents (string? clientId = null);
		public string GetEventCode ();
		public void RegisterEvent (Qetesh.QEvent ev, string? clientId = null);
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class HTMLElement : GLib.Object {
		public delegate void PropogateCallback (Qetesh.Data.DataObject datum, Qetesh.HTMLElement elem);
		public void Attach (Qetesh.QEvent ev);
		public Qetesh.HTMLElement Propogate ();
		public Qetesh.HTMLElement Replicate (int copies);
		public new Qetesh.HTMLElement? @get (string selector);
		public string Content { get; set; }
		public string Selector { get; set; }
		public string Val { get; set; }
		public int size { get; }
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class HTTPRequest : GLib.Object {
		public enum RequestMethod {
			GET,
			POST,
			PUT,
			HEAD,
			INVALID
		}
		public HTTPRequest (GLib.SocketConnection c, Qetesh.WebServerContext sc);
		public void Handle ();
		public void Respond ();
		public void Route (Qetesh.WebAppContext cxt, Qetesh.HTTPResponse resp);
		public Qetesh.WebAppContext AppContext { get; private set; }
		public Qetesh.Data.DataManager Data { get; private set; }
		public Qetesh.Data.DataObject.DataNode DataTree { get; private set; }
		public string FullPath { get; private set; }
		public Qetesh.HTTPResponse HResponse { get; private set; }
		public Gee.Map<string,string> Headers { get; private set; }
		public string Host { get; private set; }
		public Qetesh.HTTPRequest.RequestMethod Method { get; private set; }
		public string Path { get; private set; }
		public Gee.LinkedList<string> PathArgs { get; private set; }
		public uint16 RequestPort { get; private set; }
		public Qetesh.WebServerContext ServerContext { get; private set; }
		public uint16 ServerRequestPort { get; set; }
		public string UserAgent { get; private set; }
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public abstract class HTTPResponse : GLib.Object {
		public GLib.StringBuilder Content;
		public const int DEFAULT_CODE;
		public const string DEFAULT_CT;
		public HTTPResponse (Qetesh.WebAppContext ctx);
		public abstract void ComposeContent ();
		public virtual void Respond (GLib.DataOutputStream httpOut);
		public string ContentType { get; set; }
		protected Qetesh.WebAppContext Context { get; private set; }
		public Qetesh.Data.DataObject.DataNode DataTree { get; private set; }
		public Gee.LinkedList<string> Messages { get; private set; }
		public int ResponseCode { get; set; }
		public string ResponseMessage { get; set; }
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class JSONResponse : Qetesh.HTTPResponse {
		public JSONResponse (Qetesh.WebAppContext ctx);
		public void AddJson (Qetesh.Data.DataObject.DataNode node, bool parentIsArray = false);
		public override void ComposeContent ();
		public void Tab ();
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class ModuleManager : GLib.Object {
		public ModuleManager (Qetesh.WebServerContext c);
		public Qetesh.AppModule? GetHostModule (string host);
		public void LoadModules ();
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class QDateTime : GLib.Object {
		public QDateTime ();
		public void fromString (string inVal);
		public string toString ();
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class QEvent {
		public QEvent (string type);
		public void Fire (Qetesh.HTTPRequest req);
		public string ClientEventType { get; set; }
		public Qetesh.HTTPRequest Request { get; private set; }
		public signal void EventFire (Qetesh.QEvent ev);
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class QManifest : Qetesh.QWebNode {
		public QManifest ();
		public override void OnBind ();
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class QWebApp : GLib.Object {
		protected Qetesh.QWebNode RootNode;
		protected Qetesh.WebAppContext appContext;
		public QWebApp (Qetesh.WebAppContext ctx);
		protected void WriteMessage (string message, Qetesh.ErrorManager.QErrorClass errorClass = ErrorManager.QErrorClass.MODULE_CRITICAL, string? modName = null);
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class QWebNode : GLib.Object {
		public class LazyExposer {
			public Qetesh.QWebNode.LazyExposer Lazy (string propertyName, GLib.Type fType, string returnType);
		}
		public class ManifestObject {
			public class ManifestMethod {
				public ManifestMethod (string name, string path, string mType, string rType);
				public void GET ();
				public Qetesh.Data.DataObject.DataNode GetDescriptor ();
				public void POST ();
				public void PUT ();
				public string HttpMethod { get; private set; }
				public string MethodType { get; private set; }
				public string Name { get; set; }
				public string NodePath { get; set; }
				public string ReturnType { get; private set; }
			}
			public Gee.LinkedList<Qetesh.QWebNode.ManifestObject.ManifestMethod> Methods;
			public ManifestObject (string typeName);
			public Qetesh.QWebNode.ManifestObject.ManifestMethod LazyLink (string mName, string mType, Qetesh.QWebNode node);
			public Qetesh.QWebNode.ManifestObject.ManifestMethod Method (string mName, string mType, Qetesh.QWebNode node);
			public string TypeName { get; private set; }
		}
		public class ManifestWalker {
			public ManifestWalker (Qetesh.Data.DataObject.DataNode rNode);
			public Qetesh.Data.DataObject.DataNode AddObject (string tName);
		}
		public Gee.Map<string,Qetesh.QWebNode> Children;
		public Qetesh.QWebNode.ManifestObject Manifest;
		public Qetesh.QWebNode? Parent;
		protected QWebNode (string path = "");
		protected Qetesh.QWebNode.LazyExposer ExposeCrud (string typeName, GLib.Type typ, string dbName);
		public string GetFullPath ();
		public virtual void OnBind ();
		public void WalkManifests (Qetesh.QWebNode.ManifestWalker walker);
		public new Qetesh.QWebNode? @get (string subpath);
		public new void @set (string subpath, Qetesh.QWebNode node);
		public string Path { get; set; }
		public int size { get; }
		public signal void GET (Qetesh.HTTPRequest req);
		public signal void POST (Qetesh.HTTPRequest req);
		public signal void PUT (Qetesh.HTTPRequest req);
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class WebAppContext : GLib.Object {
		public WebAppContext ();
		public Qetesh.EventManager Events { get; set; }
		public Qetesh.AppModule Mod { get; set; }
		public Qetesh.WebServerContext Server { get; set; }
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class WebServerContext : GLib.Object {
		public Qetesh.ConfigFile Configuration;
		public Qetesh.Data.DBManager Databases;
		public Qetesh.ErrorManager Err;
		public Qetesh.ModuleManager Modules;
		public WebServerContext ();
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public interface FileParser<T> : GLib.Object {
		public void ReadInto (T obj);
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public interface QPlugin : GLib.Object {
		public abstract Qetesh.QWebApp GetModObject (Qetesh.WebAppContext ctx);
	}
}
