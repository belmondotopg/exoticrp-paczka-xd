import { SetStateAction } from 'jotai'
import { Dispatch, useState } from 'react'
import { useSettingsState } from '../../../state/settings'
import { useJobDataState } from '../../../state/jobData'
import './firmmanage.scss'
import { usePlayerDataState } from '../../../state/playerData'
import { fetchNui } from '../../../utils/fetchNui'
import { useInRadialData } from '../../../state/inRadial'

const FirmManage: React.FC<{setHref: Dispatch<SetStateAction<string>>}> = ({setHref}) => {
    const settings = useSettingsState()
    const [withdrawMoney, setWithdrawMoney] = useState<boolean>(false)
    const [depositMoney, setDepositMoney] = useState<boolean>(false)
    const [discordWebhook, setDiscordWebhook] = useState<boolean>(false)
    const [discordWebhookChoose, setDiscordWebhookChoose] = useState<boolean>(false)
    const [choosedWebhook, setChoosedWebhook] = useState<string>('')
    const jobData = useJobDataState()
    const playerData = usePlayerDataState()
    const inRadial = useInRadialData()


    const handleClickWithdraw = () => {
        const money = document.querySelector('.input-withdraw') as HTMLInputElement

        if(money.value){
            fetchNui('withdrawMoney', money.value)
        }
        setWithdrawMoney(false)
    }

    const handleClickDeposit = () => {
        const money = document.querySelector('.input-despoit') as HTMLInputElement

        if(money.value){
            fetchNui('depositMoney', money.value)
        }
        setDepositMoney(false)
    }

    const handleClickWebhook = () => {
        const webhook = document.querySelector('.input-webhook') as HTMLInputElement

        if (webhook.value){
            if(jobData?.jobName == 'police' || jobData?.jobName == 'sheriff'){
                fetchNui('discordWebhook', {value: webhook.value, webhook: choosedWebhook})
            } else {
                fetchNui('discordWebhook', {value: webhook.value})
            }
        }
        setDiscordWebhook(false)
    }

    const WdMoney: React.FC<{money: number}> = ({money}) => {
        return (
            <div className='kariee_changebadge'>
                <div className="kariee_changebadge_content">
                    <div className="kariee_chb_header">
                        <div className="kariee_chbh_name">{'$'+money.toLocaleString()}</div>
                        <div className="kariee_chbh_context">
                            <div className="kariee_chbh_con">WYPŁACANIE PIENIĘDZY</div>
                            <div className="kariee_chbh_line"></div>
                            <div className="kariee_chbh_btn btn" onClick={() => setWithdrawMoney(false)}>ANULUJ</div>
                        </div>
                    </div>

                    <div className="kariee_chb_content">
                        <input type="number" id="kariee_chb_content_input" className='input-withdraw' placeholder='Wpisz kwote...' ></input>
                        <div className="kariee_chbh_c_btn btn" onClick={handleClickWithdraw}>POTWIERDŹ</div>
                    </div>
                </div>
            </div>
        )
    }

    const DeMoney: React.FC<{money: number}> = ({money}) => {
        return (
            <div className='kariee_changebadge'>
                <div className="kariee_changebadge_content">
                    <div className="kariee_chb_header">
                        <div className="kariee_chbh_name">{'$'+money.toLocaleString()}</div>
                        <div className="kariee_chbh_context">
                            <div className="kariee_chbh_con">WPŁACANIE PIENIĘDZY</div>
                            <div className="kariee_chbh_line"></div>
                            <div className="kariee_chbh_btn btn" onClick={() => setDepositMoney(false)}>ANULUJ</div>
                        </div>
                    </div>

                    <div className="kariee_chb_content">
                        <input type="number" id="kariee_chb_content_input" className="input-despoit" placeholder='Wpisz kwote...' ></input>
                        <div className="kariee_chbh_c_btn btn" onClick={handleClickDeposit}>POTWIERDŹ</div>
                    </div>
                </div>
            </div>
        )
    }

    const WebhookChooseHandleClick = (webhook: string) => {
        setChoosedWebhook(webhook)
        setDiscordWebhookChoose(false)
        setDiscordWebhook(true)
    }

    const DiscordWebhookChoose: React.FC = () => {
        return (
            <div className='kariee_changebadge'>
            <div className="kariee_changebadge_content">
                <div className="kariee_chb_header">
                    <div className="kariee_chbh_name">DISCORD</div>
                    <div className="kariee_chbh_context">
                        <div className="kariee_chbh_con">WYBIERZ WEBHOOK</div>
                        <div className="kariee_chbh_line"></div>
                        <div className="kariee_chbh_btn btn" onClick={() => setDiscordWebhookChoose(false)}>ANULUJ</div>
                    </div>
                </div>

                <div className="kariee_chb_content-btns">
                    <div className="kariee_webhook_btn">
                        <div className="btn_name">WEBHOOK GŁÓWNY</div>
                        <div className="btn_choose" onClick={() => WebhookChooseHandleClick('main')}>WYBIERZ</div>
                    </div>
                    <div className="kariee_webhook_btn">
                        <div className="btn_name">WEBHOOK SZAFKI SWAT</div>
                        <div className="btn_choose" onClick={() => WebhookChooseHandleClick('swat')}>WYBIERZ</div>
                    </div>
                    <div className="kariee_webhook_btn">
                        <div className="btn_name">WEBHOOK SZAFKI HC</div>
                        <div className="btn_choose" onClick={() => WebhookChooseHandleClick('hc')}>WYBIERZ</div>
                    </div>
                </div>
            </div>
        </div>
        )
    }

    const CloseDiscordWebhook = () => {
        if (jobData?.jobName == 'police' || jobData?.jobName == 'sheriff'){
            setDiscordWebhook(false)
            setDiscordWebhookChoose(true)
            setChoosedWebhook('')
        } else {
            setDiscordWebhook(false)
        }
    }

    const DiscordWebhook: React.FC = () => {
        return (
            <div className='kariee_changebadge'>
                <div className="kariee_changebadge_content">
                    <div className="kariee_chb_header">
                        <div className="kariee_chbh_name">DISCORD {choosedWebhook ? `WEBHOOK ${choosedWebhook == 'main' ? 'GŁÓWNY' : choosedWebhook == 'swat' ? 'SZAFKI SWAT' : 'SZAFKI HC'}` : ''}</div>
                        <div className="kariee_chbh_context">
                            <div className="kariee_chbh_con">WPISZ WEBHOOK</div>
                            <div className="kariee_chbh_line"></div>
                            <div className="kariee_chbh_btn btn" onClick={CloseDiscordWebhook}>ANULUJ</div>
                        </div>
                    </div>

                    <div className="kariee_chb_content">
                        <input type="text" id="kariee_chb_content_input" className='input-webhook' placeholder='Wpisz discord channel webhook...' ></input>
                        <div className="kariee_chbh_c_btn btn" onClick={handleClickWebhook}>POTWIERDŹ</div>
                    </div>
                </div>
            </div>
        )
    }

    return (
        <>
            {withdrawMoney && <WdMoney money={(jobData) ? parseInt(jobData.jobMoney) : 0}/>}
            {depositMoney && <DeMoney money={(playerData) ? playerData.money : 0}/>}
            {discordWebhook && <DiscordWebhook/>}
            {discordWebhookChoose && <DiscordWebhookChoose/>}
            <div className='kariee_firmmanage'>
                <div className="kariee_header">
                    <span>ZARZĄDZANIE FIRMĄ</span>
                    <div className="kariee_header_line"></div>

                    <div className="kariee_header_buttons">
                        <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                    </div>
                </div>

                <div className="kariee_firmmanage_content">
                    <div className="k-fmc-topper">
                        <div className="k-fmc_stankonta">
                            <span>STAN KONTA</span>
                            <span>${(jobData && jobData.jobMoney) && jobData?.jobMoney.toLocaleString()}</span>
                        </div>
                        <div className="k-fmc_kontobuttons">
                            {!inRadial &&
                                <>
                                    <div className="k-fmc_btn kfmcbtn" onClick={() => setWithdrawMoney(true)}>WYPŁAĆ PIENIĄDZE Z KONTA</div>
                                    <div className="k-fmc_btn kfmcbtn" onClick={() => setDepositMoney(true)}>WPŁAĆ PIENIĄDZE NA KONTO</div>
                                </>
                            }

                            {settings?.ManageFraction && <div className="k-fmc_btn kfmcbtn" onClick={() => setHref('paycheck')}>ZARZĄDZAJ WYPŁATAMI</div>}
                            {jobData && (jobData.jobName == 'police' || jobData.jobName == 'sheriff') ?
                                <div className="k-fmc_btn kfmcbtn" onClick={() => setDiscordWebhookChoose(true)}>PODEPNIJ DISCORD WEBHOOK</div>
                                :
                                <div className="k-fmc_btn kfmcbtn" onClick={() => setDiscordWebhook(true)}>PODEPNIJ DISCORD WEBHOOK</div>
                            }
                        </div>
                    </div>

                    <div className="k-fmc-bottomer">


                        <div className="k-fmc-stats">
                            <div className="k-fmc_stats_data">
                                <span>ILOŚĆ ZATRUDNIONYCH GRACZY</span>
                                <span>{jobData?.jobPlayers}</span>
                            </div>
                            {(jobData && (jobData.jobName == 'police' || jobData.jobName == 'sheriff')) && 
                                <>
                                    <div className="k-fmc_stats_data">
                                        <span>ILOŚĆ WYSTAWIONYCH MANDATÓW</span>
                                        <span>{jobData?.jobData.jobDataMandaty}</span>
                                    </div>
                                    <div className="k-fmc_stats_data">
                                        <span>ILOŚĆ WYSTAWIONYCH WYROKÓW</span>
                                        <span>{jobData?.jobData.jobDataWyroki}</span>
                                    </div>
                                </>
                            } 
                            {(jobData && (jobData.jobName == 'ambulance' || jobData.jobName == 'mechanik' || jobData.jobName == 'ec')) && 
                                <div className="k-fmc_stats_data">
                                    <span>ILOŚĆ WYSTAWIONYCH FAKTUR</span>
                                    <span>{jobData?.jobData.jobDataFaktury}</span>
                                </div>
                            }
                            <div className="k-fmc_stats_data">
                                <span>ILOŚĆ OSÓB ONLINE</span>
                                <span>{jobData?.jobData.jobDataOnline}</span>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </>
    )
}

export default FirmManage