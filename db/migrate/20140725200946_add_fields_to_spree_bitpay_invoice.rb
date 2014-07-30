class AddFieldsToSpreeBitpayInvoice < ActiveRecord::Migration
  def change

  	unless Spree::BitpayInvoice.column_names.include? "payment_method_id"
    	add_column :spree_bitpay_invoices, :payment_method_id, :integer
    	add_index  :spree_bitpay_invoices, :payment_method_id
	end

	unless Spree::BitpayInvoice.column_names.include? "user_id"
	    add_column :spree_bitpay_invoices, :user_id, :integer
	end

  end
end
