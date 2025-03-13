mirror := https://ftpmirror.your.org/pub/openstreetmap
osm_date := 250217
atp_date := 2025-02-22-13-32-08

all: cluster_pois

planet.osm.pbf:
	curl -o planet.osm.pbf ${mirror}/pbf/planet-${osm_date}.osm.pbf

pois.osm.pbf: planet.osm.pbf
	osmium tags-filter planet.osm.pbf \
		amenity=animal_boarding,atm,bank,bar,bbq,bench,bicycle_parking,bicycle_rental,bicycle_repair_station,bureau_de_change,bus_station,cafe,canteen,car_rental,car_wash,charging_station,childcare,cinema,clinic,college,community_centre,compressed_air,dentist,doctors,drinking_water,fast_food,fire_station,fuel,hospital,kindergarten,library,money_transfer,mortuary,nightclub,parcel_locker,parking,parking_space,pharmacy,photo_booth,post_box,post_depot,post_office,prep_school,product_pickup,pub,public_bookcase,restaurant,school,social_facility,telephone,toilets,university,vending_machine,veterinary,waste_basket \
		club=scout \
		craft=carpenter,caterer,clockmaker,electronics_repair,jeweller,key_cutter,locksmith,shoemaker,tailor,watchmaker \
		dark_store=grocery \
		emergency=ambulance_station,defibrillator,emergency_ward_entrance,fire_hydrant,rescue_buoy,water_rescue \
		healthcare=alternative,audiologist,birthing_centre,blood_bank,blood_donation,clinic,dentist,dialysis,doctor,hospice,hospital,laboratory,medical_imaging,nurse,nutrition_counselling,optometrist,pharmacy,physiotherapist,podiatrist,psychotherapist,rehabilitation,sample_collection,speech_therapist,vaccination_centre \
		highway=bus_stop,footway,residential,street_lamp,traffic_signals \
		landuse=industrial \
		leisure=bowling_alley,dog_park,fitness_centre,fitness_station,indoor_play,nature_reserve,park,pitch,playground,resort,sauna,sports_centre \
		man_made=antenna,monitoring_station,pumping_station,street_cabinet,surveillance \
		natural=tree \
		office=architect,company,courier,engineer,estate_agent,financial,financial_advisor,insurance,it \
		power=pole,substation,transformer \
		public_transport=platform,station \
		railway=station \
		shop=agrarian,alcohol,anime,appliance,art,baby_goods,bag,bakery,bathroom_furnishing,beauty,bed,beverages,bicycle,boat,boat_parts,boat_repair,bookmaker,books,butcher,camera,candles,cannabis,car,car_parts,car_repair,caravan,carpet,catalogue,charity,cheese,chemist,chocolate,clothes,coffee,collector,computer,confectionery,convenience,copyshop,cosmetics,country_store,craft,curtain,dairy,deli,department_store,doityourself,doors,dry_cleaning,electrical,electronics,erotic,fashion_accessories,fishing,flooring,florist,frame,frozen_food,funeral_directors,furniture,games,garden_centre,gas,general,gift,gold_buyer,greengrocer,hairdresser,hairdresser_supply,hardware,health_food,hearing_aids,herbalist,hifi,household_linen,houseware,interior_decoration,jewelry,kiosk,kitchen,laundry,leather,lighting,locksmith,lottery,mall,massage,medical_supply,mobile_phone,model,money_lender,motorcycle,motorcycle_repair,music,musical_instrument,newsagent,nutrition_supplements,nuts,optician,orthopedics,outdoor,outpost,paint,party,pastry,pawnbroker,perfumery,pest_control,pet,photo,plant_hire,pottery,printer_ink,pyrotechnics,rental,seafood,second_hand,shoe_repair,shoes,spices,sports,stationery,storage_rental,supermarket,swimming_pool,tailor,tattoo,tea,telecommunication,ticket,tiles,tobacco,tool_hire,toys,trade,travel_agency,truck,truck_parts,truck_repair,tyres,vacuum_cleaner,variety_store,video,video_games,watches,wholesale,window_blind,wine \
		telecom=data_center \
		tourism=apartment,camp_site,caravan_site,chalet,hostel,hotel,motel,museum,wilderness_hut \
		waterway=fuel \
		-o pois.osm.pbf --overwrite

osm_pois: pois.lua pois.osm.pbf
	osm2pgsql -d pois -O flex -S pois.lua pois.osm.pbf

alltheplaces.zip:
	curl -o alltheplaces.zip https://alltheplaces-data.openaddresses.io/runs/${atp_date}/output.zip

alltheplaces.vrt: ziplayer.sh alltheplaces.zip
	./ziplayer.sh alltheplaces.zip > alltheplaces.vrt

atp_pois: alltheplaces.vrt
	ogr2ogr -overwrite -of PostgreSQL -nln alltheplaces -lco GEOMETRY_NAME=geometry \
		-select aeroway,amenity,club,craft,dark_store,emergency,healthcare,highway,landuse,leisure,man_made,natural,office,power,public_transport,railway,shop,telecom,tourism,waterway,addr:city,addr:country,addr:full,addr:housenumber,addr:postcode,addr:state,addr:street,addr:street_address,branch,brand,brand:wikidata,contact:facebook,contact:twitter,email,image,located_in,located_in:wikidata,name,nsi_id,opening_hours,operator,operator:wikidata,phone,website \
		-where "OGR_GEOMETRY='POINT'" \
		PG:dbname=pois alltheplaces.vrt

cluster_pois: osm_pois atp_pois
	psql -d pois -f cluster-pois.sql

clean:
	rm -f planet.osm.pbf pois.osm.pbf alltheplaces.zip alltheplaces.vrt

