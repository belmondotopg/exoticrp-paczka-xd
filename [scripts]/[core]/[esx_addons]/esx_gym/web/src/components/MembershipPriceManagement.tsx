import React, { useState, useEffect, useMemo } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faDollarSign, faTimes, faArrowLeft, faSave, faTicket } from '@fortawesome/free-solid-svg-icons'
import { fetchNui } from '../utils/fetchNui'
import './PriceManagement.scss'

interface MembershipPriceManagementProps {
  gymName: string
  prices?: {
    daily: number
    weekly: number
    monthly: number
  }
  onClose: () => void
  onBack?: () => void
}

const MembershipPriceManagement: React.FC<MembershipPriceManagementProps> = ({ 
  gymName, 
  prices = { daily: 3000, weekly: 15000, monthly: 50000 }, 
  onClose, 
  onBack 
}) => {
  const [localPrices, setLocalPrices] = useState(prices)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    setLocalPrices(prices)
  }, [prices])

  const handlePriceChange = (passType: string, value: number) => {
    setLocalPrices(prev => ({
      ...prev,
      [passType]: Math.max(0, value)
    }))
  }

  const handleSave = () => {
    if (loading) return
    
    setLoading(true)
    
    fetchNui('esx_gym/updatePassPrices', {
      prices: localPrices,
      gymName: gymName
    }).finally(() => {
      setLoading(false)
    })
  }

  const passes = useMemo(() => [
    {
      key: 'daily',
      name: 'Karnet Dzienny',
      description: 'Dostęp do siłowni na 24 godziny',
      color: '#10b981',
      icon: faTicket,
      duration: '24h'
    },
    {
      key: 'weekly',
      name: 'Karnet Tygodniowy',
      description: 'Dostęp do siłowni na 7 dni',
      color: '#3b82f6',
      icon: faTicket,
      duration: '7 dni'
    },
    {
      key: 'monthly',
      name: 'Karnet Miesięczny',
      description: 'Dostęp do siłowni na 30 dni',
      color: '#8b5cf6',
      icon: faTicket,
      duration: '30 dni'
    }
  ], [])

  const hasChanges = useMemo(() => JSON.stringify(localPrices) !== JSON.stringify(prices), [localPrices, prices])

  return (
    <div className="price-management">
      <div className="price-management__container">
        <div className="price-management__header">
          {onBack && (
            <button 
              className="price-management__back"
              onClick={onBack}
            >
              <FontAwesomeIcon icon={faArrowLeft} />
            </button>
          )}
          <h1 className="price-management__title">
            <FontAwesomeIcon icon={faDollarSign} /> Zarządzanie Cenami Karnetów
          </h1>
          <button 
            className="price-management__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="price-management__content">
          <div className="price-management__info">
            <p className="price-management__description">
              Ustaw ceny karnetów w siłowni. Wyższe ceny oznaczają większy zysk z każdego sprzedanego karnetu.
            </p>
          </div>

          <div className="price-management__prices">
            <div className="price-management__prices-header">
              <h3 className="price-management__prices-title">
                <FontAwesomeIcon icon={faTicket} /> Ceny Karnetów
              </h3>
              <div className="price-management__prices-actions">
                <button
                  className={`price-management__save-btn ${loading ? 'price-management__save-btn--loading' : ''} ${!hasChanges ? 'price-management__save-btn--disabled' : ''}`}
                  onClick={handleSave}
                  disabled={loading || !hasChanges}
                >
                  <FontAwesomeIcon icon={faSave} />
                  <span>
                    {loading ? 'Zapisywanie...' : 'Zapisz Zmiany'}
                  </span>
                </button>
              </div>
            </div>

            <div className="price-management__items">
              {passes.map((pass) => (
                <div key={pass.key} className="price-management__item">
                  <div className="price-management__item-header">
                    <div 
                      className="price-management__item-icon"
                      style={{ backgroundColor: pass.color }}
                    >
                      <FontAwesomeIcon icon={pass.icon} />
                    </div>
                    <div className="price-management__item-info">
                      <h4 className="price-management__item-name">{pass.name}</h4>
                      <p className="price-management__item-description">
                        {pass.description} • Czas trwania: {pass.duration}
                      </p>
                    </div>
                  </div>

                  <div className="price-management__item-price">
                    <div className="price-management__item-price-input">
                      <label className="price-management__item-price-label">
                        Cena ($)
                      </label>
                      <input
                        type="number"
                        className="price-management__item-price-field"
                        value={localPrices[pass.key as keyof typeof localPrices]}
                        onChange={(e) => handlePriceChange(pass.key, parseInt(e.target.value) || 0)}
                        min="0"
                        max="1000000"
                        step="100"
                      />
                    </div>
                    
                    <div className="price-management__item-price-info">
                      <span className="price-management__item-price-current">
                        Obecna: ${prices[pass.key as keyof typeof prices]?.toLocaleString()}
                      </span>
                      {localPrices[pass.key as keyof typeof localPrices] !== prices[pass.key as keyof typeof prices] && (
                        <span className="price-management__item-price-change">
                          Nowa: ${localPrices[pass.key as keyof typeof localPrices]?.toLocaleString()}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="price-management__info-section">
            <h4 className="price-management__info-title">Wskazówki Cenowe</h4>
            <ul className="price-management__info-list">
              <li className="price-management__info-item">
                <strong>Karnet dzienny</strong> powinien być najtańszy, aby zachęcić nowych klientów
              </li>
              <li className="price-management__info-item">
                <strong>Karnet tygodniowy</strong> powinien oferować lepszą wartość niż 7x karnet dzienny
              </li>
              <li className="price-management__info-item">
                <strong>Karnet miesięczny</strong> powinien być najbardziej opłacalny dla stałych klientów
              </li>
              <li className="price-management__info-item">
                <strong>Zbyt wysokie ceny</strong> mogą zniechęcić klientów do zakupów karnetów
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

export default MembershipPriceManagement

