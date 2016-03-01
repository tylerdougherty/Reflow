require 'net/http'
require 'json'

class ArchiveController < ApplicationController
    def example
        if params[:search]
            @page = (defined? params[:page]) ? params[:page] : 1

            # Showing the details/metadata of a particular item
            # url = params[:search]
            # uri = URI(url)
            # response = Net::HTTP.get(uri)
            # @json = JSON.parse(response)

            url = "https://archive.org/advancedsearch.php?q=\"title:\"#{params[:search]}\" mediatype:\"texts\"\"&fl[]=downloads,format,identifier,title&output=\"json\"&sort[]=downloads desc&rows=50&page=#{@page}"
            uri = URI(url)
            response = Net::HTTP.get(uri)
            @json = JSON.parse(response)

            @results = @json['response']['numFound']
            @docs = @json['response']['docs'].select { |doc| doc['format'].map{|it| it.downcase.include? 'abbyy'}.include? true } # only take results with Abbyy results
        else
            # nothing right now
        end
    end
end
