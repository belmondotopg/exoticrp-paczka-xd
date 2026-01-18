import React, { useState } from 'react'
import './VehicleCard.scss'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { fetchNui } from '../utils/fetchNui'

interface VehicleDetails {
  id: number
  model: string
  plate: string
  owner: string
  price: number
  since: string
  props: any
  phone: string
}

export const VehicleCard: React.FC = () => {
  const [visible, setVisible] = useState(false)
  const [vehicleDetails, setVehicleDetails] = useState<VehicleDetails | null>(null)

  useNuiEvent<VehicleDetails>('openVehicleCard', (data) => {
    setVehicleDetails(data)
    setVisible(true)
  })

  const handleClose = () => {
    setVisible(false)
    setVehicleDetails(null)
    SetNuiFocus(false, false)
  }

  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (event.key === 'Escape') {
      handleClose()
    }
  }

  if (!visible || !vehicleDetails) return null

  const getVehicleDisplayName = (model: string) => {
    return model || "Nieznany pojazd"
  }

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('pl-PL').format(price)
  }

  const getUpgradeLevel = (modValue: number) => {
    if (modValue === -1) return "Brak"
    return `Poziom ${modValue + 1}`
  }

  const getColorName = (color: number) => {
    const colors = [
      "Czarny", "Biały", "Szary", "Czerwony", "Niebieski", "Zielony", 
      "Żółty", "Pomarańczowy", "Fioletowy", "Różowy", "Brązowy"
    ]
    return colors[color] || `Kolor ${color}`
  }

  return (
    <div className="vehicle-card-overlay" onKeyDown={handleKeyDown} tabIndex={-1}>
      <div className="vehicle-card">
        <div className="vehicle-card-header">
          <h2>Karta Pojazdu</h2>
          <button className="close-btn" onClick={handleClose}>×</button>
        </div>
        
        <div className="vehicle-card-content">
          <div className="vehicle-info">
            <div className="info-section">
              <h3>Podstawowe Informacje</h3>
              <div className="info-grid">
                <div className="info-item">
                  <span className="label">Nazwa pojazdu:</span>
                  <span className="value">{getVehicleDisplayName(vehicleDetails.model)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Rejestracja:</span>
                  <span className="value">{vehicleDetails.plate}</span>
                </div>
                <div className="info-item">
                  <span className="label">Cena:</span>
                  <span className="value price">${formatPrice(vehicleDetails.price)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Data wystawienia:</span>
                  <span className="value">{vehicleDetails.since}</span>
                </div>
              </div>
            </div>

            <div className="info-section">
              <h3>Informacje o Sprzedawcy</h3>
              <div className="info-grid">
                <div className="info-item">
                  <span className="label">Imię i nazwisko:</span>
                  <span className="value">{vehicleDetails.owner}</span>
                </div>
                <div className="info-item">
                  <span className="label">Numer telefonu:</span>
                  <span className="value">{vehicleDetails.phone}</span>
                </div>
              </div>
            </div>

            <div className="info-section">
              <h3>Wygląd Pojazdu</h3>
              <div className="info-grid">
                <div className="info-item">
                  <span className="label">Kolor podstawowy:</span>
                  <span className="value">{getColorName(vehicleDetails.props.color1 || 0)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Kolor dodatkowy:</span>
                  <span className="value">{getColorName(vehicleDetails.props.color2 || 0)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Kolor wnętrza:</span>
                  <span className="value">{getColorName(vehicleDetails.props.interiorColor || 0)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Kolor deski rozdzielczej:</span>
                  <span className="value">{getColorName(vehicleDetails.props.dashboardColor || 0)}</span>
                </div>
              </div>
            </div>

            <div className="info-section">
              <h3>Ulepszenia</h3>
              <div className="info-grid">
                <div className="info-item">
                  <span className="label">Silnik:</span>
                  <span className="value">{getUpgradeLevel(vehicleDetails.props.modEngine || -1)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Skrzynia biegów:</span>
                  <span className="value">{getUpgradeLevel(vehicleDetails.props.modTransmission || -1)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Hamulce:</span>
                  <span className="value">{getUpgradeLevel(vehicleDetails.props.modBrakes || -1)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Zawieszenie:</span>
                  <span className="value">{getUpgradeLevel(vehicleDetails.props.modSuspension || -1)}</span>
                </div>
                <div className="info-item">
                  <span className="label">Turbo:</span>
                  <span className="value">{vehicleDetails.props.modTurbo ? "Zainstalowane" : "Brak"}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div className="vehicle-card-footer">
          <button className="close-button" onClick={handleClose}>
            Zamknij
          </button>
        </div>
      </div>
    </div>
  )
}

const SetNuiFocus = (hasFocus: boolean, hasCursor: boolean) => {
  fetchNui('setNuiFocus', { hasFocus, hasCursor })
}
