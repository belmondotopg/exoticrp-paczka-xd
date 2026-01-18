import React, { useState, useEffect } from 'react'
import './Notification.scss'

interface NotificationProps {
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message?: string
  duration?: number
  onClose?: () => void
}

export const Notification: React.FC<NotificationProps> = ({
  type,
  title,
  message,
  duration = 5000,
  onClose
}) => {
  const [visible, setVisible] = useState(true)
  const [progress, setProgress] = useState(100)

  useEffect(() => {
    const timer = setInterval(() => {
      setProgress(prev => {
        const newProgress = prev - (100 / (duration / 100))
        if (newProgress <= 0) {
          setVisible(false)
          onClose?.()
          return 0
        }
        return newProgress
      })
    }, 100)

    return () => clearInterval(timer)
  }, [duration, onClose])

  const getIcon = () => {
    switch (type) {
      case 'success':
        return '✓'
      case 'error':
        return '✕'
      case 'warning':
        return '⚠'
      case 'info':
        return 'ℹ'
      default:
        return 'ℹ'
    }
  }

  if (!visible) return null

  return (
    <div className={`notification notification-${type}`}>
      <div className="notification-content">
        <div className="notification-icon">
          {getIcon()}
        </div>
        <div className="notification-text">
          <div className="notification-title">{title}</div>
          {message && <div className="notification-message">{message}</div>}
        </div>
        <button className="notification-close" onClick={() => {
          setVisible(false)
          onClose?.()
        }}>
          ×
        </button>
      </div>
      <div className="notification-progress">
        <div 
          className="notification-progress-bar" 
          style={{ width: `${progress}%` }}
        ></div>
      </div>
    </div>
  )
}
