class GeocoderYandexApi < ApplicationRecord
  include HTTParty
  base_uri 'https://geocode-maps.yandex.ru'

  def self.coordinates(city)
    response = get('/1.x/', {
      query: {
        geocode: city,
        apikey: '69bc93e5-5ef5-4f28-b80e-faa33e211e5b',
        lang: 'ru_RU',
        format: 'json'
      }
    })

    if response.success?
      begin
        json = JSON.parse(response.body)
        member = json.dig('response', 'GeoObjectCollection', 'featureMember')
        raise StandardError, "Посчитать расстояние невозможно. Введено некорректное значение \"#{city}\" в одно из полей" if member.blank?

        geo = member.first['GeoObject']
        country = geo.dig("metaDataProperty", "GeocoderMetaData", "AddressDetails", "Country", "CountryName")
        points = geo['Point']['pos'].split(' ').map(&:to_f).reverse
        city_name = geo.dig("metaDataProperty", "GeocoderMetaData", "Address", "formatted").split(', ').last

        { latitude: points[0], longitude: points[1], city_name: city_name, country_name: country }
      rescue => e
        { error: e.message }
      end
    else
      { error: "Ошибка при обработке \"#{city}\": #{response.code}" }
    end
  end

  def self.address_persisted?(city)
    first_response = get('/1.x/', {
      query: {
        geocode: city,
        apikey: '69bc93e5-5ef5-4f28-b80e-faa33e211e5b',
        lang: 'ru_RU',
        format: 'json'
      }
    })
    first_response.success?
  end
end
