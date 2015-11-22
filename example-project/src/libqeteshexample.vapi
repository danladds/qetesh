/* libqeteshexample.vapi generated by valac 0.22.1, do not modify. */

namespace QExample {
	namespace Data {
		[CCode (cheader_filename = "QExample.h")]
		public class Invoice : Qetesh.Data.DataObject<global::QExample.Data.Invoice> {
			public Invoice (Qetesh.Data.QDatabaseConn dbh);
			public override string NameTransform (string fieldName);
			public string Forename { get; set; }
			public int Id { get; set; }
			public GLib.DateTime Issued { get; set; }
			public Gee.LinkedList<global::QExample.Data.InvoiceItem> Items { get; set; }
			public string Surname { get; set; }
			public int Total { get; set; }
		}
		[CCode (cheader_filename = "QExample.h")]
		public class InvoiceItem : Qetesh.Data.DataObject<global::QExample.Data.Invoice> {
			public InvoiceItem (Qetesh.Data.QDatabaseConn dbh);
			public override string NameTransform (string fieldName);
			public string Description { get; set; }
			public global::QExample.Data.Invoice FromInvoice { get; set; }
			public int Id { get; set; }
			public int Price { get; set; }
		}
	}
	[CCode (cheader_filename = "QExample.h")]
	public class InvoiceNode : Qetesh.QWebNode {
		public InvoiceNode (string path = "");
	}
	[CCode (cheader_filename = "QExample.h")]
	public class QExample : Qetesh.QWebApp {
		public QExample (Qetesh.WebAppContext ctx);
	}
}
[CCode (cheader_filename = "QExample.h")]
public class ExampleLoader : Qetesh.QPlugin, GLib.Object {
	public ExampleLoader ();
}
