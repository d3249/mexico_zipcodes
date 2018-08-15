#encoding: utf-8

#
# El documento original es un CSV.
#
# La estructura que nos interesa son los primeros seis
# elementos:
#
#  0: Código Postal
#  1: Nombre del asentamiento
#  2: Tipo de asentamiento
#  3: Municipio
#  4: Estado 
#  5: Ciudad 
#

module Zipcodes

    require 'set'

    @@sql_file_name = 'CODIGOS_POSTALES.sql'

    @@sql_schema = 'mexico_cp'
   
    @@input_encoding = 'iso-8859-1'
    @@output_encoding = 'utf-8'


    @@zipcodes = Set.new 
    @@settlement_types =Set.new 
    @@municipalities = []
    @@cities = []
    @@states = Set.new 
    @@settlements = []

    @@lines = []

    @@states_map = {}
    @@settlement_types_map = {}
    @@cities_map = {}
    @@zipcodes_map = {}
    @@municipalities_map = {}
    
    def self.convert file

        file_object = file_iterator file
        read_lines file_object

        puts "#{@@settlements.size} asentamientos"
        puts "#{@@zipcodes.size} códigos postales"
        puts "#{@@settlement_types.size} tipos de asentamiento"
        puts "#{@@municipalities.size} municipios"
        puts "#{@@cities.size} ciudades"
        puts "#{@@states.size} estados"

        reset_file @@sql_file_name

        build_simple_table('estado', @@states, @@states_map)
        build_simple_table('tipo_asentamiento', @@settlement_types, @@settlement_types_map)
        build_simple_table('ciudad', @@cities, @@cities_map)

        build_child_table('codigo_postal', @@zipcodes, @@zipcodes_map, 'ciudad', @@cities_map)
        build_child_table('municipio', @@municipalities, @@municipalities_map, 'estado', @@states_map)

        build_settlement_table
        
    end

    def build_settlement_table

        max_len = get_max_length(@@settlements.transpose[0])
        
        File.open(@@sql_file_name,'a') do |file|

            file << <<END_HERE

CREATE TABLE #{@@sql_schema}.asentamiento 
(id INT PRIMARY KEY,
name VARCHAR(#{max_len}),
fk_codigo_postal INT NULL,
fk_tipo_asentamiento INT NULL ,
fk_municipio INT NULL, 
CONSTRAINT FOREIGN KEY (fk_codigo_postal) REFERENCES codigo_postal (id),
CONSTRAINT FOREIGN KEY (fk_tipo_asentamiento) REFERENCES tipo_asentamiento (id),
CONSTRAINT FOREIGN KEY (fk_municipio) REFERENCES municipio (id)
) ENGINE = InnoDB;

END_HERE

            @@settlements.each_with_index do |element, index|

                asentamiento = element[0]
                fk_cp = @@zipcodes_map[element[1]]
                fk_st = @@settlement_types_map[element[2]]
                fk_mu = @@municipalities_map[element[3]]

                
                file << "INSERT INTO #{@@sql_schema}.asentamiento VALUES (#{index + 1}, '#{asentamiento}', #{fk_cp}, #{fk_st}, #{fk_mu});\n"
            end
             
        end

    end

    def build_child_table(tablename, set, map, parent_tablename, parent_map)

        max_len = get_max_length(set.to_a.transpose[0])
        
        File.open(@@sql_file_name,'a') do |file|

            file << <<END_HERE

CREATE TABLE #{@@sql_schema}.#{tablename} 
(id INT PRIMARY KEY,
name VARCHAR(#{max_len}),
fk_#{parent_tablename} INT NULL,
CONSTRAINT  FOREIGN KEY (fk_#{parent_tablename}) REFERENCES #{parent_tablename} (id)
) ENGINE = InnoDB;

END_HERE

            set.each_with_index do |element, index|

              if element[1].size > 0 
                  fk_index = parent_map[element[1]]
              else
                  fk_index = 'NULL'
              end
                
                file << "INSERT INTO #{@@sql_schema}.#{tablename} VALUES (#{index + 1}, '#{element[0]}', #{fk_index});\n"
                map[element[0]] = index + 1
            end
             
        end

    end

    def file_iterator file
        puts "Loading file #{file}"
        File.open(file,"r:#{@@input_encoding}")
    end

    def read_lines file
        lasts = ['','','','','']
        file.each_line do |line|
            encoded_line = line.encode @@output_encoding
            if encoded_line.match /^\d/
                @@lines << encoded_line
                lasts = load_sets(encoded_line, lasts) 
            end
        end
    end

    def reset_file filename
        File.delete(filename) if File.exist? filename
        File.open(filename, 'w') do |file|
            file << "DROP SCHEMA IF EXISTS #{@@sql_schema};\n"
            file << "CREATE SCHEMA IF NOT EXISTS #{@@sql_schema} DEFAULT CHARACTER SET utf8;\n"
        end
    end

    def load_sets(line, lasts)
        elements = line.split /\|/

        lasts[0] = load_if_different(@@zipcodes         ,[elements[0], elements[5]], lasts[0])
        lasts[1] = load_if_different(@@settlement_types , elements[2]              , lasts[1])
        lasts[2] = load_if_different(@@municipalities   ,[elements[3], elements[4]], lasts[2])
        lasts[3] = load_if_different(@@states           , elements[4]              , lasts[3])
        lasts[4] = load_if_different(@@cities           , elements[5]              , lasts[4])
        
        @@settlements << [elements[1], elements[0], elements[2], elements[3]]

        lasts
    end

    def load_if_different(set, element, last)
        if element != last and element.size > 0
            set << element 
            last = element
        end
        last
    end

    def build_simple_table(table_name, set, map)

        max_len = get_max_length(set)

        File.open(@@sql_file_name,'a') do |file|

            file << <<END_HERE

CREATE TABLE #{@@sql_schema}.#{table_name} 
(id INT PRIMARY KEY,
name VARCHAR(#{max_len})) ENGINE = InnoDB;

END_HERE

            set.each_with_index do |element, index|
                if element.size > 0
                    file << "INSERT INTO #{@@sql_schema}.#{table_name} VALUES (#{index + 1}, '#{element}');\n"
                    map[element] = index + 1
                end
            end
             
        end
    end


    def get_max_length set
        max = 0;
        set.each {|element| max = element.size if element.size > max }
        max
    end

end
