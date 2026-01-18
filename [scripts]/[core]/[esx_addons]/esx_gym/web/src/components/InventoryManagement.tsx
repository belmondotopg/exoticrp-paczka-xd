import React, { useState, useEffect, useMemo } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBox, faTimes, faArrowLeft, faPills, faTruck, faShoppingCart, faCheck } from '@fortawesome/free-solid-svg-icons'
import { SupplementStock } from '../types/gym'
import { fetchNui } from '../utils/fetchNui'
import './InventoryManagement.scss'

interface InventoryManagementProps {
  stock: SupplementStock
  gymName: string
  onClose: () => void
  onBack?: () => void
  maxStock?: number
}

const DEFAULT_MAX_STOCK = 200

const InventoryManagement: React.FC<InventoryManagementProps> = ({ stock: initialStock, gymName, onClose, onBack, maxStock }) => {
  const MAX_STOCK = maxStock || DEFAULT_MAX_STOCK
  const [showDelivery, setShowDelivery] = useState(false)
  const [loading, setLoading] = useState<string | null>(null)
  const [inputQuantities, setInputQuantities] = useState<{[key: string]: string}>({})
  const [stock, setStock] = useState<SupplementStock>(initialStock)
  const [deliveryPrices, setDeliveryPrices] = useState<{[key: string]: number}>({
    kreatyna: 100,
    l_karnityna: 150,
    bialko: 200
  })

  // Update stock when prop changes
  useEffect(() => {
    setStock(initialStock)
  }, [initialStock])

  useEffect(() => {
    if (showDelivery) {
      fetchNui('esx_gym/getDeliveryPrices', { gymName })
        .then((prices) => {
          setDeliveryPrices(prices || { kreatyna: 100, l_karnityna: 150, bialko: 200 })
        })
        .catch(() => {
          setDeliveryPrices({ kreatyna: 100, l_karnityna: 150, bialko: 200 })
        })
    }
  }, [showDelivery, gymName])

  const handleQuantityChange = (key: string, value: string) => {
    // Allow empty string or numbers
    if (value === '' || /^\d+$/.test(value)) {
      setInputQuantities({
        ...inputQuantities,
        [key]: value
      })
    }
  }

  const handleBuySelected = async () => {
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

    try {
      await fetchNui('esx_gym/buySelectedSupplies', {
        gymName: gymName,
        quantities: quantitiesToBuy
      })
      
      setInputQuantities({})
    } catch (error) {
      // Error handled silently
    } finally {
      setLoading(null)
    }
  }

  const supplements = useMemo(() => [
    {
      key: 'kreatyna',
      name: 'Kreatyna',
      description: 'Suplement zwiększający siłę',
      color: '#ef4444',
      icon: faPills
    },
    {
      key: 'l_karnityna',
      name: 'L-Karnityna',
      description: 'Suplement zwiększający wytrzymałość',
      color: '#3b82f6',
      icon: faPills
    },
    {
      key: 'bialko',
      name: 'Białko',
      description: 'Suplement zwiększający pojemność płuc',
      color: '#10b981',
      icon: faPills
    }
  ], [])

  const handleBuyAllSupplies = async () => {
    if (loading) return
    
    setLoading('buyAll')
    
    try {
      await fetchNui('esx_gym/buyAllSupplies', {
        gymName: gymName
      })
      
      setShowDelivery(false)
    } catch (error) {
      // Error handled silently
    } finally {
      setLoading(null)
    }
  }

  const handleStartDelivery = async () => {
    if (loading) return
    
    setLoading('delivery')
    
    try {
      await fetchNui('esx_gym/startDelivery', {
        gymName: gymName
      })
      
      setShowDelivery(false)
    } catch (error) {
      // Error handled silently
    } finally {
      setLoading(null)
    }
  }

  const calculateMissingStock = () => {
    let totalMissing = 0
    let totalCost = 0
    
    supplements.forEach((supplement) => {
      const current = stock[supplement.key as keyof SupplementStock] || 0
      const missing = MAX_STOCK - current
      const price = deliveryPrices[supplement.key] || 0
      
      totalMissing += missing
      totalCost += missing * price
    })
    
    return { totalMissing, totalCost, deliveryCost: Math.floor(totalCost * 0.7) }
  }

  if (showDelivery) {
    const { totalMissing, totalCost, deliveryCost } = calculateMissingStock()
    
    return (
      <div className="inventory-management">
        <div className="inventory-management__container">
          <div className="inventory-management__header">
            <button 
              className="inventory-management__back"
              onClick={() => setShowDelivery(false)}
            >
              <FontAwesomeIcon icon={faArrowLeft} />
            </button>
            <h1 className="inventory-management__title">
              <FontAwesomeIcon icon={faTruck} /> Dostawy
            </h1>
            <button 
              className="inventory-management__close"
              onClick={onClose}
            >
              <FontAwesomeIcon icon={faTimes} />
            </button>
          </div>

          <div className="inventory-management__content">
            <div className="inventory-management__info">
              <p className="inventory-management__description">
                Uzupełnij zapasy natychmiastowo lub zamów dostawę z misją.
              </p>
            </div>

            <div className="inventory-management__delivery">
              <div className="inventory-management__delivery-header">
                <h3 className="inventory-management__delivery-title">
                  <FontAwesomeIcon icon={faBox} /> Stan Magazynu
                </h3>
              </div>

              <div className="inventory-management__delivery-items">
                {supplements.map((supplement) => {
                  const current = stock[supplement.key as keyof SupplementStock] || 0
                  const price = deliveryPrices[supplement.key] || 0
                  const percentage = (current / MAX_STOCK) * 100
                  
                  return (
                    <div key={supplement.key} className="inventory-management__delivery-item">
                      <div className="inventory-management__delivery-item-header">
                        <div 
                          className="inventory-management__delivery-item-icon"
                          style={{ backgroundColor: supplement.color }}
                        >
                          <FontAwesomeIcon icon={supplement.icon} />
                        </div>
                        <div className="inventory-management__delivery-item-info">
                          <h4 className="inventory-management__delivery-item-name">{supplement.name}</h4>
                          <p className="inventory-management__delivery-item-description">
                            {current}/{MAX_STOCK} szt.
                          </p>
                        </div>
                      </div>

                      <div className="inventory-management__delivery-item-controls">
                        <div className="inventory-management__item-progress">
                          <div className="inventory-management__item-progress-bar">
                            <div 
                              className="inventory-management__item-progress-fill"
                              style={{ 
                                width: `${percentage}%`,
                                backgroundColor: supplement.color
                              }}
                            />
                          </div>
                          <span className="inventory-management__item-progress-text">
                            {percentage.toFixed(0)}%
                          </span>
                        </div>
                        <div className="inventory-management__delivery-item-inputs">
                          <div className="inventory-management__delivery-item-price">
                            <span className="inventory-management__delivery-item-price-label">Cena za sztukę:</span>
                            <span className="inventory-management__delivery-item-price-value">${price}</span>
                          </div>
                          <div className="inventory-management__delivery-item-input-wrapper">
                            <span className="inventory-management__delivery-item-input-label">Kup:</span>
                            <input 
                              type="text" 
                              className="inventory-management__delivery-item-input"
                              placeholder="Ilość"
                              value={inputQuantities[supplement.key] || ''}
                              onChange={(e) => handleQuantityChange(supplement.key, e.target.value)}
                            />
                          </div>
                        </div>
                      </div>
                    </div>
                  )
                })}
              </div>

              {/* Custom Buy Section */}
              {(() => {
                const selectedCost = supplements.reduce((sum, supplement) => {
                  const quantity = parseInt(inputQuantities[supplement.key] || '0')
                  if (isNaN(quantity) || quantity <= 0) return sum
                  const price = deliveryPrices[supplement.key] || 0
                  return sum + (quantity * price)
                }, 0)

                const selectedCount = Object.values(inputQuantities).reduce((sum, val) => {
                  const num = parseInt(val)
                  return sum + (isNaN(num) ? 0 : num)
                }, 0)

                return (
                  <div className="inventory-management__custom-buy">
                    <div className="inventory-management__custom-buy-header">
                      <div>
                        <h4 className="inventory-management__custom-buy-title">Niestandardowe zamówienie</h4>
                        <p className="inventory-management__custom-buy-description">Wpisz ilość powyżej dla każdego suplementu</p>
                      </div>
                      <div className="inventory-management__custom-buy-total">
                        <div className="inventory-management__custom-buy-total-value">${selectedCost.toLocaleString()}</div>
                        <div className="inventory-management__custom-buy-total-count">{selectedCount} szt.</div>
                      </div>
                    </div>
                    <button
                      className={`inventory-management__delivery-action-btn inventory-management__delivery-action-btn--buy ${loading === 'buySelected' ? 'inventory-management__delivery-action-btn--loading' : ''}`}
                      onClick={handleBuySelected}
                      disabled={loading !== null || selectedCount === 0}
                    >
                      <FontAwesomeIcon icon={faCheck} />
                      <span>
                        {loading === 'buySelected' ? 'Kupowanie...' : 'Kup wybrane'}
                      </span>
                    </button>
                  </div>
                )
              })()}

              <div className="inventory-management__delivery-actions">
                <div className="inventory-management__delivery-action">
                  <div className="inventory-management__delivery-action-info">
                    <h4 className="inventory-management__delivery-action-title">
                      <FontAwesomeIcon icon={faShoppingCart} /> 1. Uzupełnij wszystkie zapasy
                    </h4>
                    <p className="inventory-management__delivery-action-description">
                      Natychmiastowe uzupełnienie magazynu do maksymalnej pojemności ({MAX_STOCK} szt. każdego suplementu). Towar pojawi się od razu.
                    </p>
                    <div className="inventory-management__delivery-action-cost">
                      <span className="inventory-management__delivery-action-cost-label">Koszt (100%):</span>
                      <span className="inventory-management__delivery-action-cost-value">
                        ${totalCost > 0 ? totalCost.toLocaleString() : '0'}
                      </span>
                      <span className="inventory-management__delivery-action-cost-info">({totalMissing} szt.)</span>
                    </div>
                  </div>
                  <button
                    className={`inventory-management__delivery-action-btn inventory-management__delivery-action-btn--buy ${loading === 'buyAll' ? 'inventory-management__delivery-action-btn--loading' : ''}`}
                    onClick={handleBuyAllSupplies}
                    disabled={loading !== null || totalMissing === 0}
                  >
                    <FontAwesomeIcon icon={faShoppingCart} />
                    <span>
                      {loading === 'buyAll' ? 'Zamawianie...' : 'Uzupełnij teraz'}
                    </span>
                  </button>
                </div>

                <div className="inventory-management__delivery-action">
                  <div className="inventory-management__delivery-action-info">
                    <h4 className="inventory-management__delivery-action-title">
                      <FontAwesomeIcon icon={faTruck} /> 2. Zamów suplementy
                    </h4>
                    <p className="inventory-management__delivery-action-description">
                      Rozpocznij misję dostawy - musisz pojechać po towar i przywieźć go do siłowni. Tańsza opcja z 30% zniżką.
                    </p>
                    <div className="inventory-management__delivery-action-cost">
                      <span className="inventory-management__delivery-action-cost-label">Koszt (70%):</span>
                      <span className="inventory-management__delivery-action-cost-value delivery-discount">
                        ${deliveryCost > 0 ? deliveryCost.toLocaleString() : '0'}
                      </span>
                      <span className="inventory-management__delivery-action-cost-info">({totalMissing} szt.)</span>
                    </div>
                  </div>
                  <button
                    className={`inventory-management__delivery-action-btn inventory-management__delivery-action-btn--delivery ${loading === 'delivery' ? 'inventory-management__delivery-action-btn--loading' : ''}`}
                    onClick={handleStartDelivery}
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
      </div>
    )
  }

  return (
    <div className="inventory-management">
      <div className="inventory-management__container">
        <div className="inventory-management__header">
          <button 
            className="inventory-management__back"
            onClick={onBack || onClose}
          >
            <FontAwesomeIcon icon={faArrowLeft} />
          </button>
          <h1 className="inventory-management__title">
            <FontAwesomeIcon icon={faBox} /> Magazyn
          </h1>
          <button 
            className="inventory-management__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="inventory-management__content">
          <div className="inventory-management__info">
            <p className="inventory-management__description">
              Przeglądaj stan magazynu suplementów w siłowni.
            </p>
          </div>

          <div className="inventory-management__inventory">
            <div className="inventory-management__inventory-header">
              <h3 className="inventory-management__inventory-title">Stan magazynu</h3>
              <div className="inventory-management__inventory-summary">
                <span className="inventory-management__inventory-total">
                  Łącznie: {Object.values(stock).reduce((sum, count) => sum + count, 0)} sztuk
                </span>
              </div>
            </div>

            <div className="inventory-management__items">
              {supplements.map((supplement) => {
                const count = stock[supplement.key as keyof SupplementStock] || 0
                const status = count > 20 ? 'high' : count > 10 ? 'medium' : 'low'
                
                return (
                  <div key={supplement.key} className="inventory-management__item">
                    <div className="inventory-management__item-header">
                      <div 
                        className="inventory-management__item-icon"
                        style={{ backgroundColor: supplement.color }}
                      >
                        <FontAwesomeIcon icon={supplement.icon} />
                      </div>
                      <div className="inventory-management__item-info">
                        <h4 className="inventory-management__item-name">{supplement.name}</h4>
                        <p className="inventory-management__item-description">{supplement.description}</p>
                      </div>
                    </div>

                    <div className="inventory-management__item-details">
                      <div className="inventory-management__item-stock">
                        <span className={`inventory-management__item-stock-value inventory-management__item-stock-value--${status}`}>
                            {count} sztuk
                        </span>
                      </div>
                      <div className={`inventory-management__item-status inventory-management__item-status--${status}`}>
                        {status === 'high' ? 'Wysoki' : status === 'medium' ? 'Średni' : 'Niski'}
                      </div>
                    </div>

                    <div className="inventory-management__item-progress">
                      <div className="inventory-management__item-progress-bar">
                        <div 
                          className="inventory-management__item-progress-fill"
                          style={{ 
                            width: `${Math.min((count / 50) * 100, 100)}%`,
                            backgroundColor: supplement.color
                          }}
                        />
                      </div>
                      <span className="inventory-management__item-progress-text">
                        {Math.min((count / 50) * 100, 100).toFixed(0)}% pojemności
                      </span>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>

          <div className="inventory-management__actions">
            <div className="inventory-management__action-info">
              <h4 className="inventory-management__action-title">Zarządzanie magazynem</h4>
              <p className="inventory-management__action-description">
                Uzupełnij magazyn suplementami lub przeglądaj aktualny stan.
              </p>
            </div>
            <div className="inventory-management__action-buttons">
              <button
                className="inventory-management__delivery-btn"
                onClick={() => setShowDelivery(true)}
              >
                <FontAwesomeIcon icon={faTruck} />
                <span>Uzupełnij towar</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default InventoryManagement