class SavedDistance < ApplicationRecord
  belongs_to :from, class_name: "Place"
  belongs_to :to, class_name: "Place"

  before_save :calculate_distance

  # validate :unique_distance, on: :create



  private

  def unique_distance
    if SavedDistance.exists?(from_id: from_id, to_id: to_id) || SavedDistance.exists?(from_id: to_id, to_id: from_id)
      errors.add(:base, "Расстояние между этими местами уже сохранено")
    else
      true
    end

  end

  def calculate_distance
    distance = Geocoder::Calculations.distance_between(
      [from.latitude, from.longitude],
      [to.latitude, to.longitude])
    self.distance = distance
  end

end
