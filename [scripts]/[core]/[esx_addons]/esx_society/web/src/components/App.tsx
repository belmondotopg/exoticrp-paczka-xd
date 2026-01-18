import React, { useEffect, useState } from 'react';
import './App.scss'
import './GeneralColors.scss'
import testBg from '../img/testbg.png';
import { isEnvBrowser } from '../utils/misc';
import {debugData} from "../utils/debugData";
import { fetchNui } from '../utils/fetchNui';
import NavBar from './pages/NavBar/navbar';
import ManagePlayer from './pages/ManagePlayer/manageplayer';
import HirePlayer from './pages/ManagePlayer/HirePlayer/hireplayer';
import Paycheck from './pages/Paycheck/paycheck';
import History from './pages/History/history';
import TuneHistory from './pages/TuneHistory/history';
import OrderForm from './pages/OrderForm/form';
import Licenses from './pages/Licenses/licenses';
import FirmManage from './pages/FirmManage/firmmanage';
import Statistics from './pages/Statistics/statistics';
import FinancialReports from './pages/FinancialReports/financialreports';

import { useNuiEvent } from '../hooks/useNuiEvent';
import { userSettings } from '../types/settings';
import { useSetSettings } from '../state/settings';
import { useHrefState } from '../state/href';
import kariee_job_data from '../types/jobData';
import { useSetJobData } from '../state/jobData';
import playerData from '../types/playerData';
import { useSetPlayerData } from '../state/playerData';
import playersData from '../types/playersData';
import { useSetPlayersData } from '../state/playersData';
import playersAround from '../types/playersAround';
import { useSetPlayerAround } from '../state/playersAround';
import kariee_history from '../types/history';
import { useSetHistoryData } from '../state/history';
import tune_history from '../types/tunehistory';
import { useSetTuneHistoryData } from '../state/tunehistory';
import { useSetJobLicensesData } from '../state/licenses';
import { useSetInRadialData } from '../state/inRadial';
import { setImagePath } from '../providers/images';
import Upgrade from './pages/Upgrades/upgrade';
import { useSetUpgradesData } from '../state/upgrades';
import { UpgradesData } from '../types/upgrades';

import UpgradeLegal from './pages/UpgradesLegal/upgradelegal';
import { useSetUpgradesLegalData } from '../state/upgradeslegal';
import { UpgradesLegalData } from '../types/upgradeslegal';

// Debug data tylko w środowisku deweloperskim
if (isEnvBrowser() && import.meta.env.DEV) {
  debugData([
    {
      action: 'setVisible',
      data: true,
    }
  ])

  debugData([
    {
      action: 'setData',
    data: {
      userSetts: {
        ManageFraction: false,
        ManagePermID: false,
        ManageLegal: false,
        ManageEMS: false,
        ManageGrade: 1,
      },

      userJobData: {
        jobName: 'org1',
        jobLabel: 'ORG1 - ZOO',
        jobImage: 'https://media.discordapp.net/attachments/988013496094556181/1145544578456354858/lspdLogo_1.png',
        jobMoney: 1000000,
        jobPlayers: 100,
        jobData: {
          jobDataOnline: 3,
          jobDataLevel: 1,
          jobDataLevelPoints: 10,
          jobDataNextLevelPoints: 100,
          jobDataStrefy: 5,
          jobDataKursy: 20,
          jobDataFaktury: 30,
          jobDataMandaty: 40,
          jobDataWyroki: 50,
        }
      },

      psData: [
        {
          playerIdentifier: 'char1:kutaskutas',
          playerJob: 'org1',
          playerJobGrade: 3,
          playerJobGradeLabel: 'Koordynator',
          playerName: 'kariee',
          playerFirstName: 'Swen',
          playerLastName: 'Star',
          playerID: 1,
          playerPermID: 1,
          playerDiscordID: '313701223419346946',
          playerHours: 100,
          playerTunes: 200,
          playerTunesMoney: 20000,
          playerKursy: 5,
          playerBadge: '01',
          playerPaycheck: 1000000,
          playerLicenses: {
            seu: true,
            lw: true,
            swat: true,
            aiad: false,
            hc: false,
            swim: true,
            heli: true,
            td: false,
            hp: true,
          },
        },
        {
          playerIdentifier: 'char1:kutaskutas2',
          playerJob: 'org1',
          playerJobGrade: 4,
          playerJobGradeLabel: 'Szef',
          playerName: 'kariee',
          playerFirstName: 'Chris',
          playerLastName: 'Frog',
          playerID: 2,
          playerPermID: 2,
          playerDiscordID: '788388306241060866',
          playerHours: 150,
          playerTunes: 2,
          playerKursy: 0,
          playerBadge: '02',
          playerPaycheck: 2500000,
          playerLicenses: {
            seu: true,
            lw: true,
            swat: true,
            aiad: false,
            hc: false,
            swim: true,
            heli: true,
            td: false,
            hp: true,
          },
        },
      ],

      pData: {
        identifier: 'char1:kutaskutas',
        id: 1,
        permid: 1,
        name: 'kariee',
        firstname: 'Chris',
        lastname: 'Frog',
        job: 'org0',
        job_grade: 5,
        discordid: '788388306241060866',
      }
    }
  }
])

// debugData([
//   {
//     action: 'setPlayerAround',
//     data: [
//       {
//         identifier: 'char1:kutaskutas',
//         id: 1,
//         permid: 1,
//         name: 'kariee',
//         firstname: 'Chris',
//         lastname: 'Frog',
//         discordid: '788388306241060866',
//       },
//       {
//         identifier: 'char1:kutaskutas1',
//         id: 2,
//         permid: 2,
//         name: 'kariee',
//         firstname: 'Swein',
//         lastname: 'Aiffy',
//         discordid: '10238102983701293',
//       },
//     ]
//   }
// ])

  debugData([
    {
      action: 'setUpgradeData',
      data: [
        {
          upgrade_name: 'penis',
          upgrade_source: 'penis',
          upgrade_price: 50000000000000,
          upgrade_buyed: false
        },
        {
          upgrade_name: 'penis',
          upgrade_source: 'penis',
          upgrade_price: 500,
          upgrade_buyed: true
        },
      ]
    }
  ])
}


const App: React.FC = () => {
  const setSettings = useSetSettings()
  const setJobData = useSetJobData()
  const setPlayerData = useSetPlayerData()
  const setPlayersData = useSetPlayersData()
  const setPlayerAround = useSetPlayerAround()
  const setHistory = useSetHistoryData()
  const setTuneHistory = useSetTuneHistoryData()
  const setInRadial = useSetInRadialData()
  const setUpgradeData = useSetUpgradesData()
  const setUpgradeLegalData = useSetUpgradesLegalData()
  const [href, setHref] = useState('')


  useNuiEvent<{
    userSetts: userSettings;
    userJobData: kariee_job_data;
    pData: playerData;
    psData: playersData[];
  }>('setData', ({userSetts, userJobData, pData, psData}) => {
    setSettings(userSetts)
    setJobData(userJobData)
    setPlayerData(pData)
    setPlayersData(psData)
  })

  const setJobLicenses = useSetJobLicensesData()
  useNuiEvent<string[]>('setJobLicenses', setJobLicenses)
  useNuiEvent<kariee_history[]>('setHistory', setHistory)
  useNuiEvent<tune_history[]>('setTuneHistory', setTuneHistory)
  useNuiEvent<playersData[]>('setPlayersData', setPlayersData)
  useNuiEvent<kariee_job_data>('setJobData', setJobData)
  useNuiEvent<playerData>('setPlayerData', setPlayerData)
  useNuiEvent<UpgradesData[]>('setUpgradeData', setUpgradeData)
  useNuiEvent<UpgradesLegalData[]>('setUpgradeLegalData', setUpgradeLegalData)
  useNuiEvent<playersAround[]>('setPlayerAround', (data) => {
    setPlayerAround(data)
    setHref('hire')
  })

  useNuiEvent<boolean>('isRadial', (data) => {
    setInRadial(data)
  })

  useNuiEvent<string>('setImages', setImagePath)

  return (
    <>
      {isEnvBrowser() && <img src={testBg} className="background-image"/> }
      <div className="kariee_container">
        <div className="kariee_bosshub">
          {href == '' && <NavBar setHref={setHref}/>}
          {href == 'manage' && <ManagePlayer setHref={setHref}/>}
          {href == 'firma' && <FirmManage setHref={setHref}/>}
          {href == 'licenses' && <Licenses setHref={setHref}/>}
          {href == 'paycheck' && <Paycheck setHref={setHref}/>}
          {href == 'hire' && <HirePlayer setHref={setHref}/>}
          {href == 'history' && <History setHref={setHref}/>}
          {href == 'tunehistory' && <TuneHistory setHref={setHref}/>}
          {href == 'orderForm' && <OrderForm setHref={setHref}/>}
          {href == 'upgrades' && <Upgrade setHref={setHref}/>}
          {href == 'upgradeslegal' && <UpgradeLegal setHref={setHref}/>}
          {href == 'statistics' && <Statistics setHref={setHref}/>}
          {href == 'financialreports' && <FinancialReports setHref={setHref}/>}
        </div>
      </div>
    </>
  );
}

export default App;
