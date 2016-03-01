module ArchiveHelper
    def download_file_async(source, dest)
        Thread.new(source, dest) do |source, dest|
            #create directories if necessary
            require 'fileutils'

            dirname = File.dirname dest
            unless File.directory? dirname
                FileUtils.mkdir_p(dirname)
            end

            #download the actual file
            require 'open-uri'

            open(dest, 'wb') do |file|
                file << open(source).read
            end
        end
    end

    def unzip(source, dest)
        require 'zip'
        require 'fileutils'

        Zip::File.open(source) do |file|
            file.each do |entry|
                puts entry.name
                # entry.extract
            end
        end
    end

    def ungzip(source, dest)
        require 'zlib'

        Zlib::GzipReader.open(source) do | input_stream |
            File.open(dest, 'w') do |output_stream|
                IO.copy_stream(input_stream, output_stream)
            end
        end
    end

    def download_archive_entry(id)
        Thread.new(id) do |id|
            download_url = 'https://archive.org/download'

            d1 = download_file_async "#{download_url}/#{id}/#{id}_abbyy.gz", Rails.root.join('data', 'books', "#{id}", "#{id}.abbyy.gz").to_s
            d1.join
            ungzip Rails.root.join('data', 'books', "#{id}", "#{id}.abbyy.gz").to_s, Rails.root.join('data', 'books', "#{id}", "#{id}.abbyy").to_s

            # download_file "#{download_url}/#{id}/#{id}_jp2.zip", Rails.root.join('data', 'books', "#{id}", "#{id}.jp2.zip").to_s
            #unzip zip
        end
    end

    def get_json_response(url)
        uri = URI(url)
        response = Net::HTTP.get(uri)
        JSON.parse(response)
    end
end
