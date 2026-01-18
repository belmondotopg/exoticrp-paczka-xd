import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { useSettingsState } from '../../../../state/settings'
import './hireplayer.scss'
import { faCopy } from '@fortawesome/free-solid-svg-icons'
import { Dispatch } from 'react'
import { SetStateAction } from 'jotai'
import { usePlayerAroundState } from '../../../../state/playersAround'
import { fetchNui } from '../../../../utils/fetchNui'

const HirePlayer: React.FC<{setHref: Dispatch<SetStateAction<string>>}> = ({setHref}) => {
    const settings = useSettingsState()
    const playersAround = usePlayerAroundState()

    const copyDiscord = (discord: string) => {
        const copy = document.createElement('textarea')
        copy.value = discord;
        
        copy.style.position = "fixed";
        copy.style.opacity = "0";
        document.body.appendChild(copy);
        
        copy.select();
        document.execCommand('copy');

        document.body.removeChild(copy)
    }

    const handleClick = (identifier: string) => {
        fetchNui('hirePlayer', {targetIdentifier: identifier})
    }

    return (
        <div className='kariee_manage'>
            <div className="kariee_header">
                <span>ZATRUDNIANIE</span>
                <div className="kariee_header_line"></div>

                <div className="kariee_header_buttons">
                    <div className="btn" onClick={() => setHref('manage')}><span>POWRÓT</span></div>
                </div>
            </div>

            <div className="kariee_manage_content">
                {Array.isArray(playersAround) && playersAround.length > 0 ? (
                    playersAround.map((value, index) => (
                        <div key={value.identifier || index} className="kmc_content">
                            <div className="kmc_content_info">
                                <div className="kmc_content_id small_data">{value.id}</div>
                                {settings?.ManagePermID && <div className="kmc_content_permid small_data">{value.permid}</div>}
                                <div className="kmc_content_name">
                                    <div className="kmc_content_name_data">
                                        <span className='kmc_c_name_player'>{value.firstname + ' ' + value.lastname}</span>
                                        <span className='kmc_c_name_dcid'>#{value.discordid}</span>
                                    </div>
                                    <div className="kmc_content_name_copy" onClick={() => copyDiscord(value.discordid)}><FontAwesomeIcon icon={faCopy} /></div>
                                </div>
                            </div>

                            <div className="kmc_content_buttons">
                                <div className="btn" onClick={() => handleClick(value.identifier)}>ZATRUDNIJ</div>
                            </div>

                        </div>
                    ))
                ) : (
                    <div className="kmc_content_empty" style={{ textAlign: 'center', padding: '2rem', color: '#999' }}>
                        <span>Brak graczy w pobliżu (max. 3m)</span>
                    </div>
                )}
            </div>
        </div>
    )
}

export default HirePlayer