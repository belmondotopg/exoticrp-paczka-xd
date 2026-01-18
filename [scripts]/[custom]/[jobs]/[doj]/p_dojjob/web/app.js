let isDisplayingPhoto = false;
var audioPlayer = null;
let scale = 1;
let isDragging = false;
let startX, startY, scrollLeft, scrollTop;
const zoomStep = 0.1;

window.addEventListener("message", (event) => {
    const data = event.data;
    switch (data.action) {
        case 'displayPrinterPhoto':
            isDisplayingPhoto = true;
            scale = 1;
            isDragging = false;
            startX = null; startY = null; scrollLeft = null; scrollTop = null;
            $('body').prepend(`
            <div class="photo-wrapper photo-in">
                <img src="${data.photo.url}" style="width: ${data.photo.width}px; height: ${data.photo.height}px;">
            </div>`);
            const photoWrapper = document.querySelector('.photo-wrapper img');

            const zoomIn = () => {
                scale += zoomStep;
                photoWrapper.style.transform = `scale(${scale})`;
            };

            const zoomOut = () => {
                if (scale > zoomStep) {
                    scale -= zoomStep;
                    photoWrapper.style.transform = `scale(${scale})`;
                }
            };

            document.addEventListener('keydown', (e) => {
                if (!isDisplayingPhoto) return;
                if (e.key === '+') {
                    zoomIn();
                } else if (e.key === '-') {
                    zoomOut();
                }
            });

            photoWrapper.addEventListener('wheel', (e) => {
                if (!isDisplayingPhoto) return;
                e.preventDefault();
                if (e.deltaY < 0) {
                    zoomIn();
                } else {
                    zoomOut();
                }
            });

            const startDrag = (e) => {
                isDragging = true;
                startX = e.clientX || e.touches[0].clientX;
                startY = e.clientY || e.touches[0].clientY;
                photoWrapper.style.cursor = 'grabbing';
            };

            const drag = (e) => {
                if (!isDragging) return;
                e.preventDefault();
                const x = e.clientX || e.touches[0].clientX;
                const y = e.clientY || e.touches[0].clientY;
                const walkX = (x - startX);
                const walkY = (y - startY);
                const currentTransform = photoWrapper.style.transform.match(/translate\(([^)]+)\)/);
                const [currentX, currentY] = currentTransform
                    ? currentTransform[1].split(',').map(val => parseFloat(val))
                    : [0, 0];
                photoWrapper.style.transform = `translate(${currentX + walkX}px, ${currentY + walkY}px) scale(${scale})`;
                startX = x;
                startY = y;
            };

            const stopDrag = () => {
                isDragging = false;
                photoWrapper.style.cursor = 'grab';
            };

            photoWrapper.style.cursor = 'grab';
            photoWrapper.parentElement.addEventListener('mousedown', startDrag);
            photoWrapper.parentElement.addEventListener('mousemove', drag);
            photoWrapper.parentElement.addEventListener('mouseup', stopDrag);
            photoWrapper.parentElement.addEventListener('mouseleave', stopDrag);
            photoWrapper.parentElement.addEventListener('touchstart', startDrag);
            photoWrapper.parentElement.addEventListener('touchmove', drag);
            photoWrapper.parentElement.addEventListener('touchend', stopDrag);
            break;
        case 'playGavel':
            if (audioPlayer) {
                audioPlayer.pause();
            }
            audioPlayer = new Howl({ src: [`./sounds/gavel_${data.type}.ogg`] });
            audioPlayer.volume(data.volume || 0.5);
            audioPlayer.play();
            break;
    }
})

document.onkeydown = ((e) => {
    if (e.which == 27) {
        if (isDisplayingPhoto) {
            $('.photo-wrapper').removeClass('photo-in');
            setTimeout(() => {
                $('.photo-wrapper').addClass('photo-out');
                setTimeout(() => {
                    $('.photo-wrapper').remove();
                    isDisplayingPhoto = false;
                    $.post('https://p_dojjob/closePhoto');
                }, 490);
            }, 10);
        }
    }
})