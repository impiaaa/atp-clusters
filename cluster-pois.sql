drop table if exists clusters;

create table clusters
  as select
    sum((layer='atp')::int)::int as atp_count,
    sum((layer='osm')::int)::int as osm_count,
    ST_Force2D(ST_Transform(ST_Collect(geometry), 4326))::geometry('MULTIPOINT', 4326) as geometry
  from (
    select
      layer,
      geometry,
      ST_ClusterDBSCAN(geometry, 45, 4) over () as cid
    from (
      select
        'atp' as layer,
        ST_Transform(ST_Force3D(geometry), 4978) as geometry
      from alltheplaces
      union select
        'osm' as layer,
        ST_Transform(ST_Force3D(geometry), 4978) as geometry
      from osm_pois
    ) pois_3d
  ) sq
  where
    cid is not null
  group by cid;

alter table clusters add column difference integer;
update clusters set difference = atp_count - osm_count;

