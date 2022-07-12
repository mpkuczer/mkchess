window.boardInputs = () => {
    const isLowerCase = (str) => {
        if (str === null) {
            return false
        } else {
            return str == str.toLowerCase() && str != str.toUpperCase();
        }
    }
    const getSquareCoordinates = (square) => {
        const i = Array.from(square.parentNode.parentNode.children).indexOf(square.parentNode) + 1
        const j = Array.from(square.parentNode.children).indexOf(square) + 1
        return [i, j]
    } 
    // const addHoverToElement = () => {
    //     this.classList.add('hover')
    // }
    const addHoverToElement = function () {
        this.classList.add('hover')
    }
    const removeHoverFromElement = function () {
        this.classList.remove('hover')
    }
    // const removeHoverFromElement = () => {
    //     this.classList.remove('hover')
    // }

    const board = document.querySelector('.board');

    const positionData = document.querySelector('#position_data').getAttribute('data-position');
    const positionId = document.querySelector('#position_data').getAttribute('data-id');
    const positionActiveColor = document.querySelector('#position_data').getAttribute('data-active-color');
    const position = JSON.parse(positionData);

    const getSquare = (i, j) => {
        // Accept coordinates in range between 0 and 7
        return board.children[i].children[j]
    }

    const whitePieces = position.map(rank => 
        rank.map((symbol) => 
            isLowerCase(symbol) ? null : symbol
        )
    )
    const blackPieces = position.map(rank =>
        rank.map((symbol) =>
            isLowerCase(symbol) ? symbol : null
        )
    )

    let queue = [null, null];

    const processInput = (evt) => {
        let coords = getSquareCoordinates(evt.target)
        if (queue[0] === null) {
            if ((position[coords[0] - 1][coords[1] - 1] === null) ||
               (positionActiveColor == 'w' && whitePieces[coords[0] - 1][coords[1] - 1] === null) ||
               (positionActiveColor == 'b' && blackPieces[coords[0] - 1][coords[1] - 1] === null)) {
                queue[0] = null;
                queue[1] = null;
                return
            }
            queue[0] = coords
            evt.target.setAttribute("id", "selected")
            $.ajax({
                url: '/legal_squares',
                type: 'PATCH',
                beforeSend: (xhr) => {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
                data: {
                    i: queue[0][0],
                    j: queue[0][1],
                    id: positionId
                },
            }).done((data, textStatus, jqXHR) => {
                data.squares.forEach((square_coords) => {
                    let i; let j;
                    [i, j] = square_coords
                    let square = getSquare(i-1, j-1)
                    square.classList.add('legal-move')
                    square.addEventListener('mouseover', addHoverToElement)
                    square.addEventListener('mouseout', removeHoverFromElement)
                })
            }).fail((jqXHR, textStatus, errorThrown) => {
                console.log(jqXHR)
            })

        } else if (queue[0][0] == coords[0] &&
                   queue[0][1] == coords[1]) {
            queue[0] = null
            queue[1] = null
            if (document.getElementById("selected")) {
                document.getElementById("selected").removeAttribute("id")
            }
            Array.from(board.children).forEach((row, i) => {
                Array.from(row.children).forEach((square, j) => {
                    square.classList.remove('legal-move')
                    square.removeEventListener('mouseover', addHoverToElement)
                    square.removeEventListener('mouseout', removeHoverFromElement)
                })
            })
            return
        } else {
            queue[1] = coords
        }

        if (queue[0] !== null && queue[1] !== null) {
            $.ajax({
                url: '/move',
                type: 'PATCH',
                beforeSend: (xhr) => {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
                data: {
                    i1: queue[0][0],
                    j1: queue[0][1],
                    i2: queue[1][0],
                    j2: queue[1][1],
                    position_id: positionId
                },
            }).done((data, textStatus, jqXHR) => {
                queue[0] = null;
                queue[1] = null;
                if (document.getElementById("selected")) {
                    document.getElementById("selected").removeAttribute("id")
                }
                Array.from(board.children).forEach((row, i) => {
                    Array.from(row.children).forEach((square, j) => {
                        square.classList.remove('legal-move')
                        square.removeEventListener('mouseover', addHoverToElement)
                        square.removeEventListener('mouseout', removeHoverFromElement)
                    })
                })
                if (data.hasOwnProperty('offendingPiece')) {
                    let invalidCoords = data.offendingPiece
                    let invalidSquare = getSquare(invalidCoords[0] - 1, invalidCoords[1] - 1)
                    invalidSquare.setAttribute("id", "invalid")
                    setTimeout(() => { invalidSquare.removeAttribute("id") }, 500)
                }
            }).fail((jqXHR, textStatus, errorThrown) => {
                queue[0] = null;
                queue[1] = null;
                if (document.getElementById("selected")) {
                    document.getElementById("selected").removeAttribute("id")
                }
                Array.from(board.children).forEach((row, i) => {
                    Array.from(row.children).forEach((square, j) => {
                        square.classList.remove('legal-move')
                        square.removeEventListener('mouseover', addHoverToElement)
                        square.removeEventListener('mouseout', removeHoverFromElement)
                    })
                })
            })} 
        }

    Array.from(board.children).forEach((row, i) => {
        Array.from(row.children).forEach((square, j) => {
            square.addEventListener('click', (evt) => {
                processInput(evt);
            });
        })
    })
}