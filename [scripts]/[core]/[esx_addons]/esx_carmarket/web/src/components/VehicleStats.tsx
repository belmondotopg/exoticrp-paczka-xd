import { useState } from "react"
import './VehicleStats.scss'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { useLocaleState, useLocale } from '../hooks/useLocale'

interface VehicleData {
  model: string
  owner: string
  price: number
  since: string
  phone?: string
}

interface UpgradeCategory {
  name: string
  level: number
  maxLevel: number
  installed: boolean
}

interface PerformanceStat {
  name: string
  value: number
  maxValue: number
}

export const VehicleStats: React.FC = () => {
  const [vehicle, setVehicle] = useState<VehicleData | null>(null)
  const locale = useLocaleState()
  const [, setLocale] = useLocale()

  // Load locales when received
  useNuiEvent<{ [key: string]: string }>('loadLocales', (data) => {
    setLocale(data)
  })

  useNuiEvent<VehicleData>("setVehicleBasics", (data) => {
    setVehicle(data)
  })

  const [upgrades, setUpgrades] = useState<UpgradeCategory[]>([]);
  const [performanceStats, setPerformanceStats] = useState<PerformanceStat[]>([]);

  useNuiEvent<UpgradeCategory[]>('setUpgrades', (data) => setUpgrades(data));
  useNuiEvent<PerformanceStat[]>('setPerformanceStats', (data) => setPerformanceStats(data));

  // Function to get localized upgrade name
  const getUpgradeName = (name: string): string => {
    const upgradeMap: { [key: string]: string } = {
      'Engine': locale.engine,
      'Transmission': locale.transmission,
      'Brakes': locale.brakes,
      'Suspension': locale.suspension,
      'Turbo': locale.turbo
    }
    return upgradeMap[name] || name
  }

  // Function to get localized performance stat name
  const getPerformanceStatName = (name: string): string => {
    const statMap: { [key: string]: string } = {
      'Speed': locale.speed,
      'Acceleration': locale.acceleration,
      'Braking': locale.braking,
      'Traction': locale.traction
    }
    return statMap[name] || name
  }

  if (!vehicle || !upgrades || !performanceStats) return null

  return (
    <div className="container">
      <div className="items">
        <div>
          <h3>{vehicle.model}</h3>
          <p>Właściciel: {vehicle.owner}</p>
          <p>Cena: ${vehicle.price.toLocaleString()}</p>
          <p>Data wystawienia: {vehicle.since}</p>
          {vehicle.phone && <p>Telefon: {vehicle.phone}</p>}
        </div>

        <div>
        <h3>Ulepszenia:</h3>
          {upgrades.map((upgrade, index) => (
            <p key={index}>
              {upgrade.name}: {upgrade.installed ? `Poziom ${upgrade.level}/${upgrade.maxLevel}` : 'Brak'}
            </p>
          ))}
        </div>

        <div>
          <h3>Statystyki:</h3>
          {performanceStats.map((stat, index) => (
            <p key={index}>
              {stat.name}: {stat.value}/{stat.maxValue}
            </p>
          ))}
        </div>
      </div>
    </div>
  );
}