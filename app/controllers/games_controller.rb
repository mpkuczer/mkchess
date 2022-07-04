class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :guest]
  def show
    @game = Game.find(params[:id])
    @positions = @game.positions
  end

  def guest
    @guest = Guest.create
    @computer = Computer.create
    colors = [@guest, @computer].shuffle
    @game = Game.new(white_id: colors[0].id,
                     black_id: colors[1].id,
                     white_type: colors[0].class.name,
                     black_type: colors[1].class.name,
                     status: 0)
    @game.positions.build(Position.starting)
    if @game.save 
      redirect_to game_path(@game)
    else
      render :index, status: :unprocessable_entity
    end
  end
end
