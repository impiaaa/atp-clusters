local pois = osm2pgsql.define_table({
    name = 'osm_pois',
    ids = { type = 'any', type_column = 'osm_type', id_column = 'osm_id' },
    columns = {
        { column = 'aeroway' },
        { column = 'amenity' },
        { column = 'club' },
        { column = 'craft' },
        { column = 'dark_store' },
        { column = 'emergency' },
        { column = 'healthcare' },
        { column = 'highway' },
        { column = 'landuse' },
        { column = 'leisure' },
        { column = 'man_made' },
        { column = 'natural' },
        { column = 'office' },
        { column = 'power' },
        { column = 'public_transport' },
        { column = 'railway' },
        { column = 'shop' },
        { column = 'telecom' },
        { column = 'tourism' },
        { column = 'waterway' },
        { column = 'addr:city' },
        { column = 'addr:country' },
        { column = 'addr:full' },
        { column = 'addr:housenumber' },
        { column = 'addr:postcode' },
        { column = 'addr:state' },
        { column = 'addr:street' },
        { column = 'addr:street_address' },
        { column = 'branch' },
        { column = 'brand' },
        { column = 'brand:wikidata' },
        { column = 'contact:facebook' },
        { column = 'contact:twitter' },
        { column = 'email' },
        { column = 'image' },
        { column = 'located_in' },
        { column = 'located_in:wikidata' },
        { column = 'name' },
        { column = 'nsi_id' },
        { column = 'opening_hours' },
        { column = 'operator' },
        { column = 'operator:wikidata' },
        { column = 'phone' },
        { column = 'website' },
        { column = 'geometry', type = 'point', not_null = true, projection = 4326 },
}})

function process_poi(object, geometry)
    local a = {
        geometry = geometry
    }
    for k, v in pairs(object.tags) do
        if k ~= 'geometry' then
            a[k] = v
        end
    end
    pois:insert(a)
end

function osm2pgsql.process_node(object)
    process_poi(object, object:as_point())
end

function osm2pgsql.process_way(object)
    if object.is_closed then
        process_poi(object, object:as_polygon():centroid())
    end
end


