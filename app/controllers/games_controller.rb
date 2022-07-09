class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :pass_and_play, :new, :create]

  def show
    @game = Game.find(params[:id])
    @positions = @game.positions
  end

  def new
    @game = Game.new
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

  def move(i1, j1, i2, j2)
    @game = Game.find(params[:id])
    @position = @game.positions.last 
    # Return a position object after making a move
    if @position.validate_move(i1, j1, i2, j2)
      next_board = @position.board
      next_board[i2-1][j2-1] = @position.get_square(i1, j1)
      next_fen = next_board.to_fen
      @game.positions.build(fen: next_fen, order: @game.positions.count + 1)
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
