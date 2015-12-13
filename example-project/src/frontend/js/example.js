"use strict";

// Framework init
var $_qetesh = Qetesh.Obj();

// If you have your own class, attach its init here,
// or whatever function signals to it that Qetesh is ready.
// Otherwise, if it's a small project and you're just
// doing it "freestyle" like this, still all your code
// within this callback
$_qetesh.Ready(function(q) {
	
	// Just functions to parse currencies / date
	var printDate = function(val) {
		
		var dt = new Date(val);
		return dt.toLocaleDateString();
	};
	
	var printCurrency = function(val) {
		return (parseInt(val) / 100).toFixed(2);
	};
	
	var parseCurrency = function(val) {
		return val * 100;
	};
	
	// Establish message area
	//var messageBox = Qetesh.MessageBox.Obj("#messages");
	
	// "Pretty" list of enum value names
	var prettyTypes = { 0 : "Receivable", 1: "Payable" };
	
	// Create a new ViewManager. Only takes ID and needs a unique one.
	// ViewManager controls changes of HTML templates within any given "pane",
	// e.g. a div into which Views are loaded
	var viewPane = q.ViewManage('view-pane');
	
	// Add a new view, with a short name, template file and operator function,
	// which is called when the view is loaded, pending caching
	viewPane.View('list', 'list.html', function(view) {
		
		// Create an Invoice, which was created from the manifest provided
		// by the server. Extends DataObject on the client-side, too.
		var invoice = q.Data.Invoice.Obj();
		
		// Bind this prototype Invoice to the area containing filter controls, etc.
		var filterArea = view.Element('#invoice-proto').Bind(invoice);
		
		// Use functions exposed from the server side. On the client side,
		// they take callbacks which are called when the data request returns
		invoice.LoadAll(function(invoices) {
			
			// Bind invoices (Array[Invoice]) to template table row, 
			// the HTMLElement returned by Element(), which takes a CSS3
			// selector.
			// Automatically becomes a repeater when bound with array.
			var list = view.Element('.invoice-list-item').Bind(invoices);
			
			// Set those date and currency transform funcs to operate on
			// certain fields between UI and data
			list.Transform("Issued", printDate);
			
			// Register pretty names for the enum. If you don't do this,
			// the enum will just behave like a range-restricted integer
			// Why not from the server? 1) Difficult in Vala and
			// 2) Display names quite often different
			list.PrettyNames("IType", prettyTypes);
			
			var typeFilter = filterArea.Field("IType");
			
			typeFilter.AddUnfilter("All");
			
			typeFilter.WhenUpdated(function(invoiceFilter) {
				
				list.Filter(invoiceFilter);
			});
			
			// Set an onclick function. It's a repeater, so gets placed in context
			// on each table row and called with the relevant Invoice item that's
			// bound to that row. 'this' is also in context of the HTMLElement repeater.
			list.Click(function(invoice) {
				
				// True = reload, otherwise we just get the cached first entry
				// every time
				viewPane.Show('record', [invoice, list], true );
			});
			
			view.Element('#invoice-list-new').Click(function() {
				
				// Switch views to the one we'll define below
				viewPane.Show('record',  [q.Data.Invoice.Obj(), list], true);
			});
			
			view.Element('#invoice-list-reload').Click(function() {
				
				// To re-load data layer, just call function again,
				// callback not needed
				invoice.LoadAll();
			});
			
			view.Element('#invoice-list-reset').Click(function() {
				
				// Reset UI from data layer
				list.Reset();
			});
		});
	});
	
	viewPane.View('record', 'record.html', function(view, inParams) {
		
		var invoice = inParams[0];
		var list = inParams[1];
		
		// Attach to forms in the same way as other elements
		var invoiceForm = view.Element('#record').Bind(invoice);
		
		invoiceForm.Transform("Issued", printDate);
		invoiceForm.Transform("Total", printCurrency, parseCurrency);
		
		invoice.Items(function(items) {
		
			// Bind existing and add row with new object
			var itemList = invoiceForm.Element('.invoiceitem-list-item').Bind(items);
			
			// Add a new item
			// Bind can be called more than once. If a single item is
			// passed to an existing repeater, it is added to the list
			// Remember to initialise new object with foreign ID
			var newItem = q.Data.InvoiceItem.Obj();
			newItem.FromInvoice = invoice.Id;
			itemList.Bind(newItem);
			
			var codeOpts = [];
			
			// Load list of AccountingCode for drop down
			Qetesh.Data.AccountingCode.LoadAll(function(codes) {
				
				itemList.Populate("Code", "Code", codes);
				codeOpts = codes;
			});
			
			
			itemList.Transform("Price", printCurrency, parseCurrency);
			
			invoiceForm.Element('#invoice-reload').Click(function(invoice) {
				
				// Re-get data layer from server
				invoice.Reload();
				
				// Getting the items again automatically updates the data
				// attached to their databound locations. We don't have to
				// do anything else.
				invoice.Items();
			});
			
			var itemSaveFunc = function(invoiceItem) {
				
				// Commit data to data layer and then either create or update
				invoiceItem.Commit();

				invoiceItem.Save(function(invoiceItem) {  
					
					// Add a new one as the "add" row, now that this row is 
					// bound to an existing object
					// Remember again to set foreign object key
					var newItem = q.Data.InvoiceItem.Obj();
					newItem.FromInvoice = invoice.Id;
					itemList.Bind(newItem);
					itemList.Element(".invoiceitem-save").Click(itemSaveFunc);
				});
				
			};
			
			itemList.Element(".invoiceitem-save").Click(itemSaveFunc);
			
			itemList.Element(".invoiceitem-delete").Click(function(invoiceItem) {
				
				// Individual subitem delete- ignore for "add" row
				invoiceItem.DeleteExisting(function() {
				
					// In the callback so this happens after the delete
					// is done, otherwise we get an update lag until
					// the next Reset
				
					// Update list repeater to remove it from the UI
					// False here means we don't reset all values in all
					// other list items
					itemList.Reset(false);
				});
			});
			
			invoiceForm.Element('#invoice-save').Click(function(invoice) {
				
				// Save does a Create or Update appropriately
				// Takes two callbacks as params, both optional
				// First called on Create, second on Update
				invoice.Save(function() {
					
					// If a new item has been created,
					// add it to the list in the first view
					list.Bind(invoice);
					
					// Get values that have defaulted
					invoice.Reload();
					invoiceForm.Reset();
				});
				
				for(var i = 0; i < items.length; i++) {
					
					// Saves items that already exist on the server
					// i.e. doesn't implicitly save new rows, although
					// we easily could too with Save()
					items[i].SaveExisting();
				}
			});
			
			invoiceForm.Element('#invoice-delete').Click(function(invoice) {
				
				// Must delete all subitems first,
				// unless your database is set to cascade
				// or you've overridden Delete() on the
				// server-side DataObject and done this there (better performance)
				for(var i = 0; i < items.length; i++) {
							
					items[i].Delete();
				}
				
				// Deletes where already on the server
				invoice.DeleteExisting();
				viewPane.Show('list');
			});
		});
		
		invoiceForm.Element('#invoice-return').Click(function(invoice) {
			
			// Show from cached rendering - still shows committed changes
			viewPane.Show('list');
			
		});
		
		invoiceForm.Element('#invoice-reset').Click(function(invoice) {
			
			// Reset current view from data layer
			invoiceForm.Reset();
		});
		
		invoiceForm.Element('#invoice-commit').Click(function(invoice) {
			
			// Commit current view data to data layer
			invoiceForm.Commit(false);
		});
		
	});
	
	viewPane.Show('list');
	
});
