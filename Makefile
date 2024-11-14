mirror=https://ftpmirror.your.org/pub/openstreetmap

all: cluster_pois

planet-latest.osm.pbf:
	curl -o planet-latest.osm.pbf $mirror/pbf/planet-latest.osm.pbf

pois.osm.pbf: planet-latest.osm.pbf
	osmium tags-filter planet-latest.osm.pbf \
		amenity=animal_boarding,atm,bank,bar,bench,bicycle_parking,bicycle_rental,bureau_de_change,bus_station,cafe,canteen,car_rental,car_wash,charging_station,childcare,cinema,clinic,college,community_centre,compressed_air,dentist,doctors,fast_food,fire_station,fuel,hospital,kindergarten,library,money_transfer,mortuary,nightclub,parcel_locker,parking,pharmacy,post_box,post_depot,post_office,prep_school,product_pickup,pub,public_bookcase,restaurant,school,social_facility,telephone,university,vending_machine,veterinary \
		club=scout \
		craft=carpenter,caterer,clockmaker,electronics_repair,jeweller,key_cutter,locksmith,shoemaker,tailor \
		dark_store=grocery \
		emergency=ambulance_station,defibrillator,emergency_ward_entrance,rescue_buoy,water_rescue \
		healthcare=alternative,audiologist,birthing_centre,blood_bank,blood_donation,clinic,dentist,dialysis,doctor,hospice,hospital,laboratory,medical_imaging,nutrition_counselling,optometrist,pharmacy,physiotherapist,podiatrist,psychotherapist,rehabilitation,sample_collection,speech_therapist,vaccination_centre \
		highway=bus_stop,residential \
		landuse=industrial \
		leisure=bowling_alley,fitness_centre,park,playground,resort,sauna \
		man_made=antenna,surveillance \
		office=company,courier,engineer,estate_agent,financial,financial_advisor,insurance,it \
		public_transport=platform,station \
		shop=agrarian,alcohol,anime,appliance,art,baby_goods,bag,bakery,bathroom_furnishing,beauty,bed,beverages,bicycle,boat,bookmaker,books,butcher,camera,candles,cannabis,car,car_parts,car_repair,caravan,carpet,catalogue,charity,cheese,chemist,chocolate,clothes,coffee,computer,confectionery,convenience,copyshop,cosmetics,country_store,craft,curtain,dairy,deli,department_store,doityourself,doors,dry_cleaning,electrical,electronics,erotic,fashion_accessories,fishing,flooring,florist,frame,frozen_food,funeral_directors,furniture,games,garden_centre,gas,general,gift,gold_buyer,greengrocer,hairdresser,hairdresser_supply,hardware,health_food,hearing_aids,herbalist,hifi,household_linen,houseware,interior_decoration,jewelry,kiosk,kitchen,laundry,leather,lighting,locksmith,lottery,mall,massage,medical_supply,mobile_phone,model,money_lender,motorcycle,motorcycle_repair,music,musical_instrument,newsagent,nutrition_supplements,nuts,optician,orthopedics,outdoor,outpost,paint,party,pastry,pawnbroker,perfumery,pest_control,pet,photo,plant_hire,pottery,printer_ink,pyrotechnics,rental,seafood,second_hand,shoe_repair,shoes,spices,sports,stationery,storage_rental,supermarket,swimming_pool,tailor,tattoo,tea,telecommunication,ticket,tiles,tobacco,tool_hire,toys,trade,travel_agency,truck,truck_parts,truck_repair,tyres,vacuum_cleaner,variety_store,video,video_games,watches,wholesale,window_blind,wine \
		tourism=apartment,camp_site,caravan_site,chalet,hostel,hotel,motel,museum,wilderness_hut \
		railway=station \
		waterway=fuel \
		telecom=data_center \
		-o pois.osm.pbf --overwrite

osm_pois: pois.lua pois.osm.pbf
	osm2pgsql -d pois -O flex -S pois.lua pois.osm.pbf

alltheplaces.zip:
	curl -o alltheplaces.zip $(curl https://data.alltheplaces.xyz/runs/latest.json | jq -r '.["output_url"]')

alltheplaces.vrt: ziplayer.sh alltheplaces.zip
	./ziplayer.sh alltheplaces.zip > alltheplaces.vrt

atp_pois: alltheplaces.vrt
	ogr2ogr -overwrite -of PostgreSQL -nln alltheplaces -lco GEOMETRY_NAME=geometry \
		-select amenity,club,craft,dark_store,emergency,healthcare,highway,landuse,leisure,man_made,office,public_transport,shop,tourism,aeroway,railway,waterway,telecom,name,branch,addr:full,addr:housenumber,addr:street,addr:street_address,addr:city,addr:state,addr:postcode,addr:country,phone,email,website,contact:twitter,contact:facebook,opening_hours,image,ref,brand,brand:wikidata,operator,operator:wikidata,located_in,located_in:wikidata,nsi_id \
		-where "OGR_GEOMETRY='POINT'" \
		PG:dbname=pois alltheplaces.vrt

cluster_pois: osm_pois atp_pois
	psql -d pois -f cluster-pois.sql

