class GamesController < ApplicationController
  # before_action :authenticate_user!, except: [:index, :show, :pass_and_play, :new, :create]
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
        if @game.positions.build(fen: fen, order: @position.order + 1).save
          @new_position = @game.positions.last
          @move = [params[:i1].to_i,
                  params[:j1].to_i,
                  params[:i2].to_i,
                  params[:j2].to_i]
          respond_to do |format|
            format.js { render 'games/new', layout: false, locals: { position: @new_position } }
          end
        else
          render json: { error: fen }
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
    @new_position = @game.positions.order(:order).first
    respond_to do |format|
      format.js { render 'games/new', layout: false, locals: { position: @new_position } }
      format.html { render 'games/new', layout: false, locals: { position: @new_position } }
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
