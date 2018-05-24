-- Consultas �tiles 
-- Reproyectar 
 ALTER TABLE #Tabla_a_proyectar#
    ALTER COLUMN geom
    TYPE Geometry(#tipo_de_geometr�a#, #No_SRID#)
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

-- Topolog�a
alter table #tabla_red# add column source integer;
alter table  #tabla_red# add column target integer;

select pgr_createTopology ('#tabla_red#', 0.0001, 'geom', 'id');

-- Identificar nodos m�s cercanos 

create table #tabla_nodos# as 
select b.id as #tabla_puntos#, (
  SELECT a.id
  FROM #tabla_vertices# As a
  ORDER BY f.geom <-> n.the_geom LIMIT 1
)as closest_node
from  #tabla_puntos# b

-- Areas de servicio 

select * from #Tabla_vertices# v,
(SELECT node FROM pgr_drivingDistance(
        'SELECT #id#, source, target, cost, reverse_cost FROM #RED#',
        #NodoDeOrigen#, 0.16
      )) as service
where v.id = service.node