#encoding: utf-8

module Zipcodes


    @@sql_schema = 'mexico_cp'
    @@index_extra_characters = 1
    @@max_lines_to_commit = 10000

    def write_output_file
        reset_file @@sql_file_name

        build_simple_table('estado', @@states, @@states_map)
        build_simple_table('tipo_asentamiento', @@settlement_types, @@settlement_types_map)
        build_simple_table('ciudad', @@cities, @@cities_map)

        build_child_table('municipio', @@municipalities, @@municipalities_map, 'estado', @@states_map)

        build_settlement_table

        write_end_of_file
    end

    def reset_file filename
        File.delete(filename) if File.exist? filename
        File.open(filename, 'w') do |file|
            file << "DROP SCHEMA IF EXISTS #{@@sql_schema};\n"
            file << "CREATE SCHEMA IF NOT EXISTS #{@@sql_schema} DEFAULT CHARACTER SET utf8;\n"
            file << "SET FOREIGN_KEY_CHECKS=0;\n"
        end
    end

    def build_settlement_table

        max_len = get_max_length(@@settlements.transpose[0])

        File.open(@@sql_file_name,'a') do |file|

            file << <<END_HERE

begin;

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

commit;

END_HERE

            last_index = @@settlements.size - 1;
            @@row_counter = 1;

            @@settlements.each_with_index do |element, index|


                file << "begin;\nINSERT INTO #{@@sql_schema}.asentamiento VALUES\n" if @@row_counter == 1

                state_key = @@states_map[element[@@STATE_ARRAY]]

                asentamiento = element[@@SETTLEMENT_ARRAY]
                cp = element[@@CP_ARRAY]
                fk_st = @@settlement_types_map[element[@@SETTLEMENT_TYPE_ARRAY]]
                fk_mu = @@municipalities_map[element[@@MUNICIPALITY_ARRAY]][state_key]
                fk_ci= @@cities_map[element[@@CITY_ARRAY]] || "NULL"

                file << "(#{index  + 1}, '#{asentamiento}', '#{cp}', #{fk_st}, #{fk_mu}, #{fk_ci})"
                next_line(file, index, last_index)
            end

        end

    end

    def next_line(file, index, last_index)

        if @@row_counter == @@max_lines_to_commit || index == last_index
            file <<  ";\ncommit;\n"
            @@row_counter = 1
        else
            file << ",\n"
            @@row_counter += 1
        end
    end

    def build_child_table(tablename, set, map, parent_tablename, parent_map)

        max_len = get_max_length(set.to_a.transpose[0])

        File.open(@@sql_file_name,'a') do |file|

            file << <<END_HERE

begin;
CREATE TABLE #{@@sql_schema}.#{tablename} 
(id INT PRIMARY KEY,
name VARCHAR(#{max_len}),
fk_#{parent_tablename} INT NULL,
CONSTRAINT  FOREIGN KEY (fk_#{parent_tablename}) REFERENCES #{parent_tablename} (id)
) ENGINE = InnoDB;

commit;

END_HERE

            last_index = set.size - 1
            @@row_counter = 1;

            set.each_with_index do |element, index|

                file << "begin;\nINSERT INTO #{@@sql_schema}.#{tablename} VALUES\n" if @@row_counter == 1

                if element[1].size > 0 
                    fk_index = parent_map[element[1]]
                else
                    fk_index = 'NULL'
                end

                if map[element[0]]
                    map[element[0]][fk_index] =  index + 1
                else
                    map[element[0]] = {fk_index => index + 1}
                end

                file << "(#{index + 1}, '#{element[0]}', #{fk_index})"
                next_line(file, index, last_index)

            end


        end

    end



    def build_simple_table(table_name, set, map)

        max_len = get_max_length(set)

        File.open(@@sql_file_name,'a') do |file|

            file << <<END_HERE

begin;
CREATE TABLE #{@@sql_schema}.#{table_name} 
(id INT PRIMARY KEY,
name VARCHAR(#{max_len})) ENGINE = InnoDB;

commit;

END_HERE

            last_index = set.size - 1
            @@row_counter = 1

            set.each_with_index do |element, index|

                file << "begin;\nINSERT INTO #{@@sql_schema}.#{table_name} VALUES\n" if @@row_counter == 1

                if element.size > 0
                    map[element] = index + 1

                    file << "(#{index + 1}, '#{element}')"
                    next_line(file, index, last_index)
                end
            end

        end
    end


    def get_max_length set
        max = 0;
        set.each {|element| max = element.size if element.size > max }
        max
    end

    def write_end_of_file
        File.open(@@sql_file_name, 'a') do  |file|
            file << "\nSET FOREIGN_KEY_CHECKS=1;"
        end
    end


end

