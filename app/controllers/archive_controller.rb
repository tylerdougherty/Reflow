require 'net/http'
require 'json'

class ArchiveController < ApplicationController
    def example
        if params[:search]
            url = params[:search]
            uri = URI(url)
            response = Net::HTTP.get(uri)
            @json = JSON.parse(response)
        else
            # nothing right now
        end
    end
end
