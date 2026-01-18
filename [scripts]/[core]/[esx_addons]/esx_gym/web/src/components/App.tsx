import { useState, useCallback, useEffect, useRef, useMemo } from 'react';
import BuyPass from './BuyPass';
import PriceManagement from './PriceManagement';
import MembershipPriceManagement from './MembershipPriceManagement';
import { GymInterface, SupplementData, SupplementStock, PlayerStats } from '../types/gym';
import GymPurchase from './GymPurchase';
import SupplementShop from './SupplementShop';
import '../App.scss';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  faDumbbell,
  faPersonRunning,
  faLungs,
  faChartLine,
  faTicket,
  faPills,
  faUsers,
  faArrowUp,
  faBox,
  faTimes,
  faCog,
  faDollarSign,
  faUserPlus,
  faWallet
} from '@fortawesome/free-solid-svg-icons';
import InventoryManagement from './InventoryManagement';
import RestockManagement from './RestockManagement';
import WorkerHire from './WorkerHire';
import WorkerManagement from './WorkerManagement';
import UpgradeManagement from './UpgradeManagement';
import CompanyAccount from './CompanyAccount';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { fetchNui } from '../utils/fetchNui';

const App = () => {
  const [visible, setVisible] = useState(false)
  const [gymData, setGymData] = useState<GymInterface | null>(null)
  const [supplementData, setSupplementData] = useState<SupplementData | null>(null)
  const [inventoryData, setInventoryData] = useState<{ stock: SupplementStock; gymName: string; maxStock?: number } | null>(null)
  const [workerHireData, setWorkerHireData] = useState<{ players: any[]; gymName: string } | null>(null)
  const [workerManagementData, setWorkerManagementData] = useState<{ workers: any[]; gymName: string; ownerIdentifier?: string } | null>(null)
  const [buyPassData, setBuyPassData] = useState<{ gymName: string; prices: any } | null>(null)
  const [restockData, setRestockData] = useState<{ gymName: string; stock: any } | null>(null)
  const [priceManagementData, setPriceManagementData] = useState<{ gymName: string; prices: any } | null>(null)
  const [membershipPriceManagementData, setMembershipPriceManagementData] = useState<{ gymName: string; prices: any } | null>(null)
  const [upgradeManagementData, setUpgradeManagementData] = useState<{ gymName: string; equipmentUpgraded: boolean } | null>(null)
  const [companyAccountData, setCompanyAccountData] = useState<{ gymName: string; balance: number } | null>(null)
  const [gymPurchaseData, setGymPurchaseData] = useState<GymInterface | null>(null)
  const [playerStats, setPlayerStats] = useState<PlayerStats | null>(null)
  const isShowingGymPurchase = useRef(false)
  const [membershipData, setMembershipData] = useState<{
    firstName: string
    lastName: string
    hasPass: boolean
    isPassValid: boolean
    validUntil: string
  } | null>(null)
  const [showStatsOnly, setShowStatsOnly] = useState(false)
  const [showMembershipOnly, setShowMembershipOnly] = useState(false)

  const handleClose = useCallback(() => {
    setVisible(false)
    setGymData(null)
    setSupplementData(null)
    setInventoryData(null)
    setWorkerHireData(null)
    setWorkerManagementData(null)
    setBuyPassData(null)
    setRestockData(null)
    setPriceManagementData(null)
    setUpgradeManagementData(null)
    setCompanyAccountData(null)
    setGymPurchaseData(null)
    setPlayerStats(null)
    setMembershipData(null)
    setShowStatsOnly(false)
    setShowMembershipOnly(false)
    isShowingGymPurchase.current = false
    fetchNui('esx_gym/closeNui', {})
  }, [])

  const handleBackToMain = useCallback(() => {
    setSupplementData(null)
    setInventoryData(null)
    setWorkerHireData(null)
    setWorkerManagementData(null)
    setBuyPassData(null)
    setRestockData(null)
    setPriceManagementData(null)
    setMembershipPriceManagementData(null)
    setUpgradeManagementData(null)
    setCompanyAccountData(null)
    setShowStatsOnly(false)
    setShowMembershipOnly(false)
  }, [])

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && visible) {
        handleClose()
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => {
      document.removeEventListener('keydown', handleKeyDown)
    }
  }, [visible, handleClose])

  useNuiEvent('setVisible', (isVisible: boolean) => {
    setVisible(isVisible)
    if (!isVisible) {
      setGymData(null)
      setSupplementData(null)
      setInventoryData(null)
      setWorkerHireData(null)
      setWorkerManagementData(null)
      setBuyPassData(null)
      setRestockData(null)
      setPriceManagementData(null)
      setUpgradeManagementData(null)
      setCompanyAccountData(null)
      setGymPurchaseData(null)
      setPlayerStats(null)
      setMembershipData(null)
      setShowStatsOnly(false)
      setShowMembershipOnly(false)
      isShowingGymPurchase.current = false
    }
  })
  
  useNuiEvent('setData', (data: GymInterface) => {
    if (!isShowingGymPurchase.current) {
      setGymData(data);
      setGymPurchaseData(null);
    }
  });
  
  useNuiEvent('updateGymData', (data: GymInterface) => {
    isShowingGymPurchase.current = false;
    setGymPurchaseData(null);
    setGymData(data);
    if (upgradeManagementData) {
      setUpgradeManagementData({
        gymName: upgradeManagementData.gymName,
        equipmentUpgraded: data.equipment_upgraded === 1
      });
    }
  });
  useNuiEvent('showSupplements', setSupplementData);
  useNuiEvent('updateSupplementShop', setSupplementData);
  useNuiEvent('showInventory', setInventoryData);
  useNuiEvent('showWorkerHire', setWorkerHireData);
  useNuiEvent('showWorkerManagement', setWorkerManagementData);
  useNuiEvent('showBuyPass', setBuyPassData);
  useNuiEvent('showRestock', setRestockData);
  useNuiEvent('showPriceManagement', setPriceManagementData);
  useNuiEvent('showMembershipPriceManagement', setMembershipPriceManagementData);
  useNuiEvent('showCompanyAccount', setCompanyAccountData);
  useNuiEvent('showUpgradeManagement', (data) => {
    if (gymData) {
      setUpgradeManagementData({
        gymName: gymData.name,
        equipmentUpgraded: gymData.equipment_upgraded === 1
      });
    } else {
      setUpgradeManagementData(data);
    }
  });
  useNuiEvent('setPlayerStats', setPlayerStats);
  useNuiEvent('setMembershipData', setMembershipData);
  useNuiEvent('showGymPurchase', (data) => {
    isShowingGymPurchase.current = true;
    setGymPurchaseData(data);
  });
  useNuiEvent('purchaseGymSuccess', (success) => {
    if (success) {
      isShowingGymPurchase.current = false;
      setGymPurchaseData(null);
    }
  });
  useNuiEvent('refreshGymData', setGymData);
  useNuiEvent('showStatsOnly', (data) => {
    setShowStatsOnly(true);
    setShowMembershipOnly(false);
    setPlayerStats(data.stats);
  });
  useNuiEvent('showMembershipOnly', (data) => {
    setShowMembershipOnly(true);
    setShowStatsOnly(false);
    setMembershipData(data.membership);
  });

  if (!visible) return null;

  if (showStatsOnly) {
    return (
      <div className="gym-stats-only">
        <div className="gym-stats-only__container">
          <div className="gym-stats-only__header">
            <h2 className="gym-stats-only__title">
              <FontAwesomeIcon icon={faChartLine} /> Twoje statystyki
            </h2>
            <button className="gym-stats-only__close" onClick={handleClose}>
              <FontAwesomeIcon icon={faTimes} />
            </button>
          </div>
          <div className="gym-stats-only__stats">
            <div className="gym-stats-only__stat">
              <div className="gym-stats-only__stat-icon">
                <FontAwesomeIcon icon={faDumbbell} />
              </div>
              <div className="gym-stats-only__stat-content">
                <div className="gym-stats-only__stat-value">{playerStats?.strength || 0}/100</div>
                <div className="gym-stats-only__stat-label">Siła</div>
                <div className="gym-stats-only__stat-progress">
                  <div
                    className="gym-stats-only__stat-progress-bar gym-stats-only__stat-progress-bar--strength"
                    style={{ width: `${playerStats?.strength || 0}%` }}
                  />
                </div>
              </div>
            </div>
            <div className="gym-stats-only__stat">
              <div className="gym-stats-only__stat-icon">
                <FontAwesomeIcon icon={faPersonRunning} />
              </div>
              <div className="gym-stats-only__stat-content">
                <div className="gym-stats-only__stat-value">{playerStats?.stamina || 0}/100</div>
                <div className="gym-stats-only__stat-label">Wytrzymałość</div>
                <div className="gym-stats-only__stat-progress">
                  <div
                    className="gym-stats-only__stat-progress-bar gym-stats-only__stat-progress-bar--stamina"
                    style={{ width: `${playerStats?.stamina || 0}%` }}
                  />
                </div>
              </div>
            </div>
            <div className="gym-stats-only__stat">
              <div className="gym-stats-only__stat-icon">
                <FontAwesomeIcon icon={faLungs} />
              </div>
              <div className="gym-stats-only__stat-content">
                <div className="gym-stats-only__stat-value">{playerStats?.lung || 0}/100</div>
                <div className="gym-stats-only__stat-label">Płuca</div>
                <div className="gym-stats-only__stat-progress">
                  <div
                    className="gym-stats-only__stat-progress-bar gym-stats-only__stat-progress-bar--lung"
                    style={{ width: `${playerStats?.lung || 0}%` }}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (showMembershipOnly) {
    return (
      <div className="gym-membership-only">
        <div className="gym-membership-only__container">
          <div className="gym-membership-only__header">
            <h2 className="gym-membership-only__title">
              <FontAwesomeIcon icon={faTicket} /> Twoje członkostwo
            </h2>
            <button className="gym-membership-only__close" onClick={handleClose}>
              <FontAwesomeIcon icon={faTimes} />
            </button>
          </div>
          <div className="gym-membership-only__content">
            <div className="gym-membership-only__row">
              <span className="gym-membership-only__label">Imię i nazwisko:</span>
              <span className="gym-membership-only__value">
                {membershipData?.firstName} {membershipData?.lastName}
              </span>
            </div>
            <div className="gym-membership-only__row">
              <span className="gym-membership-only__label">Posiadane członkostwo:</span>
              <span className={`gym-membership-only__value ${membershipData?.hasPass ? 'gym-membership-only__value--yes' : 'gym-membership-only__value--no'}`}>
                {membershipData?.hasPass ? 'TAK' : 'NIE'}
              </span>
            </div>
            <div className="gym-membership-only__row">
              <span className="gym-membership-only__label">Aktywne członkostwo:</span>
              <span className={`gym-membership-only__value ${membershipData?.isPassValid ? 'gym-membership-only__value--yes' : 'gym-membership-only__value--no'}`}>
                {membershipData?.isPassValid ? 'TAK' : 'NIE'}
              </span>
            </div>
            <div className="gym-membership-only__row">
              <span className="gym-membership-only__label">Termin ważności:</span>
              <span className="gym-membership-only__value">
                {membershipData?.validUntil || 'Brak danych'}
              </span>
            </div>
          </div>
        </div>
      </div>
    );
  }

  const renderContent = () => {
    if (gymPurchaseData && isShowingGymPurchase.current) {
      return (
        <GymPurchase
          gymData={gymPurchaseData}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (supplementData) {
      return <SupplementShop data={supplementData} onClose={handleClose} onBack={handleBackToMain} />;
    }

    if (inventoryData) {
      return (
        <InventoryManagement
          stock={inventoryData.stock}
          gymName={inventoryData.gymName}
          onClose={handleClose}
          onBack={handleBackToMain}
          maxStock={inventoryData.maxStock}
        />
      );
    }

    if (workerHireData) {
      return (
        <WorkerHire
          players={workerHireData.players}
          gymName={workerHireData.gymName}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (workerManagementData) {
      return (
        <WorkerManagement
          workers={workerManagementData.workers}
          gymName={workerManagementData.gymName}
          ownerIdentifier={workerManagementData.ownerIdentifier}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (buyPassData) {
      return (
        <BuyPass
          gymName={buyPassData.gymName}
          prices={buyPassData.prices}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (restockData) {
      return (
        <RestockManagement
          gymName={restockData.gymName}
          stock={restockData.stock}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (priceManagementData) {
      return (
        <PriceManagement
          gymName={priceManagementData.gymName}
          prices={priceManagementData.prices}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (membershipPriceManagementData) {
      return (
        <MembershipPriceManagement
          gymName={membershipPriceManagementData.gymName}
          prices={membershipPriceManagementData.prices}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (upgradeManagementData) {
      return (
        <UpgradeManagement
          gymName={upgradeManagementData.gymName}
          equipmentUpgraded={upgradeManagementData.equipmentUpgraded}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (companyAccountData) {
      return (
        <CompanyAccount
          gymName={companyAccountData.gymName}
          balance={companyAccountData.balance}
          onClose={handleClose}
          onBack={handleBackToMain}
        />
      );
    }

    if (gymData && !gymPurchaseData) {
      return (
        <div className="gym-main-menu">
          <div className="gym-main-menu__container">
            <div className="gym-main-menu__header">
              <h1 className="gym-main-menu__title">
                <FontAwesomeIcon icon={faDumbbell} /> Siłownia
              </h1>
              <button className="gym-main-menu__close" onClick={handleClose}>
                <FontAwesomeIcon icon={faTimes} />
              </button>
            </div>
            <div className="gym-main-menu__content">
              <div className="gym-main-menu__stats-section">
                <h2 className="gym-main-menu__section-title">
                  <FontAwesomeIcon icon={faChartLine} /> Twoje statystyki
                </h2>
                <div className="gym-main-menu__stats">
                  <div className="gym-main-menu__stat">
                    <div className="gym-main-menu__stat-icon">
                      <FontAwesomeIcon icon={faDumbbell} />
                    </div>
                    <div className="gym-main-menu__stat-content">
                      <div className="gym-main-menu__stat-value">{playerStats?.strength || 0}/100</div>
                      <div className="gym-main-menu__stat-label">Siła</div>
                      <div className="gym-main-menu__stat-progress">
                        <div
                          className="gym-main-menu__stat-progress-bar gym-main-menu__stat-progress-bar--strength"
                          style={{ width: `${playerStats?.strength || 0}%` }}
                        />
                      </div>
                    </div>
                  </div>
                  <div className="gym-main-menu__stat">
                    <div className="gym-main-menu__stat-icon">
                      <FontAwesomeIcon icon={faPersonRunning} />
                    </div>
                    <div className="gym-main-menu__stat-content">
                      <div className="gym-main-menu__stat-value">{playerStats?.stamina || 0}/100</div>
                      <div className="gym-main-menu__stat-label">Wytrzymałość</div>
                      <div className="gym-main-menu__stat-progress">
                        <div
                          className="gym-main-menu__stat-progress-bar gym-main-menu__stat-progress-bar--stamina"
                          style={{ width: `${playerStats?.stamina || 0}%` }}
                        />
                      </div>
                    </div>
                  </div>
                  <div className="gym-main-menu__stat">
                    <div className="gym-main-menu__stat-icon">
                      <FontAwesomeIcon icon={faLungs} />
                    </div>
                    <div className="gym-main-menu__stat-content">
                      <div className="gym-main-menu__stat-value">{playerStats?.lung || 0}/100</div>
                      <div className="gym-main-menu__stat-label">Płuca</div>
                      <div className="gym-main-menu__stat-progress">
                        <div
                          className="gym-main-menu__stat-progress-bar gym-main-menu__stat-progress-bar--lung"
                          style={{ width: `${playerStats?.lung || 0}%` }}
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              {gymData && !isShowingGymPurchase.current && (
                <div className="gym-main-menu__gym-info">
                  <h2 className="gym-main-menu__section-title">
                    <FontAwesomeIcon icon={faDumbbell} /> {gymData.label || 'Siłownia'}
                  </h2>
                  <div className="gym-main-menu__gym-details">
                    <div className="gym-main-menu__gym-row">
                      <span className="gym-main-menu__gym-label">Właściciel:</span>
                      <span className="gym-main-menu__gym-value">
                        {gymData.owner_name || 'Brak'}
                      </span>
                    </div>
                    <div className="gym-main-menu__gym-row">
                      <span className="gym-main-menu__gym-label">Status:</span>
                      <span className={`gym-main-menu__gym-value ${gymData.active ? 'gym-main-menu__gym-value--active' : 'gym-main-menu__gym-value--inactive'}`}>
                        {gymData.active ? 'Aktywna' : 'Nieaktywna'}
                      </span>
                    </div>
                    <div className="gym-main-menu__gym-row">
                      <span className="gym-main-menu__gym-label">Wyposażenie:</span>
                      <span className={`gym-main-menu__gym-value ${gymData.equipment_upgraded ? 'gym-main-menu__gym-value--upgraded' : 'gym-main-menu__gym-value--basic'}`}>
                        {gymData.equipment_upgraded ? 'Ulepszone' : 'Podstawowe'}
                      </span>
                    </div>
                  </div>
                </div>
              )}
              {membershipData && !isShowingGymPurchase.current && (
                <div className="gym-main-menu__membership-section">
                  <h2 className="gym-main-menu__section-title">
                    <FontAwesomeIcon icon={faTicket} /> Twoje członkostwo
                  </h2>
                  <div className="gym-main-menu__membership-info">
                    <div className="gym-main-menu__membership-row">
                      <span className="gym-main-menu__membership-label">Status:</span>
                      <span className={`gym-main-menu__membership-value ${membershipData.isPassValid ? 'gym-main-menu__membership-value--valid' : 'gym-main-menu__membership-value--invalid'}`}>
                        {membershipData.isPassValid ? 'Aktywne' : 'Nieaktywne'}
                      </span>
                    </div>
                    <div className="gym-main-menu__membership-row">
                      <span className="gym-main-menu__membership-label">Ważne do:</span>
                      <span className="gym-main-menu__membership-value">
                        {membershipData.validUntil || 'Brak danych'}
                      </span>
                    </div>
                  </div>
                </div>
              )}
              {!isShowingGymPurchase.current && (
                <div className="gym-main-menu__actions">
                  <h2 className="gym-main-menu__section-title">
                    <FontAwesomeIcon icon={faCog} /> Akcje
                  </h2>
                  <div className="gym-main-menu__action-buttons">
                    <button
                      className="gym-main-menu__action-btn gym-main-menu__action-btn--primary"
                      onClick={() => {
                        if (gymData) fetchNui('esx_gym/gymAction', { action: 'buySupplements', gymName: gymData.name });
                      }}
                    >
                      <FontAwesomeIcon icon={faPills} />
                      <span>Sklep</span>
                    </button>
                    <button
                      className="gym-main-menu__action-btn gym-main-menu__action-btn--secondary"
                      onClick={() => {
                        if (gymData) fetchNui('esx_gym/gymAction', { action: 'buyPass', gymName: gymData.name });
                      }}
                    >
                      <FontAwesomeIcon icon={faTicket} />
                      <span>Kup karnet</span>
                    </button>
                    {gymData && (gymData.isowner || gymData.isworker) && (
                      <button
                        className="gym-main-menu__action-btn gym-main-menu__action-btn--secondary"
                        onClick={() => fetchNui('esx_gym/gymAction', { action: 'inventory', gymName: gymData.name })}
                      >
                        <FontAwesomeIcon icon={faBox} />
                        <span>Magazyn</span>
                      </button>
                    )}
                    {gymData && (gymData.isowner || (gymData.isworker && ['manager', 'deputy', 'supervisor'].includes(gymData.accessLevel || ''))) && (
                      <button
                        className="gym-main-menu__action-btn gym-main-menu__action-btn--secondary"
                        onClick={() => fetchNui('esx_gym/gymAction', { action: 'viewWorkers', gymName: gymData.name })}
                      >
                        <FontAwesomeIcon icon={faUsers} />
                        <span>Pracownicy</span>
                      </button>
                    )}
                    {gymData && (gymData.isowner || (gymData.isworker && gymData.accessLevel === 'manager')) && (
                      <button
                        className="gym-main-menu__action-btn gym-main-menu__action-btn--secondary"
                        onClick={() => fetchNui('esx_gym/gymAction', { action: 'managePrices', gymName: gymData.name })}
                      >
                        <FontAwesomeIcon icon={faDollarSign} />
                        <span>Ceny</span>
                      </button>
                    )}
                    {gymData && gymData.isowner && (
                      <button
                        className="gym-main-menu__action-btn gym-main-menu__action-btn--secondary"
                        onClick={() => fetchNui('esx_gym/gymAction', { action: 'manageMembershipPrices', gymName: gymData.name })}
                      >
                        <FontAwesomeIcon icon={faTicket} />
                        <span>Ceny Karnetów</span>
                      </button>
                    )}
                    {gymData && gymData.isowner && (
                      <button
                        className="gym-main-menu__action-btn gym-main-menu__action-btn--secondary"
                        onClick={() => fetchNui('esx_gym/gymAction', { action: 'manageCompanyAccount', gymName: gymData.name })}
                      >
                        <FontAwesomeIcon icon={faWallet} />
                        <span>Konto Firmowe</span>
                      </button>
                    )}
                    {gymData && (gymData.isowner || (gymData.isworker && gymData.accessLevel === 'manager')) && (
                      <button
                        className="gym-main-menu__action-btn gym-main-menu__action-btn--secondary"
                        onClick={() => fetchNui('esx_gym/gymAction', { action: 'viewUpgrades', gymName: gymData.name })}
                      >
                        <FontAwesomeIcon icon={faArrowUp} />
                        <span>Ulepszenia</span>
                      </button>
                    )}
                    {gymData && (gymData.isowner || (gymData.isworker && ['manager', 'deputy'].includes(gymData.accessLevel || ''))) && (
                      <button
                        className="gym-main-menu__action-btn gym-main-menu__action-btn--secondary"
                        onClick={() => fetchNui('esx_gym/gymAction', { action: 'addWorker', gymName: gymData.name })}
                      >
                        <FontAwesomeIcon icon={faUserPlus} />
                        <span>Zatrudnij</span>
                      </button>
                    )}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      );
    }

    return null;
  };

  return (
    <div className="gym-app">
      {renderContent()}
    </div>
  );
};

export default App;