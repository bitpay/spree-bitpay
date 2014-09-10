// BitPay Payment Methods
//= require spree/frontend

var Bitpay = {

  checkout: function(e, data, status, xhr) {
    e.preventDefault();
    var invoiceUrl = $.ajax({url: Bitpay.invoiceUrl, async: false}).responseText
    $('#bitpay_invoice_iframe').attr("src", invoiceUrl);
    $('#bitpay_checkout_modal').trigger('openModal');
  
    return false;
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

  continueToConfirmation: function() {
    // Backend will validate actual invoice payment
    $('#continue_to_invoice').removeAttr("disabled");
    $('#continue_to_invoice').attr("class", "continue button primary");
    $('#choose_another_method').attr("class", "button disabled");
    $('#choose_another_method').attr("disabled", "disabled");
    $('#instructions').hide();
    $('#completed').show();
  },

  showExpiredMessage: function() {
    $('#instructions').hide();
    $('#expired').show();
  }

}


