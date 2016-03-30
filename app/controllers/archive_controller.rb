require 'net/http'
require 'json'

class ArchiveController < ApplicationController
    include ArchiveHelper

    skip_before_action :verify_authenticity_token, only: [:download]

    def search
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

            # TODO: FIX THIS SEARCH WHEN IT WORKS ON ARCHIVE.ORG AGAIN
            @docs = @json['response']['docs'].select { |doc| doc['format'].map{|it| it.downcase.include? 'abbyy'}.include? true }
            @results = @docs.count # TODO: <---------
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

        if f1.nil? or f2.nil?
            success = false
            message = 'Download failed: Needed files do not exist!'
        else
            download_archive_entry params[:id], f1, f2

            success = true
            message = 'Download started...'
        end

        respond_to do |format|
            format.json { render :json => {:success => success, :message => message}}
        end
    end
end
