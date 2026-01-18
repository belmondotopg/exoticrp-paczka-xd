import { useEffect, useState } from "react"
import './TestDriveTimer.scss'
import { useNuiEvent } from '../hooks/useNuiEvent'

interface TimerData {
  remainingTime: number
}

export const TestDriveTimer: React.FC = () => {
  const [visible, setVisible] = useState(false)
  const [timeLeft, setTimeLeft] = useState(0)

  useNuiEvent<boolean>('setTestDriveVisible', (show) => {
    setVisible(show)
    if (!show) {
      setTimeLeft(0)
    }
  })

  useNuiEvent<TimerData>('updateTestDriveTime', (data) => {
    setTimeLeft(data.remainingTime)
  })

  if (!visible || timeLeft <= 0) return null

  const minutes = Math.floor(timeLeft / 60)
  const seconds = timeLeft % 60

  return (
    <div className="test-drive-timer">
      <div className="timer-content">
        <div className="timer-text">
          <div className="timer-label">JAZDA TESTOWA</div>
          <div className="timer-value">
            {String(minutes).padStart(2, '0')}:{String(seconds).padStart(2, '0')}
          </div>
          <div className="timer-instruction">
            Wyjdź z pojazdu aby zakończyć jazdę testową
          </div>
        </div>
      </div>
    </div>
  )
}


