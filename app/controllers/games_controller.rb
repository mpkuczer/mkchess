class GamesController < ApplicationController
  # before_action :authenticate_user!, except: [:index, :show, :new, :create]
  protect_from_forgery except: :skip_position

  def show
    @game = Game.find(params[:id])
    @positions = @game.positions
  end

  def new
    @game = Game.new
    @position = Position.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      @position = @game.positions.build(fen: Fen::STARTING_POSITION, order: 1, previous_move: "").save
      redirect_to game_path(@game)
    else
      render :new, notice: "Error", status: :unprocessable_entity
    end
  end

  def move
    @position = Position.find(params[:position_id].to_i)
    @game = @position.game
    @move = [ params[:i1].to_i, params[:j1].to_i, params[:i2].to_i, params[:j2].to_i ]

    unless @position == @game.positions.order(:order).last
      render json: { error: "Past position" }
      return
    end
    unless @position.validate_move(*@move)
      render json: { error: "Invalid move", offendingPiece: @move[0..1] }
      return
    end

    fen = @position.to_fen(*@move)
    @game.positions.build(fen: fen,
                          order: @position.order + 1,
                          previous_move: @move.join).save
    @new_position = @game.positions.order(:order).last

    if @new_position.checkmate
      @game.status = :finished
      respond_to do |format|
        format.js { render 'games/game_over', layout: false,
                                              locals: { position: @new_position,
                                                        winner: @position.get_active_color.to_s },
                                              status: :ok }
      end
    elsif @new_position.stalemate
      @game.status = :finished
      respond_to do |format|
        format.js { render 'games/game_over', layout: false,
                                              locals: { position: @new_position,
                                                        winner: "draw" },
                                              status: :ok }
      end
    else
      respond_to do |format|
        format.js { render 'games/new', layout: false, locals: { position: @new_position }, status: :ok }
      end
    end
  end

  def skip_position
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
