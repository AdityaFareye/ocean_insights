class ContainersController < ApplicationController
  
  def index
    @containers = Container.where(source: 'ocean-insights').all
    @portcast_containers = Container.where(source: 'portcast').all
  end

  def portcast
    @containers = Container.where(source: 'portcast').all
  end

  def show
    @container = Container.find_by(number: params[:id], source: 'ocean-insights')
  end

  def portcast_container
    @container = Container.find_by(number: params[:id], source: 'portcast')
  end

end