import React, { useState, useEffect, useMemo } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faDollarSign, faTimes, faArrowLeft, faSave, faPills } from '@fortawesome/free-solid-svg-icons'
import { fetchNui } from '../utils/fetchNui'
import './PriceManagement.scss'

interface PriceManagementProps {
  gymName: string
  prices?: {
    kreatyna: number
    l_karnityna: number
    bialko: number
  }
  onClose: () => void
  onBack?: () => void
}

const PriceManagement: React.FC<PriceManagementProps> = ({ gymName, prices = { kreatyna: 100, l_karnityna: 150, bialko: 200 }, onClose, onBack }) => {
  const [localPrices, setLocalPrices] = useState(prices)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    setLocalPrices(prices)
  }, [prices])

  const handlePriceChange = (supplement: string, value: number) => {
    setLocalPrices(prev => ({
      ...prev,
      [supplement]: Math.max(0, value)
    }))
  }

  const handleSave = () => {
    if (loading) return
    
    setLoading(true)
    
    fetchNui('esx_gym/updateSupplementPrices', {
      prices: localPrices,
      gymName: gymName
    }).finally(() => {
      setLoading(false)
    })
  }

  const supplements = useMemo(() => [
    {
      key: 'kreatyna',
      name: 'Kreatyna',
      description: 'Suplement zwiększający siłę o 50%',
      color: '#ef4444',
      icon: faPills
    },
    {
      key: 'l_karnityna',
      name: 'L-Karnityna',
      description: 'Suplement zwiększający wytrzymałość o 40%',
      color: '#3b82f6',
      icon: faPills
    },
    {
      key: 'bialko',
      name: 'Białko',
      description: 'Suplement zwiększający pojemność płuc o 30%',
      color: '#10b981',
      icon: faPills
    }
  ], [])

  const hasChanges = JSON.stringify(localPrices) !== JSON.stringify(prices)

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
            <FontAwesomeIcon icon={faDollarSign} /> Zarządzanie Cenami
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
              Ustaw ceny suplementów w siłowni. Wyższe ceny oznaczają większy zysk.
            </p>
          </div>

          <div className="price-management__prices">
            <div className="price-management__prices-header">
              <h3 className="price-management__prices-title">
                <FontAwesomeIcon icon={faPills} /> Ceny Suplementów
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
              {supplements.map((supplement) => (
                <div key={supplement.key} className="price-management__item">
                  <div className="price-management__item-header">
                    <div 
                      className="price-management__item-icon"
                      style={{ backgroundColor: supplement.color }}
                    >
                      <FontAwesomeIcon icon={supplement.icon} />
                    </div>
                    <div className="price-management__item-info">
                      <h4 className="price-management__item-name">{supplement.name}</h4>
                      <p className="price-management__item-description">{supplement.description}</p>
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
                        value={localPrices[supplement.key as keyof typeof localPrices]}
                        onChange={(e) => handlePriceChange(supplement.key, parseInt(e.target.value) || 0)}
                        min="0"
                        max="10000"
                        step="1"
                      />
                    </div>
                    
                    <div className="price-management__item-price-info">
                      <span className="price-management__item-price-current">
                        Obecna: ${prices[supplement.key as keyof typeof prices]}
                      </span>
                      {localPrices[supplement.key as keyof typeof localPrices] !== prices[supplement.key as keyof typeof prices] && (
                        <span className="price-management__item-price-change">
                          Nowa: ${localPrices[supplement.key as keyof typeof localPrices]}
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
                <strong>Niskie ceny</strong> (0-50$): Więcej klientów, mniejszy zysk
              </li>
              <li className="price-management__info-item">
                <strong>Średnie ceny</strong> (50-150$): Równowaga między klientami a zyskiem
              </li>
              <li className="price-management__info-item">
                <strong>Wysokie ceny</strong> (150$+): Mniej klientów, większy zysk
              </li>
              <li className="price-management__info-item">
                <strong>Zbyt wysokie ceny</strong> mogą zniechęcić klientów do zakupów
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

export default PriceManagement