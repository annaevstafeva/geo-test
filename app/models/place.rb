class Place < ApplicationRecord
  has_many :from_distances, class_name: 'SavedDistance', foreign_key: 'from_id', dependent: :destroy
  has_many :to_distances, class_name: 'SavedDistance', foreign_key: 'to_id', dependent: :destroy

  after_commit :get_coordinates, on: :create

  validates :city_name, presence: true, uniqueness: true, on: :create

  geocoded_by :address

  def get_coordinates
    update(GeocoderYandexApi.coordinates(self.city_name))
  end

  def address
    "#{city_name}, #{country_name}"
  end
end
