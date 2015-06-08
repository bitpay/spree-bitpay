// BitPay Payment Methods
//= require spree/frontend

var Bitpay = {

  reasonableInterval: 2000,

  checkout: function(e) {
    e.preventDefault();
    Bitpay.iframeUrl = $.ajax({url: Bitpay.invoiceUrl, async: false}).responseText
    $('#bitpay_invoice_iframe').attr("src", Bitpay.iframeUrl);
    $('#bitpay_checkout_modal').trigger('openModal');
    setTimeout(function(){ Bitpay.checkForUpdates()}, Bitpay.reasonableInterval);
    return false;
  },

  checkForUpdates: function() {
    invId = Bitpay._retrieveInvoiceIdFromURI();
    url = Bitpay.checkUrl;
    $.ajax({
      url: url,
      data: {invoice_id: invId},
      dataType: "json",
      complete: function(json) { Bitpay.getInvoiceState(json.responseText) }
    });
    return false
  },

  continueToConfirmation: function() {
    // Backend will validate actual invoice payment
    $('#continue_to_invoice').removeAttr("disabled");
    $('#continue_to_invoice').attr("class", "continue button primary");
    $('#choose_another_method').attr("class", "button disabled");
    $('#choose_another_method').attr("disabled", "disabled");
    $('#instructions').hide();
    $('#completed').show();
  },

  finishCheckout: function(message) {
    // Limit to messages from apiEndpoint
    if (Bitpay.apiEndpoint && Bitpay.apiEndpoint.lastIndexOf(message.origin, 0) == 0) {
      switch(message.data.status) {
        case "new":
          break;
        case "paid": 
        case "confirmed":
          Bitpay.continueToConfirmation();
          break;
        case "expired":
          Bitpay.showExpiredMessage();
          break;
        default:
          console.log("Unexpected message type: " + message.data.status)
      }
    }
    return false;
  },

  getInvoiceState: function(invoiceState) {
    if(invoiceState == "new"){
      var timeout = setTimeout(function(){ Bitpay.checkForUpdates() }, Bitpay.reasonableInterval);
    } else {
      Bitpay.refreshCheckout();
    }
  },

  refreshCheckout: function() {
    $('#bitpay_invoice_iframe').attr("src", Bitpay.iframeUrl);
    return false;
  },

  showExpiredMessage: function() {
    $('#instructions').hide();
    $('#expired').show();
  },

  _retrieveInvoiceIdFromURI: function() {
    var parser = document.createElement('a');
    parser.href = Bitpay.iframeUrl;
    var search = parser.search;
    Bitpay.invoiceId = search.replace(/^\?/,'').split('&')[0].split('=')[1];
    return Bitpay.invoiceId;  
 }

}

