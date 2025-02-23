--pregunta 1
--cual es el id del o los deportista, nombre, apellidos y altura
-- del deportista con una altura entre 1.60 m y 1.80 m
-- cuya aceleracion maxima alcanzada supere los 3 m/s cuadrado

create view aceleracion_mayor_a_3ms as
select idpersona, (select CONCAT(nombre,' ', apellidos)
					from personas
	    			where personas.idpersona = deportistas.idpersona),(select altura
																		from personas
																		where personas.idpersona = deportistas.idpersona)
from deportistas
where idpersona in (select idpersona
					from personas
					where altura between 1.60 and 1.80) and idpersona in (select id_deportista
																			from estadisticas
																			where id_estadistica in (select id_estadisticas
																									from estadisticas_sin_puntos
																									where aceleracion_max_alcanzada > 3));




--pregunta 2
--cual es el promedio de duracion de los sets
--cuando los partidos presentan condiciones climaticas 
--de vientos con velocidades superiores a  5 m/s



create view promedio_duracion_sets_viento as
select avg(hora_finalizacion - hora_inicio)
from sets_
where id_partido in (select id_partido
						from partidos p inner join condiciones_climaticas cc 
	 					on p.id_condicion_climatica = cc.id_condicion_climatica
							where cc.velocidad_del_viento > 5 );


-- pregunta 3

-- cual es el promedio de la distancia recorrida por set de los jugadores
-- nacidos en el continente americano en la parte sur 

create view promedio_distancia_recorrida_sets_latinoamericanos as
select avg(distacia_recorrida)
from estadisticas_sin_puntos
where id_estadisticas in (select id_estadistica
						  from estadisticas
						  where id_set in (select s.id_set
						  					from participantes_de_los_partidos p inner join sets_ s
											 on p.id_partido = s.id_partido
											where p.id_persona in (select idpersona
											from deportistas
												where idpersona in (select idpersona
												from personas
												where nacionalidad in ('Mexicana', 'Colombiana', 'Argentina','Peruana','Chilena','Brasileña','Venenzolana','Ecuatoriana')))));




-- pregunta 4 
-- ¿Cuál es el nombre, apellido y edad de los jugadores que han ganado el Roland Garros 
--en la categoría femenina mientras haya ocurrido un contratiempo? 


create or replace view mujeres_ganadoras_del_torneo as
select idpersona, nombre, apellidos,  extract( year from age(fecha_de_nacimiento))
from personas
where idpersona in (select idpersona
					from participantes_de_los_partidos
					where id_partido in (select id_partido
										from partidos
										where id_contratiempo is not null))
intersect 
				
 select *
 from  (select idpersona, nombre, apellidos, extract( year from age(fecha_de_nacimiento))*12
		from personas
		where sexo = 'F' and idpersona in  (select id_deportista
											from logros_de_los_deportistas
											where id_logro = 101));

--pregunta 5
--¿Cuáles fueron es el id, nombre y apellidos de los entrenadores  europeos que sus deportistas
--ganaron la competicion?

create view entrenadores_europeos_que_entrenaron_campeones_del_torneo as
select idpersona, (select concat(nombre,' ', apellidos) as nombre_completo
					from personas
					where personas.idpersona = e.idpersona)
from entrenadores e
where idpersona in (SELECT idpersona
					FROM personas
					WHERE nacionalidad IN ('España', 'Francia', 'Alemania', 'Italia', 'Reino Unido', 'Suiza', 
    'Suecia', 'Noruega', 'Dinamarca', 'Países Bajos', 'Bélgica', 'Austria', 
    'Portugal', 'Grecia', 'Polonia', 'Hungría', 'República Checa', 'Finlandia', 
    'Irlanda', 'Eslovaquia', 'Eslovenia', 'Croacia', 'Bosnia y Herzegovina', 
    'Serbia', 'Montenegro', 'Albania', 'Bulgaria', 'Rumania', 'Ucrania', 
    'Lituania', 'Letonia', 'Estonia'
)) and idpersona in (select idpersona
					  from entrenadores
						where id_deportista in (select id_deportista 
												from logros_de_los_deportistas
												where id_logro = 101));




--pregunta 6
-- cual es el nombre y el nivel de patrocinio de los 
--patrocinaodores que han patrocinado partidos que han tenido contratiempos 



create view patrocinadores_con_contratiempos as
SELECT p.nombre_empresa , 
       p.nivel_de_patrocinio
    FROM patrocinadores p
    WHERE p.id_patrocinador IN 
          				(SELECT id_patrocinador
          				 FROM patrocinadores_de_los_partidos
         				  WHERE id_partido IN 
                						 (SELECT id_partido
                 						 FROM partidos
                  						WHERE id_contratiempo IS NOT NULL));



-- pregunta 7
-- cual es el id del partido, nombre de los participantes de ese partido, 
-- nombre del protocolo de los partidos en que se implemento el
--protocolo de seguridad llamado evacuacion por tormentas

SELECT 
   pp.id_partido, 
   per.nombre AS nombre_persona, 
   pds.nombre AS nombre_protocolo
FROM 
    participantes_de_los_partidos pp
INNER JOIN 
    personas per ON per.idpersona = pp.id_persona
INNER JOIN 
    protocolos_de_los_partidos pdp ON pp.id_partido = pdp.id_partido
INNER JOIN 
    protocolos_de_seguridad pds ON pdp.id_protocolo = pds.id_protocolo
WHERE 
    pds.id_protocolo = 1;


	
---- funciones--------

--obtener deportistas
--------------------
-------funcion1------
---------------------
--¿cuales son los deportistas del torneo?
create or replace function obtener_deportistas()
returns table (idpersona int, nombre TEXT ) as $$
begin
	return query
	select p.idpersona, concat(p.nombre,' ', p.apellidos)
	from personas p
	where p.idpersona in (select d.idpersona
						from deportistas d);
end;
$$ language plpgsql;


select *
	from obtener_deportistas()

---patrocinadores con partidos con contratiempos--
-------------------
---funcion2---------
-------------------
CREATE OR REPLACE FUNCTION patrocinadores_con_contratiempos_partidos()
RETURNS TABLE (nombre_empresa text, nivel_patrocinio TEXT, numero_partidos int) AS $$
BEGIN
    RETURN QUERY
    SELECT cast(p.nombre_empresa as text), 
           cast(p.nivel_de_patrocinio as text), 
           cast((SELECT COUNT(pp.id_partido)
            FROM patrocinadores_de_los_partidos pp
            WHERE pp.id_patrocinador = p.id_patrocinador) as int)
    FROM patrocinadores p
    WHERE p.id_patrocinador IN 
          (SELECT id_patrocinador
           FROM patrocinadores_de_los_partidos
           WHERE id_partido IN 
                 (SELECT id_partido
                  FROM partidos
                  WHERE id_contratiempo IS NOT NULL));
END;
$$ LANGUAGE plpgsql;


----entrenadores_europeos_que_sus_deportistas_ganaron_la_competion
--------------------------
-------funcion 3-----------
create or replace function buscar_entrenadores_europeos_campeones()
returns table (idpersona integer, nombre_completo text) as $$
begin
	return query
	SELECT 
    e.idpersona, 
    CONCAT(p.nombre, ' ', p.apellidos) AS nombre_completo
FROM 
    entrenadores e
INNER JOIN 
    personas p ON e.idpersona = p.idpersona
INNER JOIN 
    logros_de_los_deportistas ldd ON e.id_deportista = ldd.id_deportista
WHERE 
    p.nacionalidad IN ('España', 'Francia', 'Alemania', 'Italia', 'Reino Unido', 'Suiza', 
                       'Suecia', 'Noruega', 'Dinamarca', 'Países Bajos', 'Bélgica', 'Austria', 
                       'Portugal', 'Grecia', 'Polonia', 'Hungría', 'República Checa', 'Finlandia', 
                       'Irlanda', 'Eslovaquia', 'Eslovenia', 'Croacia', 'Bosnia y Herzegovina', 
                       'Serbia', 'Montenegro', 'Albania', 'Bulgaria', 'Rumania', 'Ucrania', 
                       'Lituania', 'Letonia', 'Estonia')
AND 
    ldd.id_logro = 101;
end;
$$ language plpgsql;


-----------------------------LAUREN_______________________________

---¿cual es e
SELECT id_convenio, nombre_empresa, valor, tipo_convenio
FROM (SELECT C.id_convenio, C.nombre_empresa, C.valor, T.nombre AS tipo_convenio,
			ROW_NUMBER() OVER (PARTITION BY C.id_tipo ORDER BY C.valor DESC) AS rank
    FROM Convenios C

    JOIN tipos_convenios T ON C.id_tipo = T.id_tipo

    WHERE C.id_estado= 1

) AS ConveniosRank

WHERE rank = 1
ORDER BY tipo_convenio, valor DESC;


select valor, (select nombre
				from tipos_convenios t
				where t.id_tipo = c.id_tipo)
from convenios c


5. ¿cuales son los convenios activos ordenados por el valor más alto dentro de cada tipo de convenio?
 
SELECT id_convenio, nombre_empresa, valor, tipo_convenio

FROM (

    SELECT C.id_convenio, C.nombre_empresa, C.valor, T.nombre AS tipo_convenio,

           ROW_NUMBER() OVER (PARTITION BY C.id_tipo ORDER BY C.valor DESC) AS rank

    FROM Convenios C

    JOIN tipos_convenios T ON C.id_tipo = T.id_tipo

    WHERE C.id_estado = 1

) AS ConveniosRank

WHERE rank = 1

ORDER BY tipo_convenio, valor DESC;

4. ¿cuales son los deportistas que han participado en una cantidad menor o igual partidos 

que el promedio de partidos por deportista?
 
SELECT (select per.nombre

		from personas per

		where per.idpersona = D.idpersona) as "nombre", COUNT(P.id_partido) AS partidos_participados

FROM participantes_de_los_partidos P

JOIN deportistas D ON P.id_persona = D.idpersona

GROUP BY "nombre"

HAVING COUNT(P.id_partido) <= (

    SELECT AVG(participaciones)

    FROM (

        SELECT COUNT(id_partido) AS participaciones

        FROM participantes_de_los_partidos

        GROUP BY id_persona

    ) AS PromedioParticipaciones

);

3. ¿cuál es el nombre y nacionalidad de los deportistas que han participado

	en algun partido y han ganado al menos un premio?
 
SELECT (select per.nombre

		from personas per

		where per.idpersona = D.idpersona) AS nombre_deportista, (select per.nacionalidad

																	from personas per

																	where per.idpersona = D.idpersona) as "nacionalidad", COUNT(DISTINCT P.id_partido) AS partidos_participados

FROM participantes_de_los_partidos P

JOIN Deportistas D ON P.id_persona = D.idpersona

WHERE D.idpersona IN (

    SELECT id_deportista

    FROM Logros_de_los_deportistas

)

GROUP BY nombre_deportista,nacionalidad;

CREATE VIEW Vista_Logros_Deportivos AS

SELECT (select per.nombre

		from personas per

		where per.idpersona = D.idpersona) AS nombre_deportista, (select per.nacionalidad

																	from personas per

																	where per.idpersona = D.idpersona) as "nacionalidad", COUNT(DISTINCT P.id_partido) AS partidos_participados

FROM participantes_de_los_partidos P

JOIN Deportistas D ON P.id_persona = D.idpersona

WHERE D.idpersona IN (

    SELECT id_deportista

    FROM Logros_de_los_deportistas

)

GROUP BY nombre_deportista,nacionalidad;




