require 'nokogiri'

class ABBYYFile < Nokogiri::XML::SAX::Document
    def initialize
        @current_page_html = ''
        @current_page_css = ''
        @just_text = true

        @current_word = ''
        @adding_chars = false
        @page_num = 0
        @block_num = 0
        @par_num = 0
        @word_num = 0

        #constants
        @lr_padding = 4
        @baseline_percent = 2.0/3.0

        reset_dimensions
    end

    def reset_dimensions
        @left = 999999
        @right = 0
        @rx = 0
        @top = 999999
        @bot = 0
    end

    def start_element(tag, attributes)
        attributes = attributes.to_h # The info in the tag

        case tag
        when 'page'
            add_html_line "<page title=\"Page #{@page_num}\" id=\"page_#{@page_num}\">"

            @page_num += 1
        when 'block'
            add_html_line "<block id=\"block_#{@block_num}\" class=\"#{attributes['blockType']}\">"
            @block_num += 1
        when 'par'
            add_html_line "<p id=\"p_#{@par_num}\">"
            @par_num += 1
            @line_spacing = attributes.has_key?('lineSpacing') ? attributes['lineSpacing'].to_i : 0
        when 'line'
            @baseline = attributes['baseline'].to_i
        when 'formatting'
            add_html_line '<span>'   # TODO: finish handling at some point
        when 'charParams'
            if attributes['wordStart'] == 'true'
                if @current_word != ''
                    print_word
                end
            end
            @rx = @right
            @left = attributes['l'].to_i < @left ? attributes['l'].to_i : @left
            @right = attributes['r'].to_i > @right ? attributes['r'].to_i : @right
            @top = attributes['t'].to_i < @top ? attributes['t'].to_i : @top
            @bot = attributes['b'].to_i > @bot ? attributes['b'].to_i : @bot
            @adding_chars = true # the characters function picks up all whitespace in the file otherwise
            @has_added_chars = false # Figures out if this charParam is a space
        else
            # don't do anything
        end
    end

    def end_element(tag)
        case tag
        when 'page'
            add_html_line '</page>'
            put_page
        when 'block'
            add_html_line '</block>'
        when 'par'
            add_html_line '</p>'
        when 'formatting'
            if @current_word != ''
                print_word
            end
            add_html_line '</span>'
        when 'charParams'
            @adding_chars = false
            unless @has_added_chars
                @current_word += ' '
            end
        else
            # don't do anything
        end
    end

    def add_html_line(text)
        @current_page_html += "\n"
        @current_page_html += text
    end

    def add_css_line(text)
        @current_page_css += "\n"
        @current_page_css += text
    end

    def put_page
        @current_page_css = "word { background-image:url(/book/#{$book_id}/page/#{@page_num}/image); }\n" + @current_page_css

        Page.create(:book_id => $book_id, :text => @current_page_html, :css => @current_page_css, :number => @page_num)

        # #create directories if necessary
        # require 'fileutils'
        #
        # # TODO: switch this back to the data directory
        # css_filename = Rails.root.join('data', 'books', $archive_id, 'stylesheets', "#{@page_num}.css")
        # dirname = File.dirname css_filename
        # unless File.directory? dirname
        #     FileUtils.mkdir_p(dirname)
        # end
        #
        # File.open(css_filename, 'w') do |cssout|
        #     cssout.puts "#{$archive_id}_#{@page_num.to_s.rjust(4, '0')}.jp2"
        # end

        @current_page_html = ''
        @current_page_css = ''
    end

    def print_word
        # wrapper around words for margin without expanding the word view
        add_html_line "<wrap id=\"wrap_#{@word_num}\">"
        # word itself
        add_html_line "<word id=\"word_#{@word_num}\">#{@current_word}</word>"
        # close the wrapper
        add_html_line '</wrap>'

        # compute word dimensions
        @right = / $/ =~ @current_word ? @rx : @right
        wl = @left
        wt = @top
        ww = @right - @left
        wh = @bot - @top
        wh = (wh > @line_spacing and @line_spacing != 0) ? @line_spacing : wh
        # word height on the word element just chooses how much of the background shows up, while
        #   on the wrap element it is the actual size on the page

        # css entry for word
        add_css_line "#word_#{@word_num} { width:#{ww}px; height:#{wh}px; "
        add_css_line "background-position:-#{wl}px -#{wt}px; } /* #{@current_word} */"

        # compute wrap dimensions if necessary
        if @line_spacing != 0 and wh < @line_spacing
            top_to_baseline = @line_spacing * @baseline_percent
            top_pad = top_to_baseline - (@baseline - @top)
            bot_pad = (@line_spacing - top_to_baseline) - (@bot - @baseline)

            top_pad += @line_spacing - top_pad - bot_pad - wh

            # css entry for wrapper
            add_css_line "#wrap_#{@word_num} { padding:#{top_pad}px #{@lr_padding}px #{bot_pad}px; height:#{@line_spacing}px; }"
        end

        # misc. stuff
        @word_num += 1
        @current_word = ''
        reset_dimensions
    end

    def characters(string)
        if @adding_chars
            if string == '&'
                string = '&amp;'
            elsif string == '<'
                string = '&lt;'
            elsif string == '>'
                string = '&gt;'
            end
            @current_word += string
            @has_added_chars = true
        end
    end
end

def print_head
    $thml.puts '<head>'
    $thml.puts "<link rel=\"stylesheet\" href=\"out.css\">"
    $thml.puts "<meta charset=\"UTF-8\">"
    $thml.puts '</head>'

    $css.puts 'word { background-image:url(m21.png); background-size:2718; }'
end

def insert_abbyy_to_db(archive_id, book_id)
    puts '--> converting to html'

    $book_id = book_id
    $archive_id = archive_id

    parser = Nokogiri::XML::SAX::Parser.new(ABBYYFile.new)
    file = Rails.root.join('data', 'books', "#{archive_id}", "#{archive_id}.abbyy").to_s
    parser.parse_file(file)

    puts '--> html converted and inserted to db'
end

# # Make files to write to
# $thml = File.open('out.html', 'w')
# $css = File.open('out.css', 'w')
#
# # Print an opening tag
# $thml.puts '<html>'
#
# print_head
#
# # Set up the parser
# parser = Nokogiri::XML::SAX::Parser.new(ABBYYFile.new)
# parser.parse_file(File.join('m21.abbyy'))
#
# # Print a closing tag
# $thml.puts '</html>'
