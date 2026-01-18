import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { useSettingsState } from '../../../state/settings'
import './history.scss'
import { faCopy } from '@fortawesome/free-solid-svg-icons'
import { Dispatch, useState } from 'react'
import { SetStateAction } from 'jotai'
import { useTuneHistoryDataState } from '../../../state/tunehistory'
import { usePlayerData, usePlayerDataState } from '../../../state/playerData'
import { fetchNui } from '../../../utils/fetchNui'

const TuneHistory: React.FC<{setHref: Dispatch<SetStateAction<string>>}> = ({setHref}) => {
    const settings = useSettingsState()
    const history = useTuneHistoryDataState()
    const playerData = usePlayerDataState()

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

    const clearHistory = () => {
        fetchNui('clearTuneHistory')
    }

    return (
        <>
            <div className='kariee_history'>
                <div className="kariee_header">
                    <span>HISTORIA TUNINGÓW</span>
                    <div className="kariee_header_line"></div>

                    <div className="kariee_header_buttons">
                        <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                        {((playerData && settings) && playerData.job_grade >= settings.ManageGrade)
                            ?
                            <div className="btn" style={{ backgroundColor: 'green' }} onClick={() => clearHistory()}><span>WYCZYŚĆ</span></div>
                            :
                            <div className="btn" style={{ backgroundColor: 'red' }}>BRAK DOSTĘPU</div>
                        }
                    </div>
                </div>

                <div className="kariee_history_content">
                    {history.map((value, index) => (
                        <>
                            <div className="kmc_content">
                                <div className="kmc_content_info">
                                    <div className="kmc_content_name">
                                        <div className="kmc_content_name_data">
                                            <span className='kmc_c_name_player'>{value.firstplayer_name}</span>
                                            <span className='kmc_c_name_dcid'>#{value.firstplayer_discordid}</span>
                                        </div>
                                        <div className="kmc_content_name_copy" onClick={() => copyDiscord(value.firstplayer_discordid.toString())}><FontAwesomeIcon icon={faCopy} /></div>

                                    </div>
                                    {value.secondaction ?
                                        <>
                                            <div className="kmc_content_complex">
                                                <div className="kmc_content_complex_data">
                                                    <span className='kmc_c_complex_1'>{value.action}</span>
                                                    <span className='kmc_c_complex_2'>{value.secondaction}</span>
                                                </div>
                                            </div>
                                            <div className="kmc_content_name">
                                                <div className="kmc_content_name_data">
                                                    <span className='kmc_c_name_player'>{value.secondplayer_name}</span>
                                                    <span className='kmc_c_name_dcid'>#{value.secondplayer_discordid}</span>
                                                </div>
                                                <div className="kmc_content_name_copy" onClick={() => copyDiscord(value.secondplayer_discordid.toString())}><FontAwesomeIcon icon={faCopy} /></div>
                                            </div>
                                        </>
                                        :
                                        <div className="kmc_content_job">{value.action}</div>
                                    }
                                </div>

                                <div className="kmc_content_buttons">
                                    <div className="kmc_content_button btn">{new Date(value.date * 1000).toLocaleString('pl-PL', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute:'2-digit', second:'2-digit'})}</div>
                                </div>

                            </div>
                        </>
                    ))}
                </div>
            </div>
        </>
    )
}

export default TuneHistory