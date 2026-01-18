import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { useSettingsState } from '../../../state/settings'
import './history.scss'
import { faCopy, faDownload } from '@fortawesome/free-solid-svg-icons'
import { Dispatch, useState, useMemo } from 'react'
import { SetStateAction } from 'jotai'
import { useHistoryDataState } from '../../../state/history'
import kariee_history from '../../../types/history'

const History: React.FC<{setHref: Dispatch<SetStateAction<string>>}> = ({setHref}) => {
    const settings = useSettingsState()
    const history = useHistoryDataState()
    const [searchFilter, setSearchFilter] = useState<string>('')
    const [actionFilter, setActionFilter] = useState<string>('')
    const [dateFromFilter, setDateFromFilter] = useState<string>('')
    const [dateToFilter, setDateToFilter] = useState<string>('')

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

    const filteredHistory = useMemo(() => {
        return history.filter((value) => {
            const searchLower = searchFilter.toLowerCase()
            const matchesSearch = !searchFilter || 
                value.firstplayer_name.toLowerCase().includes(searchLower) ||
                value.secondplayer_name?.toLowerCase().includes(searchLower) ||
                value.action.toLowerCase().includes(searchLower) ||
                value.secondaction?.toLowerCase().includes(searchLower)
            
            const matchesAction = !actionFilter || value.action.toLowerCase().includes(actionFilter.toLowerCase())
            
            let matchesDate = true
            if (dateFromFilter) {
                const fromDate = new Date(dateFromFilter).getTime() / 1000
                matchesDate = matchesDate && value.date >= fromDate
            }
            if (dateToFilter) {
                const toDate = new Date(dateToFilter).getTime() / 1000 + 86400 // +1 day
                matchesDate = matchesDate && value.date <= toDate
            }
            
            return matchesSearch && matchesAction && matchesDate
        })
    }, [history, searchFilter, actionFilter, dateFromFilter, dateToFilter])

    const uniqueActions = useMemo(() => {
        const actions = new Set<string>()
        history.forEach(item => {
            if (item.action) actions.add(item.action)
        })
        return Array.from(actions).sort()
    }, [history])

    const exportToCSV = () => {
        const headers = ['Data', 'Gracz', 'Discord ID', 'Akcja', 'Szczegóły', 'Drugi Gracz', 'Discord ID 2']
        const rows = filteredHistory.map(item => [
            new Date(item.date * 1000).toLocaleString('pl-PL'),
            item.firstplayer_name,
            item.firstplayer_discordid.toString(),
            item.action,
            item.secondaction || '',
            item.secondplayer_name || '',
            item.secondplayer_discordid ? item.secondplayer_discordid.toString() : ''
        ])
        
        const csvContent = [
            headers.join(','),
            ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
        ].join('\n')
        
        const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' })
        const link = document.createElement('a')
        link.href = URL.createObjectURL(blob)
        link.download = `historia_${new Date().toISOString().split('T')[0]}.csv`
        link.click()
    }

    const exportToJSON = () => {
        const jsonData = filteredHistory.map(item => ({
            data: new Date(item.date * 1000).toISOString(),
            gracz: item.firstplayer_name,
            discordId: item.firstplayer_discordid,
            akcja: item.action,
            szczegoly: item.secondaction || null,
            drugiGracz: item.secondplayer_name || null,
            discordId2: item.secondplayer_discordid || null
        }))
        
        const jsonContent = JSON.stringify(jsonData, null, 2)
        const blob = new Blob([jsonContent], { type: 'application/json' })
        const link = document.createElement('a')
        link.href = URL.createObjectURL(blob)
        link.download = `historia_${new Date().toISOString().split('T')[0]}.json`
        link.click()
    }

    return (
        <>
            <div className='kariee_history'>
                <div className="kariee_header">
                    <span>HISTORIA ZDARZEŃ</span>
                    <div className="kariee_header_line"></div>

                    <div className="kariee_header_buttons">
                        <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                    </div>
                </div>

                <div className="kariee_history_filters">
                    <div className="history_filters_row">
                        <input 
                            type="text" 
                            className="history_filter_input" 
                            placeholder="Szukaj po nazwie, akcji..." 
                            value={searchFilter}
                            onChange={(e) => setSearchFilter(e.target.value)}
                        />
                        <select 
                            className="history_filter_select"
                            value={actionFilter}
                            onChange={(e) => setActionFilter(e.target.value)}
                        >
                            <option value="">Wszystkie akcje</option>
                            {uniqueActions.map((action, idx) => (
                                <option key={idx} value={action}>{action}</option>
                            ))}
                        </select>
                        <input 
                            type="date" 
                            className="history_filter_date"
                            placeholder="Od"
                            value={dateFromFilter}
                            onChange={(e) => setDateFromFilter(e.target.value)}
                        />
                        <input 
                            type="date" 
                            className="history_filter_date"
                            placeholder="Do"
                            value={dateToFilter}
                            onChange={(e) => setDateToFilter(e.target.value)}
                        />
                        <div className="history_export_buttons">
                            <div className="btn history_export_btn" onClick={exportToCSV}>
                                <FontAwesomeIcon icon={faDownload} /> CSV
                            </div>
                            <div className="btn history_export_btn" onClick={exportToJSON}>
                                <FontAwesomeIcon icon={faDownload} /> JSON
                            </div>
                        </div>
                    </div>
                    <div className="history_filter_info">
                        Znaleziono: {filteredHistory.length} z {history.length} wpisów
                    </div>
                </div>

                <div className="kariee_history_content">
                    {filteredHistory.map((value, index) => (
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

                    
                    {/* <div className="kmc_content">
                        <div className="kmc_content_info">
                            <div className="kmc_content_name">
                                <div className="kmc_content_name_data">
                                    <span className='kmc_c_name_player'>Chris Frog</span>
                                    <span className='kmc_c_name_dcid'>#192039102930123</span>
                                </div>
                                <div className="kmc_content_name_copy"><FontAwesomeIcon icon={faCopy} /></div>
                            </div>
                            <div className="kmc_content_job">Wyczyścił godziny</div>
                        </div>

                        <div className="kmc_content_buttons">
                            <div className="kmc_content_button btn">11.12.2023, 15:25</div>
                        </div>

                    </div>
                    <div className="kmc_content">
                        <div className="kmc_content_info">
                            <div className="kmc_content_name">
                                <div className="kmc_content_name_data">
                                    <span className='kmc_c_name_player'>Chris Frog</span>
                                    <span className='kmc_c_name_dcid'>#192039102930123</span>
                                </div>
                                <div className="kmc_content_name_copy"><FontAwesomeIcon icon={faCopy} /></div>
                            </div>
                            <div className="kmc_content_complex">
                                <div className="kmc_content_complex_data">
                                    <span className='kmc_c_complex_1'>Awansował</span>
                                    <span className='kmc_c_complex_2'>{'Kapitan > Senior Kapitan'}</span>
                                </div>
                            </div>
                            <div className="kmc_content_name">
                                <div className="kmc_content_name_data">
                                    <span className='kmc_c_name_player'>David Feingold</span>
                                    <span className='kmc_c_name_dcid'>#192039102930123</span>
                                </div>
                                <div className="kmc_content_name_copy"><FontAwesomeIcon icon={faCopy} /></div>
                            </div>
                        </div>

                        <div className="kmc_content_buttons">
                            <div className="kmc_content_button btn">11.12.2023, 15:25</div>
                        </div>

                    </div> */}
                </div>
            </div>
        </>
    )
}

export default History