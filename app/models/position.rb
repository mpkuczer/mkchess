class Position < ApplicationRecord
  belongs_to :game
  validates :order, presence: true, uniqueness: { scope: :game_id }
  validate :well_formed_fen
  validate :correct_board_size

  LETTERS = 'abcdefgh'

  # Retrieval of data from FEN begins here"
  def get_state_from_fen
    fen.match Fen::REGEX
  end

  def board
    board = []
    get_state_from_fen[1..8].each do |row|
      rank = []
      row.split("").each do |char|
        case char
        when /\d/
          char.to_i.times { rank.push(nil) }
        when /\w/
          rank.push(char)
        end
      end
      board.push(rank)
    end
    board 
  end

  def get_active_color
    get_state_from_fen[9].to_sym
  end

  def get_castling_rights
    get_state_from_fen[10].to_sym
  end

  def get_en_passant_square
    ep = get_state_from_fen[11]
  end
  def get_half_moves
    half_moves = get_state_from_fen[12].to_i
  end

  def get_full_moves
    full_moves = get_state_from_fen[13].to_i
  end

  def state
    [board, get_active_color, get_castling_rights, get_en_passant_square, get_half_moves, get_full_moves]
  end

# Retrieval of data from FEN ends here"

# Spatial getters

  def in_bounds(i, j)
    i.between?(1, 8) && j.between?(1,8)
  end

  def out_of_bounds(i, j)
    !in_bounds(i, j)
  end

  def get_square(i, j, template=state)
    # For a given template position, if the square is occupied, return the occupying piece, else nil. 
    # If out of bounds, return false.
    # If a template is not given, it is assumed to be the board for the position object.
    if in_bounds(i, j)
      template[0][i-1][j-1]
    else
      false
    end
  end

  def available(i, j, template=state)
    get_square(i, j, template).nil?
  end

  def occupied(i, j, template=state)
    if in_bounds(i, j)
      !available(i, j, template)
    else
      nil
    end
  end

  def color(i, j, template=state)
    # If the square is occupied, return the piece's color, else nil.
    case get_square(i, j, template)
    when /[[:upper:]]/
      :w
    when /[[:lower:]]/
      :b
    else
      nil
    end
  end

  def get_pieces_by_color(color, template=state)
    white_pieces = []
    black_pieces = []
    template[0].each_with_index do |row, i|
      row.each_with_index do |square, j|
        white_pieces.push([i+1, j+1]) if color(i+1, j+1, template) == :w
        black_pieces.push([i+1, j+1]) if color(i+1, j+1, template) == :b
      end
    end
    case color
    when :w
      white_pieces
    when :b
      black_pieces
    end
  end

  def get_king_by_color(color, template=state)
    white_king = nil
    black_king = nil
    template[0].each_with_index do |row, i|
      row.each_with_index do |square, j|
        white_king = [i+1, j+1] if get_square(i+1, j+1, template) == "K"
        black_king = [i+1, j+1] if get_square(i+1, j+1, template) == "k"
        break if white_king && black_king
      end
    end
    case color
    when :w
      white_king
    when :b
      black_king
    end
  end
  # Translation of algebraic square notation into array element

  # def get_square_from_algebraic(square)
  #   if LETTERS.include? square[0].downcase
  #     row = LETTERS.index(square[0].downcase)
  #   end
  #   if square[1].between?(1, 8)
  #     col = square[1] - 1
  #   end
  
  #   if row && col
  #     get_square(row, col)
  #   end
  # end

  ### Movement-pertaining methods begin here

  def available_squares(i, j, template=state)
    # All available moves to a free square for a piece, DOESN'T TAKE CHECKS/ETC INTO ACCOUNT
    squares = []
    case get_square(i, j, template)&.upcase
    when 'K'
      squares.push([i-1, j]) if available(i-1, j, template)
      squares.push([i-1, j+1]) if available(i-1, j+1, template)
      squares.push([i, j+1]) if available(i, j+1, template)
      squares.push([i+1, j+1]) if available(i+1, j+1, template)
      squares.push([i+1, j]) if available(i+1, j, template)
      squares.push([i+1, j-1]) if available(i+1, j-1, template)
      squares.push([i, j-1]) if available(i, j-1, template)
      squares.push([i-1, j-1]) if available(i-1, j-1, template)
    when 'Q'
      i_ = i; j_ = j
      while available(i_-1, j_, template)
        squares.push([i_-1, j_])
        i_ -= 1
      end
      i_ = i; j_ = j
      while available(i_-1, j_+1, template)
        squares.push([i_-1, j_+1])
        i_ -= 1
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_, j_+1, template)
        squares.push([i_, j_+1])
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_+1, template)
        squares.push([i_+1, j_+1])
        i_ += 1
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_, template)
        squares.push([i_+1, j_])
        i_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_-1, template)
        squares.push([i_+1, j_-1])
        i_ += 1
        j_ -= 1
      end
      i_ = i; j_ = j
      while available(i_, j_-1, template)
        squares.push([i_, j_-1])
        j_ -= 1
      end
      i_ = i; j_ = j
      while available(i_-1, j_-1, template)
        squares.push([i_-1, j_-1])
        i_ -= 1
        j_ -= 1
      end
    when 'R'
      i_ = i; j_ = j
      while available(i_-1, j_, template)
        squares.push([i_-1, j_])
        i_ -= 1
      end
      i_ = i; j_ = j
      while available(i_, j_+1, template)
        squares.push([i_, j_+1])
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_, template)
        squares.push([i_+1, j_])
        i_ += 1
      end
      i_ = i; j_ = j
      while available(i_, j_-1, template)
        squares.push([i_, j_-1])
        j_ -= 1
      end
    when 'N'
      squares.push([i-2, j+1]) if available(i-2, j+1, template)
      squares.push([i-1, j+2]) if available(i-1, j+2, template)
      squares.push([i+1, j+2]) if available(i+1, j+2, template)
      squares.push([i+2, j+1]) if available(i+2, j+1, template)
      squares.push([i+2, j-1]) if available(i+2, j-1, template)
      squares.push([i+1, j-2]) if available(i+1, j-2, template)
      squares.push([i-1, j-2]) if available(i-1, j-2, template)
      squares.push([i-2, j-1]) if available(i-2, j-1, template)
    when 'B'
      i_ = i; j_ = j
      while available(i_-1, j_+1, template)
        squares.push([i_-1, j_+1])
        i_ -= 1
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_+1, template)
        squares.push([i_+1, j_+1])
        i_ += 1
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_-1, template)
        squares.push([i_+1, j_-1])
        i_ += 1
        j_ -= 1
      end
      i_ = i; j_ = j
      while available(i_-1, j_-1, template)
        squares.push([i_-1, j_-1])
        i_ -= 1
        j_ -= 1
      end
    when 'P'
      case color(i, j, template)
      when :w
        squares.push([i-1, j]) if available(i-1, j, template)
        if i == 7
          squares.push([i-2, j]) if available(i-2, j, template)
        end
      when :b
        squares.push([i+1, j]) if available(i+1, j, template)
        if i == 2
          squares.push([i+2, j]) if available(i+2, j, template)
        end
      end
    when nil
      squares = []
    end
    squares
  end

  def capturable_squares(i, j, template=state)
    squares = []
    case get_square(i, j, template)&.upcase
    when 'K'
      squares.push([i-1, j]) if occupied(i-1, j, template) &&
                                color(i-1, j, template) != color(i, j, template)
      squares.push([i-1, j+1]) if occupied(i-1, j+1, template) &&
                                color(i-1, j+1, template) != color(i, j, template)
      squares.push([i, j+1]) if occupied(i, j+1, template) &&
                                color(i, j+1, template) != color(i, j, template)
      squares.push([i+1, j+1]) if occupied(i+1, j+1, template) &&
                                color(i+1, j+1, template) != color(i, j, template)
      squares.push([i+1, j]) if occupied(i+1, j, template) &&
                                color(i+1, j, template) != color(i, , templatej)
      squares.push([i+1, j-1]) if occupied(i+1, j-1, template) &&
                                color(i+1, j-1, template) != color(i, j, template)
      squares.push([i, j-1]) if occupied(i, j-1, template) &&
                                color(i, j-1, template) != color(i, j, template)
      squares.push([i-1, j-1]) if occupied(i-1, j-1, template) && 
                                color(i-1, j-1, template) != color(i, j, template)
    when 'Q'
      i_ = i; j_ = j
      until occupied(i_-1, j_, template) || out_of_bounds(i_-1, j_)
        i_ -= 1 
      end
      squares.push([i_-1, j_]) if color(i_-1, j_, template) && color(i_-1, j_, template) != color(i, j, template)  

      i_ = i; j_ = j
      until occupied(i_-1, j_+1, template) || out_of_bounds(i_-1, j_+1)
        i_ -= 1
        j_ += 1
      end
      squares.push([i_-1, j_+1]) if color(i_-1, j_+1, template) && color(i_-1, j_+1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_, j_+1, template) || out_of_bounds(i_, j_+1)
        j_ += 1 
      end
      squares.push([i_, j_+1]) if color(i_, j_+1, template) && color(i_, j_+1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_+1, j_+1, template) || out_of_bounds(i_+1, j_+1)
        i_ += 1 
        j_ += 1
      end
      squares.push([i_+1, j_+1]) if color(i_+1, j_+1, template) && color(i_+1, j_+1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_+1, j_, template) || out_of_bounds(i_+1, j_)
        i_ += 1 
      end
      squares.push([i_+1, j_]) if color(i_+1, j_, template) && color(i_+1, j_, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_+1, j_-1, template) || out_of_bounds(i_+1, j_-1)
        i_ += 1
        j_ -= 1
      end
      squares.push([i_+1, j_-1]) if color(i_+1, j_-1, template) && color(i_+1, j_-1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_, j_-1, template) || out_of_bounds(i_, j_-1)
        j_ -= 1 
      end
      squares.push([i_, j_-1]) if color(i_, j_-1, template) && color(i_, j_-1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_-1, j_-1, template) || out_of_bounds(i_-1, j_-1)
        i_ -= 1 
        j_ -= 1
      end
      squares.push([i_-1, j_-1]) if color(i_-1, j_-1, template) && color(i_-1, j_-1, template) != color(i, j, template)

    when 'R'
      i_ = i; j_ = j
      until occupied(i_-1, j_, template) || out_of_bounds(i_-1, j_)
        i_ -= 1 
      end
      squares.push([i_-1, j_]) if color(i_-1, j_, template) && color(i_-1, j_, template) != color(i, j, template)  

      i_ = i; j_ = j
      until occupied(i_, j_+1, template) || out_of_bounds(i_, j_+1)
        j_ += 1 
      end
      squares.push([i_, j_+1]) if color(i_, j_+1, template) && color(i_, j_+1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_+1, j_, template) || out_of_bounds(i_+1, j_)
        i_ += 1 
      end
      squares.push([i_+1, j_]) if color(i_+1, j_, template) && color(i_+1, j_, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_, j_-1, template) || out_of_bounds(i_, j_-1)
        j_ -= 1 
      end
      squares.push([i_, j_-1]) if color(i_, j_-1, template) && color(i_, j_-1, template) != color(i, j, template)
    when 'B'
      i_ = i; j_ = j
      until occupied(i_-1, j_+1, template) || out_of_bounds(i_-1, j_+1)
        i_ -= 1
        j_ += 1
      end
      squares.push([i_-1, j_+1]) if color(i_-1, j_+1, template) && color(i_-1, j_+1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_+1, j_+1, template) || out_of_bounds(i_+1, j_+1)
        i_ += 1 
        j_ += 1
      end
      squares.push([i_+1, j_+1]) if color(i_+1, j_+1, template) && color(i_+1, j_+1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_+1, j_-1, template) || out_of_bounds(i_+1, j_-1)
        i_ += 1
        j_ -= 1
      end
      squares.push([i_+1, j_-1]) if color(i_+1, j_-1, template) && color(i_+1, j_-1, template) != color(i, j, template)

      i_ = i; j_ = j
      until occupied(i_-1, j_-1, template) || out_of_bounds(i_-1, j_-1)
        i_ -= 1 
        j_ -= 1
      end
      squares.push([i_-1, j_-1]) if color(i_-1, j_-1, template) && color(i_-1, j_-1, template) != color(i, j, template)
    when 'N'
      squares.push([i-2, j+1]) if occupied(i-2, j+1, template) && color(i-2, j+1, template) != color(i, j, template)
      squares.push([i-1, j+2]) if occupied(i-1, j+2, template) && color(i-1, j+2, template) != color(i, j, template)
      squares.push([i+1, j+2]) if occupied(i+1, j+2, template) && color(i+1, j+2, template) != color(i, j, template)
      squares.push([i+2, j+1]) if occupied(i+2, j+1, template) && color(i+2, j+1, template) != color(i, j, template)
      squares.push([i+2, j-1]) if occupied(i+2, j-1, template) && color(i+2, j-1, template) != color(i, j, template)
      squares.push([i+1, j-2]) if occupied(i+1, j-2, template) && color(i+1, j-2, template) != color(i, j, template)
      squares.push([i-1, j-2]) if occupied(i-1, j-2, template) && color(i-1, j-2, template) != color(i, j, template)
      squares.push([i-2, j-1]) if occupied(i-2, j-1, template) && color(i-2, j-1, template) != color(i, j, template)
    when 'P'
      case color(i, j, template)
      when :w
        squares.push([i-1, j-1]) if occupied(i-1, j-1, template) && color(i-1, j-1, template) != color(i, j, template)
        squares.push([i-1, j+1]) if occupied(i-1, j+1, template) && color(i-1, j+1, template) != color(i, j, template)
      when :b
        squares.push([i+1, j-1]) if occupied(i+1, j-1, template) && color(i+1, j-1, template) != color(i, j, template)
        squares.push([i+1, j+1]) if occupied(i+1, j+1, template) && color(i+1, j+1, template) != color(i, j, template)
      end
    when nil
      squares = []
    end
    squares
  end

  def legal_squares(i, j, template=board)
    # No checks yet!!
    available_squares(i, j, template) + capturable_squares(i, j, template)
  end

  def active_color_not_in_check(template=board)
    case get_active_color
    when :w
      get_pieces_by_color(:w).each do |piece|
        if capturable_squares(*piece).include? get_king_by_color(:b)
          return false
        end
      end
    when :b
      get_pieces_by_color(:b).each do |piece|
        if capturable_squares(*piece).include? get_king_by_color(:w)
          errors.add("Check")
          return false
        end
      end
    end
    true
  end

  def validate_move(i1, j1, i2, j2)
    # Checks if the move from (i1, j1) to (i2, j2) is a valid chess move.
    (legal_squares(i1, j1).include? [i2, j2]) && 
    (color(i1, j1) == get_active_color) &&
    active_color_not_in_check
  end

  def castling_move(i1, j1, i2, j2)
    # Return K Q k q nil if appropriate castling was made on the move 
  end

  def en_passant_move(i1, j1, i2, j2)
  end

    # # #

  def set_board(i1, j1, i2, j2)
    if castling_move(i1, i2, j1, j2)
    elsif en_passant_move(i1, i2, j1, j2)
    else
      next_board = board
      next_board[i2 - 1][j2 - 1] = board[i1 - 1][j1 - 1]
      next_board[i1 - 1][j1 - 1] = nil
      next_board
    end
  end

  def to_fen(i1, j1, i2, j2)
    # Return the fen of position that ensues after a legal move [i1, j1] -> [i2, j2]

    rows = ""
    set_board(i1, j1, i2, j2).each do |row|
      row_long = row.map { |x| x.nil? ? '_' : x } .join
      rows << "#{row_long.gsub(/_+/) { |capture| capture.length.to_s }}/"
    end

    rows_fragment = rows.chomp("/")
    color_fragment = get_active_color == :b ? :w : :b
    castling_fragment = get_castling_rights.to_s.gsub(castling_move(i1, j1, i2, j2).to_s, "")
    en_passant_fragment = "-".to_s # IN PROGRESS
    half_moves_fragment = get_half_moves.to_s
    full_moves_fragment = ((order + 1)/2).ceil

    fen = "#{rows_fragment} #{color_fragment} #{castling_fragment} #{en_passant_fragment} #{half_moves_fragment} #{full_moves_fragment}"
  end

  private

# Validations

  def well_formed_fen
    unless fen.match? Fen::REGEX
      errors.add("Invalid FEN.")
    end
  end

  def correct_board_size
    state = get_state_from_fen[1..8]
    8.times do |i|
      row = state[i].split("")
      total_occupied_spaces = row.filter { |x| x.match? /\D/ } .length
      total_empty_spaces = 0
      row.filter { |x| x.match? /\d/ } .each do |x|
        total_empty_spaces += x.to_i
      end
      unless total_occupied_spaces + total_empty_spaces == 8
        errors.add("Incorrect board size.")
      end
    end
  end

  def each_color_has_their_king
  end

  def inactive_color_cannot_be_in_check
    case get_active_color
    when :w
      get_pieces_by_color(:w).each do |piece|
        if capturable_squares(*piece).include? get_king_by_color(:b)
          errors.add("Check")
          return
        end
      end
    when :b
      get_pieces_by_color(:b).each do |piece|
        if capturable_squares(*piece).include? get_king_by_color(:w)
          errors.add("Check")
          return
        end
      end
    end
  end
end
