require 'nokogiri'

class ABBYYFile < Nokogiri::XML::SAX::Document
    def initialize
        @current_word = ''
        @adding_chars = false
        @page_num = 0
        @block_num = 0
        @par_num = 0
        @word_num = 0
        @current_indent = 0

        #constants
        @tab = "\t"
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
            $thml.puts "<page title=\"Page #{@page_num}\" id=\"page_#{@page_num}\">"
            @page_num += 1
        when 'block'
            $thml.puts "<block id=\"block_#{@block_num}\" class=\"#{attributes['blockType']}\">"
            @block_num += 1
        when 'par'
            $thml.puts "<p id=\"p_#{@par_num}\">"
            @par_num += 1
            @line_spacing = attributes.has_key?('lineSpacing') ? attributes['lineSpacing'].to_i : 0
        when 'line'
            @baseline = attributes['baseline'].to_i
        when 'formatting'
            $thml.puts '<span>' #\n<br/>"
            # puts currentWord
        when 'charParams'
            if attributes['wordStart'] == 'true'
                if @current_word != ''
                    print_word
                end
                # $thml.print "<word>"
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

        @current_indent += 1
    end

    def end_element(tag)
        case tag
        when 'page'
            $thml.puts '</page>'
        when 'block'
            $thml.puts '</block>'
        when 'par'
            $thml.puts '</p>'
        when 'formatting'
            if @current_word != ''
                print_word
            end
            $thml.puts '</span>'
        when 'charParams'
            @adding_chars = false
            unless @has_added_chars
                @current_word += ' '
            end
        else
            # don't do anything
        end

        @current_indent -= 1
    end

    def print_word
        # wrapper around words for margin without expanding the word view
        $thml.print "<wrap id=\"wrap_#{@word_num}\">"
        # word itself
        $thml.print "<word id=\"word_#{@word_num}\">#{@current_word}</word>"
        # close the wrapper
        $thml.puts '</wrap>'

        # compute word dimensions
        @right = / $/ =~ @current_word ? @rx : @right
        wl = @left
        wt = @top
        ww = @right - @left
        wh = @bot - @top
        wh = wh > @line_spacing ? @line_spacing : wh
        # css entry for word
        $css.print "#word_#{@word_num} { width:#{ww}px; height:#{wh}px; "
        $css.puts "background-position:-#{wl}px -#{wt}px; } /* #{@current_word} */"
        # compute wrap dimensions if necessary
        if @line_spacing != 0 and wh < @line_spacing
            top_to_baseline = @line_spacing * @baseline_percent
            top_pad = top_to_baseline - (@baseline - @top)
            bot_pad = (@line_spacing - top_to_baseline) - (@bot - @baseline)

            top_pad += @line_spacing - top_pad - bot_pad - wh

            # css entry for wrapper
            $css.puts "#wrap_#{@word_num} { padding:#{top_pad}px #{@lr_padding}px #{bot_pad}px; }"
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

# Make files to write to
$thml = File.open('out.html', 'w')
$css = File.open('out.css', 'w')

# Print an opening tag
$thml.puts '<html>'

print_head

# Set up the parser
parser = Nokogiri::XML::SAX::Parser.new(ABBYYFile.new)
parser.parse_file(File.join('m21.abbyy'))

# Print a closing tag
$thml.puts '</html>'
