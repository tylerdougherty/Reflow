module ArchiveHelper
    def errors
        @error_logger ||= Logger.new("#{Rails.root}/log/errors.log")
    end

    def download_file_async(source, dest)
        Thread.new(source, dest) do |source, dest|
            begin
                puts "--> downloading #{source}"

                #create directories if necessary
                require 'fileutils'

                dirname = File.dirname dest
                unless File.directory? dirname
                    FileUtils.mkdir_p(dirname)
                end

                #download the actual file
                require 'open-uri'

                open(source, 'r') do |fin|
                    open(dest, 'wb') do |fout|
                        while (buf = fin.read(8192))
                            fout.write buf
                        end
                    end
                end

                puts "--> downloaded to #{dest}"
            rescue Exception => e
                errors.debug e.message
                errors.debug e.backtrace.inspect
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

    def convert_images(archive_id)
        puts '--> converting images'

        jp2s = Dir.glob Rails.root.join('data', 'books', "#{archive_id}", "#{archive_id}_jp2", '*.jp2')

        require 'rmagick'

        jp2s.each do |jp2_file|
            jp2 = Magick::ImageList.new jp2_file
            png = jp2.threshold 0.4*Magick::QuantumRange

            #write png
        end

        puts '--> images converted'
    end

    def download_archive_entry(identifier, abbyy, jp2, metadata_hash)
        Thread.new(identifier, abbyy, jp2, metadata_hash) do |archive_id, abbyy_file, jp2_file, metadata|
            begin
                b = Book.create(:title => metadata['title'], :archiveID => "#{archive_id}", :author => metadata['creator'], :description => metadata['description'] || 'Not listed')

                download_url = 'https://archive.org/download'

                d1 = download_file_async "#{download_url}/#{archive_id}/#{abbyy_file}", Rails.root.join('data', 'books', "#{archive_id}", "#{archive_id}.abbyy.gz").to_s
                d2 = download_file_async "#{download_url}/#{archive_id}/#{jp2_file}", Rails.root.join('data', 'books', "#{archive_id}", "#{archive_id}_jp2.zip").to_s

                d1.join
                d2.join

                ungzip Rails.root.join('data', 'books', "#{archive_id}", "#{archive_id}.abbyy.gz").to_s, Rails.root.join('data', 'books', "#{archive_id}", "#{archive_id}.abbyy").to_s
                unzip Rails.root.join('data', 'books', "#{archive_id}", "#{archive_id}_jp2.zip").to_s, Rails.root.join('data', 'books', "#{archive_id}").to_s

                convert_images archive_id

                require Rails.root.join('scripts', 'xmltothml.rb')

                insert_abbyy_to_db(archive_id, b.id)

                #TODO: delete unneeded files
            rescue Exception => e
                errors.debug e.message
                errors.debug e.backtrace.inspect
            end
        end
    end

    def get_json_response(url)
        uri = URI(url)
        response = Net::HTTP.get(uri)
        JSON.parse(response)
    end
end
