import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { useSettingsState } from '../../../state/settings'
import './manageplayer.scss'
import { faClock, faCopy, faMoneyBill, faWrench, faRoute } from '@fortawesome/free-solid-svg-icons'
import { Dispatch, useState } from 'react'
import { SetStateAction } from 'jotai'
import { usePlayersDataState } from '../../../state/playersData'
import { usePlayerDataState } from '../../../state/playerData'
import { fetchNui } from '../../../utils/fetchNui'
import { useNuiEvent } from '../../../hooks/useNuiEvent'
import { useInRadialData } from '../../../state/inRadial'
import { useJobDataState } from '../../../state/jobData'
import { isLegalJob } from '../../../utils/legalJobs'

interface jobGrades {
    jobLabel: string
    jobGrade: number
    sameJob: boolean
    higherJob: boolean
}[]

const ManagePlayer: React.FC<{ setHref: Dispatch<SetStateAction<string>> }> = ({ setHref }) => {
    const settings = useSettingsState()
    const jobData = useJobDataState()
    const [clickedName, setClickedName] = useState<string>('')
    const [clickedLicense, setClickedLicense] = useState<string>('')
    const [changeBadge, setChangeBadge] = useState<boolean>(false)
    const [changeRang, setChangeRang] = useState<boolean>(false)
    const inRadial = useInRadialData()
    const playersData = usePlayersDataState()
    const playerData = usePlayerDataState()
    const [promotionJobs, setPromotionJobs] = useState<jobGrades[]>([])

    useNuiEvent<jobGrades[]>('openPromotion', (data) => {
        setPromotionJobs(data)
        setChangeRang(true)
    })

    const resetTunow = () => {
        fetchNui('tuneCountReset')
    }

    const openZatrudnienie = () => {
        fetchNui('openZatrudnienie')
    }

    const resetGodzin = () => {
        fetchNui('hoursReset')
    }

    const resetGodzinPlayer = (identifier: string) => {
        fetchNui('targetResetHours', { identifier })
    }

    const resetKursow = () => {
        fetchNui('coursesReset')
    }

    const resetKursowPlayer = (identifier: string) => {
        fetchNui('targetResetCourses', { identifier })
    }

    const firePlayer = (license: string) => {
        fetchNui('fireTargetPlayer', { identifier: license })
    }

    const copyDiscord = (discord: string) => {
        // Use fallback method directly (Clipboard API is blocked in FiveM iframes)
        try {
            const copy = document.createElement('textarea')
            copy.value = discord
            copy.style.position = 'fixed'
            copy.style.opacity = '0'
            copy.style.left = '-9999px'
            document.body.appendChild(copy)
            copy.select()
            copy.setSelectionRange(0, 99999)
            document.execCommand('copy')
            document.body.removeChild(copy)
        } catch (err) {
            console.error('Copy to clipboard failed')
        }
    }

    const changedBadgeFP = (license: string) => {
        const userBadge = document.getElementById('kariee_chb_content_input') as HTMLInputElement
        if (!userBadge) return
        setChangeBadge(false)
        fetchNui('targetChangeBadge', { identifier: license, badge: userBadge.value })
    }

    const changedRangFP = (rang: number, license: string) => {
        setChangeRang(false)
        fetchNui('targetChangeGrade', { identifier: license, grade: rang })
    }

    const ChangeBadge: React.FC<{ name: string; license: string }> = ({ name, license }) => (
        <div className='kariee_changebadge'>
            <div className="kariee_changebadge_content">
                <div className="kariee_chb_header">
                    <div className="kariee_chbh_name">{name}</div>
                    <div className="kariee_chbh_context">
                        <div className="kariee_chbh_con">ZMIEŃ ODZNAKĘ</div>
                        <div className="kariee_chbh_line"></div>
                        <div className="kariee_chbh_btn btn" onClick={() => setChangeBadge(false)}>ANULUJ</div>
                    </div>
                </div>
                <div className="kariee_chb_content">
                    <input type="number" id="kariee_chb_content_input" placeholder='Numer odznaki...'></input>
                    <div className="kariee_chbh_c_btn btn" onClick={() => changedBadgeFP(license)}>POTWIERDŹ</div>
                </div>
            </div>
        </div>
    )

    const ChangeRang: React.FC<{ name: string; license: string }> = ({ name, license }) => (
        <div className='kariee_changebadge'>
            <div className="kariee_changerang_content">
                <div className="kariee_chb_header kariee_chr_header">
                    <div className="kariee_chbh_name">{name}</div>
                    <div className="kariee_chbh_context">
                        <div className="kariee_chbh_con">ZMIEŃ RANGĘ</div>
                        <div className="kariee_chbh_line"></div>
                        <div className="kariee_chbh_btn btn" onClick={() => setChangeRang(false)}>ANULUJ</div>
                    </div>
                </div>
                <div className="kariee_chb_content_rang">
                    {promotionJobs && promotionJobs.map((value, index) => (
                        <div className="kariee_chb_c_r_ranga" key={index}>
                            <div className="kariee_chb_cr_r_description"><span>{value.jobLabel}</span></div>
                            <div
                                className="kariee_chb_cr_r_btn btn"
                                style={{
                                    backgroundColor: value.sameJob ? 'orange' : value.higherJob ? 'red' : 'var(--_buttonColor)',
                                }}
                                onClick={() => {
                                    if (!value.sameJob && !value.higherJob) changedRangFP(value.jobGrade, license)
                                }}
                            >
                                {value.sameJob ? 'POSIADANA' : value.higherJob ? 'NIEDOSTĘPNE' : 'ZMIEŃ'}
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )

    const [checkCorrect, setCheckCorrect] = useState<number>(0)

    return (
        <>
            {changeBadge && <ChangeBadge name={clickedName} license={clickedLicense} />}
            {changeRang && <ChangeRang name={clickedName} license={clickedLicense} />}
            <div className='kariee_manage'>
                <div className="kariee_header">
                    <span>ZARZĄDZANIE PRACOWNIKAMI</span>
                    <div className="kariee_header_line"></div>
                    <div className="kariee_header_buttons">
                        {!inRadial && (
                            <>
                                <div className="btn" onClick={openZatrudnienie}><span>ZATRUDNIJ</span></div>
                                {settings?.ManageFraction && (
                                    <div className="btn" onClick={resetGodzin}><span>RESET GODZIN</span></div>
                                )}
                                {settings?.ManageLegal && isLegalJob(jobData?.jobName) && (
                                    <div className="btn" onClick={resetKursow}><span>RESET KURSÓW</span></div>
                                )}
                                {settings?.ManageFraction && (jobData?.jobName === 'mechanik' || jobData?.jobName === 'ec') && (
                                    <div className="btn" onClick={resetTunow}><span>RESET TUNINGÓW</span></div>
                                )}
                            </>
                        )}
                        <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                    </div>
                </div>
                <div className="kariee_manage_content">
                    <input
                        type="text"
                        className='search_for_player'
                        placeholder='Wyszukaj pracownika...'
                        onInput={() => setCheckCorrect(checkCorrect + 1)}
                    />
                    {playersData.map((value, index) => {
                        const search = document.querySelector('.search_for_player') as HTMLInputElement
                        let search_value = ''
                        if (search) search_value = search.value.toLowerCase()
                        const name_search = (value.playerFirstName + ' ' + value.playerLastName).toLowerCase()
                        const badge_search = String(value.playerBadge ?? '')
                        const discord_search = String(value.playerDiscordID ?? '')

                        return (
                            <>
                                {(name_search.includes(search_value)
                                    || (settings?.ManageFraction && badge_search !== '' && badge_search.includes(search_value))
                                    || (discord_search !== '' && discord_search.includes(search_value.replace('#', '')))) && (
                                    <div className="kmc_content" key={index}>
                                        <div className="kmc_content_info">
                                            <div
                                                className="kmc_content_active small_data"
                                                style={{ backgroundColor: value.playerActive ? 'green' : 'red' }}
                                            ></div>
                                            {settings?.ManageFraction && (
                                                <div className="kmc_content_permid small_data">{value.playerBadge}</div>
                                            )}
                                            {settings?.ManagePermID && (
                                                <div className="kmc_content_permid small_data">{value.playerPermID}</div>
                                            )}
                                            <div className="kmc_content_name name_data_content">
                                                <div className="kmc_content_name_data">
                                                    <span className='kmc_c_name_player'>{value.playerFirstName + ' ' + value.playerLastName}</span>
                                                    <span className='kmc_c_name_dcid'>#{value.playerDiscordID}</span>
                                                </div>
                                                <div className="kmc_content_name_copy" onClick={() => copyDiscord(discord_search)}>
                                                    <FontAwesomeIcon icon={faCopy} />
                                                </div>
                                            </div>
                                            <div className="kmc_content_job">{value.playerJobGradeLabel}</div>
                                            {settings?.ManageFraction && (
                                                <div className="kmc_content_hours small_data">
                                                    {value.playerHours}
                                                    <FontAwesomeIcon className='iconsstyle' icon={faClock} />
                                                </div>
                                            )}
                                            {settings?.ManageFraction && (jobData?.jobName === 'mechanik' || jobData?.jobName === 'ec') && (
                                                <>
                                                    <div className="kmc_content_hours small_data">
                                                        {value.playerTunes}
                                                        <FontAwesomeIcon className='iconsstyle' icon={faWrench} />
                                                    </div>
                                                    <div className="kmc_content_hours small_data">{value.playerTunesMoney}$</div>
                                                </>
                                            )}
                                            {settings?.ManageLegal && isLegalJob(jobData?.jobName) && (
                                                <div className="kmc_content_hours small_data">
                                                    {value.playerKursy || 0}
                                                    <FontAwesomeIcon className='iconsstyle' icon={faRoute} />
                                                </div>
                                            )}
                                        </div>
                                        {(playerData && settings && playerData.job_grade >= settings.ManageGrade) ? (
                                            <div className="kmc_content_buttons">
                                                <div
                                                    className="btn"
                                                    onClick={() => {
                                                        fetchNui('GetPromition', { identifier: value.playerIdentifier })
                                                        setClickedLicense(value.playerIdentifier)
                                                        setClickedName(value.playerFirstName + ' ' + value.playerLastName)
                                                    }}
                                                >
                                                    ZMIEŃ RANGĘ
                                                </div>
                                                {settings?.ManageFraction && (
                                                    <div
                                                        className="btn"
                                                        onClick={() => {
                                                            setChangeBadge(true)
                                                            setClickedLicense(value.playerIdentifier)
                                                            setClickedName(value.playerFirstName + ' ' + value.playerLastName)
                                                        }}
                                                    >
                                                        ODZNAKA
                                                    </div>
                                                )}
                                                {settings?.ManageFraction && (
                                                    <div className="btn" onClick={() => resetGodzinPlayer(value.playerIdentifier)}>RESET GODZIN</div>
                                                )}
                                                {settings?.ManageLegal && isLegalJob(jobData?.jobName) && (
                                                    <div className="btn" onClick={() => resetKursowPlayer(value.playerIdentifier)}>RESET KURSÓW</div>
                                                )}
                                                <div className="btn" onClick={() => firePlayer(value.playerIdentifier)}>ZWOLNIJ</div>
                                            </div>
                                        ) : (
                                            <div className="btn" style={{ backgroundColor: 'red' }}>BRAK DOSTĘPU</div>
                                        )}
                                    </div>
                                )}
                            </>
                        )
                    })}
                </div>
            </div>
        </>
    )
}

export default ManagePlayer