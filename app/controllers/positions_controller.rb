class PositionsController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @positions = @game.positions
  end
  def show
    @position = Position.find(params[:id])
  end
end
