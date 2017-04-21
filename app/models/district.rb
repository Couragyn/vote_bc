class District < ApplicationRecord
  validates :name, uniqueness: true
  has_many :election_districts
  has_many :elections, through: :election_districts
  has_many :candidate_election_districts
  has_many :candidates, through: :candidate_election_districts

  # For acurate results, finds exact lat and lng of addess to pinpoint specific riding
  def self.get_geolocation(address)
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI.escape(address)}&key=#{ENV['GOOGLE_MAPS_API_KEY']}"
    response = HTTP.get(url)
    location = JSON.parse(response)
    lat = location["results"][0]["geometry"]["location"]["lat"]
    lng = location["results"][0]["geometry"]["location"]["lng"]
    Hash["lat", lat, "lng", lng]
  end

  def self.get_boundary_info(geolocation)
    url = "https://represent.opennorth.ca/boundaries/?contains=#{geolocation['lat']},#{geolocation['lng']}"
    response = HTTP.get(url)
    district = JSON.parse(response)
    district['objects'].each do |boundary_set|
      if boundary_set['boundary_set_name'] == 'British Columbia electoral district'
        @district_name = boundary_set['name']
        break
      end
    end
    @district_name
  end

end
