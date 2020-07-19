class Container < ApplicationRecord
  has_many :vessels, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :container_datas, dependent: :destroy
  has_many :ocean_insight_geo_tracks, dependent: :destroy
end
