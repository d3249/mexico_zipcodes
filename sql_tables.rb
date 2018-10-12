#encoding: utf-8

module Zipcodes


    @@sql_schema = 'mexico_cp'

    def reset_file filename
        File.delete(filename) if File.exist? filename
        File.open(filename, 'w') do |file|
            file << "DROP SCHEMA IF EXISTS #{@@sql_schema};\n"
            file << "CREATE SCHEMA IF NOT EXISTS #{@@sql_schema} DEFAULT CHARACTER SET utf8;\n"
        end
    end

    def build_settlement_table

        max_len = get_max_length(@@settlements.transpose[0])
        
        File.open(@@sql_file_name,'a') do |file|

            file << <<END_HERE

CREATE TABLE #{@@sql_schema}.asentamiento 
(id INT PRIMARY KEY,
name VARCHAR(#{max_len}),
codigo_postal VARCHAR(5),
fk_tipo_asentamiento INT NULL ,
fk_municipio INT NULL, 
fk_ciudad INT NULL, 
CONSTRAINT FOREIGN KEY (fk_tipo_asentamiento) REFERENCES tipo_asentamiento (id),
CONSTRAINT FOREIGN KEY (fk_municipio) REFERENCES municipio (id),
CONSTRAINT FOREIGN KEY (fk_ciudad) REFERENCES ciudad (id)
) ENGINE = InnoDB;

CREATE INDEX cp_idx ON #{@@sql_schema}.asentamiento (codigo_postal);

END_HERE

            @@settlements.each_with_index do |element, index|

                asentamiento = element[0]
                cp = element[1]
                fk_st = @@settlement_types_map[element[2]]
                fk_mu = @@municipalities_map[element[3]]
                fk_ci= @@cities_map[element[4]] || "NULL"
                

                
                file << "INSERT INTO #{@@sql_schema}.asentamiento VALUES (#{index + 1}, '#{asentamiento}', #{cp}, #{fk_st}, #{fk_mu}, #{fk_ci});\n"
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
                
                throw "Elemento repetido en la tabla #{tablename} [#{element[0]}]" if map[element[0]]
                map[element[0]] = index + 1
            end
             
        end

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

