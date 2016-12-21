class Agency < ApplicationRecord
  has_many :websites, dependent: :destroy
  has_many :websites
  accepts_nested_attributes_for :websites
	has_many :agency_categories
	has_many :categories, through: :agency_categories
	validates :name, presence: true
  #attr_accessor :full_address, :latitude, :longitude
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj){ obj.full_address.present? and obj.address_changed? }

  before_save :upcase_fields
  # method to convert state to all uppercase and save in database -JR
  def upcase_fields
    self.state.upcase!
  end

  # def self.search(search)
  #   where("name LIKE ? OR address LIKE ? OR zipcode LIKE ? OR state LIKE ? OR city LIKE ?", "%#{search}", "%#{search}", "%#{search}", "%#{search}", "%#{search}")
  # end

  def full_address
    [address, city, state, zipcode].compact.join(', ')
  end

  #Method not finished
  
  def self.search(params)
    #agencies = Agency.where(category_id: params[:category].to_i)
    agencies = Agency.near(params[:location])
    agencies = agencies.where("name LIKE ? OR address LIKE ? OR city LIKE ? OR state LIKE ? OR zipcode LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    agencies
  end

  #def self.location(location)
   # where("zipcode LIKE ? OR state LIKE ? OR city LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%" )
  #end

end