class Position < ApplicationRecord
  belongs_to :game
  validate :well_formed_fen
  validate :correct_board_size

  LETTERS = 'abcdefgh'

  # Retrieval of data from FEN begins here"
  def get_state_from_fen
    fen.match Fen::REGEX
  end

  def get_active_color
    color = get_state_from_fen[9].to_sym
    color_values = {
      w: :white,
      b: :black
    }
    color_values[color]
  end

  def get_castling_rights
    castling = get_state_from_fen[10]
    castling_rights = {
      white_kingside: castling.include?('K'),
      white_queenside: castling.include?('Q'),
      black_kingside: castling.include?('k'),
      black_queenside: castling.include?('q')
    }
  end

  def get_en_passant_square
    ep = get_state_from_fen[11]
    if ep == '-'
      en_passant = false
    else 
      en_passant = get_square_from_algebraic(ep)
    end
  end
    
  def get_half_moves
    half_moves = get_state_from_fen[12].to_i
  end

  def get_full_moves
    full_moves = get_state_from_fen[13].to_i
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

# Retrieval of data from FEN ends here"

# Spatial getters

  # def get_rank(i)
  #   board[i-1]
  # end

  # def get_file(i)
  #   col = []
  #   board.each do |row|
  #     col.push(row[i-1])
  #   end
  #   col
  # end

  def in_bounds(i, j)
    i.between?(1, 8) && j.between?(1,8)
  end

  def get_square(i, j)
    # If the square is occupied, return the occupying piece, else nil. If out of bounds, return false.
    if in_bounds(i, j)
      board[i-1][j-1]
    else
      false
    end
  end

  def available(i, j)
    get_square(i, j).nil?
  end

  def occupied(i, j)
    if in_bounds(i, j)
      !available(i, j)
    else
      false
    end
  end

  def color(i, j)
    # If the square is occupied, return the piece's color, else nil.
    case get_square(i, j)
    when /[[:upper:]]/
      :white
    when /[[:lower:]]/
      :black
    else
      nil
    end
  end

  # Translation of algebraic square notation into array element

  def get_square_from_algebraic(square)
    if LETTERS.include? square[0].downcase
      row = LETTERS.index(square[0].downcase)
    end
    if square[1].between?(1, 8)
      col = square[1] - 1
    end
  
    if row && col
      get_square(row, col)
    end
  end

  ### Movement-pertaining methods begin here

  def available_squares(i, j)
    # All available moves to a free square for a piece, DOESN'T TAKE CHECKS/ETC INTO ACCOUNT
    squares = []
    case get_square(i, j)&.upcase
    when 'K'
      squares.push([i-1, j]) if available(i-1, j)
      squares.push([i-1, j+1]) if available(i-1, j+1)
      squares.push([i, j+1]) if available(i, j+1)
      squares.push([i+1, j+1]) if available(i+1, j+1)
      squares.push([i+1, j]) if available(i+1, j)
      squares.push([i+1, j-1]) if available(i+1, j-1)
      squares.push([i, j-1]) if available(i, j-1)
      squares.push([i-1, j-1]) if available(i-1, j-1)
    when 'Q'
      i_ = i; j_ = j
      while available(i_-1, j_)
        squares.push([i_-1, j_])
        i_ -= 1
      end
      i_ = i; j_ = j
      while available(i_-1, j_+1)
        squares.push([i_-1, j_+1])
        i_ -= 1
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_, j_+1)
        squares.push([i_, j_+1])
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_+1)
        squares.push([i_+1, j_+1])
        i_ += 1
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_)
        squares.push([i_+1, j_])
        i_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_-1)
        squares.push([i_+1, j_-1])
        i_ += 1
        j_ -= 1
      end
      i_ = i; j_ = j
      while available(i_, j_-1)
        squares.push([i_, j_-1])
        j_ -= 1
      end
      i_ = i; j_ = j
      while available(i_-1, j_-1)
        squares.push([i_-1, j_-1])
        i_ -= 1
        j_ -= 1
      end
    when 'R'
      i_ = i; j_ = j
      while available(i_-1, j_)
        squares.push([i_-1, j_])
        i_ -= 1
      end
      i_ = i; j_ = j
      while available(i_, j_+1)
        squares.push([i_, j_+1])
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_)
        squares.push([i_+1, j_])
        i_ += 1
      end
      i_ = i; j_ = j
      while available(i_, j_-1)
        squares.push([i_, j_-1])
        j_ -= 1
      end
    when 'N'
      squares.push([i-2, j+1]) if available(i-2, j+1)
      squares.push([i-1, j+2]) if available(i-1, j+2)
      squares.push([i+1, j+2]) if available(i+1, j+2)
      squares.push([i+2, j+1]) if available(i+2, j+1)
      squares.push([i+2, j-1]) if available(i+2, j-1)
      squares.push([i+1, j-2]) if available(i+1, j-2)
      squares.push([i-1, j-2]) if available(i-1, j-2)
      squares.push([i-2, j-1]) if available(i-2, j-1)
    when 'B'
      i_ = i; j_ = j
      while available(i_-1, j_+1)
        squares.push([i_-1, j_+1])
        i_ -= 1
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_+1)
        squares.push([i_+1, j_+1])
        i_ += 1
        j_ += 1
      end
      i_ = i; j_ = j
      while available(i_+1, j_-1)
        squares.push([i_+1, j_-1])
        i_ += 1
        j_ -= 1
      end
      i_ = i; j_ = j
      while available(i_-1, j_-1)
        squares.push([i_-1, j_-1])
        i_ -= 1
        j_ -= 1
      end
    when 'P'
      case color(i, j)
      when :white
        squares.push([i-1, j]) if available(i-1, j)
        if i == 7
          squares.push([i-2, j]) if available(i-2, j)
        end
      when :black
        squares.push([i+1, j]) if available(i+1, j)
        if i == 2
          squares.push([i+2, j]) if available(i+2, j)
        end
      end
    when nil
      squares = []
    end
    squares
  end

  def capturable_squares(i, j)
    squares = []
    case get_square(i, j)&.upcase
    when 'K'
      squares.push([i-1, j]) if occupied(i-1, j) && color(i-1, j) != color(i, j)
      squares.push([i-1, j+1]) if occupied(i-1, j+1) && color(i-1, j+1) != color(i, j)
      squares.push([i, j+1]) if occupied(i, j+1) && color(i, j+1) != color(i, j)
      squares.push([i+1, j+1]) if occupied(i+1, j+1) && color(i+1, j+1) != color(i, j)
      squares.push([i+1, j]) if occupied(i+1, j) && color(i+1, j) != color(i, j)
      squares.push([i+1, j-1]) if occupied(i+1, j-1) && color(i+1, j-1) != color(i, j)
      squares.push([i, j-1]) if occupied(i, j-1) && color(i, j-1) != color(i, j)
      squares.push([i-1, j-1]) if occupied(i-1, j-1) && color(i-1, j-1) != color(i, j)
    when 'Q'
      i_ = i; j_ = j
      until occupied(i_-1, j_)
        i_ -= 1 
      end
      squares.push([i_-1, j_]) if color(i_-1, j_) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_-1, j_+1)
        i_ -= 1
        j_ += 1
      end
      squares.push([i_-1, j_+1]) if color(i_-1, j_+1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_, j_+1)
        j_ += 1 
      end
      squares.push([i_, j_+1]) if color(i_, j_+1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_+1, j_+1)
        i_ += 1 
        j_ += 1
      end
      squares.push([i_+1, j_+1]) if color(i_+1, j_+1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_+1, j_)
        i_ += 1 
      end
      squares.push([i_+1, j_]) if color(i_+1, j_) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_+1, j_-1)
        i_ += 1
        j_ -= 1
      end
      squares.push([i_+1, j_-1]) if color(i_+1, j_-1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_, j_-1)
        j_ -= 1 
      end
      squares.push([i_, j_-1]) if color(i_, j_-1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_-1, j_-1)
        i_ -= 1 
        j_ -= 1
      end
      squares.push([i_-1, j_-1]) if color(i_-1, j_-1) != color(i, j)
    when 'R'
      i_ = i; j_ = j
      until occupied(i_-1, j_)
        i_ -= 1 
      end
      squares.push([i_-1, j_]) if color(i_-1, j_) != color(i, j)  

      i_ = i; j_ = j
      until occupied(i_, j_+1)
        j_ += 1 
      end
      squares.push([i_, j_+1]) if color(i_, j_+1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_+1, j_)
        i_ += 1 
      end
      squares.push([i_+1, j_]) if color(i_+1, j_) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_, j_-1)
        j_ -= 1 
      end
      squares.push([i_, j_-1]) if color(i_, j_-1) != color(i, j)
    when 'B'
      i_ = i; j_ = j
      until occupied(i_-1, j_+1)
        i_ -= 1
        j_ += 1
      end
      squares.push([i_-1, j_+1]) if color(i_-1, j_+1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_+1, j_+1)
        i_ += 1 
        j_ += 1
      end
      squares.push([i_+1, j_+1]) if color(i_+1, j_+1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_+1, j_-1)
        i_ += 1
        j_ -= 1
      end
      squares.push([i_+1, j_-1]) if color(i_+1, j_-1) != color(i, j)

      i_ = i; j_ = j
      until occupied(i_-1, j_-1)
        i_ -= 1 
        j_ -= 1
      end
      squares.push([i_-1, j_-1]) if color(i_-1, j_-1) != color(i, j)
    when 'N'
      squares.push([i-2, j+1]) if occupied(i-2, j+1) && color(i-2, j+1) != color(i, j)
      squares.push([i-1, j+2]) if occupied(i-1, j+2) && color(i-1, j+2) != color(i, j)
      squares.push([i+1, j+2]) if occupied(i+1, j+2) && color(i+1, j+2) != color(i, j)
      squares.push([i+2, j+1]) if occupied(i+2, j+1) && color(i+2, j+1) != color(i, j)
      squares.push([i+2, j-1]) if occupied(i+2, j-1) && color(i+2, j-1) != color(i, j)
      squares.push([i+1, j-2]) if occupied(i+1, j-2) && color(i+1, j-2) != color(i, j)
      squares.push([i-1, j-2]) if occupied(i-1, j-2) && color(i-1, j-2) != color(i, j)
      squares.push([i-2, j-1]) if occupied(i-2, j-1) && color(i-2, j-1) != color(i, j)
    when 'P'
      case color(i, j)
      when :white
        squares.push([i-1, j-1]) if occupied(i-1, j-1) && color(i-1, j-1) != color(i, j)
        squares.push([i-1, j+1]) if occupied(i-1, j+1) && color(i-1, j+1) != color(i, j)
      when :black
        squares.push([i+1, j-1]) if occupied(i+1, j-1) && color(i+1, j-1) != color(i, j)
        squares.push([i+1, j+1]) if occupied(i+1, j+1) && color(i+1, j+1) != color(i, j)
      end
    end
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
  end

  # Callbacks
end