import React, { useState } from 'react'
import './VehicleComparison.scss'

interface VehicleData {
  id: number
  model: string
  plate: string
  owner: string
  price: number
  since: string
  props: any
  phone: string
}

interface VehicleComparisonProps {
  vehicles: VehicleData[]
  onClose: () => void
}

export const VehicleComparison: React.FC<VehicleComparisonProps> = ({
  vehicles,
  onClose
}) => {
  const [selectedVehicles, setSelectedVehicles] = useState<VehicleData[]>(vehicles.slice(0, 2))

  const addToComparison = (vehicle: VehicleData) => {
    if (selectedVehicles.length >= 3) return
    if (selectedVehicles.find(v => v.id === vehicle.id)) return
    
    setSelectedVehicles(prev => [...prev, vehicle])
  }

  const removeFromComparison = (vehicleId: number) => {
    setSelectedVehicles(prev => prev.filter(v => v.id !== vehicleId))
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

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('pl-PL').format(price)
  }

  return (
    <div className="comparison-overlay">
      <div className="comparison-container">
        <div className="comparison-header">
          <h2>Porównanie Pojazdów</h2>
          <button className="close-btn" onClick={onClose}>×</button>
        </div>

        <div className="comparison-content">
          {selectedVehicles.length === 0 ? (
            <div className="no-vehicles">
              <p>Wybierz pojazdy do porównania</p>
            </div>
          ) : (
            <div className="comparison-table">
              <div className="comparison-row header">
                <div className="comparison-cell">Kryterium</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell vehicle-header">
                    <div className="vehicle-name">{vehicle.model}</div>
                    <button 
                      className="remove-btn"
                      onClick={() => removeFromComparison(vehicle.id)}
                    >
                      ×
                    </button>
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Cena</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    ${formatPrice(vehicle.price)}
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Właściciel</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    {vehicle.owner}
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Data wystawienia</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    {vehicle.since}
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Kolor podstawowy</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    {getColorName(vehicle.props.color1 || 0)}
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Silnik</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    {getUpgradeLevel(vehicle.props.modEngine || -1)}
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Skrzynia biegów</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    {getUpgradeLevel(vehicle.props.modTransmission || -1)}
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Hamulce</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    {getUpgradeLevel(vehicle.props.modBrakes || -1)}
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Zawieszenie</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    {getUpgradeLevel(vehicle.props.modSuspension || -1)}
                  </div>
                ))}
              </div>

              <div className="comparison-row">
                <div className="comparison-cell">Turbo</div>
                {selectedVehicles.map(vehicle => (
                  <div key={vehicle.id} className="comparison-cell">
                    {vehicle.props.modTurbo ? "Tak" : "Nie"}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="comparison-footer">
          <button className="close-button" onClick={onClose}>
            Zamknij
          </button>
        </div>
      </div>
    </div>
  )
}
