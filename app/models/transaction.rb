class Transaction < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :invoices
  has_many :customers, through: :invoices

  default_scope { order(id: :asc) }
  
  scope :successful, -> { where(result: "success") }
end
