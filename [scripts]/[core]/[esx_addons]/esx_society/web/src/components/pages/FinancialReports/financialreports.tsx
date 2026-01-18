import { Dispatch, useState, useMemo } from 'react'
import { SetStateAction } from 'jotai'
import { usePlayersDataState } from '../../../state/playersData'
import { useJobDataState } from '../../../state/jobData'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from 'recharts'
import './financialreports.scss'

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d']

const FinancialReports: React.FC<{ setHref: Dispatch<SetStateAction<string>> }> = ({ setHref }) => {
    const playersData = usePlayersDataState()
    const jobData = useJobDataState()
    const [period, setPeriod] = useState<'all' | 'week' | 'month'>('all')

    const financialStats = useMemo(() => {
        const totalPaychecks = playersData.reduce((sum, p) => sum + p.playerPaycheck, 0)
        const avgPaycheck = playersData.length > 0 ? Math.round(totalPaychecks / playersData.length) : 0
        const maxPaycheck = playersData.length > 0 ? Math.max(...playersData.map(p => p.playerPaycheck)) : 0
        const minPaycheck = playersData.length > 0 ? Math.min(...playersData.map(p => p.playerPaycheck)) : 0
        
        // Podział wypłat według rang
        const paychecksByGrade: { [key: string]: { total: number, count: number } } = {}
        playersData.forEach(player => {
            const gradeLabel = player.playerJobGradeLabel || 'Brak'
            if (!paychecksByGrade[gradeLabel]) {
                paychecksByGrade[gradeLabel] = { total: 0, count: 0 }
            }
            paychecksByGrade[gradeLabel].total += player.playerPaycheck
            paychecksByGrade[gradeLabel].count += 1
        })
        
        const paychecksByGradeData = Object.entries(paychecksByGrade).map(([name, data]) => ({
            name,
            total: data.total,
            avg: Math.round(data.total / data.count),
            count: data.count
        })).sort((a, b) => b.total - a.total)

        // Podział wypłat według godzin (przedziały)
        const paychecksByHours: { [key: string]: number } = {}
        playersData.forEach(player => {
            const hoursRange = player.playerHours < 10 ? '0-10h' : 
                              player.playerHours < 50 ? '10-50h' :
                              player.playerHours < 100 ? '50-100h' :
                              player.playerHours < 200 ? '100-200h' : '200h+'
            paychecksByHours[hoursRange] = (paychecksByHours[hoursRange] || 0) + player.playerPaycheck
        })
        
        const paychecksByHoursData = Object.entries(paychecksByHours).map(([name, value]) => ({
            name,
            value
        })).sort((a, b) => {
            const order = ['0-10h', '10-50h', '50-100h', '100-200h', '200h+']
            return order.indexOf(a.name) - order.indexOf(b.name)
        })

        const accountBalance = jobData?.jobMoney ? parseInt(jobData.jobMoney) : 0

        return {
            totalPaychecks,
            avgPaycheck,
            maxPaycheck,
            minPaycheck,
            accountBalance,
            paychecksByGradeData,
            paychecksByHoursData,
            totalEmployees: playersData.length
        }
    }, [playersData, jobData])

    const topPaycheckRecipients = useMemo(() => {
        return [...playersData]
            .sort((a, b) => b.playerPaycheck - a.playerPaycheck)
            .slice(0, 10)
            .map(player => ({
                name: player.playerFirstName + ' ' + player.playerLastName,
                paycheck: player.playerPaycheck,
                hours: player.playerHours,
                rate: player.playerHours > 0 ? Math.round(player.playerPaycheck / player.playerHours) : 0
            }))
    }, [playersData])

    const financialHealth = useMemo(() => {
        const balance = financialStats.accountBalance
        const pendingPaychecks = financialStats.totalPaychecks
        const coverage = (balance > 0 && pendingPaychecks > 0) ? Math.round((balance / pendingPaychecks) * 100) : 0
        
        return {
            balance,
            pendingPaychecks,
            coverage,
            canAfford: balance >= pendingPaychecks,
            remainingAfterPaychecks: balance - pendingPaychecks
        }
    }, [financialStats])

    return (
        <div className='kariee_financial_reports'>
            <div className="kariee_header">
                <span>RAPORTY FINANSOWE</span>
                <div className="kariee_header_line"></div>
                <div className="kariee_header_buttons">
                    <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                </div>
            </div>

            <div className="financial_reports_content">
                <div className="financial_summary">
                    <div className="summary_card highlight">
                        <div className="summary_label">Stan konta</div>
                        <div className="summary_value">${financialStats.accountBalance.toLocaleString()}</div>
                    </div>
                    <div className="summary_card">
                        <div className="summary_label">Oczekujące wypłaty</div>
                        <div className="summary_value">${financialStats.totalPaychecks.toLocaleString()}</div>
                    </div>
                    <div className="summary_card">
                        <div className="summary_label">Średnia wypłata</div>
                        <div className="summary_value">${financialStats.avgPaycheck.toLocaleString()}</div>
                    </div>
                    <div className="summary_card">
                        <div className={`summary_label ${financialHealth.canAfford ? 'positive' : 'negative'}`}>
                            Pokrycie wypłat
                        </div>
                        <div className={`summary_value ${financialHealth.canAfford ? 'positive' : 'negative'}`}>
                            {financialHealth.coverage}%
                        </div>
                    </div>
                    <div className="summary_card">
                        <div className="summary_label">Po wypłatach</div>
                        <div className={`summary_value ${financialHealth.remainingAfterPaychecks >= 0 ? 'positive' : 'negative'}`}>
                            ${financialHealth.remainingAfterPaychecks.toLocaleString()}
                        </div>
                    </div>
                </div>

                <div className="financial_charts">
                    <div className="chart_section full_width">
                        <div className="chart_header">
                            <span>Wydatki na wypłaty według rang</span>
                        </div>
                        <div className="chart_container">
                            <ResponsiveContainer width="100%" height={300}>
                                <BarChart data={financialStats.paychecksByGradeData}>
                                    <CartesianGrid strokeDasharray="3 3" />
                                    <XAxis dataKey="name" angle={-45} textAnchor="end" height={100} />
                                    <YAxis />
                                    <Tooltip formatter={(value: number) => `$${value.toLocaleString()}`} />
                                    <Legend />
                                    <Bar dataKey="total" fill={COLORS[0]} name="Łączna wypłata" />
                                    <Bar dataKey="avg" fill={COLORS[1]} name="Średnia wypłata" />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>
                    </div>

                    <div className="chart_section">
                        <div className="chart_header">
                            <span>Wydatki według godzin</span>
                        </div>
                        <div className="chart_container">
                            <ResponsiveContainer width="100%" height={300}>
                                <PieChart>
                                    <Pie
                                        data={financialStats.paychecksByHoursData}
                                        cx="50%"
                                        cy="50%"
                                        labelLine={false}
                                        label={({ name, percent, value }: { name: string, percent: number, value: number }) => 
                                            `${name}: $${value.toLocaleString()} (${(percent * 100).toFixed(0)}%)`
                                        }
                                        outerRadius={100}
                                        fill="#8884d8"
                                        dataKey="value"
                                    >
                                        {financialStats.paychecksByHoursData.map((entry, index) => (
                                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                        ))}
                                    </Pie>
                                    <Tooltip formatter={(value: number) => `$${value.toLocaleString()}`} />
                                </PieChart>
                            </ResponsiveContainer>
                        </div>
                    </div>

                    <div className="chart_section">
                        <div className="chart_header">
                            <span>Top 10 odbiorców wypłat</span>
                        </div>
                        <div className="chart_container">
                            <ResponsiveContainer width="100%" height={300}>
                                <BarChart data={topPaycheckRecipients}>
                                    <CartesianGrid strokeDasharray="3 3" />
                                    <XAxis dataKey="name" angle={-45} textAnchor="end" height={100} />
                                    <YAxis />
                                    <Tooltip formatter={(value: number) => `$${value.toLocaleString()}`} />
                                    <Legend />
                                    <Bar dataKey="paycheck" fill={COLORS[2]} name="Wypłata" />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>
                    </div>
                </div>

                <div className="financial_analysis">
                    <div className="analysis_card">
                        <div className="analysis_header">Analiza finansowa</div>
                        <div className="analysis_content">
                            <div className="analysis_item">
                                <span className="analysis_label">Największa wypłata:</span>
                                <span className="analysis_value">${financialStats.maxPaycheck.toLocaleString()}</span>
                            </div>
                            <div className="analysis_item">
                                <span className="analysis_label">Najmniejsza wypłata:</span>
                                <span className="analysis_value">${financialStats.minPaycheck.toLocaleString()}</span>
                            </div>
                            <div className="analysis_item">
                                <span className="analysis_label">Różnica:</span>
                                <span className="analysis_value">${(financialStats.maxPaycheck - financialStats.minPaycheck).toLocaleString()}</span>
                            </div>
                            <div className="analysis_item">
                                <span className="analysis_label">Pracowników z wypłatą:</span>
                                <span className="analysis_value">
                                    {playersData.filter(p => p.playerPaycheck > 0).length} / {financialStats.totalEmployees}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default FinancialReports
