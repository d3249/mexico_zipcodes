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

    @@CP_LINE = 0
    @@SETTLEMENT_LINE = 1
    @@SETTLEMENT_TYPE_LINE = 2
    @@MUNICIPALITY_LINE = 3
    @@STATE_LINE = 4
    @@CITY_LINE = 5

    @@CP_ARRAY = 1
    @@SETTLEMENT_ARRAY = 0
    @@SETTLEMENT_TYPE_ARRAY = 2
    @@MUNICIPALITY_ARRAY = 3
    @@STATE_ARRAY = 5
    @@CITY_ARRAY = 4

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


    def load_sets(line, lasts)
        elements = line.split /\|/

        lasts[0] = load_if_different(@@zipcodes         ,[elements[@@CP_LINE], elements[@@CITY_LINE]], lasts[0])
        lasts[1] = load_if_different(@@settlement_types , elements[@@SETTLEMENT_TYPE_LINE], lasts[1])
        lasts[2] = load_if_different(@@municipalities   ,[elements[@@MUNICIPALITY_LINE], elements[@@STATE_LINE]], lasts[2])
        lasts[3] = load_if_different(@@states           , elements[@@STATE_LINE], lasts[3])
        lasts[4] = load_if_different(@@cities           , elements[@@CITY_LINE], lasts[4])

        this_settlement = []

        this_settlement[@@SETTLEMENT_ARRAY] = elements[@@SETTLEMENT_LINE]
        this_settlement[@@CP_ARRAY] = elements[@@CP_LINE]
        this_settlement[@@SETTLEMENT_TYPE_ARRAY] = elements[@@SETTLEMENT_TYPE_LINE]
        this_settlement[@@MUNICIPALITY_ARRAY] = elements[@@MUNICIPALITY_LINE]
        this_settlement[@@STATE_ARRAY] = elements[@@STATE_LINE]
        this_settlement[@@CITY_ARRAY] = elements[@@CITY_LINE]
        
        @@settlements <<  this_settlement

        lasts
    end

    def load_if_different(set, element, last)
        if element != last and element.size > 0

            set << element 
            last = element
        end
        last
    end

end
