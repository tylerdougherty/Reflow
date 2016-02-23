require 'net/http'
require 'json'

class ArchiveController < ApplicationController
    def example
        if params[:search]
            # url = params[:search]
            # uri = URI(url)
            # response = Net::HTTP.get(uri)
            # @json = JSON.parse(response)

            url = 'https://archive.org/advancedsearch.php?q="title:"moby dick" mediatype:"texts""&fl[]=downloads,format,identifier,title&output="json"&sort[]=downloads desc&rows=50&page=1'
            uri = URI(url)
            response = Net::HTTP.get(uri)
            @json = JSON.parse(response)

            @results = @json['response']['numFound']
            @docs = @json['response']['docs']
        else
            # nothing right now
        end
    end
end
