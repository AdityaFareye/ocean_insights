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
@data = {}
    @container.container_datas.each do |x|
      puts ">>>>>>>>> #{x.created_at}"
      date = x.created_at
      data =  eval(x.data)
      containershipments = data['containershipments']
      containershipments.each do |y|
        puts ">>>>>>>>> #{y}"
        if y['pod_vslarrival_prediction']
          @data["#{date}"] = y['pod_vslarrival_prediction']['predicted']
        end
      end
    end
	@final_hash = {}
    puts ">>>>>>>>> #{@data}"
	@data.each do |k,v|
  if @final_hash[v].nil?
   @final_hash[v] = k
  end
end

	puts "------------- #{@final_hash}"
  end

  def portcast_container
    @container = Container.find_by(number: params[:id], source: 'portcast')

	@pod_predicted_arrival_lt_hash = {}
    @pod_predicted_departure_lt_hash = {}
    @pod_predicted_discharge_lt_hash = {}

    @container.container_datas.each do |x|
      date = x.created_at 
      data =  eval(x.data) 
      containershipments = data['sailing_info_tracking']
      containershipments.each do |z|
        y = z['sailing_info']        
        @pod_predicted_arrival_lt_hash[date] = y['pod_predicted_arrival_lt'] 
        @pod_predicted_departure_lt_hash[date] = y['pod_predicted_departure_lt'] 
        @pod_predicted_discharge_lt_hash[date] = y['pod_predicted_discharge_lt'] 
      end 
    end

    puts "------------ pod_predicted_arrival_lt_hash --- #{@pod_predicted_arrival_lt_hash}"
    puts "------------ pod_predicted_departure_lt_hash -- #{@pod_predicted_departure_lt_hash}"
    puts "------------ pod_predicted_discharge_lt_hash --- #{@pod_predicted_discharge_lt_hash}"

    @pod_predicted_arrival_hash = {}
    @pod_predicted_departure_hash = {} 
    @pod_predicted_discharge_hash = {}
   
	@pod_predicted_arrival_lt_hash.each do |k,v|
      if @pod_predicted_arrival_hash[v].nil?
       @pod_predicted_arrival_hash[v] = k
      end
    end

    @pod_predicted_departure_lt_hash.each do |k,v|
      if @pod_predicted_departure_hash[v].nil?
       @pod_predicted_departure_hash[v] = k
      end
    end

    @pod_predicted_discharge_lt_hash.each do |k,v|
      if @pod_predicted_discharge_hash[v].nil?
       @pod_predicted_discharge_hash[v] = k
      end
    end
    
  end

end
