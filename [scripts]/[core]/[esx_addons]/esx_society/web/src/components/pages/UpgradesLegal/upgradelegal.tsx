import './upgradelegal.scss'
import { Dispatch, useState } from 'react'
import { SetStateAction } from 'jotai'
import { useUpgradesLegalData } from '../../../state/upgradeslegal'
import { fetchNui } from '../../../utils/fetchNui'

const UpgradeLegal: React.FC<{ setHref: Dispatch<SetStateAction<string>> }> = ({ setHref }) => {
    const upgrades = useUpgradesLegalData()

    const handleClick = (source: string, price: number) => {
        fetchNui('kariee/buyUpgradeLegal', {upgrade_name: source, upgrade_price: price})
    }

    return (
        <>
            <div className='kariee_pozwolenia'>
                <div className="kariee_header">
                    <span>ZARZĄDZANIE ULEPSZENIAMI</span>
                    <div className="kariee_header_line"></div>

                    <div className="kariee_header_buttons">
                        <div className="btn" onClick={() => setHref('')}><span>POWRÓT</span></div>
                    </div>
                </div>

                <div className="kariee_pozwolenia_content">

                    {upgrades.map((value, index) => {
                        return (
                            <div className="kmh_content" key={index}>
                                <div className="kmh_content_info">
                                    <div className="kmh_content_name">{value.upgrade_name}</div>
                                </div>
                                <div className="kmh_content_buttons_upgrade" style={{backgroundColor: value.upgrade_buyed ? 'green' : 'red'}} onClick={() => handleClick(value.upgrade_source, value.upgrade_price)}>
                                    {value.upgrade_buyed ? 'KUPIONE' : value.upgrade_price.toLocaleString()+'$'}
                                </div>
                            </div>
                        )
                    })}
                </div>
            </div>
        </>
    )
}

export default UpgradeLegal