import React, { useState, useEffect, useMemo } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faTruck, faTimes, faArrowLeft, faShoppingCart, faBox, faCheck } from '@fortawesome/free-solid-svg-icons'
import { SupplementStock } from '../types/gym'
import { fetchNui } from '../utils/fetchNui'
import './RestockManagement.scss'

interface RestockManagementProps {
  gymName: string
  stock?: SupplementStock
  onClose: () => void
  onBack?: () => void
  maxStock?: number
}

const DEFAULT_MAX_STOCK = 200

const RestockManagement: React.FC<RestockManagementProps> = ({ gymName, stock = {}, onClose, onBack, maxStock }) => {
  const MAX_STOCK = maxStock || DEFAULT_MAX_STOCK
  const [loading, setLoading] = useState<string | null>(null)
  const [deliveryPrices, setDeliveryPrices] = useState<any>({ kreatyna: 100, l_karnityna: 150, bialko: 200 })
  const [inputQuantities, setInputQuantities] = useState<{[key: string]: string}>({})

  useEffect(() => {
    // Pobierz ceny dostaw z serwera
    fetchNui('esx_gym/getDeliveryPrices', { gymName: gymName })
      .then((prices) => {
        if (prices) {
          setDeliveryPrices(prices)
        }
      })
      .catch(() => {
        // Użyj domyślnych cen jeśli błąd (zgodne z bazą danych)
        setDeliveryPrices({ kreatyna: 100, l_karnityna: 150, bialko: 200 })
      })
  }, [gymName])

  const handleOrderDelivery = () => {
    if (loading) return
    
    setLoading('delivery')
    
    // Opcja 2: Zamów suplementy - wymaga misji delivery, tańsza (70% ceny)
    fetchNui('esx_gym/startDelivery', {
      gymName: gymName
    }).finally(() => {
      setLoading(null)
    })
  }

  const handleBuyAllSupplies = () => {
    if (loading) return
    
    setLoading('buyAll')
    
    // Opcja 1: Uzupełnij wszystkie zapasy - natychmiastowe, droższa (100% ceny)
    fetchNui('esx_gym/buyAllSupplies', {
      gymName: gymName
    }).finally(() => {
      setLoading(null)
    })
  }

  const handleQuantityChange = (key: string, value: string) => {
    // Allow empty string or numbers
    if (value === '' || /^\d+$/.test(value)) {
      setInputQuantities({
        ...inputQuantities,
        [key]: value
      })
    }
  }

  const handleBuySelected = () => {
    if (loading) return

    const quantitiesToBuy: {[key: string]: number} = {}
    let totalItems = 0

    Object.entries(inputQuantities).forEach(([key, value]) => {
      const numVal = parseInt(value)
      if (!isNaN(numVal) && numVal > 0) {
        quantitiesToBuy[key] = numVal
        totalItems += numVal
      }
    })

    if (totalItems === 0) return

    setLoading('buySelected')

    fetchNui('esx_gym/buySelectedSupplies', {
      gymName: gymName,
      quantities: quantitiesToBuy
    }).finally(() => {
      setLoading(null)
      setInputQuantities({})
    })
  }

  const supplements = useMemo(() => [
    {
      key: 'kreatyna',
      name: 'Kreatyna',
      current: stock?.kreatyna || 0,
      max: MAX_STOCK,
      price: deliveryPrices.kreatyna || 100,
      color: '#ef4444'
    },
    {
      key: 'l_karnityna',
      name: 'L-Karnityna',
      current: stock?.l_karnityna || 0,
      max: MAX_STOCK,
      price: deliveryPrices.l_karnityna || 150,
      color: '#3b82f6'
    },
    {
      key: 'bialko',
      name: 'Białko',
      current: stock?.bialko || 0,
      max: MAX_STOCK,
      price: deliveryPrices.bialko || 200,
      color: '#10b981'
    }
  ], [stock, MAX_STOCK, deliveryPrices])

  // Oblicz całkowity koszt brakujących suplementów
  const totalMissing = useMemo(() => supplements.reduce((sum, supplement) => {
    const needed = supplement.max - supplement.current
    return sum + needed
  }, 0), [supplements])

  const totalCostFull = useMemo(() => supplements.reduce((sum, supplement) => {
    const needed = supplement.max - supplement.current
    return sum + (needed * supplement.price)
  }, 0), [supplements])
  
  // Koszt dostawy osobistej (70% ceny - 30% zniżki)
  const deliveryCost = useMemo(() => Math.floor(totalCostFull * 0.7), [totalCostFull])

  // Calculate selected cost
  const selectedCost = useMemo(() => supplements.reduce((sum, supplement) => {
    const quantity = parseInt(inputQuantities[supplement.key] || '0')
    if (isNaN(quantity) || quantity <= 0) return sum
    return sum + (quantity * supplement.price)
  }, 0), [supplements, inputQuantities])

  const selectedCount = useMemo(() => Object.values(inputQuantities).reduce((sum, val) => {
    const num = parseInt(val)
    return sum + (isNaN(num) ? 0 : num)
  }, 0), [inputQuantities])

  return (
    <div className="restock-management">
      <div className="restock-management__container">
        <div className="restock-management__header">
          {onBack && (
            <button 
              className="restock-management__back"
              onClick={onBack}
            >
              <FontAwesomeIcon icon={faArrowLeft} />
            </button>
          )}
          <h1 className="restock-management__title">
            <FontAwesomeIcon icon={faTruck} /> Zarządzanie Dostawami
          </h1>
          <button 
            className="restock-management__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="restock-management__content">
          <div className="restock-management__info">
            <h2 className="restock-management__gym-name">{gymName}</h2>
            <p className="restock-management__description">
              Zarządzaj dostawami suplementów do siłowni. Uzupełnij zapasy natychmiastowo lub zamów dostawę z misją.
            </p>
          </div>

          <div className="restock-management__stock">
            <div className="restock-management__stock-header">
              <h3 className="restock-management__stock-title">
                <FontAwesomeIcon icon={faBox} /> Stan Magazynu
              </h3>
              <div className="restock-management__stock-summary">
                <span className="restock-management__stock-total">
                  Łącznie: {supplements.reduce((sum, s) => sum + s.current, 0)}/{supplements.reduce((sum, s) => sum + s.max, 0)}szt.
                </span>
              </div>
            </div>

            <div className="restock-management__items">
              {supplements.map((supplement) => {
                const percentage = (supplement.current / supplement.max) * 100
                
                return (
                  <div key={supplement.key} className="restock-management__item">
                    <div className="restock-management__item-header">
                      <div 
                        className="restock-management__item-icon"
                        style={{ backgroundColor: supplement.color }}
                      >
                        <FontAwesomeIcon icon={faBox} />
                      </div>
                      <div className="restock-management__item-info">
                        <h4 className="restock-management__item-name">{supplement.name}</h4>
                        <p className="restock-management__item-stock">
                          {supplement.current}/{supplement.max}szt.
                        </p>
                      </div>
                    </div>

                    <div className="restock-management__item-details">
                      <div className="restock-management__item-progress">
                        <div className="restock-management__item-progress-bar">
                          <div 
                            className="restock-management__item-progress-fill"
                            style={{ 
                              width: `${percentage}%`,
                              backgroundColor: supplement.color
                            }}
                          />
                        </div>
                        <span className="restock-management__item-progress-text">
                          {percentage.toFixed(0)}%
                        </span>
                      </div>
                      
                      <div className="restock-management__item-actions" style={{ marginTop: '10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                        <div className="restock-management__item-cost">
                            <span className="restock-management__item-cost-label">Cena za sztukę:</span>
                            <span className="restock-management__item-cost-value">${supplement.price}</span>
                        </div>
                        <div className="restock-management__item-input-wrapper" style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
                            <span style={{ fontSize: '12px', color: '#aaa' }}>Kup:</span>
                            <input 
                                type="text" 
                                className="restock-management__item-input"
                                placeholder="Ilość"
                                value={inputQuantities[supplement.key] || ''}
                                onChange={(e) => handleQuantityChange(supplement.key, e.target.value)}
                                style={{
                                    background: 'rgba(255, 255, 255, 0.1)',
                                    border: '1px solid rgba(255, 255, 255, 0.2)',
                                    color: 'white',
                                    padding: '5px 10px',
                                    borderRadius: '4px',
                                    width: '80px',
                                    textAlign: 'center'
                                }}
                            />
                        </div>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
            
            {/* Added Buy Selected Button inside stock section or below */}
             <div className="restock-management__custom-buy" style={{ marginTop: '15px', padding: '15px', background: 'rgba(0,0,0,0.2)', borderRadius: '8px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <div>
                        <h4 style={{ margin: 0, color: 'white' }}>Niestandardowe zamówienie</h4>
                        <p style={{ margin: '5px 0 0', fontSize: '12px', color: '#aaa' }}>Wpisz ilość powyżej dla każdego suplementu</p>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                        <div style={{ fontSize: '18px', fontWeight: 'bold', color: '#10b981' }}>${selectedCost.toLocaleString()}</div>
                        <div style={{ fontSize: '12px', color: '#aaa' }}>{selectedCount} szt.</div>
                    </div>
                </div>
                <button
                    className={`restock-management__action-btn restock-management__action-btn--buy ${loading === 'buySelected' ? 'restock-management__action-btn--loading' : ''}`}
                    onClick={handleBuySelected}
                    disabled={loading !== null || selectedCount === 0}
                    style={{ width: '100%', padding: '10px' }}
                >
                    <FontAwesomeIcon icon={faCheck} />
                    <span>
                        {loading === 'buySelected' ? 'Kupowanie...' : 'Kup wybrane'}
                    </span>
                </button>
            </div>
          </div>

          <div className="restock-management__actions">
            <div className="restock-management__action">
              <div className="restock-management__action-info">
                <h4 className="restock-management__action-title">
                  <FontAwesomeIcon icon={faShoppingCart} /> 1. Uzupełnij wszystkie zapasy
                </h4>
                <p className="restock-management__action-description">
                  Natychmiastowe uzupełnienie magazynu do maksymalnej pojemności ({MAX_STOCK} szt. każdego suplementu). Towar pojawi się od razu.
                </p>
                <div className="restock-management__action-cost">
                  <span className="restock-management__action-cost-label">Koszt (100%):</span>
                  <span className="restock-management__action-cost-value">${totalCostFull > 0 ? totalCostFull.toLocaleString() : '0'}</span>
                  <span className="restock-management__action-cost-info">({totalMissing} szt.)</span>
                </div>
              </div>
              <button
                className={`restock-management__action-btn restock-management__action-btn--buy ${loading === 'buyAll' ? 'restock-management__action-btn--loading' : ''}`}
                onClick={handleBuyAllSupplies}
                disabled={loading !== null || totalMissing === 0}
              >
                <FontAwesomeIcon icon={faShoppingCart} />
                <span>
                  {loading === 'buyAll' ? 'Zamawianie...' : 'Uzupełnij wszystko'}
                </span>
              </button>
            </div>

            <div className="restock-management__action">
              <div className="restock-management__action-info">
                <h4 className="restock-management__action-title">
                  <FontAwesomeIcon icon={faTruck} /> 2. Zamów suplementy
                </h4>
                <p className="restock-management__action-description">
                  Rozpocznij misję dostawy - musisz pojechać po towar i przywieźć go do siłowni. Tańsza opcja z 30% zniżką.
                </p>
                <div className="restock-management__action-cost">
                  <span className="restock-management__action-cost-label">Koszt (70%):</span>
                  <span className="restock-management__action-cost-value delivery-discount">${deliveryCost > 0 ? deliveryCost.toLocaleString() : '0'}</span>
                  <span className="restock-management__action-cost-info">({totalMissing} szt.)</span>
                </div>
              </div>
              <button
                className={`restock-management__action-btn restock-management__action-btn--delivery ${loading === 'delivery' ? 'restock-management__action-btn--loading' : ''}`}
                onClick={handleOrderDelivery}
                disabled={loading !== null || totalMissing === 0}
              >
                <FontAwesomeIcon icon={faTruck} />
                <span>
                  {loading === 'delivery' ? 'Rozpoczynanie...' : 'Rozpocznij misję'}
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default RestockManagement