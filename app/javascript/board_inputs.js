window.boardInputs = () => {
    const board = document.querySelector('.board');
    const positionData = document.querySelector('#position_data').getAttribute('data-position');
    const positionId = document.querySelector('#position_data').getAttribute('data-id');
    const position = JSON.parse(positionData);
    let queue = [null, null];

    const processInput = (evt) => {

        let coords = getSquareCoordinates(evt.target)
        if (queue[0] === null) {
            if (evt.target.classList.contains("blank")) {
                console.log('empty tile')
                queue[0] = null;
                queue[1] = null;
                return
            } 
            queue[0] = coords
            evt.target.setAttribute("id", "selected")
        } else if (queue[0][0] == coords[0] &&
                   queue[0][1] == coords[1]) {
            queue[0] = null
            queue[1] = null
            if (document.getElementById("selected")) {
                document.getElementById("selected").removeAttribute("id")
            }
            return
        } else {
            queue[1] = coords
        }
        if (queue[0] !== null && queue[1] !== null) {
            $.ajax({
                url: '/move',
                type: 'PATCH',
                beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
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
            }).fail((jqXHR, textStatus, errorThrown) => {
                queue[0] = null;
                queue[1] = null;
                if (document.getElementById("selected")) {
                    document.getElementById("selected").removeAttribute("id")
                }
                if (jqXHR.responseJSON.hasOwnProperty('offendingPiece')) {
                    let invalidCoords = jqXHR.responseJSON.offendingPiece
                    let invalidTile = board.children[invalidCoords[0] - 1].children[invalidCoords[1] - 1]
                    invalidTile.setAttribute("id", "invalid")
                    setTimeout(() => { invalidTile.removeAttribute("id") }, 500)
                }
            })} 
        }

    const getSquareCoordinates = (square) => {
        const i = Array.from(square.parentNode.parentNode.children).indexOf(square.parentNode) + 1
        const j = Array.from(square.parentNode.children).indexOf(square) + 1
        return [i, j]
    } 

    Array.from(board.children).forEach((row, i) => {
        Array.from(row.children).forEach((square, j) => {
            square.addEventListener('click', (evt) => {
                processInput(evt);
            });
        })
    })
}