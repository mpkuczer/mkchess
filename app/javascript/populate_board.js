window.populateBoard = () => {
    const classes = {
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

    const board = document.querySelector('.board');
    const positionData = document.querySelector('#position_data').getAttribute('data-position');
    const position = JSON.parse(positionData);
    const moveData = document.querySelector('#position_data').getAttribute('data-move');
    const move = JSON.parse(moveData);

    Array.from(board.children).forEach((row, i) => {
        Array.from(row.children).forEach((square, j) => {
            square.classList.add(classes[position[i][j]])
        })
    })
    if (move.length !== 0) {
        board.children[move[0] - 1].children[move[1] - 1].classList.add("successful")
        board.children[move[2] - 1].children[move[3] - 1].classList.add("successful")
    }
}
