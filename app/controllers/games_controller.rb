class GamesController < ApplicationController
  before_action: :authenticate_user!, except: [:index, :show, :guest_new]
  def show
  end

  # def new
  #   @game = Game.new
  # end
end
