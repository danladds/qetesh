qsh.Ready(function(data) {
	
	qsh.View('list.html', function(view, data) {
		
		var invoice = new data.Invoice();
		view.Bind(invoice.LoadAll());
	});
	
	qsh.View('record.html', function(view, data, id) {
	
		var invoice = new data.Invoice();
		invoice.Id = id;
		invoice.Load();
		
		view.Bind(invoice);
	});
	
});
