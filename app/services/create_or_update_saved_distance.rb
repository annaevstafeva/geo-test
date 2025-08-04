class CreateOrUpdateSavedDistance
  attr_reader :from_place, :to_place, :saved_distance, :error

  def initialize(from_name, to_name)
    @from_name = from_name
    @to_name = to_name

    @from_place_previously_new = false
    @to_place_previously_new = false
    @existing_found = false
  end

  def call
    resolve_places

    return false if @error

    # Проверяем существование дистанции в любом направлении
    @saved_distance = SavedDistance.find_by(from: @from_place, to: @to_place) ||
      SavedDistance.find_by(from: @to_place, to: @from_place)

    if @saved_distance
      @saved_distance.touch
      @existing_found = true
    else
      @saved_distance = SavedDistance.create(from: @from_place, to: @to_place)
    end

    true
  end

  def from_place_previously_new?
    @from_place_previously_new
  end

  def to_place_previously_new?
    @to_place_previously_new
  end

  def existing_was_found?
    @existing_found
  end

  private

  def resolve_places
    from_data = GeocoderYandexApi.coordinates(@from_name)
    to_data   = GeocoderYandexApi.coordinates(@to_name)

    if from_data[:error] || to_data[:error]
      @error = [from_data[:error], to_data[:error]].compact.join(', ')
      return
    end

    @from_place = Place.find_by(from_data)
    unless @from_place
      @from_place = Place.create(from_data)
      @from_place_previously_new = true
    end

    @to_place = Place.find_by(to_data)
    unless @to_place
      @to_place = Place.create(to_data)
      @to_place_previously_new = true
    end
  end
end
