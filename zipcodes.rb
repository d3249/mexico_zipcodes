#encoding: utf-8


require 'set'
require_relative 'sql_tables'
require_relative 'file_reader'

module Zipcodes

    @@sql_file_name = 'CODIGOS_POSTALES.sql'
   
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

        read_file file
        print_summary_info
        write_output_file
    end

    def read_file file
        file_object = file_iterator file
        read_lines file_object
    end
    
    def print_summary_info
        puts "#{@@settlements.size} asentamientos"
        puts "#{@@zipcodes.size} códigos postales"
        puts "#{@@settlement_types.size} tipos de asentamiento"
        puts "#{@@municipalities.size} municipios"
        puts "#{@@cities.size} ciudades"
        puts "#{@@states.size} estados"
    end




end
