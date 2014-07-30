class CreateSpreeBitpayInvoices < ActiveRecord::Migration
  def change
    create_table :spree_bitpay_invoices do |t|
      t.string :invoice_id
      t.timestamps
    end
  end
end
