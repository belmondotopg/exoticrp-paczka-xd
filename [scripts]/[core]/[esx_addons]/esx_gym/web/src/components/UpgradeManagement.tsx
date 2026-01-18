import React, { useState, useEffect } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowUp, faTimes, faArrowLeft, faCheck, faDollarSign, faCog } from '@fortawesome/free-solid-svg-icons'
import { fetchNui } from '../utils/fetchNui'
import './UpgradeManagement.scss'

interface UpgradeManagementProps {
  gymName: string
  equipmentUpgraded: boolean
  onClose: () => void
  onBack: () => void
}

const UpgradeManagement: React.FC<UpgradeManagementProps> = ({ gymName, equipmentUpgraded, onClose, onBack }) => {
  const [loading, setLoading] = useState(false)
  const [currentUpgraded, setCurrentUpgraded] = useState(equipmentUpgraded)

  // Aktualizuj stan gdy prop się zmieni
  useEffect(() => {
    setCurrentUpgraded(equipmentUpgraded)
  }, [equipmentUpgraded])

  const handleUpgradeEquipment = () => {
    if (loading || currentUpgraded) return
    
    setLoading(true)
    
    fetchNui('esx_gym/gymAction', { 
      action: 'upgradeEquipment', 
      gymName: gymName 
    }).then(() => {
      setLoading(false)
      // Natychmiast zaktualizuj stan lokalnie
      setCurrentUpgraded(true)
      // Wróć do głównego menu po zakupie, żeby odświeżyć dane
      setTimeout(() => {
        onBack()
      }, 1000)
    }).catch(() => {
      setLoading(false)
    })
  }

  const upgrades = [
    {
      id: 'equipment',
      name: 'Ulepszenie Sprzętu',
      description: 'Ulepszenie sprzętu pozwala na szybsze i efektywniejsze ćwiczenie',
      price: 100000,
      icon: faCog,
      color: '#3b82f6',
      isUpgraded: currentUpgraded,
      benefits: [
        'Szybsze wykonywanie ćwiczeń',
        'Zwiększona efektywność treningu',
        'Lepsze doświadczenie dla klientów'
      ]
    }
  ]

  return (
    <div className="upgrade-management">
      <div className="upgrade-management__container">
        <div className="upgrade-management__header">
          <button 
            className="upgrade-management__back"
            onClick={onBack || onClose}
          >
            <FontAwesomeIcon icon={faArrowLeft} />
          </button>
          <h1 className="upgrade-management__title">
            <FontAwesomeIcon icon={faArrowUp} /> Ulepszenia siłowni
          </h1>
          <button 
            className="upgrade-management__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="upgrade-management__content">
          <div className="upgrade-management__info">
            <p className="upgrade-management__description">
              Ulepsz swoją siłownię, aby zwiększyć efektywność i przyciągnąć więcej klientów.
            </p>
          </div>

          <div className="upgrade-management__upgrades">
            <h3 className="upgrade-management__upgrades-title">Dostępne ulepszenia</h3>
            
            <div className="upgrade-management__upgrades-list">
              {upgrades.map((upgrade) => (
                <div key={upgrade.id} className={`upgrade-management__upgrade ${upgrade.isUpgraded ? 'upgrade-management__upgrade--upgraded' : ''}`}>
                  <div className="upgrade-management__upgrade-header">
                    <div 
                      className="upgrade-management__upgrade-icon"
                      style={{ backgroundColor: upgrade.color }}
                    >
                      <FontAwesomeIcon icon={upgrade.icon} />
                    </div>
                    <div className="upgrade-management__upgrade-info">
                      <h4 className="upgrade-management__upgrade-name">{upgrade.name}</h4>
                      <p className="upgrade-management__upgrade-description">{upgrade.description}</p>
                    </div>
                    <div className="upgrade-management__upgrade-status">
                      {upgrade.isUpgraded ? (
                        <div className="upgrade-management__upgrade-badge upgrade-management__upgrade-badge--upgraded">
                          <FontAwesomeIcon icon={faCheck} />
                          <span>Ulepszone</span>
                        </div>
                      ) : (
                        <div className="upgrade-management__upgrade-price">
                          <FontAwesomeIcon icon={faDollarSign} />
                          <span>{upgrade.price.toLocaleString()}</span>
                        </div>
                      )}
                    </div>
                  </div>

                  <div className="upgrade-management__upgrade-benefits">
                    <h5 className="upgrade-management__upgrade-benefits-title">Korzyści:</h5>
                    <ul className="upgrade-management__upgrade-benefits-list">
                      {upgrade.benefits.map((benefit, index) => (
                        <li key={index} className="upgrade-management__upgrade-benefit">
                          <FontAwesomeIcon icon={faCheck} />
                          <span>{benefit}</span>
                        </li>
                      ))}
                    </ul>
                  </div>

                  <div className="upgrade-management__upgrade-actions">
                    {upgrade.isUpgraded ? (
                      <div className="upgrade-management__upgrade-completed">
                        <FontAwesomeIcon icon={faCheck} />
                        <span>Ulepszenie zostało zakupione</span>
                      </div>
                    ) : (
                      <button
                        className={`upgrade-management__upgrade-btn ${loading ? 'upgrade-management__upgrade-btn--loading' : ''}`}
                        onClick={handleUpgradeEquipment}
                        disabled={loading}
                      >
                        <FontAwesomeIcon icon={faDollarSign} />
                        <span>
                          {loading ? 'Kupowanie...' : `Kup za ${upgrade.price.toLocaleString()}`}
                        </span>
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="upgrade-management__info-section">
            <h4 className="upgrade-management__info-title">Informacje o ulepszeniach</h4>
            <div className="upgrade-management__info-content">
              <p>
                Ulepszenia siłowni to jednorazowe inwestycje, które trwale zwiększają efektywność Twojej działalności.
                Każde ulepszenie przynosi konkretne korzyści i może przyciągnąć więcej klientów.
              </p>
              <p>
                <strong>Uwaga:</strong> Ulepszenia są nieodwracalne i działają na stałe po zakupie.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default UpgradeManagement
