require 'net/http'
require 'json'

class ArchiveController < ApplicationController
    include ArchiveHelper

    def example
        if params[:search]
            @page = (params[:page] != nil) ? params[:page].to_i : 1

            page_size = 50

            search_url = 'https://archive.org/advancedsearch.php'
            query = "q=\"title:\"#{params[:search]}\" mediatype:\"texts\"\""
            requested_info = 'fl[]=downloads,format,identifier,title'
            output = 'output=\"json\"'
            sort = 'sort[]=downloads desc'
            rows = "rows=#{page_size}"
            page = "page=#{@page}"
            @json = get_json_response "#{search_url}?#{query}&#{requested_info}&#{output}&#{sort}&#{rows}&#{page}"

            @results = @json['response']['numFound']
            @docs = @json['response']['docs'].select { |doc| doc['format'].map{|it| it.downcase.include? 'abbyy'}.include? true } # only take results with Abbyy results
            @has_next = @results > @page*page_size
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
                download_archive_entry params[:id]
            end
        end
    end
end
