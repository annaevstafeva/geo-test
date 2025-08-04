class CreatePlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.string :city_name
      t.string :country_name
      t.float :latitude #ширина
      t.float :longitude #долгота

      t.timestamps
    end
  end
end
