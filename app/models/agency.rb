class Agency < ApplicationRecord
  require 'csv'
  has_many :websites, dependent: :destroy
  accepts_nested_attributes_for :websites
  has_many :agency_categories
  has_many :categories, through: :agency_categories
  validates :name, presence: true
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj) { obj.full_address.present? && obj.address_changed? }
  include PgSearch

  pg_search_scope :search_name, against: %i[name address state city zipcode description descripcion],
                                associated_against: { categories: %i[name categoria] },
                                ignoring: :accents


  def upcase_fields
    state.upcase!
  end

  def full_address
    [address, city, state, zipcode].compact.join(', ')
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Agency.find_or_create_by row.to_hash
    end
  end
end
