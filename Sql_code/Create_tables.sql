create table personas(
	idpersona serial primary key,
	nombre varchar(30) not null,
	apellidos varchar(40) not null,
	fecha_de_nacimiento date not null,
	altura float,
	peso float,
	sexo char not null check (sexo in ('F','M')),
	nacionalidad varchar(30)
);

create table modalidades(
	id_modalidad int primary key,
	tipo varchar(20) not null,
	descripcion varchar(30)
);

create table seguros(
	numero_de_poliza int primary key,
	tipo_de_cobertura varchar(20) not null,
	cobertura_medica_asociada varchar(20) not null,
	fecha_inicio date not null,
	fecha_finalizacion date not null check (fecha_inicio < fecha_finalizacion)
);

create table deportistas(
	idpersona int not null,
	estado_activo varchar(10),
	ranking_mundial int not null,
	id_modalidad int not null,
	numero_de_poliza int not null,
	primary key (idpersona),
	foreign key (idpersona) references personas(idpersona),
	foreign key (id_modalidad) references modalidades(id_modalidad),
	foreign key (numero_de_poliza) references seguros(numero_de_poliza)
);

create table especificaciones_medicas(
	id_especificacion_medica int primary key,
    id_deportista int not null,
	padecimiento varchar(20) not null,
	tratamiento_medico varchar(20) not null,
	estado_actual varchar(20) not null,
	medicamento_recetado varchar(20) not null,
	FOREIGN KEY (id_deportista) REFERENCES deportistas(idpersona)
); 


CREATE TABLE historial_de_trabajo (
  id_historial INT NOT NULL PRIMARY KEY,
  nombre_deportista VARCHAR(40) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_finalizacion DATE NOT NULL check (fecha_finalizacion > fecha_inicio)
);

CREATE TABLE certificaciones (
  id_certificacion INT NOT NULL PRIMARY KEY,
  nombre VARCHAR(40) NOT NULL,
  institucion VARCHAR(30) NOT NULL
);

create table entrenadores(
	idpersona int not null,
	id_deportista int not null,
	id_certificacion int not null,
	historial_de_trabajo int not null,
	primary key (idpersona),
	foreign key (idpersona) references personas(idpersona),
	foreign key (id_deportista) references deportistas(idpersona),
	foreign key (id_certificacion) references certificaciones(id_certificacion),
	foreign key (historial_de_trabajo) references historial_de_trabajo(id_historial)
);

create table arbitros(
	idpersona int not null,
	tipo varchar(30) not null,
	fecha_inicio_carrera date,
	id_certificacion int not null,
	primary key (idpersona),
	foreign key (idpersona) references personas(idpersona),
	foreign key (id_certificacion) references certificaciones(id_certificacion)
);

create table logros(
	id_logro int primary key,
	nombre varchar(30),
	fecha date
);

create table premios(
	id_premio int primary key,
	cantidad int,
	nombre varchar(20) not null
);

create table logros_de_los_deportistas(
	id_logro_del_deportista int not null,
	id_logro int not null,
	id_deportista int not null,
	id_premio int not null,
	primary key (id_logro_del_deportista),
	foreign key (id_logro) references logros(id_logro),
	foreign key (id_deportista) references deportistas(idpersona),
	foreign key (id_premio) references premios(id_premio)
);

create table horarios_staff(
	id_horario int primary key,
	fecha date not null,
	hora_entrada time not null,
	hora_salida time not null check (hora_entrada < hora_salida)
);

create table informacion_de_contacto(
	id_informacion_de_contacto int primary key,
	numero_de_telefono int not null,
	correo varchar(30) not null,
	direccion varchar(30) not null,
	ciudad_de_residencia varchar(20) not null
);

create table roles_de_los_staff(
	id_rol_staff int primary key,
	nombre varchar(30) not null,
	descripcion varchar(50),
	responsabilidad_especifica varchar(30)
);

create table staffs(
	idpersona int not null,
	id_rol int not null,
	id_informacion_de_contacto int not null,
	id_horarios_de_staff int not null,
	primary key (idpersona),
	foreign key (id_rol) references roles_de_los_staff(id_rol_staff),
	foreign key (id_informacion_de_contacto) references informacion_de_contacto(id_informacion_de_contacto),
	foreign key (id_horarios_de_staff) references horarios_staff(id_horario)
);

create table contratiempos (
	id_contratiempo int primary key,
	id_partido int not null,
	tipo varchar(20) not null,
	descripcion varchar(40)
);

create table condiciones_climaticas(
	id_condicion_climatica int primary key,
	nubosidad int not null,
	temperatura float not null,
	humedad float not null,
	probabilidad_de_precipitacion float not null,
	velocidad_del_viento float not null,
	direccion_del_viento varchar(20) not null,
	observacion_adicional varchar(30) 
);

create table partidos(
	id_partido int primary key,
	fecha date not null,
    hora_inicio TIME NOT NULL,
	hora_finalizacion TIME NOT NULL CHECK (hora_inicio < hora_finalizacion),
	canal_de_transmision varchar(30),
	fase varchar(20),	
	id_condicion_climatica int not null,
	id_contratiempo int,
	foreign key (id_condicion_climatica) references condiciones_climaticas(id_condicion_climatica),
	foreign key (id_contratiempo) references contratiempos(id_contratiempo)
);

create table premios_de_los_partidos(
	id_premio int not null,
	id_partido int not null,
	primary key (id_premio, id_partido),
	foreign key (id_premio) references premios(id_premio),
	foreign key (id_partido) references partidos(id_partido)
);

create table tipo_personas(
	id_tipo_persona int primary key,
	nombre varchar(50) not null,
	descripcion varchar(100) not null
);

create table participantes_de_los_partidos(
	id_persona int not null,
	id_partido int not null, 
	id_tipo_persona int not null,
	primary key (id_persona, id_partido, id_tipo_persona),
	foreign key (id_persona) references personas(idpersona),
	foreign key (id_partido) references partidos(id_partido),
	foreign key (id_tipo_persona) references tipo_personas(id_tipo_persona)
);

create table patrocinadores(
	id_patrocinador int primary key,
	telefono int not null,
	nombre_empresa varchar(30) not null,
	correo varchar(30) not null,
	nivel_de_patrocinio varchar(20) not null,
	fecha_inicio date not null,
	fecha_finalizacion date not null check (fecha_inicio < fecha_finalizacion)
);

create table patrocinadores_de_los_partidos(
	id_patrocinador int not null,
	id_partido int not null,
	primary key (id_partido, id_patrocinador),
	foreign key (id_partido) references partidos(id_partido),
	foreign key (id_patrocinador) references patrocinadores(id_patrocinador)
);

create table patrocinadores_de_los_deportistas(
	id_deportista int not null,
	id_patrocinador int not null,
	primary key (id_deportista, id_patrocinador),
	foreign key (id_deportista) references deportistas(idpersona),
	foreign key(id_patrocinador) references patrocinadores(id_patrocinador)
);

create table estado_convenios(
	id_estado int primary key,
	nombre varchar(20) not null,
	decripcion varchar(30)
);

create table tipos_convenios(
	id_tipo int primary key,
	nombre varchar(20) not null,
	descripcion varchar(30)
);

CREATE TABLE convenios (
   id_convenio INT NOT NULL PRIMARY KEY,
   nombre_empresa VARCHAR(20) NOT NULL,
   id_tipo INT NOT NULL,
   fecha_inicio date not null,
   fecha_finalizacion date not null check(fecha_inicio < fecha_finalizacion),
   valor INT NOT NULL,
   id_estado INT NOT NULL,
   FOREIGN KEY (id_tipo) REFERENCES Tipos_convenios(id_tipo),
   FOREIGN KEY (id_estado) REFERENCES Estado_convenios(id_estado)
);

CREATE TABLE convenios_de_los_partidos(
   id_convenio INT NOT NULL,
   id_partido INT NOT NULL,
   FOREIGN KEY (id_convenio) REFERENCES Convenios(id_convenio),
   FOREIGN KEY (id_partido) REFERENCES Partidos(id_partido)
);

CREATE TABLE sets_ (
   id_set INT NOT NULL PRIMARY KEY,
	id_partido int not null,
   hora_inicio TIME NOT NULL,
   hora_finalizacion TIME NOT NULL CHECK (hora_finalizacion > hora_inicio),
   numero_set INT NOT NULL,
	foreign key (id_partido) references partidos(id_partido)
);

CREATE TABLE estadisticas (
   id_estadistica SERIAL NOT NULL PRIMARY KEY,
   id_deportista INT NOT NULL,
   id_set INT NOT NULL,
   FOREIGN KEY (id_deportista) REFERENCES deportistas(idpersona),
   FOREIGN KEY (id_set) REFERENCES sets_(id_set)
);

create table estadisticas_sin_puntos(
	id_estadisticas int primary key,
	aceleracion_max_alcanzada float not null,
	distacia_recorrida float not null,
	velocidad_max_saque_efectivo float not null,
	velocidad_max_alcanzada float not null,
	foreign key (id_estadisticas) references estadisticas(id_estadistica)
);


create table reglamentos(
	id_reglamento int not null primary key,
	nombre varchar(20) not null,
	descripcion varchar(40) not null,
	fecha_de_puesta_en_marcha date not null
);


CREATE TABLE estadisticas_con_puntos(
    id_estadistica int primary key,
	id_reglamento int not null,
	numero_de_puntos int not null,
	FOREIGN KEY (id_estadistica) REFERENCES estadisticas(id_estadistica),
	FOREIGN KEY (id_reglamento) REFERENCES reglamentos (id_reglamento)
);

create table protocolos_de_seguridad(
	id_protocolo int not null primary key,
	nombre varchar(20) not null,
	descripcion varchar(40)
);

create table protocolos_de_los_partidos(
	id_protocolo int not null,
	id_partido int not null,
	primary key (id_protocolo, id_partido),
	foreign key (id_protocolo) references partidos(id_partido),
	foreign key (id_partido) references protocolos_de_seguridad(id_protocolo)
);

CREATE TABLE opiniones (
    id_opinion SERIAL PRIMARY KEY,
    id_partido INTEGER NOT NULL,
    opinion TEXT NOT NULL,
    FOREIGN KEY (id_partido) REFERENCES partidos(id_partido)
);








