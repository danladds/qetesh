"use strict";

$_qetesh.Ready(function(q) {
	
	var viewPane = q.ViewManage('view-pane');
	
	viewPane.View('list', 'list.html', function(view, data) {
		
		var invoice = q.Data.Invoice();
		invoice.LoadAll(function(invoices) {
			
			view.Bind(invoices);
		});
	});
	
	viewPane.View('record', 'record.html', function(view, data, id) {
	
		var invoice = q.Data.Invoice();
		invoice.Id = id;
		invoice.Load(function () {
			
			view.Bind(invoice);
		});
		
	});
	
	// Can define alternative functions for views, e.g. edit
	
	viewPane.Show('list');
	
});
