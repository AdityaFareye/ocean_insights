class ContainerVessel < ApplicationRecord
  belongs_to :container
  belongs_to :vessel
end
