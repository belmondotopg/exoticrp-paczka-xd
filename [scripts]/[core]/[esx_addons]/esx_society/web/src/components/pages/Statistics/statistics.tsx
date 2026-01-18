import { Dispatch, useState, useMemo, useEffect } from 'react'
import { SetStateAction } from 'jotai'
import { usePlayersDataState } from '../../../state/playersData'
import { useJobDataState } from '../../../state/jobData'
import { useSettingsState } from '../../../state/settings'
import { isLegalJob } from '../../../utils/legalJobs'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from 'recharts'
import './statistics.scss'

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d', '#ffc658', '#ff7c7c']

const Statistics: React.FC<{ setHref: Dispatch<SetStateAction<string>> }> = ({ setHref }) => {
    const playersData = usePlayersDataState()
    const jobData = useJobDataState()
    const settings = useSettingsState()
    const isLegal = isLegalJob(jobData?.jobName)
    const isFraction = settings?.ManageFraction || false
    
    // Dla legal jobs: domyślnie kursy, dla frakcji: domyślnie godziny
    const defaultSort = isLegal ? 'kursy' : 'hours'
    const defaultChart = isLegal ? 'kursy' : 'hours'
    
    const [sortBy, setSortBy] = useState<'hours' | 'paycheck' | 'kursy' | 'name'>(defaultSort as any)
    const [chartType, setChartType] = useState<'hours' | 'paycheck' | 'kursy'>(defaultChart as any)

    // Zabezpieczenie: upewnij się, że wybrane wartości są dozwolone
    useEffect(() => {
        if (isLegal && (chartType === 'hours' || chartType === 'paycheck')) {
            setChartType('kursy')
        } else if (isFraction && chartType === 'kursy') {
            setChartType('hours')
        }
        if (isLegal && (sortBy === 'hours' || sortBy === 'paycheck')) {
            setSortBy('kursy')
        } else if (isFraction && sortBy === 'kursy') {
            setSortBy('hours')
        }
    }, [isLegal, isFraction, chartType, sortBy])

    const sortedPlayers = useMemo(() => {
        const sorted = [...playersData].sort((a, b) => {
            switch (sortBy) {
                case 'hours':
                    return b.playerHours - a.playerHours
                case 'paycheck':
                    return b.playerPaycheck - a.playerPaycheck
                case 'kursy':
                    return (b.playerKursy || 0) - (a.playerKursy || 0)
                case 'name':
                    return (a.playerFirstName + ' ' + a.playerLastName).localeCompare(b.playerFirstName + ' ' + b.playerLastName)
                default:
                    return 0
            }
        })
        return sorted.slice(0, 10) // Top 10
    }, [playersData, sortBy])

    const chartData = useMemo(() => {
        return sortedPlayers.map(player => ({
            name: player.playerFirstName + ' ' + player.playerLastName,
            hours: player.playerHours,
            paycheck: player.playerPaycheck,
            kursy: player.playerKursy || 0,
        }))
    }, [sortedPlayers])

    const pieData = useMemo(() => {
        const gradeGroups: { [key: string]: number } = {}
        playersData.forEach(player => {
            const gradeLabel = player.playerJobGradeLabel || 'Brak'
            gradeGroups[gradeLabel] = (gradeGroups[gradeLabel] || 0) + 1
        })
        return Object.entries(gradeGroups).map(([name, value]) => ({ name, value }))
    }, [playersData])

    const statsSummary = useMemo(() => {
        const totalHours = playersData.reduce((sum, p) => sum + p.playerHours, 0)
        const totalPaycheck = playersData.reduce((sum, p) => sum + p.playerPaycheck, 0)
        const totalKursy = playersData.reduce((sum, p) => sum + (p.playerKursy || 0), 0)
        const avgHours = playersData.length > 0 ? Math.round(totalHours / playersData.length) : 0
        const avgPaycheck = playersData.length > 0 ? Math.round(totalPaycheck / playersData.length) : 0
        
        return {
            totalHours,
            totalPaycheck,
            totalKursy,
            avgHours,
            avgPaycheck,
            totalPlayers: playersData.length
        }
    }, [playersData])

    const getChartDataKey = () => {
        switch (chartType) {
            case 'hours':
                return 'hours'
            case 'paycheck':
                return 'paycheck'
            case 'kursy':
                return 'kursy'
            default:
                return 'hours'
        }
    }

    const getChartLabel = () => {
        switch (chartType) {
            case 'hours':
                return 'Godziny'
            case 'paycheck':
                return 'Wypłata ($)'
            case 'kursy':
                return 'Kursy'
            default:
                return 'Godziny'
        }
    }

    return (
        <div className='kariee_statistics'>
            <div className="kariee_header">
                <span>STATYSTYKI PRACOWNIKÓW</span>
                <div className="kariee_header_line"></div>
                <div className="kariee_header_buttons">
                    <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                </div>
            </div>

            <div className="statistics_content">
                <div className="statistics_summary">
                    {!isLegal && (
                        <>
                            <div className="summary_card">
                                <div className="summary_label">Łączne godziny</div>
                                <div className="summary_value">{statsSummary.totalHours}h</div>
                            </div>
                            <div className="summary_card">
                                <div className="summary_label">Średnie godziny</div>
                                <div className="summary_value">{statsSummary.avgHours}h</div>
                            </div>
                            <div className="summary_card">
                                <div className="summary_label">Łączna wypłata</div>
                                <div className="summary_value">${statsSummary.totalPaycheck.toLocaleString()}</div>
                            </div>
                            <div className="summary_card">
                                <div className="summary_label">Średnia wypłata</div>
                                <div className="summary_value">${statsSummary.avgPaycheck.toLocaleString()}</div>
                            </div>
                        </>
                    )}
                    {!isFraction && (
                        <div className="summary_card">
                            <div className="summary_label">Łączne kursy</div>
                            <div className="summary_value">{statsSummary.totalKursy}</div>
                        </div>
                    )}
                    <div className="summary_card">
                        <div className="summary_label">Pracowników</div>
                        <div className="summary_value">{statsSummary.totalPlayers}</div>
                    </div>
                </div>

                <div className="statistics_charts">
                    <div className="chart_section">
                        <div className="chart_header">
                            <span>Wykres aktywności (Top 10)</span>
                            <div className="chart_type_selector">
                                {!isLegal && (
                                    <button 
                                        className={chartType === 'hours' ? 'active' : ''} 
                                        onClick={() => setChartType('hours')}
                                    >
                                        Godziny
                                    </button>
                                )}
                                {!isLegal && (
                                    <button 
                                        className={chartType === 'paycheck' ? 'active' : ''} 
                                        onClick={() => setChartType('paycheck')}
                                    >
                                        Wypłata
                                    </button>
                                )}
                                {!isFraction && (
                                    <button 
                                        className={chartType === 'kursy' ? 'active' : ''} 
                                        onClick={() => setChartType('kursy')}
                                    >
                                        Kursy
                                    </button>
                                )}
                            </div>
                        </div>
                        <div className="chart_container">
                            <ResponsiveContainer width="100%" height={300}>
                                <BarChart data={chartData}>
                                    <CartesianGrid strokeDasharray="3 3" />
                                    <XAxis dataKey="name" angle={-45} textAnchor="end" height={100} />
                                    <YAxis />
                                    <Tooltip />
                                    <Legend />
                                    <Bar dataKey={getChartDataKey()} fill={COLORS[0]} name={getChartLabel()} />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>
                    </div>

                    <div className="chart_section">
                        <div className="chart_header">
                            <span>Rozkład według rang</span>
                        </div>
                        <div className="chart_container">
                            <ResponsiveContainer width="100%" height={300}>
                                <PieChart>
                                    <Pie
                                        data={pieData}
                                        cx="50%"
                                        cy="50%"
                                        labelLine={false}
                                        label={({ name, percent }: { name: string, percent: number }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                                        outerRadius={100}
                                        fill="#8884d8"
                                        dataKey="value"
                                    >
                                        {pieData.map((entry, index) => (
                                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                        ))}
                                    </Pie>
                                    <Tooltip />
                                </PieChart>
                            </ResponsiveContainer>
                        </div>
                    </div>
                </div>

                <div className="statistics_ranking">
                    <div className="ranking_header">
                        <span>Ranking pracowników (Top 10)</span>
                        <div className="ranking_sort">
                            <span>Sortuj według:</span>
                            <select value={sortBy} onChange={(e) => setSortBy(e.target.value as any)}>
                                {!isLegal && <option value="hours">Godziny</option>}
                                {!isLegal && <option value="paycheck">Wypłata</option>}
                                {!isFraction && <option value="kursy">Kursy</option>}
                                <option value="name">Nazwa</option>
                            </select>
                        </div>
                    </div>
                    <div className="ranking_list">
                        {sortedPlayers.map((player, index) => (
                            <div key={player.playerIdentifier} className="ranking_item">
                                <div className="ranking_position">#{index + 1}</div>
                                <div className="ranking_info">
                                    <div className="ranking_name">
                                        {player.playerFirstName} {player.playerLastName}
                                    </div>
                                    <div className="ranking_grade">{player.playerJobGradeLabel}</div>
                                </div>
                                <div className="ranking_stats">
                                    {!isLegal && (
                                        <div className="ranking_stat">
                                            <span className="stat_label">Godziny:</span>
                                            <span className="stat_value">{player.playerHours}h</span>
                                        </div>
                                    )}
                                    {!isLegal && (
                                        <div className="ranking_stat">
                                            <span className="stat_label">Wypłata:</span>
                                            <span className="stat_value">${player.playerPaycheck.toLocaleString()}</span>
                                        </div>
                                    )}
                                    {!isFraction && (
                                        <div className="ranking_stat">
                                            <span className="stat_label">Kursy:</span>
                                            <span className="stat_value">{player.playerKursy || 0}</span>
                                        </div>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    )
}

export default Statistics
