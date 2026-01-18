import type React from "react"
import { FaTrash, FaQrcode, FaEllipsis, FaSpinner } from "react-icons/fa6"
import { useState } from "react"

type Outfit = {
    id: number
    name: string
}

type Props = {
    outfit: Outfit
    selected: boolean
    onSelect: () => void
    onDelete: (e: React.MouseEvent) => void
    onUpdate?: (e: React.MouseEvent) => void
    onGenerateCode?: (e: React.MouseEvent) => void
}

const OutfitItem = ({ outfit, selected, onSelect, onDelete, onUpdate, onGenerateCode }: Props) => {
    const [showMenu, setShowMenu] = useState(false)

    return (
        <div
            onClick={onSelect}
            className="p-[0.8vw] rounded-[0.4vw] cursor-pointer transition-all flex justify-between items-center relative"
            style={{
                backgroundColor: selected
                    ? "rgba(255,140,0,0.18)"
                    : "rgba(30,30,30,0.65)",
                border: selected
                    ? "1px solid #ff8c00"
                    : "1px solid #2a2a2a",
            }}
        >
            <h3
                className="text-[0.75vw] font-semibold"
                style={{ color: "#e5e5e5" }}
            >
                {outfit.name}
            </h3>

            <div className="flex items-center gap-[0.3vw]">
                <button
                    onClick={(e) => {
                        e.stopPropagation()
                        setShowMenu(!showMenu)
                    }}
                    className="p-[0.4vw]"
                    style={{ color: "#9a9a9a" }}
                    onMouseEnter={(e) =>
                        (e.currentTarget.style.color = "#e5e5e5")
                    }
                    onMouseLeave={(e) =>
                        (e.currentTarget.style.color = "#9a9a9a")
                    }
                >
                    <FaEllipsis style={{ fontSize: "0.7vw" }} />
                </button>
                
                <button
                    onClick={onDelete}
                    className="p-[0.4vw]"
                    style={{ color: "#9a9a9a" }}
                    onMouseEnter={(e) =>
                        (e.currentTarget.style.color = "#ff4444")
                    }
                    onMouseLeave={(e) =>
                        (e.currentTarget.style.color = "#9a9a9a")
                    }
                >
                    <FaTrash style={{ fontSize: "0.7vw" }} />
                </button>
            </div>

            {showMenu && (
                <>
                    <div
                        className="fixed inset-0 z-10"
                        onClick={(e) => {
                            e.stopPropagation()
                            setShowMenu(false)
                        }}
                    />
                    <div
                        className="absolute right-[2.5vw] top-[50%] translate-y-[-50%] z-20 rounded-[0.3vw] overflow-hidden"
                        style={{
                            backgroundColor: "rgba(25,25,25,0.98)",
                            border: "1px solid #3a3a3a",
                            boxShadow: "0 4px 12px rgba(0,0,0,0.5)",
                            minWidth: "10vw"
                        }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        {onUpdate && (
                            <button
                                onClick={(e) => {
                                    setShowMenu(false)
                                    onUpdate(e)
                                }}
                                className="w-full px-[1vw] py-[0.8vh] flex items-center gap-[0.5vw] transition-all"
                                style={{ color: "#b5b5b5" }}
                                onMouseEnter={(e) => {
                                    e.currentTarget.style.backgroundColor = "rgba(255,140,0,0.15)"
                                    e.currentTarget.style.color = "#ff8c00"
                                }}
                                onMouseLeave={(e) => {
                                    e.currentTarget.style.backgroundColor = "transparent"
                                    e.currentTarget.style.color = "#b5b5b5"
                                }}
                            >
                                <FaSpinner style={{ fontSize: "0.7vw" }} />
                                <span className="text-[0.7vw]">Zaktualizuj</span>
                            </button>
                        )}
                        
                        {onGenerateCode && (
                            <button
                                onClick={(e) => {
                                    setShowMenu(false)
                                    onGenerateCode(e)
                                }}
                                className="w-full px-[1vw] py-[0.8vh] flex items-center gap-[0.5vw] transition-all"
                                style={{ color: "#b5b5b5" }}
                                onMouseEnter={(e) => {
                                    e.currentTarget.style.backgroundColor = "rgba(255,140,0,0.15)"
                                    e.currentTarget.style.color = "#ff8c00"
                                }}
                                onMouseLeave={(e) => {
                                    e.currentTarget.style.backgroundColor = "transparent"
                                    e.currentTarget.style.color = "#b5b5b5"
                                }}
                            >
                                <FaQrcode style={{ fontSize: "0.7vw" }} />
                                <span className="text-[0.7vw]">Generuj kod</span>
                            </button>
                        )}
                    </div>
                </>
            )}
        </div>
    )
}

export default OutfitItem;