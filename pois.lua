local pois = osm2pgsql.define_table({
    name = 'osm_pois',
    ids = { type = 'any', type_column = 'osm_type', id_column = 'osm_id' },
    columns = {
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
        { column = 'office' },
        { column = 'public_transport' },
        { column = 'shop' },
        { column = 'tourism' },
        { column = 'aeroway' },
        { column = 'railway' },
        { column = 'waterway' },
        { column = 'telecom' },
        { column = 'name' },
        { column = 'branch' },
        { column = 'addr:full' },
        { column = 'addr:housenumber' },
        { column = 'addr:street' },
        { column = 'addr:street_address' },
        { column = 'addr:city' },
        { column = 'addr:state' },
        { column = 'addr:postcode' },
        { column = 'addr:country' },
        { column = 'phone' },
        { column = 'email' },
        { column = 'website' },
        { column = 'contact:twitter' },
        { column = 'contact:facebook' },
        { column = 'opening_hours' },
        { column = 'image' },
        { column = 'ref' },
        { column = 'brand' },
        { column = 'brand:wikidata' },
        { column = 'operator' },
        { column = 'operator:wikidata' },
        { column = 'located_in' },
        { column = 'located_in:wikidata' },
        { column = 'nsi_id' },
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


