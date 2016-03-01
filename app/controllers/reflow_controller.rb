class ReflowController < ApplicationController
  def index
      @books = Book.all
  end
  def text
      @books = Book.all
      @pages = Page.joins(:book).where('books.id' => request.original_url.split('/').last )
  end
end
