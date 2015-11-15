Qetesh.Ready(function(data) {
	
	Qetesh.View('list.html', function(view, data) {
		
		var invoice = new data.Invoice();
		view.Bind(invoice.LoadAll());
	});
	
	Qetesh.View('record.html', function(view, data, id) {
	
		var invoice = new data.Invoice();
		invoice.Id = id;
		invoice.Load();
		
		view.Bind(invoice);
	});
	
});
