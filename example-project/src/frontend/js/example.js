"use strict";

$_qetesh.Ready(function(q) {
	
	var viewPane = q.ViewManage('view-pane');
	
	viewPane.View('list', 'list.html', function(view) {
		
		var invoice = q.Data.Invoice.Obj();
		invoice.LoadAll(function(invoices) {
			
			view.Bind(invoices, '.invoice-list-item').Click(function(invoice) {
				
				viewPane.Show('record', invoice );
			});
		});
	});
	
	viewPane.View('record', 'record.html', function(view, invoice) {
		
		var invoiceForm = view.Bind(invoice, '#record');
		
		// This is for elements that don't utilise bound data for their actions
		view.Element('#invoice-return').Click(function(invoice) {
			
			viewPane.Show('list');
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
