import { useSettingsState } from '../../../state/settings'
import './licenses.scss'
import { Dispatch, useState } from 'react'
import { SetStateAction } from 'jotai'
import { usePlayersDataState } from '../../../state/playersData'
import { fetchNui } from '../../../utils/fetchNui'
import { useJobLicensesData } from '../../../state/licenses'

const Licenses: React.FC<{ setHref: Dispatch<SetStateAction<string>> }> = ({ setHref }) => {
    const settings = useSettingsState()
    const playersData = usePlayersDataState()
    const jobLicenses = useJobLicensesData()

    const handleClick = (license: string, identifier: string, button: any, hasLicense: boolean) => {
        fetchNui('addLicense', { identifier, license, hasLicense })
    }

    const [checkCorrect, setCheckCorrect] = useState<number>(0)
    return (
        <>
            <div className='kariee_licenses'>
                <div className="kariee_header">
                    <span>ZARZĄDZANIE LICENCJAMI</span>
                    <div className="kariee_header_line"></div>

                    <div className="kariee_header_buttons">
                        <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                    </div>
                </div>

                <div className="kariee_licenses_content">
                    <input type="text" className='search_for_player_licenses' placeholder='Wyszukaj pracownika...' onInput={() => setCheckCorrect(checkCorrect + 1)}></input>


                    {playersData.map((value, index) => {
                        const search = document.querySelector('.search_for_player_licenses') as HTMLInputElement

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
                                    <div className="kmh_content">
                                        <div className="kmh_content_info">
                                            <div className="kmh_content_badge small_data">{value.playerBadge}</div>
                                            <div className="kmh_content_name">{value.playerFirstName + ' ' + value.playerLastName}</div>
                                        </div>
                                        <div className="kmh_content_buttons_license">
                                            {jobLicenses.map((value1, index1) => (
                                                <div className="kmh_content_license_seu btn_license" key={index} onClick={() => handleClick(value1, value.playerIdentifier, this, value.playerLicenses[value1])} style={{ backgroundColor: (value.playerLicenses[value1]) ? 'green' : 'red' }}>{value1}</div>
                                            ))}
                                        </div>
                                    </div>
                                }
                            </>
                        )
                    })}
                </div>
            </div>
        </>
    )
}

export default Licenses