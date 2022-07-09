window.boardInputs = () => {
    board = document.querySelector('.board')
    position_data = document.querySelector('#position_data').getAttribute('data-position')
    positionId = document.querySelector('#position_data').getAttribute('data-id')
    position = JSON.parse(position_data)
    queue = [null, null]
    const processInput = (evt) => {

        coords = getSquareCoordinates(evt.target)
        if (queue[0] === null) {
            queue[0] = coords
        } else if (queue[0] === coords) {
            queue[0] = null
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
            }).done((data, textStatus, jqHXR) => {
                console.log(data);
                queue[0] = null;
                queue[1] = null;
            }).fail((jqXHR, textStatus, errorThrown) => {
                console.log('error')
                queue[0] = null;
                queue[1] = null;
            });
            }
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