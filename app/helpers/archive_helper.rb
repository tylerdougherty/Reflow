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

        puts '--> unzipping file'
        Zip::File.open(source) do |zip_file|
            zip_file.each do |entry|
                entry.extract("#{dest}/#{entry.name}")
            end
        end
        puts '--> unzipped file'
    end

    def ungzip(source, dest)
        require 'zlib'

        puts '--> unzipping file'
        Zlib::GzipReader.open(source) do |input_stream|
            File.open(dest, 'w') do |output_stream|
                IO.copy_stream(input_stream, output_stream)
            end
        end
        puts '--> unzipped file'
    end

    def download_archive_entry(identifier, abbyy_file, jp2_file)
        Thread.new(identifier) do |id|
            download_url = 'https://archive.org/download'

            puts '--> downloading abbyy file'
            d1 = download_file_async "#{download_url}/#{id}/#{abbyy_file}", Rails.root.join('data', 'books', "#{id}", "#{id}.abbyy.gz").to_s

            puts '--> downloading page images'
            d2 = download_file_async "#{download_url}/#{id}/#{jp2_file}", Rails.root.join('data', 'books', "#{id}", "#{id}_jp2.zip").to_s

            d1.join
            d2.join
            puts '--> downloaded abbyy file'
            puts '--> downloaded page images'

            ungzip Rails.root.join('data', 'books', "#{id}", "#{id}.abbyy.gz").to_s, Rails.root.join('data', 'books', "#{id}", "#{id}.abbyy").to_s
            unzip Rails.root.join('data', 'books', "#{id}", "#{id}_jp2.zip").to_s, Rails.root.join('data', 'books', "#{id}").to_s
        end
    end

    def get_json_response(url)
        uri = URI(url)
        response = Net::HTTP.get(uri)
        JSON.parse(response)
    end
end
