"use strict";

qsh.Ready(function(data) {
	
	qsh.View('list.html', function(view, data) {
		
		var invoice = data.Invoice();
		invoice.LoadAll(function(invoices) {
			
			view.Bind(invoices);
		});
	});
	
	qsh.View('record.html', function(view, data, id) {
	
		var invoice = data.Invoice();
		invoice.Id = id;
		invoice.Load(function () {
			
			view.Bind(invoice);
		});
		
	});
	
});
