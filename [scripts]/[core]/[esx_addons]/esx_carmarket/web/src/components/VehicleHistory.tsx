import React, { useState, useEffect } from 'react'
import './VehicleHistory.scss'

interface HistoryEntry {
  id: string
  action: 'view' | 'test_drive' | 'favorite' | 'compare' | 'purchase'
  vehicleId: number
  vehicleName: string
  timestamp: Date
  details?: string
}

interface VehicleHistoryProps {
  onClose: () => void
}

export const VehicleHistory: React.FC<VehicleHistoryProps> = ({ onClose }) => {
  const [history, setHistory] = useState<HistoryEntry[]>([])
  const [filter, setFilter] = useState<string>('all')
  const [stats, setStats] = useState({
    totalViews: 0,
    totalTestDrives: 0,
    totalFavorites: 0,
    totalComparisons: 0,
    totalPurchases: 0
  })

  useEffect(() => {
    const savedHistory = localStorage.getItem('vehicleHistory')
    if (savedHistory) {
      const parsedHistory = JSON.parse(savedHistory).map((entry: any) => ({
        ...entry,
        timestamp: new Date(entry.timestamp)
      }))
      setHistory(parsedHistory)
      calculateStats(parsedHistory)
    }
  }, [])

  const calculateStats = (historyData: HistoryEntry[]) => {
    const newStats = {
      totalViews: historyData.filter(h => h.action === 'view').length,
      totalTestDrives: historyData.filter(h => h.action === 'test_drive').length,
      totalFavorites: historyData.filter(h => h.action === 'favorite').length,
      totalComparisons: historyData.filter(h => h.action === 'compare').length,
      totalPurchases: historyData.filter(h => h.action === 'purchase').length
    }
    setStats(newStats)
  }

  const getActionIcon = (action: string) => {
    switch (action) {
      case 'view': return '👁️'
      case 'test_drive': return '🚗'
      case 'favorite': return '❤️'
      case 'compare': return '⚖️'
      case 'purchase': return '💰'
      default: return '📝'
    }
  }

  const getActionText = (action: string) => {
    switch (action) {
      case 'view': return 'Przeglądano'
      case 'test_drive': return 'Jazda testowa'
      case 'favorite': return 'Dodano do ulubionych'
      case 'compare': return 'Porównano'
      case 'purchase': return 'Zakupiono'
      default: return 'Nieznana akcja'
    }
  }

  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('pl-PL', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date)
  }

  const filteredHistory = history.filter(entry => 
    filter === 'all' || entry.action === filter
  )

  const clearHistory = () => {
    localStorage.removeItem('vehicleHistory')
    setHistory([])
    setStats({
      totalViews: 0,
      totalTestDrives: 0,
      totalFavorites: 0,
      totalComparisons: 0,
      totalPurchases: 0
    })
  }

  return (
    <div className="history-overlay">
      <div className="history-container">
        <div className="history-header">
          <h2>Historia i Statystyki</h2>
          <button className="close-btn" onClick={onClose}>×</button>
        </div>

        <div className="history-content">
          <div className="stats-section">
            <h3>Statystyki</h3>
            <div className="stats-grid">
              <div className="stat-item">
                <div className="stat-icon">👁️</div>
                <div className="stat-value">{stats.totalViews}</div>
                <div className="stat-label">Przeglądnięć</div>
              </div>
              <div className="stat-item">
                <div className="stat-icon">🚗</div>
                <div className="stat-value">{stats.totalTestDrives}</div>
                <div className="stat-label">Jazd testowych</div>
              </div>
              <div className="stat-item">
                <div className="stat-icon">❤️</div>
                <div className="stat-value">{stats.totalFavorites}</div>
                <div className="stat-label">Ulubionych</div>
              </div>
              <div className="stat-item">
                <div className="stat-icon">⚖️</div>
                <div className="stat-value">{stats.totalComparisons}</div>
                <div className="stat-label">Porównań</div>
              </div>
              <div className="stat-item">
                <div className="stat-icon">💰</div>
                <div className="stat-value">{stats.totalPurchases}</div>
                <div className="stat-label">Zakupów</div>
              </div>
            </div>
          </div>

          <div className="history-section">
            <div className="history-controls">
              <h3>Historia aktywności</h3>
              <div className="controls">
                <select
                  value={filter}
                  onChange={(e) => setFilter(e.target.value)}
                  className="filter-select"
                >
                  <option value="all">Wszystkie</option>
                  <option value="view">Przeglądania</option>
                  <option value="test_drive">Jazdy testowe</option>
                  <option value="favorite">Ulubione</option>
                  <option value="compare">Porównania</option>
                  <option value="purchase">Zakupy</option>
                </select>
                <button className="clear-btn" onClick={clearHistory}>
                  Wyczyść historię
                </button>
              </div>
            </div>

            <div className="history-list">
              {filteredHistory.length === 0 ? (
                <div className="no-history">
                  <p>Brak historii aktywności</p>
                </div>
              ) : (
                filteredHistory.map(entry => (
                  <div key={entry.id} className="history-entry">
                    <div className="entry-icon">
                      {getActionIcon(entry.action)}
                    </div>
                    <div className="entry-content">
                      <div className="entry-title">
                        {getActionText(entry.action)}: {entry.vehicleName}
                      </div>
                      <div className="entry-details">
                        {entry.details && <span>{entry.details}</span>}
                        <span className="entry-time">{formatDate(entry.timestamp)}</span>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        <div className="history-footer">
          <button className="close-button" onClick={onClose}>
            Zamknij
          </button>
        </div>
      </div>
    </div>
  )
}
