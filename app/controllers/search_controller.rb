class SearchController < ApplicationController
        def search
                if params[:search]
                        @definition = Wordnik.word.get_definitions(params[:search],:part_of_speech => 'noun,adjective,verb,adverb,interjection,pronoun,preposition,noun-plural,past-participle,proper-noun,verb-intransitive,verb-transitive')
                        @definitions = @definition.uniq {|e| e['partOfSpeech'] } 
                        @word = params[:search]
                        @pronounciation_url = "http://api.wordnik.com:80/v4/word.json/#{params[:search]}/pronunciations?useCanonical=false&api_key=#{Wordnik.configuration.api_key}"
                        pro_buffer = RestClient.get @pronounciation_url
                        @pro_results = JSON.parse(pro_buffer)
                        @related_url = "http://api.wordnik.com:80/v4/word.json/#{params[:search]}/relatedWords?useCanonical=false&limitPerRelationshipType=10&api_key=#{Wordnik.configuration.api_key}"
                        rel_buffer = RestClient.get @related_url
                        @rel_results = JSON.parse(rel_buffer)
                        @top_url = "http://api.wordnik.com:80/v4/word.json/#{params[:search]}/topExample?useCanonical=false&api_key=#{Wordnik.configuration.api_key}"
                        top_buffer = RestClient.get @top_url
                        @top_results = JSON.parse(top_buffer)
                        @example_url = "http://api.wordnik.com:80/v4/word.json/#{params[:search]}/examples?includeDuplicates=false&useCanonical=false&skip=0&api_key=#{Wordnik.configuration.api_key}"
                        example_buffer = RestClient.get @example_url
                        @example_results = JSON.parse(example_buffer)
                        @audio_url = "http://api.wordnik.com:80/v4/word.json/#{params[:search]}/audio?includeDuplicates=false&useCanonical=false&skip=0&api_key=#{Wordnik.configuration.api_key}"
                        audio_buffer = RestClient.get @audio_url
                        @audio_results = JSON.parse(audio_buffer)
                        @picture_url = "https://openclipart.org/search/json/?query=#{params[:search]}&amount=20"
                        pic_buffer = RestClient.get @picture_url
                        @pic_results = JSON.parse(pic_buffer)
                        @image = @pic_results['payload'][0]['svg']['png_thumb']
                        @image2 = @pic_results['payload'][1]['svg']['png_thumb']
                        @image3 = @pic_results['payload'][2]['svg']['png_thumb']
                        @image4 = @pic_results['payload'][3]['svg']['png_thumb']
                        @image5 = @pic_results['payload'][4]['svg']['png_thumb']
                        @xml = Nokogiri::XML(open("http://www.dictionaryapi.com/api/v1/references/sd2/xml/#{params[:search]}?key=42c43bc1-6d57-4fba-8453-2c6886a96a42"))

                else
                end

        end
        def convert_pdf
                definitions_count = params["definitions_count"]
                pronounciations_count = params["pronounciations_count"]
                related_words_count = params["related_words_count"]
                top_example = params["top_example"]
                examples_count = params["examples_count"]
                mw_dictionaries_count = params["mw_dictionaries_count"]
                pictures_count = params["pictures_count"]
                puts definitions_count
                respond_to do |format|
                        format.pdf do
                                pdf = Prawn::Document.new(:page_layout => :landscape)
                                        pdf.move_down(30)
                                        pdf.text params['word'].titleize, :size => 30
                                        pdf.move_down(30)
                                #Definition
                                        a = 0
                                        (0..definitions_count.to_i).each do |count|
                                            if params["part_of_speech_#{count}_check"] == "1"
                                              if a == 0
                                                pdf.text "Definition", :size => 20
                                                pdf.stroke_horizontal_rule
                                                pdf.move_down(20)
                                              end
                                                definition = eval(params["part_of_speech_#{count}"])
                                                pdf.text "#{definition['partOfSpeech']} - #{definition['text']}" 
                                              a=a+1
                                            end
                                        end
                                 #Pronounciation
                                        b = 0
                                        (0..pronounciations_count.to_i).each do |count|
                                          if params["raw_type_#{count}_check"] == "1"
                                            if b == 0
                                              pdf.move_down(40)
                                              pdf.text "Pronounciation", :size => 20
                                              pdf.stroke_horizontal_rule
                                            end
                                            pdf.move_down(20)
                                            pronounciations = eval(params["raw_type_#{count}"])
                                            pdf.text "#{pronounciations['rawType']}" #- #{pronounciations['raw']}" 
                                            b = b+1
                                          end
                                        end
                                        #Related Words
                                        e = 0
                                        (0..related_words_count.to_i).each do |count|                                        
                                          if params["relationship_type_#{count}_check"] == "1"
                                            if e == 0
                                              pdf.move_down(40)
                                              pdf.text "Related Words", :size => 20
                                              pdf.stroke_horizontal_rule
                                            end
                                            pdf.move_down(20)
                                            related_words = eval(params["relationship_type_#{count}"])
                                            pdf.text "#{related_words['relationshipType']} = #{related_words['words'].join(",")}"
                                            e = e+1
                                          end
                                        end
                                        if params['top_example_check'] == "1"
                                        pdf.move_down(40)
                                        pdf.text "Top Examples", :size => 20
                                        pdf.stroke_horizontal_rule
                                                pdf.move_down(20)
                                                pdf.text top_example
                                        end

                                       puts "examples_check"
                                        c = 0
                                        pdf.move_down(40)
                                        (0..examples_count.to_i).each do |count|
                                          if params["example_#{count}_check"] == "1"
                                            if c == 0
                                              pdf.text "Examples", :size => 20
                                              pdf.stroke_horizontal_rule
                                              pdf.move_down(20)
                                            end
                                            examples = eval(params["example_#{count}"])
                                            pdf.text examples['text']
                                            pdf.move_down(10)
                                            c = c+1
                                          end
                                        end

                                        g = 0
                                        pdf.move_down(40)
                                        (0..mw_dictionaries_count.to_i).each do |count|
                                          if params["hw_#{count}_check"] == "1"
                                            if g == 0
                                              pdf.text "My Dictionary API", :size => 20
                                              pdf.stroke_horizontal_rule
                                            end
                                            pdf.move_down(20)
                                            pdf.text  params["hw_#{count}"].to_s
                                          end
                                          g = g+1
                                        end

                                        d = 0
                                        pdf.move_down(40)
                                        if pdf.cursor < 100
                                          pdf.start_new_page
                                        end
                                        x,y = 0, pdf.cursor-50

                                        (0..pictures_count.to_i).each do |count|
                                          if params["picture_#{count}_check"] == "1"
                                            if d == 0
                                              pdf.text "Pictures", :size => 20
                                              pdf.stroke_horizontal_rule 
                                            end
                                            pdf.move_down(20)
                                            pictures = eval(params["picture_#{count}"])
                                            begin
                                              size=100
                                              if x < 650
                                                pdf.bounding_box([x,y], :width => size, :height => size) do
                                                  pdf.image open(pictures['svg']['png_thumb'] ),:fit => [size, size]
                                                  x = x+120
                                                end
                                              else
                                                if pdf.cursor < 50
                                                  pdf.start_new_page
                                                end
                                                x = 0
                                                y = pdf.cursor 
                                                pdf.bounding_box([x,y], :width => size, :height => size) do
                                                  pdf.image open(pictures['svg']['png_thumb'] ),:fit => [size, size]
                                                  x = x+120                                                
                                                end
                                              end
                                            rescue
                                              next
                                            end
                                            d = d+1
                                          end
                                        end
                                send_data(pdf.render, filename: "dictionary_report.pdf",
                                  type: "application/pdf")

                        end


                end
        end
end
