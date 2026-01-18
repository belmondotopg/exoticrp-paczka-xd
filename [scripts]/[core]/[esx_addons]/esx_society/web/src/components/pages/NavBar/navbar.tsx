import { Dispatch, useState, useEffect, useRef } from 'react'
import { useSetHref } from '../../../state/href'
import './navbar.scss'
import { SetStateAction } from 'jotai'
import { useSettingsState } from '../../../state/settings'
import { useJobDataState } from '../../../state/jobData'
import { fetchNui } from '../../../utils/fetchNui'
import { usePlayerDataState } from '../../../state/playerData'
import { useInRadialData } from '../../../state/inRadial'
import { getImagePath } from '../../../providers/images'
import { useVisibility } from '../../../providers/VisibilityProvider'
import { isLegalJob } from '../../../utils/legalJobs'

const NavBar: React.FC<{ setHref: Dispatch<SetStateAction<string>> }> = ({ setHref }) => {
  const settings = useSettingsState()
  const jobData = useJobDataState()
  const playerData = usePlayerDataState()
  const inRadial = useInRadialData()
  const { visible } = useVisibility()
  const [isClosing, setIsClosing] = useState(false)
  const logoutButtonRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!visible && isClosing) {
      setIsClosing(false)
    }
  }, [visible, isClosing])

  useEffect(() => {
    if (!visible && logoutButtonRef.current) {
      // Wymuszenie wyłączenia hover/active gdy UI jest ukryte
      logoutButtonRef.current.style.backgroundColor = 'var(--_buttonColor)'
      logoutButtonRef.current.style.pointerEvents = 'none'
    }
  }, [visible])

  return (
    <div className="kariee_navbar">
      <div className="k_navbar_topper">
        <div className="k_n_t_logo"><img src={getImagePath((jobData && jobData.jobName) ? jobData.jobName : 'org') != undefined ? getImagePath((jobData && jobData.jobName) ? jobData.jobName : 'org') : getImagePath('org')} /></div>
        <div className="k_n_t_text">
          <div className="k_n_t_t_job important_text extrabold_text">{jobData?.jobLabel}</div>
          <div className="k_n_t_t_description">
            <div className="k_n_t_t_d_text">
              <span className='description_text'>Witaj, </span><span className='important_text'>{playerData?.firstname + ' ' + playerData?.lastname}</span>
            </div>
            <div className="k_n_t_t_d_line"></div>
            <div 
              ref={logoutButtonRef}
              className={`k_n_t_t_d_logout btn ${isClosing || !visible ? 'closing' : ''}`} 
              onMouseDown={(e) => {
                e.preventDefault()
                setIsClosing(true)
                if (logoutButtonRef.current) {
                  logoutButtonRef.current.style.backgroundColor = 'var(--_buttonColor)'
                  logoutButtonRef.current.style.pointerEvents = 'none'
                }
                fetchNui('closeUI')
              }}
              style={isClosing || !visible ? { pointerEvents: 'none', backgroundColor: 'var(--_buttonColor)' } : {}}
            >
              <span>Wyloguj się</span>
            </div>
          </div>
        </div>
      </div>

      <div className="k_navbar_content">
        <div className="k_n_c_content">
          <div className="k_n_c_content_info">
            <span className='important_text bold_text'>ZARZĄDZANIE PRACOWNIKAMI</span>
            <span className='description_text bold_text'>Awansuj, degraduj, nadzoruj.</span>
          </div>

          <div className="k_n_c_content_btn btn" onClick={() => setHref('manage')}><span>WYBIERZ</span></div>
        </div>
      </div>
                    <div className="k_navbar_content">
                      <div className="k_n_c_content">
                        <div className="k_n_c_content_info">
                          <span className='important_text bold_text'>ZARZĄDZANIE FIRMĄ</span>
                          <span className='description_text bold_text'>Wpłacaj, wypłacaj pieniądze, sprawdzaj statystyki.</span>
                        </div>

                        <div className="k_n_c_content_btn btn" onClick={() => setHref('firma')}><span>WYBIERZ</span></div>
                      </div>
                    </div>
                    {!isLegalJob(jobData?.jobName) && (
                      <div className="k_navbar_content">
                        <div className="k_n_c_content">
                          <div className="k_n_c_content_info">
                            <span className='important_text bold_text'>RAPORTY FINANSOWE</span>
                            <span className='description_text bold_text'>Analiza wydatków, wykresy finansowe</span>
                          </div>

                          <div className="k_n_c_content_btn btn" onClick={() => setHref('financialreports')}><span>WYBIERZ</span></div>
                        </div>
                      </div>
                    )}

      {(settings?.ManageFraction && jobData?.jobName != 'mechanik' && jobData?.jobName != 'ec') &&
        <>
          <div className="k_navbar_content">
            <div className="k_n_c_content">
              <div className="k_n_c_content_info">
                <span className='important_text bold_text'>ZARZĄDZANIE LICENCJAMI</span>
                <span className='description_text bold_text'>Nadaj bądź odbierz pracownikom licencje</span>
              </div>

              <div className="k_n_c_content_btn btn" onClick={() => setHref('licenses')}><span>WYBIERZ</span></div>
            </div>
          </div>
        </>
      }

      {!inRadial &&
        <>
          <div className="k_navbar_content">
            <div className="k_n_c_content">
              <div className="k_n_c_content_info">
                <span className='important_text bold_text'>STATYSTYKI PRACOWNIKÓW</span>
                <span className='description_text bold_text'>Wykresy, rankingi i analizy</span>
              </div>

              <div className="k_n_c_content_btn btn" onClick={() => setHref('statistics')}><span>WYBIERZ</span></div>
            </div>
          </div>
          <div className="k_navbar_content">
            <div className="k_n_c_content">
              <div className="k_n_c_content_info">
                <span className='important_text bold_text'>HISTORIA ZDARZEŃ</span>
                <span className='description_text bold_text'>Sprawdzaj ostatnie statystyki pracy</span>
              </div>

              <div className="k_n_c_content_btn btn" onClick={() => setHref('history')}><span>WYBIERZ</span></div>
            </div>
          </div>
        </>
      }
      {(jobData?.jobName == 'mechanik' || jobData?.jobName == 'ec') &&
        <>
          <div className="k_navbar_content">
            <div className="k_n_c_content">
              <div className="k_n_c_content_info">
                <span className='important_text bold_text'>HISTORIA TUNINGÓW</span>
                <span className='description_text bold_text'>Sprawdź ostatnie tuningi</span>
              </div>

              <div className="k_n_c_content_btn btn" onClick={() => setHref('tunehistory')}><span>WYBIERZ</span></div>
            </div>
          </div>
        </>
      }
    </div>
  )
}

export default NavBar