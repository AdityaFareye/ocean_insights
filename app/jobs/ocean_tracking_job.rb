class OceanTrackingJob

  def self.fetch_data_from_ocean_insight
    shipment_ids = ContainerList.all.map(&:shipment_id)
    shipment_ids.each do |shipment_id|
      result = HTTParty.get("https://capi.ocean-insights.com/containertracking/v2/subscriptions/#{shipment_id}/", 
      :headers => { 'Authorization' => 'Token ee0c7552b680e73d31aaba1fc8f2130a1655fb96'})
  
      result = result.parsed_response
      containershipments = result['containershipments'][0]
      container_number = containershipments['container_number']
      descriptive_name = containershipments['descriptive_name']
      carrier_name = containershipments['carrier_name']
      carrier_scac = containershipments['carrier_scac']
      container_type_iso = containershipments['container_type_iso']
      container_type_str = containershipments['container_type_str']
      weight = containershipments['weight']
      status_verbose = containershipments['status_verbose']
      status_code = containershipments['status']

      con = Container.find_by(number: container_number, source: 'ocean-insights')
      if con
        con.update(number: container_number, container_type: container_type_str, weight: weight, iso: container_type_iso, name: descriptive_name, status: status_verbose, status_code: status_code, carrier_name: carrier_name, carrier_scac: carrier_scac )
        con.container_datas.create(data: result)
        con.touch
      else
        con = Container.create(number: container_number, container_type: container_type_str, weight: weight, iso: container_type_iso, name: descriptive_name, status: status_verbose, status_code: status_code, carrier_name: carrier_name, carrier_scac: carrier_scac, source: 'ocean-insights' )
        con.container_datas.create(data: result)
      end
      
      if containershipments['leg1_vessel']
        vessel = con.vessels.find_by(number: containershipments['leg1_vessel']['id'].to_s) || con.vessels.find_by(name: containershipments['leg1_vessel']['name'])
        if vessel
          vessel.update(number: containershipments['leg1_vessel']['id'], name: containershipments['leg1_vessel']['name'], imo: containershipments['leg1_vessel']['imo'])
          vessel.vessel_logs.create(log: containershipments['current_vessel_position'], next_port: containershipments['current_vessel_nextport'])
        else
          vessel = con.vessels.create(number: containershipments['leg1_vessel']['id'], name: containershipments['leg1_vessel']['name'], imo: containershipments['leg1_vessel']['imo'])
          vessel.vessel_logs.create(log: containershipments['current_vessel_position'], next_port: containershipments['current_vessel_nextport'])
        end
      end
      
      if containershipments['leg2_vessel']
        vessel = con.vessels.find_by(number: containershipments['leg2_vessel']['id'].to_s) || con.vessels.find_by(name: containershipments['leg2_vessel']['name'])
        if vessel
          vessel.update(number: containershipments['leg2_vessel']['id'], name: containershipments['leg2_vessel']['name'], imo: containershipments['leg2_vessel']['imo'])
        else
          vessel = con.vessels.create(number: containershipments['leg2_vessel']['id'], name: containershipments['leg2_vessel']['name'], imo: containershipments['leg2_vessel']['imo'])
        end
      end

      if containershipments['leg3_vessel']
        vessel = con.vessels.find_by(number: containershipments['leg3_vessel']['id'].to_s) || con.vessels.find_by(name: containershipments['leg3_vessel']['name'])
        if vessel
          vessel.update(number: containershipments['leg3_vessel']['id'], name: containershipments['leg3_vessel']['name'], imo: containershipments['leg3_vessel']['imo'])
        else
          vessel = con.vessels.create(number: containershipments['leg3_vessel']['id'], name: containershipments['leg3_vessel']['name'], imo: containershipments['leg3_vessel']['imo'])
        end
      end

      if containershipments['leg4_vessel']
        vessel = con.vessels.find_by(number: containershipments['leg4_vessel']['id'].to_s) || con.vessels.find_by(name: containershipments['leg4_vessel']['name'])
        if vessel
          vessel.update(number: containershipments['leg4_vessel']['id'], name: containershipments['leg4_vessel']['name'], imo: containershipments['leg4_vessel']['imo'])
        else
          vessel = con.vessels.create(number: containershipments['leg4_vessel']['id'], name: containershipments['leg4_vessel']['name'], imo: containershipments['leg4_vessel']['imo'])
        end
      end

      if containershipments['leg5_vessel']
        vessel = con.vessels.find_by(number: containershipments['leg5_vessel']['id'].to_s) || con.vessels.find_by(name: containershipments['leg5_vessel']['name'])
        if vessel
          vessel.update(number: containershipments['leg5_vessel']['id'], name: containershipments['leg5_vessel']['name'], imo: containershipments['leg5_vessel']['imo'])
        else
          vessel = con.vessels.create(number: containershipments['leg5_vessel']['id'], name: containershipments['leg5_vessel']['name'], imo: containershipments['leg5_vessel']['imo'])
        end
      end

      current_vessel_position = containershipments['current_vessel_position']
      
      #vessel.locations.create(lat: current_vessel_position['latitude'], long: current_vessel_position['longitude'], timestamp: current_vessel_position['timestamp'])
      
      ############ origin_loc ############
      origin_loc = containershipments['origin_loc']
      if origin_loc
        loc = con.locations.find_by(location_type_name: 'origin_loc')
        unless loc
          loc = con.locations.create!(name: origin_loc['name'], lat: origin_loc['latitude'], long: origin_loc['longitude'], location_type_name: 'origin_loc', timezone: origin_loc['timezone'], code: origin_loc['locode'])
        end
        timeline = loc.location_timelines
        if timeline.empty?
          loc.location_timelines.create(initial_time: containershipments['origin_pickup_planned_initial'], last_time: containershipments['origin_pickup_planned_last'], actual_time: containershipments['origin_pickup_actual'])
        else
          timeline.update(initial_time: containershipments['origin_pickup_planned_initial'], last_time: containershipments['origin_pickup_planned_last'], actual_time: containershipments['origin_pickup_actual'])
        end
        
      end
      ####################################

      ############ dlv_loc ###############
      dlv_loc = containershipments['dlv_loc']
      if dlv_loc
        loc = con.locations.find_by(location_type_name: 'dlv_loc')
        unless loc
          loc = con.locations.create(name: dlv_loc['name'], lat: dlv_loc['latitude'], long: dlv_loc['longitude'], location_type_name: 'dlv_loc', timezone: dlv_loc['timezone'], code: dlv_loc['locode'])
        end
        timeline = loc.location_timelines
        if timeline.empty?
          loc.location_timelines.create(initial_time: containershipments['dlv_delivery_planned_initial'], last_time: containershipments['dlv_delivery_planned_last'], actual_time: containershipments['dlv_delivery_actual'])
        else
          timeline.update(initial_time: containershipments['dlv_delivery_planned_initial'], last_time: containershipments['dlv_delivery_planned_last'], actual_time: containershipments['dlv_delivery_actual'])
        end
      end
      ####################################

      ############ pod_loc ###############
      
      pod_loc = containershipments['pod_loc']
      if pod_loc
        loc = con.locations.find_by(location_type_name: 'pod_loc')
        unless loc
          loc = con.locations.create(name: pod_loc['name'], lat: pod_loc['latitude'], long: pod_loc['longitude'], location_type_name: 'pod_loc', timezone: pod_loc['timezone'], code: pod_loc['locode'])
        end
        timelines = loc.location_timelines
        if timelines.empty?
          loc.location_timelines.create(initial_time: containershipments['pod_vslarrival_planned_initial'], last_time: containershipments['pod_vslarrival_planned_last'], actual_time: containershipments['pod_vslarrival_actual'], detected_time: containershipments['pod_vslarrival_detected'], timeline_type: 'pod_vslarrival')
          loc.location_timelines.create(initial_time: containershipments['pod_discharge_planned_initial'], last_time: containershipments['pod_discharge_planned_last'], actual_time: containershipments['pod_discharge_actual'], timeline_type: 'pod_discharge')
          loc.location_timelines.create(initial_time: containershipments['pod_departure_planned_initial'], last_time: containershipments['pod_departure_planned_last'], actual_time: containershipments['pod_departure_actual'], timeline_type: 'pod_departure')
        else
          timelines.each do |timeline|
            timeline.update(initial_time: containershipments["#{timeline.timeline_type}_planned_initial"], last_time: containershipments["#{timeline.timeline_type}_planned_last"], actual_time: containershipments["#{timeline.timeline_type}_actual"], detected_time: containershipments["#{timeline.timeline_type}_detected"])
          end
        end
      end
      ####################################

      ############ pol_loc ###############
      pol_loc = containershipments['pol_loc']
      if pol_loc
        loc = con.locations.find_by(location_type_name: 'pol_loc')
        unless loc
          loc = con.locations.create(name: pol_loc['name'], lat: pol_loc['latitude'], long: pol_loc['longitude'], location_type_name: 'pol_loc', timezone: pol_loc['timezone'], code: pol_loc['locode'])
        end
        timelines = loc.location_timelines
        if timelines.empty?
          loc.location_timelines.create(initial_time: containershipments['pol_arrival_planned_initial'], last_time: containershipments['pol_arrival_planned_last'], actual_time: containershipments['pol_arrival_actual'],  timeline_type: 'pol_arrival')
            loc.location_timelines.create(initial_time: containershipments['pol_loaded_planned_initial'], last_time: containershipments['pol_loaded_planned_last'], actual_time: containershipments['pol_loaded_actual'], timeline_type: 'pol_loaded')
            loc.location_timelines.create(initial_time: containershipments['pol_vsldeparture_planned_initial'], last_time: containershipments['pol_vsldeparture_planned_last'], actual_time: containershipments['pol_vsldeparture_actual'], detected_time: containershipments['pol_vsldeparture_detected'],timeline_type: 'pol_vsldeparture')
        else
          timelines.each do |timeline|
            timeline.update(initial_time: containershipments["#{timeline.timeline_type}_planned_initial"], last_time: containershipments["#{timeline.timeline_type}_planned_last"], actual_time: containershipments["#{timeline.timeline_type}_actual"], detected_time: containershipments["#{timeline.timeline_type}_detected"])
          end
        end
      end
      ####################################

      ############ empty_pickup_loc ###############
      empty_pickup_loc = containershipments['empty_pickup_loc']
      if empty_pickup_loc
        loc = con.locations.find_by(location_type_name: 'empty_pickup_loc')
        unless loc
          loc = con.locations.create(name: empty_pickup_loc['name'], lat: empty_pickup_loc['latitude'], long: empty_pickup_loc['longitude'], location_type_name: 'empty_pickup_loc', timezone: empty_pickup_loc['timezone'], code: empty_pickup_loc['locode'])
        end
        timeline = loc.location_timelines
        if timeline.empty?
          loc.location_timelines.create(initial_time: containershipments['empty_pickup_planned_initial'], last_time: containershipments['empty_pickup_planned_last'], actual_time: containershipments['empty_pickup_actual'])
        else
          timeline.update(initial_time: containershipments['empty_pickup_planned_initial'], last_time: containershipments['empty_pickup_planned_last'], actual_time: containershipments['empty_pickup_actual'])
        end
      end
      ####################################

      ############ tsp1_loc ###############
      tsp1_loc = containershipments['tsp1_loc']
      if tsp1_loc
        loc = con.locations.find_by(location_type_name: 'tsp1_loc')
        unless loc
          loc = con.locations.create(name: tsp1_loc['name'], lat: tsp1_loc['latitude'], long: tsp1_loc['longitude'], location_type_name: 'tsp1_loc', timezone: tsp1_loc['timezone'], code: tsp1_loc['locode'])
        end

        timelines = loc.location_timelines
        if timelines.empty?
          loc.location_timelines.create(initial_time: containershipments['tsp1_vslarrival_planned_initial'], last_time: containershipments['tsp1_vslarrival_planned_last'], actual_time: containershipments['tsp1_vslarrival_actual'], detected_time: containershipments['tsp1_vslarrival_detected'], expected_time: containershipments['tsp1_vslarrival_prediction'], timeline_type: 'tsp1_vslarrival')
          loc.location_timelines.create(initial_time: containershipments['tsp1_discharge_planned_initial'], last_time: containershipments['tsp1_discharge_planned_last'], actual_time: containershipments['tsp1_discharge_actual'], timeline_type: 'tsp1_discharge')
          loc.location_timelines.create(initial_time: containershipments['tsp1_loaded_planned_initial'], last_time: containershipments['tsp1_loaded_planned_last'], actual_time: containershipments['tsp1_loaded_actual'], timeline_type: 'tsp1_loaded')
          loc.location_timelines.create(initial_time: containershipments['tsp1_vsldeparture_planned_initial'], last_time: containershipments['tsp1_vsldeparture_planned_last'], actual_time: containershipments['tsp1_vsldeparture_actual'], detected_time: containershipments['tsp1_vsldeparture_detected'], timeline_type: 'tsp1_vsldeparture')
        else
          timelines.each do |timeline|
            timeline.update(initial_time: containershipments["#{timeline.timeline_type}_planned_initial"], last_time: containershipments["#{timeline.timeline_type}_planned_last"], actual_time: containershipments["#{timeline.timeline_type}_actual"], detected_time: containershipments["#{timeline.timeline_type}_detected"])
          end
        end
      end
      ####################################
      # byebug
      ############ tsp2_loc ###############
      tsp2_loc = containershipments['tsp2_loc']
      if tsp2_loc
        loc = con.locations.find_by(location_type_name: 'tsp2_loc')
        unless loc
          loc = con.locations.create(name: tsp2_loc['name'], lat: tsp2_loc['latitude'], long: tsp2_loc['longitude'], location_type_name: 'tsp2_loc', timezone: tsp2_loc['timezone'], code: tsp2_loc['locode'])
        end

        timelines = loc.location_timelines
        if timelines.empty?
          loc.location_timelines.create(initial_time: containershipments['tsp2_vslarrival_planned_initial'], last_time: containershipments['tsp2_vslarrival_planned_last'], actual_time: containershipments['tsp2_vslarrival_actual'], detected_time: containershipments['tsp2_vslarrival_detected'], expected_time: containershipments['tsp2_vslarrival_prediction'], timeline_type: 'tsp2_vslarrival')
          loc.location_timelines.create(initial_time: containershipments['tsp2_discharge_planned_initial'], last_time: containershipments['tsp2_discharge_planned_last'], actual_time: containershipments['tsp2_discharge_actual'], timeline_type: 'tsp2_discharge')
          loc.location_timelines.create(initial_time: containershipments['tsp2_loaded_planned_initial'], last_time: containershipments['tsp2_loaded_planned_last'], actual_time: containershipments['tsp2_loaded_actual'], timeline_type: 'tsp2_loaded')
          loc.location_timelines.create(initial_time: containershipments['tsp2_vsldeparture_planned_initial'], last_time: containershipments['tsp2_vsldeparture_planned_last'], actual_time: containershipments['tsp2_vsldeparture_actual'], detected_time: containershipments['tsp2_vsldeparture_detected'], timeline_type: 'tsp2_vsldeparture')
        else
          timelines.each do |timeline|
            timeline.update(initial_time: containershipments["#{timeline.timeline_type}_planned_initial"], last_time: containershipments["#{timeline.timeline_type}_planned_last"], actual_time: containershipments["#{timeline.timeline_type}_actual"], detected_time: containershipments["#{timeline.timeline_type}_detected"])
          end
        end
      end
      ####################################

      ############ tsp3_loc ###############
      tsp3_loc = containershipments['tsp3_loc']
      if tsp3_loc
        loc = con.locations.find_by(location_type_name: 'tsp3_loc')
        unless loc
          loc = con.locations.create(name: tsp3_loc['name'], lat: tsp3_loc['latitude'], long: tsp3_loc['longitude'], location_type_name: 'tsp3_loc', timezone: tsp3_loc['timezone'], code: tsp3_loc['locode'])
        end

        timelines = loc.location_timelines
        if timelines.empty?
          loc.location_timelines.create(initial_time: containershipments['tsp3_vslarrival_planned_initial'], last_time: containershipments['tsp3_vslarrival_planned_last'], actual_time: containershipments['tsp3_vslarrival_actual'], detected_time: containershipments['tsp3_vslarrival_detected'], expected_time: containershipments['tsp3_vslarrival_prediction'], timeline_type: 'tsp3_vslarrival')
          loc.location_timelines.create(initial_time: containershipments['tsp3_discharge_planned_initial'], last_time: containershipments['tsp3_discharge_planned_last'], actual_time: containershipments['tsp3_discharge_actual'], timeline_type: 'tsp3_discharge')
          loc.location_timelines.create(initial_time: containershipments['tsp3_loaded_planned_initial'], last_time: containershipments['tsp3_loaded_planned_last'], actual_time: containershipments['tsp3_loaded_actual'], timeline_type: 'tsp3_loaded')
          loc.location_timelines.create(initial_time: containershipments['tsp3_vsldeparture_planned_initial'], last_time: containershipments['tsp3_vsldeparture_planned_last'], actual_time: containershipments['tsp3_vsldeparture_actual'], detected_time: containershipments['tsp3_vsldeparture_detected'], timeline_type: 'tsp3_vsldeparture')
        else
          timelines.each do |timeline|
            timeline.update(initial_time: containershipments["#{timeline.timeline_type}_planned_initial"], last_time: containershipments["#{timeline.timeline_type}_planned_last"], actual_time: containershipments["#{timeline.timeline_type}_actual"], detected_time: containershipments["#{timeline.timeline_type}_detected"])
          end
        end
      end
      ####################################

      ############ tsp4_loc ###############
      tsp4_loc = containershipments['tsp4_loc']
      if tsp4_loc
        loc = con.locations.find_by(location_type_name: 'tsp4_loc')
        unless loc
          loc = con.locations.create(name: tsp4_loc['name'], lat: tsp4_loc['latitude'], long: tsp4_loc['longitude'], location_type_name: 'tsp4_loc', timezone: tsp4_loc['timezone'], code: tsp4_loc['locode'])
        end

        timelines = loc.location_timelines
        if timelines.empty?
          loc.location_timelines.create(initial_time: containershipments['tsp4_vslarrival_planned_initial'], last_time: containershipments['tsp4_vslarrival_planned_last'], actual_time: containershipments['tsp4_vslarrival_actual'], detected_time: containershipments['tsp4_vslarrival_detected'], expected_time: containershipments['tsp4_vslarrival_prediction'], timeline_type: 'tsp4_vslarrival')
          loc.location_timelines.create(initial_time: containershipments['tsp4_discharge_planned_initial'], last_time: containershipments['tsp4_discharge_planned_last'], actual_time: containershipments['tsp4_discharge_actual'], timeline_type: 'tsp4_discharge')
          loc.location_timelines.create(initial_time: containershipments['tsp4_loaded_planned_initial'], last_time: containershipments['tsp4_loaded_planned_last'], actual_time: containershipments['tsp4_loaded_actual'], timeline_type: 'tsp4_loaded')
          loc.location_timelines.create(initial_time: containershipments['tsp4_vsldeparture_planned_initial'], last_time: containershipments['tsp4_vsldeparture_planned_last'], actual_time: containershipments['tsp4_vsldeparture_actual'], detected_time: containershipments['tsp4_vsldeparture_detected'], timeline_type: 'tsp4_vsldeparture')
        else
          timelines.each do |timeline|
            timeline.update(initial_time: containershipments["#{timeline.timeline_type}_planned_initial"], last_time: containershipments["#{timeline.timeline_type}_planned_last"], actual_time: containershipments["#{timeline.timeline_type}_actual"], detected_time: containershipments["#{timeline.timeline_type}_detected"])
          end
        end
      end
      ####################################

      ############ tsp5_loc ###############
      tsp5_loc = containershipments['tsp5_loc']
      if tsp5_loc
        loc = con.locations.find_by(location_type_name: 'tsp5_loc')
        unless loc
          loc = con.locations.create(name: tsp5_loc['name'], lat: tsp5_loc['latitude'], long: tsp5_loc['longitude'], location_type_name: 'tsp5_loc', timezone: tsp5_loc['timezone'], code: tsp5_loc['locode'])
        end

        timelines = loc.location_timelines
        if timelines.empty?
          loc.location_timelines.create(initial_time: containershipments['tsp5_vslarrival_planned_initial'], last_time: containershipments['tsp5_vslarrival_planned_last'], actual_time: containershipments['tsp5_vslarrival_actual'], detected_time: containershipments['tsp5_vslarrival_detected'], expected_time: containershipments['tsp5_vslarrival_prediction'], timeline_type: 'tsp5_vslarrival')
          loc.location_timelines.create(initial_time: containershipments['tsp5_discharge_planned_initial'], last_time: containershipments['tsp5_discharge_planned_last'], actual_time: containershipments['tsp5_discharge_actual'], timeline_type: 'tsp5_discharge')
          loc.location_timelines.create(initial_time: containershipments['tsp5_loaded_planned_initial'], last_time: containershipments['tsp5_loaded_planned_last'], actual_time: containershipments['tsp5_loaded_actual'], timeline_type: 'tsp5_loaded')
          loc.location_timelines.create(initial_time: containershipments['tsp5_vsldeparture_planned_initial'], last_time: containershipments['tsp5_vsldeparture_planned_last'], actual_time: containershipments['tsp5_vsldeparture_actual'], detected_time: containershipments['tsp5_vsldeparture_detected'], timeline_type: 'tsp5_vsldeparture')
        else
          timelines.each do |timeline|
            timeline.update(initial_time: containershipments["#{timeline.timeline_type}_planned_initial"], last_time: containershipments["#{timeline.timeline_type}_planned_last"], actual_time: containershipments["#{timeline.timeline_type}_actual"], detected_time: containershipments["#{timeline.timeline_type}_detected"])
          end
        end
      end
      ####################################

      ############ empty_return_loc ###############
      empty_return_loc = containershipments['empty_return_loc']
      if empty_return_loc
        loc = con.locations.find_by(location_type_name: 'empty_return_loc')
        unless loc
          loc = con.locations.create(name: empty_return_loc['name'], lat: empty_return_loc['latitude'], long: empty_return_loc['longitude'], location_type_name: 'empty_return_loc', timezone: empty_return_loc['timezone'], code: empty_return_loc['locode'])
        end

        timeline = loc.location_timelines
        if timeline.empty?
          loc = loc.location_timelines.create(initial_time: containershipments['empty_return_planned_initial'], last_time: containershipments['empty_return_planned_last'], actual_time: containershipments['empty_return_actual'])
        else
          timeline.update(initial_time: containershipments['empty_return_planned_initial'], last_time: containershipments['empty_return_planned_last'], actual_time: containershipments['empty_return_actual'])
        end
      end
      ####################################
      
      ############ empty_pickup_loc ###############
      empty_pickup_loc = containershipments['empty_pickup_loc']
      if empty_pickup_loc
        loc = con.locations.find_by(location_type_name: 'empty_pickup_loc')
        unless loc
          loc = con.locations.create(name: empty_pickup_loc['name'], lat: empty_pickup_loc['latitude'], long: empty_pickup_loc['longitude'], location_type_name: 'empty_pickup_loc', timezone: empty_pickup_loc['timezone'], code: empty_pickup_loc['locode'])
        end
        
        timeline = loc.location_timelines
        if timeline.empty?
          loc = loc.location_timelines.create(initial_time: containershipments['empty_pickup_planned_initial'], last_time: containershipments['empty_pickup_planned_last'], actual_time: containershipments['empty_pickup_actual'])
        else
          timeline.update(initial_time: containershipments['empty_pickup_planned_initial'], last_time: containershipments['empty_pickup_planned_last'], actual_time: containershipments['empty_pickup_actual'])
        end
      end
      ####################################
    end
  end

  def self.generate_shipment_ids
    containers = ContainerList.all
    containers.each do |container|
      begin
        result = HTTParty.post('https://capi.ocean-insights.com/containertracking/v2/subscriptions/', 
      :body => {
          "request_carrier_code": container.code,
          "request_type": "c_id",
          "request_key": container.key
        }.to_json,
      :headers => {'Content-Type' => 'application/json', 'Authorization' => 'Token ee0c7552b680e73d31aaba1fc8f2130a1655fb96'} )
        
        result = result.parsed_response
        if result 
          url = result["url"]
          if url
            id = url.split('/').last
            container.shipment_id = id
            container.save!
          end
        end
      rescue Exception => e
        puts "Do nothing "
      end
    end
  end

  def self.fetch_data_from_portcast
    bill_of_lading_bookmark_ids = ContainerList.all.map(&:bill_of_lading_bookmark_id)
    bill_of_lading_bookmark_ids.each do |id|
      result = HTTParty.get("https://api.portcast.io/api/v1/eta/tracking/bill-of-lading-bookmarks/#{id}",
        :headers => {'Content-Type':'application/json', 'Accept':'application/json', 'x-api-key':'PC87B33F7CC106BFFCD9F7BF7434DBFDD2'})
      
      result = result.parsed_response
      if result
        obj = result['obj']
        if obj
          bill_of_lading = obj['bill_of_lading']
          container_meta_info = obj['container_meta_info']
          
          con = Container.find_by(number: bill_of_lading['cntr_no'], source: 'portcast')
          if con
            con.update(number: bill_of_lading['cntr_no'], bill_number: bill_of_lading['bl_no'], container_type: container_meta_info['cntr_type'], size: container_meta_info['cntr_size'] ,weight: bill_of_lading['kgs'], carrier_scac: bill_of_lading['carrier_no'] )
            con.container_datas.create(data: obj)
            con.touch
          else
            con = Container.create(status: obj['bill_of_lading_bookmark']['status'], status_code: obj['bill_of_lading_bookmark']['status_code'],number: bill_of_lading['cntr_no'], bill_number: bill_of_lading['bl_no'], container_type: container_meta_info['cntr_type'], size: container_meta_info['cntr_size'] ,weight: bill_of_lading['kgs'], carrier_scac: bill_of_lading['carrier_no'], source: 'portcast' )
            con.container_datas.create(data: obj)
          end
          
          sailing_info_tracking = obj['sailing_info_tracking']
          if sailing_info_tracking
            sailing_info_tracking.each do |s|
              
              sailing_info = s['sailing_info']
              vessel = con.vessels.find_by(imo: sailing_info['imo'].to_s)
              if vessel
                vessel.update(imo: sailing_info['imo'], ais: s['ais'], name: sailing_info['vessel_name'], status_code: sailing_info['status_code'], status: sailing_info['status'], target_port_code: s['target_port_code'], target_port_name: s['target_port_name'])
                vessel.vessel_logs.create(log: s['ais'])
              else
                vessel = con.vessels.create(imo: sailing_info['imo'], ais: s['ais'], name: sailing_info['vessel_name'], status_code: sailing_info['status_code'], status: s['status'], target_port_code: s['target_port_code'], target_port_name: s['target_port_name'])
                vessel.vessel_logs.create(log: s['ais'])
              end

              loc = vessel.locations.find_by(location_type_name: 'pod')
              if loc
                loc.location_timelines.find_by(timeline_type: 'pod_arrival_lt').update(actual_time: sailing_info['pod_actual_arrival_lt'], detected_time: sailing_info['pod_predicted_arrival_lt'], expected_time: sailing_info['pod_scheduled_arrival_lt'])
                loc.location_timelines.find_by(timeline_type: 'pod_departure_lt').update(actual_time: sailing_info['pod_actual_departure_lt'], detected_time: sailing_info['pod_predicted_departure_lt'], expected_time: sailing_info['pod_scheduled_departure_lt'])
                loc.location_timelines.find_by(timeline_type: 'pod_discharge_lt').update(actual_time: sailing_info['pod_actual_discharge_lt'], detected_time: sailing_info['pod_predicted_discharge_lt'], expected_time: sailing_info['pod_scheduled_discharge_lt'])
              else
                loc = vessel.locations.create(location_type_name: 'pod')
                loc.location_timelines.create(timeline_type: 'pod_arrival_lt', actual_time: sailing_info['pod_actual_arrival_lt'], detected_time: sailing_info['pod_predicted_arrival_lt'], expected_time: sailing_info['pod_scheduled_arrival_lt'])
                loc.location_timelines.create(timeline_type: 'pod_departure_lt', actual_time: sailing_info['pod_actual_departure_lt'], detected_time: sailing_info['pod_predicted_departure_lt'], expected_time: sailing_info['pod_scheduled_departure_lt'])
                loc.location_timelines.create(timeline_type: 'pod_discharge_lt', actual_time: sailing_info['pod_actual_discharge_lt'], detected_time: sailing_info['pod_predicted_discharge_lt'], expected_time: sailing_info['pod_scheduled_discharge_lt'])
              end

              loc = vessel.locations.find_by(location_type_name: 'pol')
              if loc
                loc.location_timelines.find_by(timeline_type: 'pol_arrival_lt').update(actual_time: sailing_info['pol_actual_arrival_lt'], detected_time: sailing_info['pol_predicted_arrival_lt'], expected_time: sailing_info['pol_scheduled_arrival_lt'])
                loc.location_timelines.find_by(timeline_type: 'pol_departure_lt').update(actual_time: sailing_info['pol_actual_departure_lt'], detected_time: sailing_info['pol_predicted_departure_lt'], expected_time: sailing_info['pol_scheduled_departure_lt'])
                loc.location_timelines.find_by(timeline_type: 'pol_discharge_lt').update(actual_time: sailing_info['pol_actual_discharge_lt'], detected_time: sailing_info['pol_predicted_discharge_lt'], expected_time: sailing_info['pol_scheduled_discharge_lt'])
              else
                loc = vessel.locations.create(location_type_name: 'pol')
                loc.location_timelines.create(timeline_type: 'pol_arrival_lt', actual_time: sailing_info['pol_actual_arrival_lt'], detected_time: sailing_info['pol_predicted_arrival_lt'], expected_time: sailing_info['pol_scheduled_arrival_lt'])
                loc.location_timelines.create(timeline_type: 'pol_departure_lt', actual_time: sailing_info['pol_actual_departure_lt'], detected_time: sailing_info['pol_predicted_departure_lt'], expected_time: sailing_info['pol_scheduled_departure_lt'])
                loc.location_timelines.create(timeline_type: 'pol_discharge_lt', actual_time: sailing_info['pol_actual_discharge_lt'], detected_time: sailing_info['pol_predicted_discharge_lt'], expected_time: sailing_info['pol_scheduled_discharge_lt'])
              end
              voyage_details = s['voyage_details']
              if voyage_details
                voyage_details.each do |v|
                  loc = vessel.locations.find_by(port_code: v['port_code'])
                  if loc
                    loc.location_timelines.find_by(timeline_type: 'arrival').update( actual_time: v['actual_arrival_lt'], detected_time: v['predicted_arrival_lt'], expected_time: v['scheduled_arrival_lt'])
                    loc.location_timelines.find_by(timeline_type: 'departure').update( actual_time: v['actual_departure_lt'], detected_time: v['predicted_departure_lt'], expected_time: v['scheduled_departure_lt'])
                  else
                    loc = vessel.locations.create(port_code: v['port_code'], port_name: v['port_name'])
                    loc.location_timelines.create(timeline_type: 'arrival', actual_time: v['actual_arrival_lt'], detected_time: v['predicted_arrival_lt'], expected_time: v['scheduled_arrival_lt'])
                    loc.location_timelines.create(timeline_type: 'departure', actual_time: v['actual_departure_lt'], detected_time: v['predicted_departure_lt'], expected_time: v['scheduled_departure_lt'])

                  end
                end
              end
            end
          end

          loc = con.locations.find_by(location_type_name: 'pod')
          unless loc
            loc = con.locations.create(location_type_name: 'pod', name: bill_of_lading['pod_name'], code: bill_of_lading['pod'])
            loc.location_timelines.create(timeline_type: 'pod_arrival_lt', actual_time: bill_of_lading['pod_actual_arrival_lt'], detected_time: bill_of_lading['pod_predicted_arrival_lt'], expected_time: bill_of_lading['pod_scheduled_arrival_lt'])
            loc.location_timelines.create(timeline_type: 'pod_departure_lt', actual_time: bill_of_lading['pod_actual_departure_lt'], detected_time: bill_of_lading['pod_predicted_departure_lt'], expected_time: bill_of_lading['pod_scheduled_departure_lt'])
            loc.location_timelines.create(timeline_type: 'pod_discharge_lt', actual_time: bill_of_lading['pod_actual_discharge_lt'], detected_time: bill_of_lading['pod_predicted_discharge_lt'], expected_time: bill_of_lading['pod_scheduled_discharge_lt'])
          else
            loc.location_timelines.find_by(timeline_type: 'pod_arrival_lt').update( actual_time: bill_of_lading['pod_actual_arrival_lt'], detected_time: bill_of_lading['pod_predicted_arrival_lt'], expected_time: bill_of_lading['pod_scheduled_arrival_lt'])
            loc.location_timelines.find_by(timeline_type: 'pod_departure_lt').update( actual_time: bill_of_lading['pod_actual_departure_lt'], detected_time: bill_of_lading['pod_predicted_departure_lt'], expected_time: bill_of_lading['pod_scheduled_departure_lt'])
            loc.location_timelines.find_by(timeline_type: 'pod_discharge_lt').update( actual_time: bill_of_lading['pod_actual_discharge_lt'], detected_time: bill_of_lading['pod_predicted_discharge_lt'], expected_time: bill_of_lading['pod_scheduled_discharge_lt'])
          end
          
          loc = con.locations.find_by(location_type_name: 'pol')
          unless loc
            loc = con.locations.create(location_type_name: 'pol', name: bill_of_lading['pol_name'], code: bill_of_lading['pol'])
            loc.location_timelines.create(timeline_type: 'pol_arrival_lt', actual_time: bill_of_lading['pol_actual_arrival_lt'], detected_time: bill_of_lading['pol_predicted_arrival_lt'], expected_time: bill_of_lading['pol_scheduled_arrival_lt'])
            loc.location_timelines.create(timeline_type: 'pol_departure_lt', actual_time: bill_of_lading['pol_actual_departure_lt'], detected_time: bill_of_lading['pol_predicted_departure_lt'], expected_time: bill_of_lading['pol_scheduled_departure_lt'])
            loc.location_timelines.create(timeline_type: 'pol_discharge_lt', actual_time: bill_of_lading['pol_actual_discharge_lt'], detected_time: bill_of_lading['pol_predicted_discharge_lt'], expected_time: bill_of_lading['pol_scheduled_discharge_lt'])
          else
            loc.location_timelines.find_by(timeline_type: 'pol_arrival_lt').update(actual_time: bill_of_lading['pol_actual_arrival_lt'], detected_time: bill_of_lading['pol_predicted_arrival_lt'], expected_time: bill_of_lading['pol_scheduled_arrival_lt'])
            loc.location_timelines.find_by(timeline_type: 'pol_departure_lt').update(actual_time: bill_of_lading['pol_actual_departure_lt'], detected_time: bill_of_lading['pol_predicted_departure_lt'], expected_time: bill_of_lading['pol_scheduled_departure_lt'])
            loc.location_timelines.find_by(timeline_type: 'pol_discharge_lt').update( actual_time: bill_of_lading['pol_actual_discharge_lt'], detected_time: bill_of_lading['pol_predicted_discharge_lt'], expected_time: bill_of_lading['pol_scheduled_discharge_lt'])
          end

          loc = con.locations.find_by(location_type_name: 'place of delivery')
          unless loc
            loc = con.locations.create(location_type_name: 'place of delivery', name: bill_of_lading['place_of_delivery_name'], raw: bill_of_lading['place_of_delivery'])
            loc.location_timelines.create(timeline_type: 'delivery_time', expected_time: bill_of_lading['scheduled_delivery_time'], actual_time: bill_of_lading['actual_delivery_time'])
          else
            loc.location_timelines.find_by(timeline_type: 'delivery_time').update(expected_time: bill_of_lading['scheduled_delivery_time'], actual_time: bill_of_lading['actual_delivery_time'])
          end

          loc = con.locations.find_by(location_type_name: 'place of receipt')
          unless loc
            loc = con.locations.create(location_type_name: 'place of receipt', name: bill_of_lading['place_of_receipt_name'], raw: bill_of_lading['place_of_receipt'])
            loc.location_timelines.create(timeline_type: 'receipt_time', expected_time: bill_of_lading['scheduled_receipt_time'], actual_time: bill_of_lading['actual_receipt_time'])
          else
            loc.location_timelines.find_by(timeline_type: 'receipt_time').update(expected_time: bill_of_lading['scheduled_receipt_time'], actual_time: bill_of_lading['actual_receipt_time'])
          end

          container_event_list = obj['container_event_list']
          if container_event_list
            container_event_list.each do |event|
              loc = con.locations.find_by(location_type_name: event['location_type_code'].try(:downcase))
              if loc
                loc.update(event_raw: event['event_raw'], event_time: event['event_time'], event_type_code: event['event_type_code'], event_type_name: event['event_type_name'], port_code: event['port_code'], port_name: event['port_name'], raw: event['location_raw'])
              else
                con.locations.create(location_type_name: event['location_type_code'].downcase, event_raw: event['event_raw'], event_time: event['event_time'], event_type_code: event['event_type_code'], event_type_name: event['event_type_name'], port_code: event['port_code'], port_name: event['port_name'], raw: event['location_raw'])
              end
            end
          end
        end
      end
    end

  end
  def self.generate_bill_of_lading_bookmark_ids
    containers = ContainerList.all
    containers.each do |container|
      result = HTTParty.post('https://api.portcast.io/api/v1/eta/bill-of-lading-bookmarks',
        :body => {
          "bl_no": container.bill_of_lading,
          "cntr_no": container.key
        }.to_json,
        :headers => {'Content-Type':'application/json', 'Accept':'application/json', 'x-api-key':'PC87B33F7CC106BFFCD9F7BF7434DBFDD2'})
        result = result.parsed_response
      if result 
        obj = result["obj"]
        if obj
          id = obj['id']
          container.bill_of_lading_bookmark_id = id
          container.save!
        end
      end
    end
  end

  def self.get_subscription_ids
    result = HTTParty.get('https://capi.ocean-insights.com/containertracking/v2/subscriptions/', 
      :headers => {'Content-Type' => 'application/json', 'Authorization' => 'Token ee0c7552b680e73d31aaba1fc8f2130a1655fb96'} )
       
      result = result.parsed_response
      if result
        result.each do |res|
          containershipments = res['containershipments']
          if containershipments
            containershipment = containershipments.first
            url = containershipment['shipmentsubscription']
            container_number = containershipment['container_number']
            con = ContainerList.find_by(key: container_number)
            con.shipment_id = url.split('/').last
            con.save!
          end
        end
      end
  end


end

# @result = HTTParty.post('https://api.portcast.io/api/v1/eta/bill-of-lading-bookmarks', 
#     :body => { :bl_no => 'YMLUN851098484', 
#                :cntr_no => 'TGHU5312550'
#              }.to_json,
#     :headers => { 'Content-Type' => 'application/json', 'Accept': 'application/json', 'x-api-key': 'PC87B33F7CC106BFFCD9F7BF7434DBFDD2' } )