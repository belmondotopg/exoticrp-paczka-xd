import React, { useState, useEffect } from 'react'
import './FavoriteButton.scss'

interface FavoriteButtonProps {
  vehicleId: number
  isFavorite: boolean
  onToggle: (vehicleId: number, isFavorite: boolean) => void
  size?: 'small' | 'medium' | 'large'
}

export const FavoriteButton: React.FC<FavoriteButtonProps> = ({
  vehicleId,
  isFavorite,
  onToggle,
  size = 'medium'
}) => {
  const [favorite, setFavorite] = useState(isFavorite)
  const [animating, setAnimating] = useState(false)

  useEffect(() => {
    setFavorite(isFavorite)
  }, [isFavorite])

  const handleClick = () => {
    setAnimating(true)
    const newFavorite = !favorite
    setFavorite(newFavorite)
    onToggle(vehicleId, newFavorite)
    
    setTimeout(() => setAnimating(false), 300)
  }

  return (
    <button
      className={`favorite-button ${size} ${favorite ? 'favorited' : ''} ${animating ? 'animating' : ''}`}
      onClick={handleClick}
      title={favorite ? 'Usuń z ulubionych' : 'Dodaj do ulubionych'}
    >
      <span className="heart-icon">
        {favorite ? '❤️' : '🤍'}
      </span>
    </button>
  )
}
