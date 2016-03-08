class ReflowController < ApplicationController
    def index
        @books = Book.all
    end

    def text
        @pages = Page.where(book_id: params[:id])
        @pageNum = (params[:page] != nil) ? params[:page].to_i : 1
        @hasNext = @pages.length > @pageNum
        @hasPrevious = @pageNum > 1
        @currentPage = @pages.find_by(number: @pageNum)
    end
end
