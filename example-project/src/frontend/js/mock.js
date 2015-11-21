var __tmp = {
	Invoice : function () {
		
		this.Id = 0;
		this.Forename = "";
		this.Surname = "";
		this.Issued = Date();
		this.Total = 0;
		
		this.LoadAll = function() {
			
			return _qsh.__callServerFunc('Invoice', 'LoadAll', [], true);
		}
		
		return this;
	},
	
	InvoiceItem : function () {
		
		this.Id = 0;
		this.FromInvoice = 0;
		this.Description = "";
		this.Price = 0;
		
		return this;
	}
}

return __tmp;
