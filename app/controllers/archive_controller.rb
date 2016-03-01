require 'net/http'
require 'json'

class ArchiveController < ApplicationController
    def example
        if params[:search]
            @page = (params[:page] != nil) ? params[:page].to_i : 1

            search_url = 'https://archive.org/advancedsearch.php'
            query = "q=\"title:\"#{params[:search]}\" mediatype:\"texts\"\""
            requested_info = 'fl[]=downloads,format,identifier,title'
            output = 'output=\"json\"'
            sort = 'sort[]=downloads desc'
            rows = 'rows=50'
            page = "page=#{@page}"
            @json = get_json_response "#{search_url}?#{query}&#{requested_info}&#{output}&#{sort}&#{rows}&#{page}"

            @results = @json['response']['numFound']
            @docs = @json['response']['docs'].select { |doc| doc['format'].map{|it| it.downcase.include? 'abbyy'}.include? true } # only take results with Abbyy results
            @has_next = @results > @page*50
            @has_prev = @page > 1
        else
            # nothing right now
        end
    end

    def download
        @json = get_json_response "https://archive.org/metadata/#{params[:id]}"

        @files = @json['files']

        @files.each do |file|
            if file['name'].include? '.gz'
                require 'open-uri'
                open ''
            end
        end
    end

    def get_json_response(url)
        uri = URI(url)
        response = Net::HTTP.get(uri)
        JSON.parse(response)
    end
end
