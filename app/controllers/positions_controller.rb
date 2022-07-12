class PositionsController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
    @positions = @game.positions
  end
  def show
    @position = Position.find(params[:id])
  end
  def legal_squares
    @piece = [ params[:i].to_i, params[:j].to_i ]
    @position = Position.find(params[:id])
    @squares = @position.legal_squares(*@piece)
    respond_to do |format|
      format.json { render json: { squares: @squares }}
    end
  end
end
