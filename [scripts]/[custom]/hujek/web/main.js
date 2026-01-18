const selectors = {
    oxygenWrapper: document.querySelector(".oxygen"),
    chestsCollectedWrapper: document.querySelector(".chestsCollected"),
    normalOpenedCounter: document.getElementById("normal"),
    extraOpenedCounter: document.getElementById("extra")
}

document.addEventListener("DOMContentLoaded", () => {
    console.log('dostalem cyne')
    window.addEventListener("message", function({ data }){
        if (data.action === "update" && data.part === "chestCollected") {
            const { normalOpened, normalTotal, extraOpened, extraTotal } = data.value;
            const { normalOpenedCounter, extraOpenedCounter } = selectors
            
            normalOpenedCounter.innerText = `${normalOpened} / ${normalTotal}`;
            extraOpenedCounter.innerText = `${extraOpened} / ${extraTotal}`;
        } else if (data.action === "show" && data.part === "chestCollected") {
            const { chestsCollectedWrapper, normalOpenedCounter, extraOpenedCounter } = selectors;
            const { normalOpened, normalTotal, extraOpened, extraTotal } = data.value;
    
            normalOpenedCounter.innerText = `${normalOpened} / ${normalTotal}`;
            extraOpenedCounter.innerText = `${extraOpened} / ${extraTotal}`;
    
            chestsCollectedWrapper.style.opacity = "1";
            chestsCollectedWrapper.style.display = "flex";
        } else if (data.action === "hide" && data.part === "chestCollected") {
            const { chestsCollectedWrapper } = selectors;

            chestsCollectedWrapper.style.opacity = "0";
            chestsCollectedWrapper.style.display = "none";
        }
    });
});

