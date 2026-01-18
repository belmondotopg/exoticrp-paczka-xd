export interface GymInterface {
  id?: number
  name: string
  label: string
  price: number
  owner_name: string
  owner_identifier: string
  avaliable: number
  active: number
  stock: string
  supplement_prices?: string
  isowner: boolean
  isworker?: boolean
  accessLevel?: string // 'owner', 'manager', 'deputy', 'supervisor', 'worker', 'trainee', 'none'
  equipment_upgraded?: number
  company_account?: number
}

export interface GymWorker {
  id: number
  gym_name: string
  worker_name: string
  worker_identifier: string
  worker_rank_label: string
  worker_rank_grade: number
}

export interface SupplementStock {
  kreatyna?: number
  l_karnityna?: number
  bialko?: number
  // Angielskie klucze (fallback)
  creatine?: number
  lcarnitine?: number
  whey?: number
}

export interface SupplementPrices {
  kreatyna?: number
  l_karnityna?: number
  bialko?: number
  // Angielskie klucze (fallback)
  creatine?: number
  lcarnitine?: number
  whey?: number
}

export interface SupplementData {
  stock: SupplementStock
  prices: SupplementPrices
  gymName: string
}

export interface SupplementShopProps {
  data: SupplementData
  onClose: () => void
  onBack: () => void
}

export interface BuyPassProps {
  gymName: string
  onClose: () => void
  onBack: () => void
}

export interface PlayerStats {
  stamina: number
  strength: number
  lung: number
}

export interface SupplementBoosts {
  stamina: number
  strength: number
  lung: number
}
