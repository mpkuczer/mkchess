class GamesController < ApplicationController
  # before_action :authenticate_user!, except: [:index, :show, :new, :create]
  protect_from_forgery except: :skip_to_position

  def show
    @game = Game.find(params[:id])
    @positions = @game.positions
    @move = []
  end

  def new
    @game = Game.new
    @position = Position.new
    @move = []
  end

  def create
    @game = Game.new(game_params)
    @move = ['x']
    if @game.save
      @position = @game.positions.build(fen: Fen::STARTING_POSITION, order: 1).save
      redirect_to game_path(@game)
    else
      render :new, notice: "Error", status: :unprocessable_entity
    end
  end

  def move
    @position = Position.find(params[:position_id].to_i)
    @game = @position.game
    @move = [ params[:i1].to_i, params[:j1].to_i, params[:i2].to_i, params[:j2].to_i ]

    if @position == @game.positions.order(:order).last
      if @position.validate_move(*@move)
        fen = @position.to_fen(*@move)
        @game.positions.build(fen: fen, order: @position.order + 1).save
        @new_position = @game.positions.order(:order).last
        respond_to do |format|
          format.js { render 'games/new', layout: false, locals: { position: @new_position, move: @move }, status: :ok }
        end
      else
        render json: { error: "Invalid move", offendingPiece: @move[0..1] }, status: :unprocessable_entity
      end
    else
      render json: { error: "Past position" }, status: :unprocessable_entity
    end
  end

  def skip_to_position
    @position = Position.find(params[:position_id].to_i)
    @game = @position.game
    case params[:option].to_sym
    when :start
      @new_position = @game.positions.order(:order).first
    when :previous
      @new_position = @position.order == 1 ? @position : @game.positions.find_by(order: @position.order - 1)
    when :next
      @new_position = @position.order == @game.positions.count ? @position : @game.positions.find_by(order: @position.order + 1)
    when :current
      @new_position = @game.positions.order(:order).last
    end
      respond_to do |format|
        format.js { render 'games/new', layout: false, locals: { position: @new_position } }
      end
  end

  private

  def game_params
    params.require(:game).permit(:white_id, :black_id, :white_type, :black_type, :status)
  end
end
