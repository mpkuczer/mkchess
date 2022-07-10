class GamesController < ApplicationController
  # before_action :authenticate_user!, except: [:index, :show, :new, :create]
  protect_from_forgery except: :skip_to_position

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
      @position = @game.positions.build(fen: Fen::STARTING_POSITION, order: 1).save
      redirect_to game_path(@game)
    else
      render :new, notice: "Error", status: :unprocessable_entity
    end
  end

  def move
    @position = Position.find(params[:position_id].to_i)
    @game = @position.game

    if @position == @game.positions.order(:order).last
      if @position.validate_move(params[:i1].to_i,
                                 params[:j1].to_i,
                                 params[:i2].to_i,
                                 params[:j2].to_i)
        fen = @position.to_fen(params[:i1].to_i,
                              params[:j1].to_i,
                              params[:i2].to_i,
                              params[:j2].to_i)
        @game.positions.build(fen: fen, order: @position.order + 1).save
        @new_position = @game.positions.last
        @move = [params[:i1].to_i,
                params[:j1].to_i,
                params[:i2].to_i,
                params[:j2].to_i]
        respond_to do |format|
          format.js { render 'games/new', layout: false, locals: { position: @new_position } }
        end
      else
        render json: { error: "Invalid move" }
      end
    else
      render json: { error: "Past position" }
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
      byebug
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
