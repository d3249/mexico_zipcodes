## Description

### Español
> English version of this documentation below

Este repositorio contiene todos los códigos postales de México como los proporciona
SEPOMEX (Servicio Postal Mexicano) en su sitio http://sepomex.gob.mx/lservicios/servicios/CodigoPostal_Exportar.aspx

Dicho sitio facilita un archivo TXT (texto plano separado por pipes), en MS Excel (xls) y XML.

Este script toma como entrada el archivo en formato TXT y genera un script SQL.

El catálogo completo consta de más de 145,000 asentamientos, así que una inspección detallada para
la normalización de la base de datos es complicada.

Esto es lo que se sabe del archivo:
    
1. De forma predeterminada se llama CPdescarga.txt
2. Usa codificación ISO-8859-1

Esto es lo que se sabe sobre los datos contenidos:

1. Cada asentamiento tiene un código postal
2. Un código postal puede estar asignado a múltiples asentamientos (ejemplo, código postal 01030)
3. Un asentamiento puede pertenecer a una ciudad (ejemplo, código postal 1317)
4. No todos los asentamientos pertenecen a una ciudad (ejemplo, Los Negritos, código postal 20310)
5. Cada asentamiento tiene un tipo 
6. Cada asentamiento pertenece a un municipio
7. Un mismo municipio puede contener varias ciudades (ejemplo, Muelegé)
8. Un municipio pertenece a un estado


Con esto, el script genera los catálogos básicos (Tipo de asentamiento, Ciudad, Estado) y compuestos
(Código Postal - Ciudad, Municipio - Estado y Asentamiento - Código Postal - Tipo Asentamiento - Municipio) en el
script CODIGOS_POSTALES.sql

> El script generado tarda 3+ horas en ejecturase en una computadora Acer aspire A-515 con MariaDB en Arch Linux

**Pendientes**:
    * Separar los scripts de estructura y de insersión de datos
    * Optimizar el script

Si vas a usar esta base de datos, considera descargar el archivo diréctamente del sitio para que esté actualizado.

### English
This repository contains every zip code in Mexico as provided by SEPOMEX (Mexican Postal Service) on the site
http://sepomex.gob.mx/lservicios/servicios/CodigoPostal_Exportar.aspx

The given site can generate a TXT file (plain text separated by pipes), MS Excel file (xls) and XML file.

This script uses the TXT file to generate an SQL script.

The full catalog contempts more than 145,000 settlements, so any in-detail analysis is hard.

This is what we know of the file:

1. By default the file is named CPdescarga.txt
2. It has ISO-8859-1 text encoding


This is what we know on the content:

1. Each settlement have a zip code
2. A zip code can be assigned to multiple settlements (example, zip code 01030)
3. A settlement can belong to a city (example, zip code 1317)
4. Not all settlements belong to a city (example, Los Negritos, zip code 20310)
5. Every settlement have a type
6. Every settlement belongs to a district 
7. A single district can have multiple cities (example, Muelegé)
8. A district belongs to a state


With this, the script generates the basic catalogs (Settlement type, City, State) and the compound ones
(Zip code - City, District - State and Settlement - Zip Code - Settlement type - District) all in CODIGOS_POSTALES.sql file

> Generated script takes 3+ hours to run on  Acer aspire A-515 con MariaDB en Arch Linux

**TODO**:
    * Split structure and inserts scripts
    * Cleanup the script code

If you're using this data base, consider to download the file from the site in order to be updated.
