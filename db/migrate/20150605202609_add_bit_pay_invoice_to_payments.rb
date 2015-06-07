class AddBitPayInvoiceToPayments < ActiveRecord::Migration
  def change
    change_table :spree_payments do |t|
      t.belongs_to :spree_bit_pay_invoices
    end
  end
end
