class Position < ApplicationRecord
  belongs_to :game
  validates :order, presence: true, uniqueness: { scope: :game_id }
  validate :well_formed_fen
  validate :correct_board_size

  def active
    self == game.positions.last
  end

  LETTERS = 'abcdefgh'

  # Retrieval of data from FEN

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
    { board: board,
      get_active_color: get_active_color,
      get_castling_rights: get_castling_rights,
      get_en_passant_square: get_en_passant_square,
      get_half_moves: get_half_moves,
      get_full_moves: get_full_moves }
  end

# Static getters

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
      template[:board][i-1][j-1]
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

  def switch_color(color)
    case color
    when :w 
      :b
    when :b
      :w
    else
      nil
    end
  end

  def get_pieces_by_color(color, template=state)
    white_pieces = []
    black_pieces = []
    template[:board].each_with_index do |row, i|
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
    template[:board].each_with_index do |row, i|
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

  ### Movement and validation

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

      if (available(i, j+1, template) &&
          available(i, j+2, template) &&
          get_square(i, 8, template)&.upcase == 'R' &&
          color(i, 8, template) == color(i, j, template) &&
         (template[:get_castling_rights].to_s.include? color(i, j, template) == :w ? 'K' : 'k')) then
        squares.push([i, j+2])
      end
      if (available(i, j-1, template) &&
          available(i, j-2, template) &&
          get_square(i, 1)&.upcase == 'R' &&
          color(i, 1) == color(i, j) &&
         (template[:get_castling_rights].to_s.include? color(i, j, template) == :w ? 'Q' : 'q')) then
        squares.push([i, j-2])
      end
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
                                color(i+1, j, template) != color(i, j, template)
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

  def square_attacked(i, j, template=state)
    # Return a hash like this one:
    # {b: 5, w: 3}
    # which reads: attacked 5 times by black, 3 times by white

    # Doesn't work!!
    w = 0
    b = 0
    get_pieces_by_color(:b, template).each do |piece|
      if (available_squares(*piece, template) + capturable_squares(*piece, template)).include? [i, j]
        b += 1
      end
    end
    get_pieces_by_color(:w, template).each do |piece|
      if (available_squares(*piece, template) + capturable_squares(*piece, template)).include? [i, j]
        w += 1
      end
    end
    { b: b, w: w }
  end

  def active_color_in_check(template=state)
    active = template[:get_active_color]
    inactive = switch_color(template[:get_active_color])
    king = get_king_by_color(active, template)
    square_attacked(*king, template)[inactive] > 0
  end

  def inactive_color_not_in_check(template=state)
    active = template[:get_active_color]
    inactive = switch_color(template[:get_active_color])
    king = get_king_by_color(inactive, template)
    square_attacked(*king, template)[active] == 0
  end

  def legal_squares(i, j, template=state)
    squares = available_squares(i, j, template) + capturable_squares(i, j, template)
    squares.filter { |sq| inactive_color_not_in_check(set_state(i, j, *sq)) }
  end

  def validate_move(i1, j1, i2, j2)

    # Checks if the move from (i1, j1) to (i2, j2) is a valid chess move.
    (legal_squares(i1, j1).include? [i2, j2]) && 
    (color(i1, j1) == get_active_color)
  end

  def castling_move(i1, j1, i2, j2, template=state)
    get_square(i1, j1, template)&.upcase == 'K' &&
    (j1 - j2).abs == 2
  end

  # def en_passant_move(i1, j1, i2, j2)
  # end

  def checkmate(template=state)
    active_color_in_check(template) &&
    get_pieces_by_color(template[:get_active_color]).all? { |piece| legal_squares(*piece, template).empty? } 
  end

  def stalemate(template=state)
    !active_color_in_check(template) &&
    get_pieces_by_color(template[:get_active_color]).all? { |piece| legal_squares(*piece, template).empty? } 
  end
    # # #

  def set_state(i1, j1, i2, j2)
    # Return state of a new position after making a move [i1, j1] => [i2, j2]
    next_state = state

    if castling_move(i1, j1, i2, j2)

      next_state[:board][i2 - 1][j2 - 1] = state[:board][i1 - 1][j1 - 1]
      next_state[:board][i1 - 1][j1 - 1] = nil
      case j2
      when 3
        next_state[:board][i2 - 1][3] = state[:board][i1 - 1][0]
        next_state[:board][i1 - 1][0] = nil
      when 7
        next_state[:board][i2 - 1][5] = state[:board][i1 - 1][7]
        next_state[:board][i1 - 1][7] = nil
      end

    else
      next_state[:board][i2 - 1][j2 - 1] = state[:board][i1 - 1][j1 - 1]
      next_state[:board][i1 - 1][j1 - 1] = nil
    end
    if get_square(i1, j1)&.upcase == 'K'

      case color(i1, j1) 
      when :w
        next_state[:get_castling_rights] = state[:get_castling_rights].to_s.tr('KQ', '')
  
      when :b
        next_state[:get_castling_rights] = state[:get_castling_rights].to_s.tr('kq', '')
      end


    elsif get_square(i1, j1)&.upcase == 'R'
      if color(i1, j1) == :w && j1 == 1 
        next_state[:get_castling_rights] = state[:get_castling_rights].to_s.tr('Q', '')
      elsif color(i1, j1) == :b && j1 == 1 
        next_state[:get_castling_rights] = state[:get_castling_rights].to_s.tr('q', '')
      elsif color(i1, j1) == :w && j1 == 1 
        next_state[:get_castling_rights] = state[:get_castling_rights].to_s.tr('K', '')
      elsif color(i1, j1) == :b && j1 == 1 
        next_state[:get_castling_rights] = state[:get_castling_rights].to_s.tr('k', '')
      end
 
    end

    next_state[:get_active_color] = switch_color(state[:get_active_color])
    next_state[:get_full_moves] = ((order + 1) / 2).ceil
    next_state
  end

  def to_fen(i1, j1, i2, j2)
    # Return the fen of position that ensues after move [i1, j1] -> [i2, j2]
    new_state = set_state(i1, j1, i2, j2)
    rows = ""
    new_state[:board].each do |row|
      row_long = row.map { |x| x.nil? ? '_' : x } .join
      rows << "#{row_long.gsub(/_+/) { |capture| capture.length.to_s }}/"
    end

    rows_fragment = rows.chomp("/")
    color_fragment = new_state[:get_active_color]
    castling_fragment = new_state[:get_castling_rights]
    en_passant_fragment = new_state[:get_en_passant_square]
    half_moves_fragment = new_state[:get_half_moves]
    full_moves_fragment = new_state[:get_full_moves]

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
