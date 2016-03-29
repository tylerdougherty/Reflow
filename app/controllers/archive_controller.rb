require 'net/http'
require 'json'

class ArchiveController < ApplicationController
    include ArchiveHelper

    skip_before_action :verify_authenticity_token, only: [:download]

    def example
        if params[:search]
            @page = (params[:page] != nil) ? params[:page].to_i : 1

            page_size = 50

            search_url = 'https://archive.org/advancedsearch.php'
            # TODO: escape search query
            query = "q=\"title:\"#{params[:search]}\" mediatype:\"texts\"\""
            requested_info = 'fl[]=downloads,format,identifier,title'
            output = 'output=\"json\"'
            sort = 'sort[]=downloads desc'
            rows = "rows=#{page_size}"
            page = "page=#{@page}"
            @json = get_json_response "#{search_url}?#{query}&#{requested_info}&#{output}&#{sort}&#{rows}&#{page}"

            @docs = @json['response']['docs'].select { |doc| doc['format'].map{|it| it.downcase.include? 'abbyy'}.include? true } # only take results with Abbyy results
            @results = @docs.count
            @has_next = @results > @page*page_size
            @has_prev = @page > 1
        else
            # nothing right now
        end
    end

    def download
        @json = get_json_response "https://archive.org/metadata/#{params[:id]}"
        @files = @json['files']

        f1 = @files.each.select{|x| x['format'] == 'Abbyy GZ'}[0]['name']
        f2 = @files.each.select{|x| x['format'] == 'Single Page Processed JP2 ZIP'}[0]['name']

        # TODO: error handling if we don't have both file types

        download_archive_entry params[:id], f1, f2

        result = 'download started'
        respond_to do |format|
            format.json { render :json => {:result => result}}
        end
    end
end
