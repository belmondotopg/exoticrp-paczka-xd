import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { useSettingsState } from '../../../state/settings'
import './paycheck.scss'
import { faCopy, faRoute } from '@fortawesome/free-solid-svg-icons'
import { Dispatch, useState } from 'react'
import { SetStateAction } from 'jotai'
import { usePlayersData, usePlayersDataState } from '../../../state/playersData'
import { fetchNui } from '../../../utils/fetchNui'
import { useInRadialData } from '../../../state/inRadial'
import { useJobDataState } from '../../../state/jobData'
import { isLegalJob } from '../../../utils/legalJobs'


const Paycheck: React.FC<{ setHref: Dispatch<SetStateAction<string>> }> = ({ setHref }) => {
    const settings = useSettingsState()
    const playersData = usePlayersDataState()
    const jobData = useJobDataState()
    const inRadial = useInRadialData()
    const isLegal = isLegalJob(jobData?.jobName)

    const money = 1000000

    const transferMoney = (money: number, identifier: string) => {
        fetchNui('transferMoney', { identifier, money })
    }

    const [checkCorrect, setCheckCorrect] = useState<number>(0)
    return (
        <div className='kariee_paycheck'>
            <div className="kariee_header">
                <span>{isLegal ? 'PRACOWNICY I KURSY' : 'ZARZĄDZANIE WYPŁATAMI'}</span>
                <div className="kariee_header_line"></div>

                <div className="kariee_header_buttons">
                    <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                </div>
            </div>

            <div className="kariee_paycheck_content">
                <input type="text" className='search_for_player_paycheck' placeholder='Wyszukaj pracownika...' onInput={() => setCheckCorrect(checkCorrect + 1)}></input>

                {playersData.map((value, index) => {
                    const search = document.querySelector('.search_for_player_paycheck') as HTMLInputElement

                    let search_value = ''
                    if (search) {
                        search_value = search.value.toLowerCase()
                    }
                    const name_search = (value.playerFirstName + ' ' + value.playerLastName).toLowerCase()
                    const badge_search = value.playerBadge
                    const discord_search = value.playerDiscordID

                    return (
                        <>
                            {(name_search.includes(search_value) || badge_search.includes(search_value) || (search_value.includes('#') && discord_search.includes(search_value.replace('#', '')))) &&
                                <div className="kmc_content" key={index}>
                                    <div className="kmc_content_info">
                                        {!isLegal && settings?.ManageFraction && <div className="kmc_content_name_badge small_data">{value.playerBadge}</div>}
                                        {isLegal && (
                                            <div 
                                                className="kmc_content_active small_data"
                                                style={{ backgroundColor: value.playerActive ? 'green' : 'red' }}
                                                title={value.playerActive ? 'Online' : 'Offline'}
                                            ></div>
                                        )}
                                        <div className="kmc_content_name">
                                            <div className="kmc_content_name_data">
                                                <span className='kmc_c_name_player'>{value.playerFirstName + ' ' + value.playerLastName}</span>
                                                <span className='kmc_c_name_dcid'>#{value.playerDiscordID}</span>
                                            </div>
                                            <div className="kmc_content_name_copy"><FontAwesomeIcon icon={faCopy} /></div>
                                        </div>
                                        <div className="kmc_content_job">{value.playerJobGradeLabel}</div>
                                        {isLegal ? (
                                            <>
                                                <div className="kmc_content_hours_kursy small_data">
                                                    {value.playerKursy || 0}
                                                    <FontAwesomeIcon className='iconsstyle' icon={faRoute} style={{ marginLeft: '5px' }} />
                                                </div>
                                            </>
                                        ) : (
                                            <>
                                                <div className="kmc_content_hours_kursy small_data">{value.playerHours}h</div>
                                                <div className="kmc_content_rate small_data">
                                                    {value.playerHours > 0 ? (Math.round(value.playerPaycheck / value.playerHours)).toLocaleString() + '$/h' : '0$/h'}
                                                </div>
                                                <div className="kmc_content_money">{value.playerPaycheck.toLocaleString() + '$'}</div>
                                            </>
                                        )}
                                    </div>

                                    {!isLegal && !inRadial ? (
                                        <div className="kmc_content_buttons">
                                            {value.playerPaycheck > 0
                                                ?
                                                <div className="btn" onClick={() => transferMoney(value.playerPaycheck, value.playerIdentifier)}>PRZELEJ</div>
                                                :
                                                <div className="btn" style={{ backgroundColor: 'red' }}>BRAK</div>
                                            }
                                        </div>
                                    ) : isLegal ? null : (
                                        <div className="btn" style={{ backgroundColor: 'red' }}>BRAK DOSTĘPU</div>
                                    )}

                                </div>
                            }
                        </>
                    )
                })}
            </div>
        </div>
    )
}

export default Paycheck