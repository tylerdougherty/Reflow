class ReflowController < ApplicationController
  def index
      @books = Book.all
  end
  def text
      @books = Book.all
      @pages = Page.joins(:book).where('books.id' => request.original_url.split('/').last )
      page = "page=#{@currentPage}"
      @pageNum = (params[:page] != nil) ? params[:page].to_i : 1
      @hasNext = @pages.length > @pageNum
      @hasPrevious = @pageNum > 1
      @currentPage = @pages.find_by(number: @pageNum)
  end
end
