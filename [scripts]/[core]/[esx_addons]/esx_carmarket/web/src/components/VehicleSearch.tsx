import React, { useState } from 'react'
import './VehicleSearch.scss'

interface VehicleSearchProps {
  onSearch: (query: string) => void
  onFilter: (filters: SearchFilters) => void
  onSort: (sortBy: string) => void
}

interface SearchFilters {
  priceMin: number
  priceMax: number
  category: string
  condition: string
}

export const VehicleSearch: React.FC<VehicleSearchProps> = ({
  onSearch,
  onFilter,
  onSort
}) => {
  const [searchQuery, setSearchQuery] = useState('')
  const [showFilters, setShowFilters] = useState(false)
  const [filters, setFilters] = useState<SearchFilters>({
    priceMin: 0,
    priceMax: 10000000,
    category: 'all',
    condition: 'all'
  })

  const handleSearch = (query: string) => {
    setSearchQuery(query)
    onSearch(query)
  }

  const handleFilterChange = (newFilters: Partial<SearchFilters>) => {
    const updatedFilters = { ...filters, ...newFilters }
    setFilters(updatedFilters)
    onFilter(updatedFilters)
  }

  const clearFilters = () => {
    const defaultFilters: SearchFilters = {
      priceMin: 0,
      priceMax: 10000000,
      category: 'all',
      condition: 'all'
    }
    setFilters(defaultFilters)
    onFilter(defaultFilters)
  }

  return (
    <div className="vehicle-search">
      <div className="search-header">
        <div className="search-input-container">
          <input
            type="text"
            placeholder="Szukaj pojazdów..."
            value={searchQuery}
            onChange={(e) => handleSearch(e.target.value)}
            className="search-input"
          />
          <div className="search-icon">🔍</div>
        </div>
        
        <div className="search-controls">
          <button
            className={`filter-toggle ${showFilters ? 'active' : ''}`}
            onClick={() => setShowFilters(!showFilters)}
          >
            <span>Filtry</span>
            <span className="filter-icon">⚙️</span>
          </button>
          
          <select
            className="sort-select"
            onChange={(e) => onSort(e.target.value)}
            defaultValue="newest"
          >
            <option value="newest">Najnowsze</option>
            <option value="oldest">Najstarsze</option>
            <option value="price-low">Cena: rosnąco</option>
            <option value="price-high">Cena: malejąco</option>
            <option value="name">Nazwa: A-Z</option>
          </select>
        </div>
      </div>

      {showFilters && (
        <div className="search-filters">
          <div className="filter-section">
            <h4>Zakres cenowy</h4>
            <div className="price-range">
              <input
                type="number"
                placeholder="Min"
                value={filters.priceMin || ''}
                onChange={(e) => handleFilterChange({ priceMin: parseInt(e.target.value) || 0 })}
                className="price-input"
              />
              <span>-</span>
              <input
                type="number"
                placeholder="Max"
                value={filters.priceMax || ''}
                onChange={(e) => handleFilterChange({ priceMax: parseInt(e.target.value) || 10000000 })}
                className="price-input"
              />
            </div>
          </div>

          <div className="filter-section">
            <h4>Kategoria</h4>
            <select
              value={filters.category}
              onChange={(e) => handleFilterChange({ category: e.target.value })}
              className="filter-select"
            >
              <option value="all">Wszystkie</option>
              <option value="sports">Sportowe</option>
              <option value="sedan">Sedany</option>
              <option value="suv">SUV</option>
              <option value="motorcycle">Motocykle</option>
              <option value="truck">Ciężarówki</option>
            </select>
          </div>

          <div className="filter-section">
            <h4>Stan</h4>
            <select
              value={filters.condition}
              onChange={(e) => handleFilterChange({ condition: e.target.value })}
              className="filter-select"
            >
              <option value="all">Wszystkie</option>
              <option value="excellent">Doskonały</option>
              <option value="good">Dobry</option>
              <option value="fair">Przeciętny</option>
              <option value="poor">Słaby</option>
            </select>
          </div>

          <button className="clear-filters" onClick={clearFilters}>
            Wyczyść filtry
          </button>
        </div>
      )}
    </div>
  )
}
