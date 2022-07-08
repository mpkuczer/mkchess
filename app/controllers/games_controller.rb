class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :pass_and_play]

  def show
    @game = Game.find(params[:id])
    @positions = @game.positions
  end

  def create
    @game = Game.new(game_params)
    @position = @game.positions.build(fen: Fen::STARTING_POSITION,
                                      order: 1)
    if @game.save
      redirect_to game_path(@game), notice: "Game created successfully."
    else
      render :new, notice: "Error", status: :unprocessable_entity
    end
  end

  def pass_and_play
    @player_one = Guest.create
    @player_two = Guest.create
    colors = [@player_one, @player_two].shuffle
    @game = Game.new(white_id: colors[0].id,
                     black_id: colors[1].id,
                     white_type: colors[0].class.name,
                     black_type: colors[1].class.name,
                     status: 0)
    @game.positions.build.save
    if @game.save 
      redirect_to game_path(@game)
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def game_params
    params.require(:game).permit(:white_id, :black_id, :white_type, :black_type, :status)
  end
end
