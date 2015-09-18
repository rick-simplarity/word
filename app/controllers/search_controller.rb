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
                definitions = params["definitions"]
                pronounciations = params["pronounciations"]
                related_words = params["related_words"]
                top_example = params["top_example"]
                examples = params["examples"]

                puts definitions
                respond_to do |format|
                        format.pdf do
                                pdf = Prawn::Document.new
                                        pdf.move_down(30)
                                        pdf.text params['word'], :size => 30
                                        pdf.move_down(30)
                                #Definition
                                        if params['definition_check'] == "1"
                                        pdf.text "Definition", :size => 20
                                        pdf.stroke_horizontal_rule
                                        definitions.each do|d|
                                                pdf.move_down(20)
                                                definition = eval(d)
                                                pdf.text "#{definition['partOfSpeech']} - #{definition['text']}" 
                                                
                                        end
                                        end
                                        pdf.move_down(40)
                                 #Pronounciation
                                        if params['pronounciation_check'] == "1"
                                        pdf.text "Pronounciation", :size => 20
                                        pdf.stroke_horizontal_rule
                                        pronounciations.each do|p|
                                                pdf.move_down(20)
                                                pronounciations = eval(p)
                                                pdf.text "#{pronounciations['rawType']}" #- #{pronounciations['raw']}" 
                                        end
                                        
                                        end
                                        pdf.move_down(40)
                                        #Related Words
                                        if params['related_words_check'] == "1"
                                        pdf.text "Related Words", :size => 20
                                        pdf.stroke_horizontal_rule
                                        related_words.each do|r|
                                                pdf.move_down(20)
                                                related_words = eval(r)
                                                pdf.text "#{related_words['relationshipType']} = #{related_words['words'].join(",")}"
                                        end
                                        
                                        end
                                        pdf.move_down(40)
                                        if params['top_example_check'] == "1"
                                        pdf.text "Top Examples", :size => 20
                                        pdf.stroke_horizontal_rule
                                                pdf.move_down(20)
                                                pdf.text top_example
                                        end
                                       puts "examples_check #{params['examples_check']}"
                                        if params['examples_check'] == "1"
                                        pdf.text "Examples", :size => 20
                                        pdf.stroke_horizontal_rule
                                        examples.each do|e|
                                                pdf.move_down(20)
                                                examples = eval(e)
                                                pdf.text examples['text']
                                        end
                                        
                                        end
                                send_data pdf.render, filename: "dictnory_report.pdf",
                                  type: "application/pdf",
                                   disposition: "inline"

                        end


                end
        end
end
