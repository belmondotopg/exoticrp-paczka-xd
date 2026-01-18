import React, { useState, useEffect, useMemo } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faPills, faTimes, faArrowLeft, faShoppingCart, faMinus, faPlus, faCreditCard, faMoneyBill } from '@fortawesome/free-solid-svg-icons'
import { SupplementData } from '../types/gym'
import { fetchNui } from '../utils/fetchNui'
import './SupplementShop.scss'

interface SupplementShopProps {
  data: SupplementData
  onClose: () => void
  onBack: () => void
}

type PaymentMethod = 'cash' | 'card'

const SupplementShop: React.FC<SupplementShopProps> = ({ data, onClose, onBack }) => {
  const [stock, setStock] = useState(data.stock || {})
  const [prices, setPrices] = useState(data.prices || {})
  const [loading, setLoading] = useState(false)
  const [quantities, setQuantities] = useState<{[key: string]: number}>({})
  const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>('cash')

  const supplements = useMemo(() => [
    {
      key: 'kreatyna',
      name: 'Kreatyna',
      description: 'Zwiększa siłę mięśni o 50%',
      icon: faPills,
      color: '#ef4444'
    },
    {
      key: 'l_karnityna',
      name: 'L-Karnityna',
      description: 'Zwiększa wytrzymałość o 40%',
      icon: faPills,
      color: '#3b82f6'
    },
    {
      key: 'bialko',
      name: 'Białko',
      description: 'Zwiększa pojemność płuc o 30%',
      icon: faPills,
      color: '#10b981'
    }
  ], [])

  useEffect(() => {
    setStock(data.stock || {})
    setPrices(data.prices || {})
    const initialQuantities: {[key: string]: number} = {}
    supplements.forEach(supp => {
      initialQuantities[supp.key] = 1
    })
    setQuantities(initialQuantities)
  }, [data.stock, data.prices, data.gymName])

  const handleQuantityChange = (supplement: string, change: number) => {
    const currentQuantity = quantities[supplement] || 1
    const newQuantity = Math.max(1, Math.min(currentQuantity + change, stock[supplement as keyof typeof stock] || 0))
    setQuantities(prev => ({
      ...prev,
      [supplement]: newQuantity
    }))
  }

  const handlePurchase = (supplement: string) => {
    if (loading) return
    
    const quantity = quantities[supplement] || 1
    if (quantity <= 0) return
    
    setLoading(true)
    fetchNui('esx_gym/purchaseSupplement', {
      gymName: data.gymName,
      supplement: supplement,
      quantity: quantity,
      paymentMethod: paymentMethod
    }).then(() => {
      setQuantities(prev => ({
        ...prev,
        [supplement]: 1
      }))
    }).finally(() => {
      setLoading(false)
    })
  }

  return (
    <div className="supplement-shop">
      <div className="supplement-shop__container">
        <div className="supplement-shop__header">
          <button 
            className="supplement-shop__back"
            onClick={onBack}
          >
            <FontAwesomeIcon icon={faArrowLeft} />
          </button>
          <h1 className="supplement-shop__title">
            <FontAwesomeIcon icon={faShoppingCart} /> Sklep suplementów
          </h1>
          <button 
            className="supplement-shop__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="supplement-shop__content">
          <div className="supplement-shop__info">
            <p className="supplement-shop__description">
              Wybierz suplement, który chcesz kupić. Każdy suplement daje bonus do treningu.
            </p>
          </div>

          <div className="supplement-shop__payment-section">
            <h3 className="supplement-shop__payment-title">Metoda płatności:</h3>
            <div className="supplement-shop__payment-methods">
              <button
                className={`supplement-shop__payment-btn ${paymentMethod === 'cash' ? 'supplement-shop__payment-btn--active' : ''}`}
                onClick={() => setPaymentMethod('cash')}
              >
                <FontAwesomeIcon icon={faMoneyBill} />
                <span>Gotówka</span>
              </button>
              <button
                className={`supplement-shop__payment-btn ${paymentMethod === 'card' ? 'supplement-shop__payment-btn--active' : ''}`}
                onClick={() => setPaymentMethod('card')}
              >
                <FontAwesomeIcon icon={faCreditCard} />
                <span>Karta</span>
              </button>
            </div>
          </div>

          <div className="supplement-shop__items">
            {supplements.map((supplement) => (
              <div key={supplement.key} className="supplement-shop__item">
                <div className="supplement-shop__item-header">
                  <div 
                    className="supplement-shop__item-icon"
                    style={{ backgroundColor: supplement.color }}
                  >
                    <FontAwesomeIcon icon={supplement.icon} />
                  </div>
                  <div className="supplement-shop__item-info">
                    <h3 className="supplement-shop__item-name">{supplement.name}</h3>
                    <p className="supplement-shop__item-description">{supplement.description}</p>
                  </div>
                </div>

                <div className="supplement-shop__item-details">
                  <div className="supplement-shop__item-stock">
                    <span className="supplement-shop__item-stock-label">Dostępne:</span>
                    <span className="supplement-shop__item-stock-value">
                      {stock[supplement.key as keyof typeof stock] || 0}
                    </span>
                  </div>
                  <div className="supplement-shop__item-price">
                    <span className="supplement-shop__item-price-label">Cena za sztukę:</span>
                    <span className="supplement-shop__item-price-value">
                      ${prices[supplement.key as keyof typeof prices] || 0}
                    </span>
                  </div>
                  <div className="supplement-shop__item-total">
                    <span className="supplement-shop__item-total-label">Razem:</span>
                    <span className="supplement-shop__item-total-value">
                      ${((prices[supplement.key as keyof typeof prices] || 0) * (quantities[supplement.key] || 1))}
                    </span>
                  </div>
                </div>

                <div className="supplement-shop__item-quantity">
                  <span className="supplement-shop__item-quantity-label">Ilość:</span>
                  <div className="supplement-shop__item-quantity-controls">
                    <button
                      className="supplement-shop__item-quantity-btn"
                      onClick={() => handleQuantityChange(supplement.key, -1)}
                      disabled={quantities[supplement.key] <= 1}
                    >
                      <FontAwesomeIcon icon={faMinus} />
                    </button>
                    <span className="supplement-shop__item-quantity-value">
                      {quantities[supplement.key] || 1}
                    </span>
                    <button
                      className="supplement-shop__item-quantity-btn"
                      onClick={() => handleQuantityChange(supplement.key, 1)}
                      disabled={(quantities[supplement.key] || 1) >= (stock[supplement.key as keyof typeof stock] || 0)}
                    >
                      <FontAwesomeIcon icon={faPlus} />
                    </button>
                  </div>
                </div>

                <button
                  className={`supplement-shop__item-buy ${loading ? 'supplement-shop__item-buy--loading' : ''}`}
                  onClick={() => handlePurchase(supplement.key)}
                  disabled={loading || (stock[supplement.key as keyof typeof stock] || 0) <= 0}
                >
                  <FontAwesomeIcon icon={faShoppingCart} />
                  <span>
                    {loading ? 'Kupowanie...' : 
                     (stock[supplement.key as keyof typeof stock] || 0) <= 0 ? 'Brak w magazynie' : 
                     `Kup ${quantities[supplement.key] || 1}x`}
                  </span>
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

export default SupplementShop