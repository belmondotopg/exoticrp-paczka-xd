import React, { useState } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faWallet, faTimes, faArrowLeft, faArrowDown } from '@fortawesome/free-solid-svg-icons'
import { fetchNui } from '../utils/fetchNui'
import './CompanyAccount.scss'

interface CompanyAccountProps {
  gymName: string
  balance: number
  onClose: () => void
  onBack?: () => void
}

const CompanyAccount: React.FC<CompanyAccountProps> = ({ gymName, balance, onClose, onBack }) => {
  const [withdrawAmount, setWithdrawAmount] = useState('')
  const [loading, setLoading] = useState(false)

  const handleWithdraw = () => {
    if (loading) return
    
    const amount = parseInt(withdrawAmount)
    
    if (!amount || amount <= 0) {
      return
    }
    
    if (amount > balance) {
      return
    }
    
    setLoading(true)
    
    fetchNui('esx_gym/withdrawCompanyAccount', {
      gymName: gymName,
      amount: amount
    }).finally(() => {
      setLoading(false)
    })
  }

  const handleMaxWithdraw = () => {
    setWithdrawAmount(balance.toString())
  }

  return (
    <div className="company-account">
      <div className="company-account__container">
        <div className="company-account__header">
          {onBack && (
            <button 
              className="company-account__back"
              onClick={onBack}
            >
              <FontAwesomeIcon icon={faArrowLeft} />
            </button>
          )}
          <h1 className="company-account__title">
            <FontAwesomeIcon icon={faWallet} /> Konto Firmowe
          </h1>
          <button 
            className="company-account__close"
            onClick={onClose}
          >
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>

        <div className="company-account__content">
          <div className="company-account__info">
            <p className="company-account__description">
              Wszystkie zarobki z siłowni (sprzedane karnety, suplementy itd.) trafiają na to konto. 
              Jako właściciel możesz wypłacić środki z konta firmowego.
            </p>
          </div>

          <div className="company-account__balance-section">
            <div className="company-account__balance-header">
              <div className="company-account__balance-icon">
                <FontAwesomeIcon icon={faWallet} />
              </div>
              <h3 className="company-account__balance-title">Saldo Konta Firmowego</h3>
            </div>
            <div className="company-account__balance-amount">
              ${balance.toLocaleString()}
            </div>
            <p className="company-account__balance-label">Dostępne środki</p>
          </div>

          <div className="company-account__withdraw-section">
            <div className="company-account__withdraw-header">
              <h3 className="company-account__withdraw-title">
                <FontAwesomeIcon icon={faArrowDown} /> Wypłać Środki
              </h3>
            </div>

            <div className="company-account__withdraw-form">
              <div className="company-account__form-group">
                <label className="company-account__form-label">
                  Kwota do wypłaty ($)
                </label>
                <div className="company-account__form-input-wrapper">
                  <input
                    type="number"
                    className="company-account__form-input"
                    value={withdrawAmount}
                    onChange={(e) => setWithdrawAmount(e.target.value)}
                    min="1"
                    max={balance}
                    placeholder="0"
                  />
                  <button
                    className="company-account__max-btn"
                    onClick={handleMaxWithdraw}
                    disabled={balance === 0}
                  >
                    MAX
                  </button>
                </div>
                <p className="company-account__available-info">
                  Dostępne do wypłaty: ${balance.toLocaleString()}
                </p>
              </div>

              <button
                className={`company-account__withdraw-btn ${loading ? 'company-account__withdraw-btn--loading' : ''}`}
                onClick={handleWithdraw}
                disabled={loading || !withdrawAmount || parseInt(withdrawAmount) <= 0 || parseInt(withdrawAmount) > balance}
              >
                <FontAwesomeIcon icon={faArrowDown} />
                <span>
                  {loading ? 'Wypłacanie...' : 'Wypłać Środki'}
                </span>
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  )
}

export default CompanyAccount
