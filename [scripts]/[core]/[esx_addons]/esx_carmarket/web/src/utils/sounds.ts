export class SoundManager {
  private static instance: SoundManager
  private audioContext: AudioContext | null = null
  private sounds: Map<string, AudioBuffer> = new Map()
  private volume: number = 0.3

  private constructor() {
    this.initAudioContext()
  }

  public static getInstance(): SoundManager {
    if (!SoundManager.instance) {
      SoundManager.instance = new SoundManager()
    }
    return SoundManager.instance
  }

  private async initAudioContext() {
    try {
      this.audioContext = new (window.AudioContext || (window as any).webkitAudioContext)()
      await this.loadSounds()
    } catch (error) {
      console.warn('Audio context not supported:', error)
    }
  }

  private async loadSounds() {
    if (!this.audioContext) return

    this.sounds.set('success', this.generateTone(800, 0.2, 'sine'))
    this.sounds.set('error', this.generateTone(300, 0.3, 'sawtooth'))
    this.sounds.set('click', this.generateTone(1000, 0.1, 'square'))
    this.sounds.set('notification', this.generateTone(600, 0.4, 'sine'))
    this.sounds.set('favorite', this.generateTone(523, 0.2, 'sine'))
    this.sounds.set('unfavorite', this.generateTone(392, 0.2, 'sine'))
  }

  private generateTone(frequency: number, duration: number, type: OscillatorType): AudioBuffer {
    if (!this.audioContext) throw new Error('Audio context not initialized')

    const sampleRate = this.audioContext.sampleRate
    const buffer = this.audioContext.createBuffer(1, sampleRate * duration, sampleRate)
    const data = buffer.getChannelData(0)

    for (let i = 0; i < data.length; i++) {
      const t = i / sampleRate
      let sample = 0

      switch (type) {
        case 'sine':
          sample = Math.sin(2 * Math.PI * frequency * t)
          break
        case 'square':
          sample = Math.sin(2 * Math.PI * frequency * t) > 0 ? 1 : -1
          break
        case 'sawtooth':
          sample = 2 * (t * frequency - Math.floor(t * frequency + 0.5))
          break
      }

      const envelope = Math.exp(-t * 3)
      data[i] = sample * envelope * this.volume
    }

    return buffer
  }

  public playSound(soundName: string) {
    if (!this.audioContext || !this.sounds.has(soundName)) return

    const buffer = this.sounds.get(soundName)!
    const source = this.audioContext.createBufferSource()
    const gainNode = this.audioContext.createGain()

    source.buffer = buffer
    source.connect(gainNode)
    gainNode.connect(this.audioContext.destination)

    gainNode.gain.setValueAtTime(this.volume, this.audioContext.currentTime)
    source.start()
  }

  public setVolume(volume: number) {
    this.volume = Math.max(0, Math.min(1, volume))
  }

  public getVolume(): number {
    return this.volume
  }

  public playSuccess() {
    this.playSound('success')
  }

  public playError() {
    this.playSound('error')
  }

  public playClick() {
    this.playSound('click')
  }

  public playNotification() {
    this.playSound('notification')
  }

  public playFavorite() {
    this.playSound('favorite')
  }

  public playUnfavorite() {
    this.playSound('unfavorite')
  }
}

export const soundManager = SoundManager.getInstance()
