import React from 'react'
import './LoadingSpinner.scss'

interface LoadingSpinnerProps {
  size?: 'small' | 'medium' | 'large'
  text?: string
  overlay?: boolean
}

export const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({ 
  size = 'medium', 
  text = 'Ładowanie...', 
  overlay = false 
}) => {
  const spinnerClass = `loading-spinner ${size}`
  
  if (overlay) {
    return (
      <div className="loading-overlay">
        <div className="loading-content">
          <div className={spinnerClass}></div>
          {text && <p className="loading-text">{text}</p>}
        </div>
      </div>
    )
  }
  
  return (
    <div className="loading-container">
      <div className={spinnerClass}></div>
      {text && <p className="loading-text">{text}</p>}
    </div>
  )
}
