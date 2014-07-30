class AddIndexToSpreePayments < ActiveRecord::Migration
  def change
  	add_index :spree_payments, :identifier
  end
end
