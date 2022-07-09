window.previousMove = (move) => {
    const board = document.querySelector('.board')
    board.children[move[0] - 1].children[move[1] - 1].classList.add("tile_successful_move")
    board.children[move[2] - 1].children[move[3] - 1].classList.add("tile_successful_move")
}