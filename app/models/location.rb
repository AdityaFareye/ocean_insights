class Location < ApplicationRecord
  belongs_to :vessel, optional: true
  belongs_to :container, optional: true
  has_many :location_timelines, dependent: :destroy
end
