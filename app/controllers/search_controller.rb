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
		else
		end
	end
end
