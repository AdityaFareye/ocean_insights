class Vessel < ApplicationRecord
  belongs_to :container
  has_many :locations, dependent: :destroy
  has_many :vessel_logs, dependent: :destroy
end
