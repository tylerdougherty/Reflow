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
            # TODO: escape search query (to prevent malicious queries)
            query = "q=\"title:\"#{params[:search]}\" mediatype:\"texts\"\" format:\"Abbyy GZ\" AND format:\"Single Page Processed JP2 ZIP\""
            requested_info = 'fl[]=downloads,format,identifier,title'
            output = 'output=\"json\"'
            sort = 'sort[]=downloads desc'
            rows = "rows=#{page_size}"
            page = "page=#{@page}"

            @json = get_json_response "#{search_url}?#{query}&#{requested_info}&#{output}&#{sort}&#{rows}&#{page}"

            @docs = @json['response']['docs'].each{ |doc|
                book = Book.find_by_archiveID(doc['identifier'])
                if book.nil?
                    doc['status'] = 'none'
                else
                    doc['dbID'] = book.id
                    if book.downloadStatus == "Downloading"
                        doc['status'] = 'downloading'
                    elsif book.downloadStatus == "Done"
                        doc['status'] = 'done'
                    end
                end
                doc['downloaded'] = !Book.find_by_archiveID(doc['identifier']).nil?
            }
            @results = @json['response']['numFound']
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

        # May be unnecessary now but it doesn't hurt to make sure
        if f1.nil? or f2.nil?
            success = false
            message = 'Download failed: Needed files do not exist!'
        else
            download_archive_entry params[:id], f1, f2, @json['metadata']

            success = true
            message = 'Download started...'
        end

        respond_to do |format|
            format.json { render :json => {:success => success, :message => message}}
        end
    end
end
