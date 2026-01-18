import React, { useState } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faUsers, faTimes, faArrowLeft, faUserMinus, faArrowUp, faArrowDown, faCrown } from '@fortawesome/free-solid-svg-icons'
import { fetchNui } from '../utils/fetchNui'
import './WorkerManagement.scss'

interface WorkerManagementProps {
  workers: any[]
  gymName: string
  onClose: () => void
  onBack?: () => void
  ownerIdentifier?: string
}

const WorkerManagement: React.FC<WorkerManagementProps> = ({ workers, gymName, onClose, onBack, ownerIdentifier }) => {
  const [loading, setLoading] = useState<string | null>(null)

  const handleFire = (worker: any) => {
    if (loading) return
    
    setLoading(`fire-${worker.id}`)
    
    fetchNui('esx_gym/fireWorker', {
      gymName: gymName,
      workerId: worker.id,
      workerIdentifier: worker.worker_identifier,
      workerName: worker.name
    }).finally(() => {
      setLoading(null)
    })
  }

  const handlePromote = (worker: any) => {
    if (loading) return
    
    setLoading(`promote-${worker.id}`)
    
    const newGrade = (worker.rank || 0) + 1
    
    fetchNui('esx_gym/promoteWorker', {
      gymName: gymName,
      workerId: worker.id,
      workerIdentifier: worker.worker_identifier,
      workerName: worker.name,
      newGrade: newGrade
    }).finally(() => {
      setLoading(null)
    })
  }

  const handleDemote = (worker: any) => {
    if (loading) return
    
    setLoading(`demote-${worker.id}`)
    
    const newGrade = Math.max(0, (worker.rank || 0) - 1)
    
    fetchNui('esx_gym/demoteWorker', {
      gymName: gymName,
      workerId: worker.id,
      workerIdentifier: worker.worker_identifier,
      workerName: worker.name,
      newGrade: newGrade
    }).finally(() => {
      setLoading(null)
    })
  }

  const getRankInfo = (rank: number) => {
    const ranks = [
      { name: 'Stażysta', color: '#6b7280', icon: faUsers },
      { name: 'Pracownik', color: '#3b82f6', icon: faUsers },
      { name: 'Kierownik', color: '#10b981', icon: faArrowUp },
      { name: 'Zastępca', color: '#f59e0b', icon: faCrown },
      { name: 'Menedżer', color: '#ef4444', icon: faCrown },
      { name: 'Właściciel', color: '#8b5cf6', icon: faCrown }
    ]
    
    return ranks[Math.min(rank, ranks.length - 1)] || ranks[0]
  }

  return (
    <div className="worker-management">
      <div className="worker-management__container">
        <div className="worker-management__header">
          {onBack && (
            <button 
              className="worker-management__back"
              onClick={onBack}
            >
              <FontAwesomeIcon icon={faArrowLeft} />
            </button>
          )}
          <h1 className="worker-management__title">
            <FontAwesomeIcon icon={faUsers} /> Zarządzanie pracownikami
          </h1>
          <button 
            className="worker-management__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="worker-management__content">
          <div className="worker-management__info">
            <p className="worker-management__description">
              Zarządzaj pracownikami siłowni. Możesz zwolnić, awansować lub degradować pracowników w zależności od Twoich uprawnień.
            </p>
            <div className="worker-management__permissions">
              <h4>Twoje uprawnienia:</h4>
              <ul>
                <li>Przeglądanie listy pracowników (poziom 2+)</li>
                <li>Zwalnianie pracowników (poziom 3+)</li>
                <li>Awansowanie i degradowanie pracowników (poziom 4+)</li>
                <li>Zatrudnianie nowych pracowników (poziom 3+)</li>
              </ul>
            </div>
          </div>

          <div className="worker-management__workers">
            <div className="worker-management__workers-header">
              <h3 className="worker-management__workers-title">
                <FontAwesomeIcon icon={faUsers} /> Pracownicy
              </h3>
              <span className="worker-management__workers-count">
                {workers.length} pracowników
              </span>
            </div>

            {workers.length === 0 ? (
              <div className="worker-management__empty">
                <FontAwesomeIcon icon={faUsers} />
                <h4 className="worker-management__empty-title">Brak pracowników</h4>
                <p className="worker-management__empty-description">
                  Obecnie nie masz zatrudnionych pracowników.
                </p>
              </div>
            ) : (
              <div className="worker-management__workers-list">
                {workers.map((worker: any) => {
                  const rankInfo = getRankInfo(worker.rank || 0)
                  
                  return (
                    <div key={worker.id} className="worker-management__worker">
                      <div className="worker-management__worker-info">
                        <div 
                          className="worker-management__worker-avatar"
                          style={{ backgroundColor: rankInfo.color }}
                        >
                          <FontAwesomeIcon icon={rankInfo.icon} />
                        </div>
                        <div className="worker-management__worker-details">
                          <h4 className="worker-management__worker-name">
                            {worker.name || `Pracownik #${worker.id}`}
                          </h4>
                          <p className="worker-management__worker-id">
                            ID: {worker.id}
                          </p>
                          <div 
                            className="worker-management__worker-rank"
                            style={{ color: rankInfo.color }}
                          >
                            {rankInfo.name}
                          </div>
                          {worker.salary && (
                            <p className="worker-management__worker-salary">
                              Pensja: ${worker.salary.toLocaleString()}
                            </p>
                          )}
                        </div>
                      </div>

                      <div className="worker-management__worker-actions">
                        {worker.rank < 4 && (
                          <button
                            className={`worker-management__worker-promote ${loading === `promote-${worker.id}` ? 'worker-management__worker-promote--loading' : ''}`}
                            onClick={() => handlePromote(worker)}
                            disabled={loading !== null}
                          >
                            <FontAwesomeIcon icon={faArrowUp} />
                            <span>
                              {loading === `promote-${worker.id}` ? 'Awansowanie...' : 'Awansuj'}
                            </span>
                          </button>
                        )}
                        
                        {(worker.rank > 0 && worker.rank < 5 && worker.worker_identifier !== ownerIdentifier) && (
                          <button
                            className={`worker-management__worker-demote ${loading === `demote-${worker.id}` ? 'worker-management__worker-demote--loading' : ''}`}
                            onClick={() => handleDemote(worker)}
                            disabled={loading !== null}
                          >
                            <FontAwesomeIcon icon={faArrowDown} />
                            <span>
                              {loading === `demote-${worker.id}` ? 'Degradując...' : 'Degraduj'}
                            </span>
                          </button>
                        )}
                        
                        {(worker.worker_identifier !== ownerIdentifier && (worker.rank || 0) < 5) && (
                          <button
                            className={`worker-management__worker-fire ${loading === `fire-${worker.id}` ? 'worker-management__worker-fire--loading' : ''}`}
                            onClick={() => handleFire(worker)}
                            disabled={loading !== null}
                          >
                            <FontAwesomeIcon icon={faUserMinus} />
                            <span>
                              {loading === `fire-${worker.id}` ? 'Zwalnianie...' : 'Zwolnij'}
                            </span>
                          </button>
                        )}
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

export default WorkerManagement