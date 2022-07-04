class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :guest]
  def show
  end

  def guest
    @game = Game.new
  end
end
