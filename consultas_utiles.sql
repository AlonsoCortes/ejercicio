-- Consultas útiles 
-- Reproyectar 
 ALTER TABLE #Tabla_a_proyectar#
    ALTER COLUMN geom
    TYPE Geometry(#tipo_de_geometría#, #No_SRID#)
    USING ST_Transform(geom, #No_SRID#);

-- join con id

select a.*, b.*
from #Tabla1# a
join #Tabla2# b
on a.#id_tabla1# = b.#id_tabla2#

-- join st_intersects

select a.*, b.*
from #Tabla1# a
join #Tabla2# b
on st_intersects(a.geom, b.geom)

-- R E D E S 

-- Topología
alter table #tabla_red# add column source integer;
alter table  #tabla_red# add column target integer;

select pgr_createTopology ('#tabla_red#', 0.0001, 'geom', 'id');

-- Identificar nodos más cercanos 

create table #tabla_nodos# as 
select b.id as #id_puntos#, (
  SELECT a.id
  FROM #tabla_vertices# As a
  ORDER BY b.geom <-> n.the_geom LIMIT 1
)as closest_node
from  #tabla_puntos# b

-- Actualizar la tabla de los puntos originales, agregando los id del nodo más cercano 
alter table #tabla_puntos# add column closest_node bigint; 
update #tabla_puntos# set closest_node = u.closest_node
from  
(select b.id as #id_puntos#, (
  SELECT a.id
  FROM #tabla_vertices# As a
  ORDER BY b.geom <-> a.the_geom LIMIT 1
)as closest_node
from  #tabla_puntos# b) as c
where c.#id_puntos# = #tabla_puntos#.id

-- Areas de servicio  

select * from #Tabla_vertices# v,
(SELECT node FROM pgr_drivingDistance(
        'SELECT #id#, source, target, cost, reverse_cost FROM #RED#',
        #NodoDeOrigen#, 0.16
      )) as service
where v.id = service.node
 
-- Ruta 
select b.geom, a.*
from
(select node, edge as id, cost from pgr_dijkstra(
  ' SELECT  id,
           source::int4,
           target::int4,
           cost::float8 AS cost
    FROM  #TABLA RED#', #NODO_1#, #NODO_2#, directed:=false)) as a
join #TABLA RED# b
on a.id = b.id
