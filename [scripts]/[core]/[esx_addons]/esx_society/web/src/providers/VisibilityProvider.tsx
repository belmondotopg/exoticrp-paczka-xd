import React, {Context, createContext, useContext, useEffect, useState} from "react";
import {useNuiEvent} from "../hooks/useNuiEvent";
import {fetchNui} from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";
import './vp.scss'


const VisibilityCtx = createContext<VisibilityProviderValue | null>(null)

interface VisibilityProviderValue {
  setVisible: (visible: boolean) => void
  visible: boolean
}

interface DispatchNotiff {
  id: string,
  localization: {
      x: number,
      y: number,
      z: number,
  },
  title: string,
  subtitle: string,
  code: string,
  color: string,
  time: string,
  response: number,
}

export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [visible, setVisible] = useState(false)


  useNuiEvent<boolean>('setVisible', setVisible)

  // if (visible) {
  //   const windowWidth = window.innerWidth
  //   const casualWidth = 1920

  //   let scale = windowWidth / casualWidth

  //   const scaledDiv = document.getElementById('scaling_div')

  //   if (scaledDiv){
  //     scaledDiv.style.transform = `scale(${scale})`
  //   }
  // }


  useEffect(() => {
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (["Escape"].includes(e.code)) {
        if (!isEnvBrowser()) fetchNui("closeUI");
        else setVisible(!visible);
      }
    }

    window.addEventListener("keydown", keyHandler)

    return () => window.removeEventListener("keydown", keyHandler)
  }, [visible])

  return (
    <VisibilityCtx.Provider
      value={{
        visible,
        setVisible
      }}
    >
    <div style={{ display: visible ? 'block' : 'none', height: '100%'}} id="scaling_div">
      {children}
    </div>

  </VisibilityCtx.Provider>)
}

export const useVisibility = () => useContext<VisibilityProviderValue>(VisibilityCtx as Context<VisibilityProviderValue>)
