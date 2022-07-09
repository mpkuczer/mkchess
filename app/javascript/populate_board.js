classes = {
    'k': 'king-black',
    'q': 'queen-black',
    'r': 'rook-black',
    'b': 'bishop-black',
    'n': 'knight-black',
    'p': 'pawn-black',
    'K': 'king-white',
    'Q': 'queen-white',
    'R': 'rook-white',
    'B': 'bishop-white',
    'N': 'knight-white',
    'P': 'pawn-white',
    null: 'blank'
}

board = document.querySelector('.board')
positionData = document.querySelector('#position_data').getAttribute('data-position')
position = JSON.parse(positionData)

Array.from(board.children).forEach((row, i) => {
    Array.from(row.children).forEach((square, j) => {
        square.classList.add(classes[position[i][j]])
    })
})
