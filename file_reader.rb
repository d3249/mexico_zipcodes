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

        lasts[0] = load_if_different(@@zipcodes         ,[elements[0], elements[5]], lasts[0])
        lasts[1] = load_if_different(@@settlement_types , elements[2]              , lasts[1])
        lasts[2] = load_if_different(@@municipalities   ,[elements[3], elements[4]], lasts[2])
        lasts[3] = load_if_different(@@states           , elements[4]              , lasts[3])
        lasts[4] = load_if_different(@@cities           , elements[5]              , lasts[4])
        
        @@settlements << [elements[1], elements[0], elements[2], elements[3], elements[5]]

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
