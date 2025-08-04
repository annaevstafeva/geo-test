class SavedDistancesController < ApplicationController
  def new
    @saved_distance = SavedDistance.new
  end

  def create
    empty_lists = Place.any?
    from_data = GeocoderYandexApi.coordinates(params[:saved_distance][:from])
    to_data = GeocoderYandexApi.coordinates(params[:saved_distance][:to])

    if from_data[:error] || to_data[:error]
      error_message = [from_data[:error], to_data[:error]].compact.join(', ')
      @saved_distance = SavedDistance.new
      return render_form_with_error(error_message, @saved_distance)
    end

    from_present = Place.exists?(from_data)
    to_present = Place.exists?(to_data)

    if params[:saved_distance][:from] == params[:saved_distance][:to]
      place = from_present ? Place.find_by(from_data) : Place.create(from_data)
      @from = @to = place
    else
      @from = from_present ? Place.find_by(from_data) : Place.create(from_data)
      @to = to_present ? Place.find_by(to_data) : Place.create(to_data)
    end

    existing = SavedDistance.find_by(from: @from, to: @to) || SavedDistance.find_by(from: @to, to: @from)

    if existing
      existing.touch
      return render turbo_stream: build_streams(existing, @from, @to, from_present, to_present)
    end

    @saved_distance = SavedDistance.new(from: @from, to: @to)

    if @saved_distance.save
      streams = build_streams(@saved_distance, @from, @to, from_present, to_present)
      streams << replace_empty_state(empty_lists)
      render turbo_stream: streams.flatten
    else
      render_form_with_error(@saved_distance.errors.full_messages.join(', '), @saved_distance)

    end
  end


  private

  def replace_empty_state(empty_lists)
    streams = []
    streams << turbo_stream.replace('empty_state_places', partial: 'places/place_header') unless empty_lists
    streams << turbo_stream.replace('empty_state_distance', partial: 'saved_distances/distance_header') unless empty_lists
    streams
  end

  def render_form_with_error(error, saved_distance)
    render turbo_stream: turbo_stream.replace('distance_form', partial: 'saved_distances/new', locals: { saved_distance: saved_distance, error: error })
  end

  def build_streams(distance, from_place, to_place, from_present, to_present)
    streams = []

    streams << turbo_stream.prepend('distances_list', partial: 'saved_distances/distance_item', locals: { distance: distance })
    streams << turbo_stream.replace('search_result', partial: 'saved_distances/search_result', locals: { result: distance })
    streams << turbo_stream.replace('distance_form', partial: 'saved_distances/new', locals: { saved_distance: SavedDistance.new })
    streams << turbo_stream.prepend('places_list', partial: 'places/place_item', locals: { place: from_place }) unless from_present
    streams << turbo_stream.prepend('places_list', partial: 'places/place_item', locals: { place: to_place }) unless to_present

    streams
  end

  def saved_distance_params
    params.require(:saved_distance).permit(:distance, :from, :to)
  end
end
