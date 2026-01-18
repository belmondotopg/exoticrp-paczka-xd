class PoolSoundManager {
    constructor() {
        // Pre-load audio files
        this.strikeAudio = [
            new Audio('sounds/strike1.wav'),
            new Audio('sounds/strike2.wav'),
            new Audio('sounds/strike3.wav'),
        ];

        this.bounceAudio = [
            new Audio('sounds/bounce1.wav'),
            new Audio('sounds/bounce2.wav'),
            new Audio('sounds/bounce3.wav'),
            new Audio('sounds/bounce4.wav'),
            new Audio('sounds/bounce5.wav'),
        ];

        // Keep track of last played indexes
        this.lastStrikeIndex = -1;
        this.lastBounceIndex = -1;

        // Sound cooldowns in milliseconds
        this.strikeCooldown = 100;
        this.bounceCooldown = 50;

        // Last played timestamps
        this.lastStrikeTime = 0;
        this.lastBounceTime = 0;

        // Create pools with cloned audio elements
        this.strikePool = this.createAudioPool(this.strikeAudio, 3);
        this.bouncePool = this.createAudioPool(this.bounceAudio, 5);
    }

    createAudioPool(sourceAudio, poolSize) {
        const pool = [];
        // Create poolSize copies of each sound
        for (let i = 0; i < poolSize; i++) {
            const variants = sourceAudio.map(audio => {
                const clone = audio.cloneNode();
                clone.volume = 0.7;
                // Store the original index to track which sound variant this is
                clone.variantIndex = sourceAudio.indexOf(audio);
                return clone;
            });
            pool.push(...variants);
        }
        return pool;
    }

    getNextIndex(totalVariants, lastIndex) {
        if (totalVariants <= 1) return 0;

        if (totalVariants === 2) {
            return lastIndex === 0 ? 1 : 0;
        }

        let nextIndex;
        do {
            nextIndex = Math.floor(Math.random() * totalVariants);
        } while (nextIndex === lastIndex);

        return nextIndex;
    }

    getFreeAudio(pool, desiredVariantIndex) {
        // First try to find a free audio element of the desired variant
        let audio = pool.find(a =>
            (a.paused || a.ended) &&
            a.variantIndex === desiredVariantIndex
        );

        // If no free audio of desired variant, try any free audio
        if (!audio) {
            audio = pool.find(a => a.paused || a.ended);
        }

        return audio;
    }

    playStrike(volume = 1.0) {
        const currentTime = Date.now();
        if (currentTime - this.lastStrikeTime < this.strikeCooldown) {
            return;
        }

        // Get next variant index
        this.lastStrikeIndex = this.getNextIndex(this.strikeAudio.length, this.lastStrikeIndex);

        const audio = this.getFreeAudio(this.strikePool, this.lastStrikeIndex);
        if (!audio) return;

        this.lastStrikeTime = currentTime;

        audio.volume = volume;
        audio.currentTime = 0;
        audio.play().catch(e => console.error('Error playing strike sound:', e));
    }

    playBounce(volume = 1.0) {
        const currentTime = Date.now();
        if (currentTime - this.lastBounceTime < this.bounceCooldown) {
            return;
        }

        // Get next variant index
        this.lastBounceIndex = this.getNextIndex(this.bounceAudio.length, this.lastBounceIndex);

        const audio = this.getFreeAudio(this.bouncePool, this.lastBounceIndex);
        if (!audio) return;

        this.lastBounceTime = currentTime;

        audio.volume = volume;
        audio.currentTime = 0;
        audio.play().catch(e => console.error('Error playing bounce sound:', e));
    }
}

// Usage example:
const soundManager = new PoolSoundManager();

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'playSound') {
        switch (data.soundType) {
            case 'strike':
                soundManager.playStrike(data.volume);
                break;
            case 'bounce':
                soundManager.playBounce(data.volume);
                break;
        }
    }
});