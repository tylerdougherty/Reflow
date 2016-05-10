class ReflowController < ApplicationController
    def index
        @books = Book.all
    end

    def text
        @pages = Page.where(book_id: params[:id])
        @page_num = (params[:page] != nil) ? params[:page].to_i : 1
        @has_next = @pages.length > @page_num
        @has_previous = @page_num > 1
        @current_page = @pages.find_by(number: @page_num)
    end

    def css
        page = Page.where(book_id: params[:id], number: params[:page])

        respond_to do |format|
            format.html { render :text => page.first.css, :content_type => 'text/css' }
        end
    end

    def image
        archive_id = Book.where(id:params[:id]).first.archiveID
        image_num = params[:page].to_s.rjust(4,'0')

        send_file Rails.root.join('data', 'books', "#{archive_id}", 'images', "#{image_num}.png"), type: 'image/png', disposition: 'inline'
    end
end
