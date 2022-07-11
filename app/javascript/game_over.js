window.gameOver = (result) => {
    const positionsFooter = document.querySelector('.positions-footer')
    positionsFooter.style = "color: var(--success-light-color); font-size: 2rem;"

    switch (result) {
        case 'w':
            positionsFooter.textContent = "Checkmate! White won."
            break;
        case 'b':
            positionsFooter.textContent = "Checkmate! Black won."
            break;
        case 'draw':
            positionsFooter.textContent = "Stalemate! The game is drawn."
            break;
    }
}