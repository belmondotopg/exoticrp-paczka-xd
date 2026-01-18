import React, { useState, useMemo } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faTicket, faTimes, faArrowLeft, faCheck } from '@fortawesome/free-solid-svg-icons'
import { fetchNui } from '../utils/fetchNui'
import './BuyPass.scss'

interface BuyPassProps {
  gymName: string
  prices?: {
    daily: number
    weekly: number
    monthly: number
  }
  onClose: () => void
  onBack?: () => void
}

const BuyPass: React.FC<BuyPassProps> = ({ gymName, prices = { daily: 50, weekly: 300, monthly: 1000 }, onClose, onBack }) => {
  const [loading, setLoading] = useState(false)
  const [selectedPass, setSelectedPass] = useState<string | null>(null)

  const handlePurchase = (passType: string) => {
    if (loading) return
    
    setLoading(true)
    setSelectedPass(passType)
    
    fetchNui('esx_gym/purchasePass', {
      gymName: gymName,
      membershipType: passType
    }).finally(() => {
      setLoading(false)
      setSelectedPass(null)
    })
  }

  const passes = useMemo(() => [
    {
      key: 'daily',
      name: 'Karnet Dzienny',
      price: prices.daily,
      duration: '24 godziny',
      description: 'Dostęp do siłowni na jeden dzień',
      color: '#3b82f6',
      icon: faTicket
    },
    {
      key: 'weekly',
      name: 'Karnet Tygodniowy',
      price: prices.weekly,
      duration: '7 dni',
      description: 'Dostęp do siłowni na tydzień',
      color: '#10b981',
      icon: faTicket
    },
    {
      key: 'monthly',
      name: 'Karnet Miesięczny',
      price: prices.monthly,
      duration: '30 dni',
      description: 'Dostęp do siłowni na miesiąc',
      color: '#f59e0b',
      icon: faTicket
    }
  ], [prices])

  return (
    <div className="buy-pass">
      <div className="buy-pass__container">
        <div className="buy-pass__header">
          {onBack && (
            <button 
              className="buy-pass__back"
              onClick={onBack}
            >
              <FontAwesomeIcon icon={faArrowLeft} />
            </button>
          )}
          <h1 className="buy-pass__title">
            <FontAwesomeIcon icon={faTicket} /> Kup Karnet
          </h1>
          <button 
            className="buy-pass__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="buy-pass__content">
          <div className="buy-pass__info">
            <p className="buy-pass__description">
              Wybierz karnet, który chcesz kupić. Karnet daje dostęp do wszystkich funkcji siłowni.
            </p>
          </div>

          <div className="buy-pass__passes">
            {passes.map((pass) => (
              <div key={pass.key} className="buy-pass__pass">
                <div className="buy-pass__pass-header">
                  <div 
                    className="buy-pass__pass-icon"
                    style={{ backgroundColor: pass.color }}
                  >
                    <FontAwesomeIcon icon={pass.icon} />
                  </div>
                  <div className="buy-pass__pass-info">
                    <h3 className="buy-pass__pass-name">{pass.name}</h3>
                    <p className="buy-pass__pass-description">{pass.description}</p>
                  </div>
                </div>

                <div className="buy-pass__pass-details">
                  <div className="buy-pass__pass-duration">
                    <span className="buy-pass__pass-duration-label">Czas trwania:</span>
                    <span className="buy-pass__pass-duration-value">{pass.duration}</span>
                  </div>
                  <div className="buy-pass__pass-price">
                    <span className="buy-pass__pass-price-label">Cena:</span>
                    <span className="buy-pass__pass-price-value">${pass.price}</span>
                  </div>
                </div>

                <button
                  className={`buy-pass__pass-buy ${loading && selectedPass === pass.key ? 'buy-pass__pass-buy--loading' : ''}`}
                  onClick={() => handlePurchase(pass.key)}
                  disabled={loading}
                >
                  {loading && selectedPass === pass.key ? (
                    <>
                      <FontAwesomeIcon icon={faCheck} />
                      <span>Kupowanie...</span>
                    </>
                  ) : (
                    <>
                      <FontAwesomeIcon icon={faTicket} />
                      <span>Kup karnet</span>
                    </>
                  )}
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

export default BuyPass