window.skipPosition = () => {
    const positionId = document.querySelector('#position_data').getAttribute('data-id');
    const navButtons = document.querySelectorAll('.nav-btn')
    const options = {
        'nav-previous': 'previous',
        'nav-next': 'next',
        'nav-start': 'start',
        'nav-current': 'current'
    }
    
    const skipPosition = (evt) => {
        evt.preventDefault();
        $.ajax({
            url: '/skip_position',
            type: 'PATCH',
            beforeSend: (xhr) => {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
            data: {
                position_id: positionId,
                option: options[evt.target.id]
            }
        })
    }

    navButtons.forEach((button) => {
        button.addEventListener('click', skipPosition)
    })

    
}