import React, { useState } from 'react'
import './App.scss'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { useLocale } from '../hooks/useLocale'
import { VehicleStats } from './VehicleStats'
import { VehicleCard } from './VehicleCard'
import { Notification } from './Notification'
import { LoadingSpinner } from './LoadingSpinner'

interface NotificationData {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message?: string
  duration?: number
}

const App: React.FC = () => {
  const [visible, setVisible] = useState(true)
  const [notifications, setNotifications] = useState<NotificationData[]>([])
  const [loading, setLoading] = useState(false)
  const [loadingText, setLoadingText] = useState('Ładowanie...')
  const [, setLocale] = useLocale()

  useNuiEvent('setVisible', setVisible)
  
  // Load locales from NUI message
  useNuiEvent<{ [key: string]: string }>('loadLocales', (data) => {
    setLocale(data)
  })
  
  useNuiEvent<{ type: string; title: string; message?: string }>('showNotification', (data) => {
    const notification: NotificationData = {
      id: Date.now().toString(),
      type: data.type as any,
      title: data.title,
      message: data.message,
      duration: 5000
    }
    setNotifications(prev => [...prev, notification])
  })

  useNuiEvent<{ visible: boolean; text?: string }>('setLoading', (data) => {
    setLoading(data.visible)
    if (data.text) setLoadingText(data.text)
  })

  const removeNotification = (id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id))
  }

  if (!visible) return null

  return (
    <>
      <VehicleStats />
      <VehicleCard />
      
      {loading && (
        <LoadingSpinner 
          overlay={true} 
          text={loadingText}
          size="large"
        />
      )}
      
      {notifications.map(notification => (
        <Notification
          key={notification.id}
          type={notification.type}
          title={notification.title}
          message={notification.message}
          duration={notification.duration}
          onClose={() => removeNotification(notification.id)}
        />
      ))}
    </>
  )
}

export default App