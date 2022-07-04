module Fen
  REGEX = %r{
    ^((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})           # 1
    \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 2
    \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 3
    \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 4
    \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 5
    \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 6
    \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 7
    \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 8 
    \s([bw])                                      # active color
    \s((?:K?Q?k?q?)|-)                            # castling rights
    \s((?:[a-h][1-8])|-)                          # possible en passant
    \s(\d+)                                       # halfmove number
    \s(\d+)$                                      # fullmove number
  }x

  STARTING_POSITION = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
end