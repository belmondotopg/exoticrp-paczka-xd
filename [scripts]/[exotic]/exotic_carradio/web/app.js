let antiSpam = new Date().getTime();
let isSelecting = false;
var timeInterval;
let radioData = {
    playTime: 0,
    loop: false,
    url: null,
    volume: 100
};
let languageData = {};
const playBtn = document.getElementById('play-btn');
const musicSlots = document.querySelectorAll('#music-slots .slot');
const loopBtn = document.getElementById('loop-btn');

window.addEventListener("message", (event) => {
    let data = event.data;
    switch(data.action) {
        case 'OpenRadio':
            languageData = data.lang;
            LoadRadio(data.radio.vehicle);
            LoadSlots(data.radio.songs);
            $('.radio').css('display', 'flex');
            break;
        case 'RadioTime':
            StartInterval(data.duration, data.time);
            break;
    }
})

const LoadRadio = ((data) => {
    $('#playing').text(languageData['playing']);
    $('#saved').text(languageData['saved_songs']);
    $('#music-url').attr('placeholder', languageData['music_link']);
    if (data) {
        fetch(`https://noembed.com/embed?dataType=json&url=${data.url}`).then(res => res.json()).then(song => $('#song').text(song.title || song.url));
        radioData.playTime = 0;
        clearInterval(timeInterval);

        radioData.loop = data.loop;
        console.log(radioData.loop)
        loopBtn.onclick = (() => {ToggleLoop(!radioData.loop)});
        loopBtn.innerHTML = `<span>${radioData.loop ? languageData['loop_off'] : languageData['loop_on']}</span>`

        $('#music-url').val(data.url);
        playBtn.onclick = (() => {StopMusic()});
        playBtn.innerHTML = `<i class="fa-solid fa-stop"></i>`;
        $('#music-volume').val(`${data.volume * 100}%`);
        
        StartInterval(data.duration, data.time)
    } else {
        radioData.loop = false;
        radioData.playTime = 0;
        radioData.url = null;
        radioData.volume = 100;
        clearInterval(timeInterval);

        $('#song').text(languageData['nothing']);
        $('#music-url').val('');
        $('#music-volume').val(`100%`);

        loopBtn.onclick = (() => {ToggleLoop(!radioData.loop)});
        loopBtn.innerHTML = `<span>${languageData['loop_on']}</span>`;

        playBtn.onclick = (() => {PlayMusic()});
        playBtn.innerHTML = `<i class="fa-solid fa-play"></i>`;

        $('#timer').text(`${languageData['remaining_time']}: 00:00:00`);
    }
})

const LoadSlots = ((data) => {
    musicSlots.forEach(slot => {
        slot.onclick = (() => {});
    })

    musicSlots.forEach(slot => {
        let number = parseInt($(slot).text());
        for (let i in data) {
            let music = data[i];
            if (music.slot == number) {
                slot.onclick = (() => {PlayMusic(music.url)});
            }
        }
    })
})

const PlayMusic = ((link) => {
    let url = link ? link : $('#music-url').val();
    if (url.length < 1 || url.includes('script')) return;

    let nowDate = new Date().getTime();
    if (antiSpam > nowDate) return;

    let volume = $('#music-volume').val();
    volume.replace('%', '');
    volume = (parseInt(volume) / 100);

    antiSpam = nowDate + 500;
    clearInterval(timeInterval);
    radioData.playTime = 0;
    radioData.url = url;
    $.post('https://exotic_carradio/PlayMusic', JSON.stringify({url: url, volume: volume}));
    fetch(`https://noembed.com/embed?dataType=json&url=${url}`).then(res => res.json()).then(data => $('#song').text(data.title || data.url));
    playBtn.onclick = (() => {StopMusic()});
    playBtn.innerHTML = `<i class="fa-solid fa-stop"></i>`;
})

const StopMusic = (() => {
    let nowDate = new Date().getTime();
    if (antiSpam > nowDate) return;

    antiSpam = nowDate + 500;
    $.post('https://exotic_carradio/StopMusic');
    playBtn.onclick = (() => {PlayMusic()});
    playBtn.innerHTML = `<i class="fa-solid fa-play"></i>`;
    clearInterval(timeInterval);
    radioData.playTime = 0;
    radioData.url = null;
})

const ChangeVolume = ((type) => {
    let volume = $('#music-volume').val();
    volume.replace('%', '');
    volume = parseInt(volume);
    if (type == 'up' && volume < 100) {
        volume = volume + 10;
        $('#music-volume').val(`${volume}%`);
        if (radioData.url) {
            $.post('https://exotic_carradio/ChangeVolume', JSON.stringify({volume: volume}));
        }
        return;
    }

    if (type == 'down' && volume >= 10) {
        volume = volume - 10;
        $('#music-volume').val(`${volume}%`);
        if (radioData.url) {
            $.post('https://exotic_carradio/ChangeVolume', JSON.stringify({volume: volume}));
        }
        return;
    }
})

const SaveMusic = (() => {
    if (isSelecting) return;
    
    let url = $('#music-url').val();
    if (url.length < 1 || url.includes('script')) return;

    let nowDate = new Date().getTime();
    if (antiSpam > nowDate) return;
    antiSpam = nowDate + 500;
    isSelecting = true;
    musicSlots.forEach(slot => {
        $(slot).css('background', '#ffffff1f');
        slot.onclick = (() => {
            isSelecting = false;
            slot.onclick = (() => {PlayMusic(url)});
            let number = $(slot).text();
            musicSlots.forEach(slot => {
                $(slot).css('background', '#ffffff13');
            });
            $.post('https://exotic_carradio/SaveMusic', JSON.stringify({url: url, slot: number}));
        })
    })
})

const ToggleLoop = (() => {
    if (!radioData.url) return;

    let nowDate = new Date().getTime();
    if (antiSpam > nowDate) return;
    antiSpam = nowDate + 500;
    radioData.loop = !radioData.loop;
    loopBtn.innerHTML = `<span>${!radioData.loop ? languageData['loop_on'] : languageData['loop_off']}</span>`
    loopBtn.onclick = (() => {ToggleLoop(!radioData.loop)});
    $.post('https://exotic_carradio/ToggleLoop', JSON.stringify({loop: radioData.loop}));
})

const StartInterval = ((duration, time) => {
    radioData.playTime = (Math.floor(duration) - Math.floor(time));
    $('#timer').text(FormatTime(radioData.playTime));
    timeInterval = setInterval(() => {
        radioData.playTime--;
        let formattedTime = FormatTime(radioData.playTime);
        $('#timer').text(formattedTime);
        if (radioData.playTime < 1) {
            if (radioData.loop) {
                radioData.playTime = (Math.floor(duration) - Math.floor(time));
            } else {
                clearInterval(timeInterval);
                radioData.playTime = 0;
            }
        }
    }, 1000);
})

const FormatTime = ((time) => {
    let hours = Math.floor(time / 3600);
    let minutes = Math.floor((time - (hours * 3600)) / 60);
    let seconds = (time - (hours * 3600)) - (minutes * 60);
    hours = hours.toString(); minutes = minutes.toString(); seconds = seconds.toString();
    hours = hours.padStart(2, '0'); minutes = minutes.padStart(2, '0'); seconds = seconds.padStart(2, '0');
    return `${languageData['remaining_time']}: ${hours}:${minutes}:${seconds}`
})

setInterval(() => {
    let nowDate = new Date();
    let hour = nowDate.getHours();
    let minute = nowDate.getMinutes();
    hour = hour.toString().padStart(2, '0');
    minute = minute.toString().padStart(2, '0');
    $('#time').text(hour + ':' + minute);
}, 5000);

document.onkeydown = ((e) => {
    if (e.which == 27) {
        if (isSelecting) {
            musicSlots.forEach(slot => {
                $(slot).css('background', '#ffffff13');
            });
            isSelecting = false; return
        }

        clearInterval(timeInterval);
        $('.radio').hide();
        $.post('https://exotic_carradio/CloseRadio');
    }
})