import React, { useState } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faUserPlus, faTimes, faArrowLeft, faUsers } from '@fortawesome/free-solid-svg-icons'
import { fetchNui } from '../utils/fetchNui'
import './WorkerHire.scss'

interface WorkerHireProps {
  players: any[]
  gymName: string
  onClose: () => void
  onBack?: () => void
}

const WorkerHire: React.FC<WorkerHireProps> = ({ players, gymName, onClose, onBack }) => {
  const [loading, setLoading] = useState<string | null>(null)

  const handleHire = (player: any) => {
    if (loading) return
    
    setLoading(player.id.toString())
    
    fetchNui('esx_gym/hireWorker', {
      gymName: gymName,
      workerId: player.id,
      workerName: player.name,
      workerIdentifier: player.identifier
    }).finally(() => {
      setLoading(null)
    })
  }

  return (
    <div className="worker-hire">
      <div className="worker-hire__container">
        <div className="worker-hire__header">
          {onBack && (
            <button 
              className="worker-hire__back"
              onClick={onBack}
            >
              <FontAwesomeIcon icon={faArrowLeft} />
            </button>
          )}
          <h1 className="worker-hire__title">
            <FontAwesomeIcon icon={faUserPlus} /> Zatrudnij Pracownika
          </h1>
          <button 
            className="worker-hire__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="worker-hire__content">
          <div className="worker-hire__info">
            <h2 className="worker-hire__gym-name">{gymName}</h2>
            <p className="worker-hire__description">
              Wybierz gracza, którego chcesz zatrudnić jako pracownika siłowni.
            </p>
          </div>

          <div className="worker-hire__players">
            <div className="worker-hire__players-header">
              <h3 className="worker-hire__players-title">
                <FontAwesomeIcon icon={faUsers} /> Dostępni Gracze
              </h3>
              <span className="worker-hire__players-count">
                {players.length} graczy online
              </span>
            </div>

            {players.length === 0 ? (
              <div className="worker-hire__empty">
                <FontAwesomeIcon icon={faUsers} />
                <h4 className="worker-hire__empty-title">Brak graczy</h4>
                <p className="worker-hire__empty-description">
                  Obecnie nie ma graczy online, których można zatrudnić.
                </p>
              </div>
            ) : (
              <div className="worker-hire__players-list">
                {players.map((player: any) => (
                  <div key={player.id} className="worker-hire__player">
                    <div className="worker-hire__player-info">
                      <div className="worker-hire__player-avatar">
                        <FontAwesomeIcon icon={faUsers} />
                      </div>
                      <div className="worker-hire__player-details">
                        <h4 className="worker-hire__player-name">
                          {player.name || `Gracz #${player.id}`}
                        </h4>
                        <p className="worker-hire__player-id">
                          ID: {player.id}
                        </p>
                      </div>
                    </div>

                    <div className="worker-hire__player-actions">
                      <button
                        className={`worker-hire__player-hire ${loading === player.id.toString() ? 'worker-hire__player-hire--loading' : ''}`}
                        onClick={() => handleHire(player)}
                        disabled={loading !== null}
                      >
                        <FontAwesomeIcon icon={faUserPlus} />
                        <span>
                          {loading === player.id.toString() ? 'Zatrudnianie...' : 'Zatrudnij'}
                        </span>
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="worker-hire__info-section">
            <h4 className="worker-hire__info-title">Informacje o zatrudnianiu</h4>
            <ul className="worker-hire__info-list">
              <li className="worker-hire__info-item">
                Zatrudnieni pracownicy mogą zarządzać siłownią w Twoim imieniu
              </li>
              <li className="worker-hire__info-item">
                Pracownicy mają dostęp do wszystkich funkcji siłowni
              </li>
              <li className="worker-hire__info-item">
                Możesz zwolnić pracowników w sekcji "Zarządzanie pracownikami"
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

export default WorkerHire