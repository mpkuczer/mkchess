module Fen
  REGEX = %r{
    ^([kqrbnpKQRBNP1-8]{1,8})           # 1
    \/([kqrbnpKQRBNP1-8]{1,8})          # 2
    \/([kqrbnpKQRBNP1-8]{1,8})          # 3
    \/([kqrbnpKQRBNP1-8]{1,8})          # 4
    \/([kqrbnpKQRBNP1-8]{1,8})          # 5
    \/([kqrbnpKQRBNP1-8]{1,8})          # 6
    \/([kqrbnpKQRBNP1-8]{1,8})          # 7
    \/([kqrbnpKQRBNP1-8]{1,8})\b          # 8 
    \s([bw])                                      # active color
    \s((?:K?Q?k?q?)|-)                            # castling rights
    \s((?:[a-h][1-8])|-)                          # possible en passant
    \s([0-9]+)                                       # halfmove number
    \s([0-9]+)$                                      # fullmove number
  }x

  STARTING_POSITION = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
end


# 'RNBQKB1R b KQkq - 9 99'.match /((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})\b\s([bw])\s((?:K?Q?k?q?)|-)\s((?:[a-h][1-8])|-)\s([0-9]+)\s([0-9]+)/

# NOTE

# For some unknown reason, previous regex doesn't work once either move count exceeds 2 digits.

#   REGEX = %r{
#     ^((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})           # 1
#     \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 2
#     \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 3
#     \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 4
#     \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 5
#     \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 6
#     \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 7
#     \/((?!.*\d\d)[kqrbnpKQRBNP1-8]{1,8})          # 8 
#     \s([bw])                                      # active color
#     \s((?:K?Q?k?q?)|-)                            # castling rights
#     \s((?:[a-h][1-8])|-)                          # possible en passant
#     \s(\d+)                                       # halfmove number
#     \s(\d+)$                                      # fullmove number
#   }x
