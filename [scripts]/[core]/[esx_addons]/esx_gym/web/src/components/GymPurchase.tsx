import React, { useState, useEffect } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faDumbbell, faTimes, faArrowLeft, faShoppingCart, faCheck } from '@fortawesome/free-solid-svg-icons'
import { fetchNui } from '../utils/fetchNui'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { GymInterface } from '../types/gym'
import './GymPurchase.scss'

interface GymPurchaseProps {
  gymData: GymInterface
  onClose: () => void
  onBack: () => void
}

const GymPurchase: React.FC<GymPurchaseProps> = ({ gymData, onClose, onBack }) => {
  const [loading, setLoading] = useState(false)
  const [playerMoney, setPlayerMoney] = useState(0)

  // Pobierz pieniądze gracza przy załadowaniu komponentu
  useEffect(() => {
    fetchNui('esx_gym/getPlayerMoney', {}).then((money) => {
      setPlayerMoney(money || 0)
    }).catch(() => {
      setPlayerMoney(0)
    })
  }, [])

  // Obsługa sukcesu zakupu
  useNuiEvent('purchaseGymSuccess', (success) => {
    if (success) {
      setLoading(false)
      onBack() // Przełącz na normalne menu zarządzania
    }
  })

  const handlePurchase = () => {
    if (loading || !gymData.id) return
    
    setLoading(true)
    
    fetchNui('esx_gym/purchaseGym', {
      gymId: gymData.id,
      gymName: gymData.name
    }).catch(() => {
      setLoading(false)
    })
  }

  const isAvailable = gymData.avaliable === 1 && !gymData.owner_name
  const isOwned = gymData.owner_name !== null
  const canAfford = playerMoney >= gymData.price
  const isDisabled = loading || !canAfford

  return (
    <div className="gym-purchase">
      <div className="gym-purchase__container">
        <div className="gym-purchase__header">
          <button 
            className="gym-purchase__back"
            onClick={onBack}
          >
            <FontAwesomeIcon icon={faArrowLeft} />
          </button>
          <h1 className="gym-purchase__title">
            <FontAwesomeIcon icon={faDumbbell} /> Zakup siłowni
          </h1>
          <button 
            className="gym-purchase__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="gym-purchase__content">
          <div className="gym-purchase__gym-info">
            <div className="gym-purchase__gym-header">
              <div className="gym-purchase__gym-icon">
                <FontAwesomeIcon icon={faDumbbell} />
              </div>
              <div className="gym-purchase__gym-details">
                <h2 className="gym-purchase__gym-name">{gymData.label}</h2>
              </div>
            </div>

            <div className="gym-purchase__gym-status">
              <div className="gym-purchase__status-item">
                <span className="gym-purchase__status-label">Status:</span>
                <span className={`gym-purchase__status-value ${isOwned ? 'gym-purchase__status-value--owned' : isAvailable ? 'gym-purchase__status-value--available' : 'gym-purchase__status-value--unavailable'}`}>
                  {isOwned ? 'Własność' : isAvailable ? 'Dostępna' : 'Niedostępna'}
                </span>
              </div>
  
              <div className="gym-purchase__status-item">
                <span className="gym-purchase__status-label">Aktywna:</span>
                <span className={`gym-purchase__status-value ${gymData.active ? 'gym-purchase__status-value--active' : 'gym-purchase__status-value--inactive'}`}>
                  {gymData.active ? 'Tak' : 'Nie'}
                </span>
              </div>
            </div>
          </div>

          <div className="gym-purchase__purchase-section">
            <div className="gym-purchase__price">
              <h3 className="gym-purchase__price-title">Cena Siłowni</h3>
              <div className="gym-purchase__price-value">
                ${gymData.price.toLocaleString()}
              </div>
              <p className="gym-purchase__price-description">
                Jednorazowa opłata za zakup siłowni
              </p>
            </div>

            {isAvailable ? (
              <div className="gym-purchase__purchase-info">
                <h4 className="gym-purchase__purchase-title">Korzyści z zakupu</h4>
                <ul className="gym-purchase__purchase-benefits">
                  <li className="gym-purchase__purchase-benefit">
                    <FontAwesomeIcon icon={faCheck} />
                    <span>Pełne zarządzanie siłownią</span>
                  </li>
                  <li className="gym-purchase__purchase-benefit">
                    <FontAwesomeIcon icon={faCheck} />
                    <span>Ustawianie cen suplementów i karnetów</span>
                  </li>
                  <li className="gym-purchase__purchase-benefit">
                    <FontAwesomeIcon icon={faCheck} />
                    <span>Zatrudnianie i zarządzanie pracownikami</span>
                  </li>
                  <li className="gym-purchase__purchase-benefit">
                    <FontAwesomeIcon icon={faCheck} />
                    <span>Zarządzanie magazynem i dostawami</span>
                  </li>
                  <li className="gym-purchase__purchase-benefit">
                    <FontAwesomeIcon icon={faCheck} />
                    <span>Ulepszanie wyposażenia siłowni</span>
                  </li>
                  <li className="gym-purchase__purchase-benefit">
                    <FontAwesomeIcon icon={faCheck} />
                    <span>Zyski z działalności siłowni</span>
                  </li>
                </ul>

                <button
                  className={`gym-purchase__purchase-btn ${loading ? 'gym-purchase__purchase-btn--loading' : ''} ${isDisabled ? 'gym-purchase__purchase-btn--disabled' : ''}`}
                  onClick={handlePurchase}
                  disabled={isDisabled}
                >
                  <FontAwesomeIcon icon={faShoppingCart} />
                  <span>
                    {loading ? 'Kupowanie...' : !canAfford ? 'Za mało pieniędzy' : 'Kup siłownię'}
                  </span>
                </button>
              </div>
            ) : isOwned ? (
              <div className="gym-purchase__owned-info">
                <h4 className="gym-purchase__owned-title">Siłownia należy do kogoś Innego</h4>
                <p className="gym-purchase__owned-description">
                  Ta siłownia jest już własnością innego gracza. Nie możesz jej kupić.
                </p>
              </div>
            ) : (
              <div className="gym-purchase__unavailable-info">
                <h4 className="gym-purchase__unavailable-title">Siłownia Niedostępna</h4>
                <p className="gym-purchase__unavailable-description">
                  Ta siłownia nie jest obecnie dostępna do zakupu.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

export default GymPurchase