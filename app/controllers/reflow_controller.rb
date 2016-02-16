class ReflowController < ApplicationController
  def index
    @books = Book.all
  end
  def text
    #Create page text
  end
end
