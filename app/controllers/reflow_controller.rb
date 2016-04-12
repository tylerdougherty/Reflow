class ReflowController < ApplicationController
    def index
        @books = Book.all
    end

    def text
        begin
            #this doesn't work right now.... not sure what it was supposed to do actually
            book = Book.where(archiveID: params[:id])
            @archive_id = book.archiveID
        rescue
            #nothing
        end

        @pages = Page.where(book_id: params[:id])
        @pageNum = (params[:page] != nil) ? params[:page].to_i : 1
        @hasNext = @pages.length > @pageNum
        @hasPrevious = @pageNum > 1
        @currentPage = @pages.find_by(number: @pageNum)
    end

    def css
        page = Page.where(book_id: params[:id], number: params[:page])

        respond_to do |format|
            format.html { render :text => page.first.css, :content_type => 'text/css' }
        end
    end
end
