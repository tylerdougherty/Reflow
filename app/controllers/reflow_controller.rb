class ReflowController < ApplicationController
  def index
    @books = Book.all
  end
end
