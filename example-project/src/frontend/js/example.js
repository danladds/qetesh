"use strict";

$_qetesh.Ready(function(q) {
	
	var printDate = function(val) {
		
		var dt = new Date(val);
		return dt.toLocaleDateString();
	};
	
	var parseDate = function(val) {
				
		var dt = new Date(val);
		return dt.toISOString();
	};
	
	var printCurrency = function(val) {
		return (parseInt(val) / 100).toFixed(2);
	};
	
	var parseCurrency = function(val) {
		return val * 100;
	};
	
	var viewPane = q.ViewManage('view-pane');
	
	viewPane.View('list', 'list.html', function(view) {
		
		var invoice = q.Data.Invoice.Obj();
		invoice.LoadAll(function(invoices) {
			
			var list = view.Element('.invoice-list-item').Bind(invoices);
			
			list.Transform("Issued", printDate);
			list.Transform("Total", printCurrency);
			
			list.Click(function(invoice) {
				
				// True = reload, otherwise we just get the cached first entry
				// every time
				viewPane.Show('record', invoice, true );
			});
			
			view.Element('#invoice-list-new').Click(function() {
				
				viewPane.Show('record', q.Data.Invoice.Obj());
			});
			
			view.Element('#invoice-list-reload').Click(function() {
				
				invoice.LoadAll(function(invoices) {
					viewPane.Show('list');
				});
			});
		});
	});
	
	viewPane.View('record', 'record.html', function(view, invoice) {
		
		var invoiceForm = view.Element('#record').Bind(invoice);
		
		invoiceForm.Transform("Issued", printDate, parseDate);
		invoiceForm.Transform("Total", printCurrency, parseCurrency);
		
		invoice.Items(function(items) {
		
			// Bind existing and add row with new object
			var itemList = invoiceForm.Element('.invoiceitem-list-item').Bind(items).Bind(q.Data.InvoiceItem.Obj());
			
			
			itemList.Transform("Price", printCurrency, parseCurrency);
		});
		
		// This is for elements that don't utilise bound data for their actions
		invoiceForm.Element('#invoice-return').Click(function(invoice) {
			
			// Show from cached rendering 
			viewPane.Show('list');
			
		});
		
		invoiceForm.Element('#invoice-reset').Click(function(invoice) {
			
			invoiceForm.Reset();
		});
		
		invoiceForm.Element('#invoice-commit').Click(function(invoice) {
			
			invoiceForm.Commit();
		});
		
		invoiceForm.Element('#invoice-reload').Click(function(invoice) {
			
			invoice.Reload();
		});
		
		invoiceForm.Element('#invoice-save').Click(function(invoice) {
			
			invoice.Update();
		});
		
		/* - No need to load individually, as we already have it!
		 * Need to demo Load() somewhere else though...
		invoice.Load(function () {
			
			view.Bind(invoice);
		});
		*/
		
	});
	
	// Can define alternative functions for views, e.g. edit
	
	viewPane.Show('list');
	
});
