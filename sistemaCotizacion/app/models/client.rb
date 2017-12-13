class Client < ApplicationRecord
  has_many :quotations

  validates :first_name, format: {with: /\A[a-zA-Z ]+\p{Latin}+\z/, message: "El nombre solo puede contener letras"}, length: { maximum: 20 }, presence: true
  validates :middle_name, format: {with: /\A[a-zA-Z ]+\p{Latin}+\z/, message: "El nombre solo puede contener letras"}, length: { maximum: 20 }, allow_blank: true
  validates :first_surname, format: {with: /\A[a-zA-Z ]+\p{Latin}+\z/, message: "El nombre solo puede contener letras"}, length: { maximum: 20 }, presence: true
  validates :second_surname, format: {with: /\A[a-zA-Z ]+\p{Latin}+\z/, message: "El nombre solo puede contener letras"}, length: { maximum: 20 }, allow_blank: true
  validates :email, length: { maximum: 50 }, presence: true
  validates :phone, numericality: { only_integer: true }, presence: true

end
