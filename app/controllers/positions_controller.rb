class PositionsController < ApplicationController
  def show
    populate_board
  end

  def populate_board
    @position = Position.find(params[:id])
    respond_to do |format|
      format.js { render 'positions/populate_board.js.erb', layout: false, locals: { board: @position.board }}
    end
  end
end
