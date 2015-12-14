/* libqetesh.vapi generated by valac 0.22.1, do not modify. */

namespace Qetesh {
	namespace Data {
		[CCode (cheader_filename = "libqetesh.h")]
		public class BoolValidator : Qetesh.Data.Validator<bool?> {
			public BoolValidator ();
			public override void Convert ();
		}
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
		public class DataNode {
			public DataNode (string name = "Data", string? val = null);
			public bool? BoolVal { get; set; }
			public Gee.LinkedList<Qetesh.Data.DataNode> Children { get; private set; }
			public double? DoubleVal { get; set; }
			public int? IntVal { get; set; }
			public bool IsArray { get; set; }
			public bool IsEnum { get; set; }
			public bool IsNull { get; set; }
			public string Name { get; set; }
			public string Val { get; set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public abstract class DataObject<TImp> : GLib.Object {
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
			public delegate void DataNodeTransform (Qetesh.Data.DataNode n);
			public Gee.HashMap<string,Qetesh.Data.Validator> Validators;
			public DataObject (Qetesh.Data.QDatabaseConn dbh);
			public void Create () throws Qetesh.Data.ValidationError, Qetesh.Data.QDBError;
			public Qetesh.Data.DataObject CreateObject (Gee.TreeMap<string?,string?> datum);
			public void Delete () throws Qetesh.Data.QDBError, Qetesh.Data.ValidationError;
			public void FromNode (Qetesh.Data.DataNode data) throws Qetesh.Data.ValidationError;
			public void FromRequest (Qetesh.HTTPRequest req) throws Qetesh.Data.ValidationError;
			public Qetesh.Data.DataNode? GetPropertyNode (string pName, GLib.Type? propertyType = null, bool shallow = false);
			public Qetesh.Data.DataNode GetValidatorNode () throws Qetesh.Data.ValidationError;
			public abstract void Init ();
			protected Gee.LinkedList<Qetesh.Data.DataObject> LazyLoadList (string propertyName, GLib.Type fType) throws Qetesh.Data.ValidationError, Qetesh.Data.QDBError;
			public void Load () throws Qetesh.Data.QDBError;
			public Gee.LinkedList<Qetesh.Data.DataObject> LoadAll () throws Qetesh.Data.QDBError;
			public void MapObject (Gee.TreeMap<string?,string?> datum);
			public Gee.LinkedList<Qetesh.Data.DataObject> MapObjectList (Gee.LinkedList<Gee.TreeMap<string?,string?>> rows);
			protected virtual string NameTransform (string fieldName);
			public Qetesh.Data.DataNode ToNode (Qetesh.Data.DataObject.DataNodeTransform? transform = null);
			public void Update () throws Qetesh.Data.ValidationError, Qetesh.Data.QDBError;
			public void ValidateAll () throws Qetesh.Data.ValidationError;
			public string ClientName { get; set; }
			public string PKeyName { get; protected set; }
			protected string TableName { get; set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class DoubleValidator : Qetesh.Data.Validator<double?> {
			public DoubleValidator ();
			public override void Convert ();
			public Qetesh.Data.DoubleValidator Equals (double? comp);
			public Qetesh.Data.DoubleValidator GreaterThan (double? comp);
			public Qetesh.Data.DoubleValidator LessThan (double? comp);
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class EnumValidator : Qetesh.Data.IntValidator {
			public EnumValidator (GLib.Type enumType);
			public override void Convert ();
			public Gee.HashMap<int,string> AllowableValues { get; private set; }
			public bool ValidEnum { get; private set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class IntValidator : Qetesh.Data.Validator<int?> {
			public IntValidator ();
			public override void Convert ();
			public Qetesh.Data.IntValidator Equals (int comp);
			public Qetesh.Data.IntValidator GreaterThan (int comp);
			public Qetesh.Data.IntValidator LessThan (int comp);
			protected bool ValidInt { get; private set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public abstract class QDataQuery : GLib.Object {
			public abstract class QueryParam {
				public QueryParam ();
				public abstract Qetesh.Data.QDataQuery.QueryParam Equal (Qetesh.Data.DataNode val);
				public abstract Qetesh.Data.QDataQuery.QueryParam GreaterThan (Qetesh.Data.DataNode val);
				public abstract Qetesh.Data.QDataQuery.QueryParam LessThan (Qetesh.Data.DataNode val);
				public abstract Qetesh.Data.QDataQuery.QueryParam Like (Qetesh.Data.DataNode val);
			}
			public abstract class QueryResult {
				public QueryResult ();
				public abstract Gee.LinkedList<Gee.TreeMap<string,string>> Items { get; protected set; }
			}
			public QDataQuery ();
			public abstract Qetesh.Data.QDataQuery Count ();
			public abstract Qetesh.Data.QDataQuery Create ();
			public abstract Qetesh.Data.QDataQuery DataSet (string setName);
			public abstract Qetesh.Data.QDataQuery Delete ();
			public abstract Qetesh.Data.QDataQuery.QueryResult Do () throws Qetesh.Data.QDBError;
			public abstract int DoInt () throws Qetesh.Data.QDBError;
			protected abstract Gee.LinkedList<Gee.TreeMap<string,string>>? Fetch () throws Qetesh.Data.QDBError;
			public abstract Qetesh.Data.QDataQuery Read ();
			public abstract Qetesh.Data.QDataQuery.QueryParam Set (string fieldName);
			public abstract Qetesh.Data.QDataQuery Update ();
			public abstract Qetesh.Data.QDataQuery.QueryParam Where (string fieldName);
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
			public abstract Gee.LinkedList<Gee.TreeMap<string?,string?>>? DirectQuery (string qText, bool isInsert = false) throws Qetesh.Data.QDBError;
			public abstract Qetesh.Data.QDataQuery NewQuery ();
			public bool IsConnected { get; protected set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class QDateTimeValidator : Qetesh.Data.Validator<Qetesh.QDateTime> {
			public QDateTimeValidator ();
			public override void Convert ();
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class QMysqlConn : Qetesh.Data.QDatabaseConn {
			public QMysqlConn (Qetesh.ConfigFile.DBConfig config, Qetesh.WebServerContext sc);
			public override void Connect () throws Qetesh.Data.QDBError;
			public override Gee.LinkedList<Gee.TreeMap<string?,string?>>? DirectQuery (string qText, bool isInsert) throws Qetesh.Data.QDBError;
			public override Qetesh.Data.QDataQuery NewQuery ();
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class QMysqlDB : Qetesh.Data.QDatabase {
			public QMysqlDB (Qetesh.ConfigFile.DBConfig config, Qetesh.WebServerContext sc);
			public override Qetesh.Data.QDatabaseConn Connect () throws Qetesh.Data.QDBError;
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class QMysqlQuery : Qetesh.Data.QDataQuery {
			public class MysqlQueryParam : Qetesh.Data.QDataQuery.QueryParam {
				public override Qetesh.Data.QDataQuery.QueryParam Equal (Qetesh.Data.DataNode val);
				public static string EscapeString (string inVal);
				protected void GetValue (Qetesh.Data.DataNode node);
				public override Qetesh.Data.QDataQuery.QueryParam GreaterThan (Qetesh.Data.DataNode val);
				public override Qetesh.Data.QDataQuery.QueryParam LessThan (Qetesh.Data.DataNode val);
				public override Qetesh.Data.QDataQuery.QueryParam Like (Qetesh.Data.DataNode val);
				public string FieldComparator { get; private set; }
				public string FieldName { get; private set; }
				public string FieldValue { get; private set; }
			}
			public class MysqlQueryResult : Qetesh.Data.QDataQuery.QueryResult {
				public override Gee.LinkedList<Gee.TreeMap<string,string>> Items { get; protected set; }
			}
			protected GLib.StringBuilder sql;
			public QMysqlQuery (Qetesh.Data.QMysqlConn conn);
			public override Qetesh.Data.QDataQuery Count ();
			public override Qetesh.Data.QDataQuery Create ();
			public override Qetesh.Data.QDataQuery DataSet (string setName);
			public override Qetesh.Data.QDataQuery Delete ();
			public override Qetesh.Data.QDataQuery.QueryResult Do () throws Qetesh.Data.QDBError;
			public override int DoInt () throws Qetesh.Data.QDBError;
			protected override Gee.LinkedList<Gee.TreeMap<string,string>>? Fetch () throws Qetesh.Data.QDBError;
			public override Qetesh.Data.QDataQuery Read ();
			public override Qetesh.Data.QDataQuery.QueryParam Set (string fieldName);
			public override Qetesh.Data.QDataQuery Update ();
			public override Qetesh.Data.QDataQuery.QueryParam Where (string fieldName);
			protected Qetesh.Data.QMysqlConn db { get; set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class StringValidator : Qetesh.Data.Validator<string> {
			public StringValidator ();
			public Qetesh.Data.StringValidator Contains (string comp);
			public override void Convert ();
			public Qetesh.Data.StringValidator DoesntContain (string comp);
			public Qetesh.Data.StringValidator Equals (string comp);
			public Qetesh.Data.StringValidator Matches (string regex);
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public class ValidationTest<T> : GLib.Object {
			public delegate bool TestFunc ();
			public Qetesh.Data.ValidationTest.TestFunc Func;
			public ValidationTest ();
			public bool Run ();
			public string Comparator { get; set; }
			public bool Passed { get; set; }
			public string TestName { get; set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public abstract class Validator<TField> : GLib.Object {
			public Gee.LinkedList<Qetesh.Data.ValidationTest> Tests;
			public Validator ();
			public abstract void Convert ();
			public string DumpResult ();
			public bool Validate ();
			public string InValue { get; set; }
			public bool Mandatory { get; set; }
			public string Name { get; set; }
			public bool NullOut { get; protected set; }
			public TField OutValue { get; set; }
			public bool Passed { get; set; }
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public errordomain QDBError {
			CONNECT,
			QUERY
		}
		[CCode (cheader_filename = "libqetesh.h")]
		public errordomain ValidationError {
			INVALID_VALUE,
			INVALID_DATETIME_STRING,
			UNVALIDATED_FIELD,
			INVALID_PATTERN,
			NULLABLE
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
		public AppModule (string modPath, string nick, string loader, Qetesh.WebServerContext sc, int execUser, int execGroup) throws Qetesh.QModuleError;
		public void ExposeData (Gee.List<Qetesh.Data.DataObject> data);
		public Qetesh.QWebApp GetApp () throws Qetesh.QModuleError;
		public void Handle (Qetesh.HTTPRequest req) throws Qetesh.QModuleError;
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
		public ConfigFile (Qetesh.WebServerContext sc) throws Qetesh.QFileError;
		public void ReParse () throws Qetesh.QFileError;
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
	public class HTTPRequest : GLib.Object {
		public enum RequestMethod {
			GET,
			POST,
			PUT,
			HEAD,
			DELETE,
			INVALID
		}
		public HTTPRequest (GLib.SocketConnection c, Qetesh.WebServerContext sc) throws Qetesh.QRequestError;
		public void Handle () throws Qetesh.QRequestError;
		public void Respond ();
		public void Route (Qetesh.WebAppContext cxt, Qetesh.HTTPResponse resp);
		public Qetesh.WebAppContext AppContext { get; private set; }
		public Qetesh.Data.DataManager Data { get; private set; }
		public string FullPath { get; private set; }
		public Qetesh.HTTPResponse HResponse { get; private set; }
		public Gee.Map<string,string> Headers { get; private set; }
		public string Host { get; private set; }
		public int MaxContentLength { get; private set; }
		public int MaxHeaderLines { get; private set; }
		public int MaxRequestTime { get; private set; }
		public int MaxResponseTime { get; private set; }
		public Qetesh.HTTPRequest.RequestMethod Method { get; private set; }
		public string Path { get; private set; }
		public Gee.LinkedList<string> PathArgs { get; private set; }
		public Qetesh.RequestDataParser RequestData { get; private set; }
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
		public const string DEFAULT_RM;
		public HTTPResponse (Qetesh.WebAppContext ctx);
		public abstract void ComposeContent ();
		public virtual void Respond (GLib.DataOutputStream httpOut);
		public string ContentType { get; set; }
		protected Qetesh.WebAppContext Context { get; private set; }
		public Qetesh.Data.DataNode DataTree { get; private set; }
		public Gee.LinkedList<string> Messages { get; private set; }
		public int ResponseCode { get; set; }
		public string ResponseMessage { get; set; }
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class JSONReqestDataParser : GLib.Object, Qetesh.RequestDataParser {
		public JSONReqestDataParser ();
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class JSONResponse : Qetesh.HTTPResponse {
		public JSONResponse (Qetesh.WebAppContext ctx);
		public void AddJson (Qetesh.Data.DataNode node, bool parentIsArray = false);
		public override void ComposeContent ();
		public string EscapeString (string inStr);
		public void Tab ();
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class ModuleManager : GLib.Object {
		public ModuleManager (Qetesh.WebServerContext c);
		public Qetesh.AppModule? GetHostModule (string host);
		public void LoadModules () throws Qetesh.QModuleError;
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class QDateTime : GLib.Object {
		public QDateTime ();
		public void fromString (string? inVal) throws Qetesh.Data.ValidationError;
		public string toString ();
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
			public Qetesh.QWebNode.LazyExposer Lazy (string propertyName, GLib.Type fType, string returnType) throws Qetesh.ManifestError;
		}
		public class ManifestObject {
			public class ManifestMethod {
				public ManifestMethod (string name, string path, string mType, string rType);
				public void DELETE ();
				public void GET ();
				public Qetesh.Data.DataNode GetDescriptor ();
				public void POST ();
				public void PUT ();
				public string HttpMethod { get; private set; }
				public string MethodType { get; private set; }
				public string Name { get; set; }
				public string NodePath { get; set; }
				public string ReturnType { get; private set; }
			}
			public ManifestObject (string typeName, string pKey);
			public Qetesh.QWebNode.ManifestObject.ManifestMethod LazyLink (string mName, string mType, Qetesh.QWebNode node);
			public Qetesh.QWebNode.ManifestObject.ManifestMethod Method (string mName, string mType, Qetesh.QWebNode node);
			public void Prop (Qetesh.Data.DataNode node);
			public Gee.LinkedList<Qetesh.QWebNode.ManifestObject.ManifestMethod> Methods { get; private set; }
			public string PKeyName { get; private set; }
			public Gee.LinkedList<Qetesh.Data.DataNode> Props { get; private set; }
			public string TypeName { get; private set; }
			public Qetesh.Data.DataNode ValidatorNode { get; set; }
		}
		public class ManifestWalker {
			public ManifestWalker (Qetesh.Data.DataNode rNode);
			public Qetesh.Data.DataNode AddObject (string tName, string pKey);
		}
		public Gee.Map<string,Qetesh.QWebNode> Children;
		public Qetesh.QWebNode.ManifestObject Manifest;
		public Qetesh.QWebNode? Parent;
		protected Qetesh.WebAppContext appContext;
		protected QWebNode (string path = "");
		protected Qetesh.QWebNode.LazyExposer ExposeCrud (GLib.Type typ, string dbName) throws Qetesh.ManifestError;
		protected void ExposeProperties (string typeName, GLib.Type typ) throws Qetesh.ManifestError;
		public string GetFullPath ();
		public static Qetesh.Data.DataNode GetValidationResults (Qetesh.Data.DataObject proto, string message = "");
		public virtual void OnBind () throws Qetesh.AppError;
		public void WalkManifests (Qetesh.QWebNode.ManifestWalker walker);
		protected void WriteMessage (string message, Qetesh.ErrorManager.QErrorClass errorClass = ErrorManager.QErrorClass.MODULE_DEBUG, string? modName = null);
		public new Qetesh.QWebNode? @get (string subpath);
		public new void @set (string subpath, Qetesh.QWebNode node);
		public string Path { get; set; }
		public int size { get; }
		public signal void DELETE (Qetesh.HTTPRequest req);
		public signal void GET (Qetesh.HTTPRequest req);
		public signal void POST (Qetesh.HTTPRequest req);
		public signal void PUT (Qetesh.HTTPRequest req);
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public class WebAppContext : GLib.Object {
		public WebAppContext ();
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
	[CCode (cheader_filename = "libqetesh.h")]
	public interface RequestDataParser : GLib.Object {
		public abstract void Parse (string inData) throws Qetesh.ParserError;
		public abstract Qetesh.Data.DataNode DataTree { get; protected set; }
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public errordomain AppError {
		ABORT
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public errordomain CriticalServerError {
		NOPE
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public errordomain ManifestError {
		COMPOSE
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public errordomain ParserError {
		INVALID_CHAR,
		INVALID_NAME,
		INVALID_VALUE
	}
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
		STRUCTURE,
		RUN,
		CRITICAL
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public errordomain QRequestError {
		CRITICAL,
		HEADERS,
		BODY,
		PATH
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public errordomain QResponseError {
		CRITICAL
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public errordomain QRouterError {
		MODULE,
		USER,
		RESPONSE
	}
	[CCode (cheader_filename = "libqetesh.h")]
	public errordomain QSanityError {
		UNSPECIFIED
	}
}
