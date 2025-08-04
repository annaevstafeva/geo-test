class PlacesController < ApplicationController
  def index
    @places = Place.order(created_at: :desc)
    @saved_distances = SavedDistance.order(updated_at: :desc).includes(:from, :to)
    @saved_distance = SavedDistance.new
  end

  private

end
