import OutfitItem from "./OutfitItem"
import { FaPlus, FaFileImport } from "react-icons/fa6"

type Outfit = {
    id: number
    name: string
}

type Props = {
    outfits: Outfit[]
    selectedOutfit: number | null
    onSelect: (id: number) => void
    onDelete: (id: number, e: React.MouseEvent) => void
    onUpdate?: (id: number, e: React.MouseEvent) => void
    onGenerateCode?: (id: number, e: React.MouseEvent) => void
    onNewOutfit?: () => void
    onImport?: () => void
}

const OutfitListPanel = ({
    outfits,
    selectedOutfit,
    onSelect,
    onDelete,
    onUpdate,
    onGenerateCode,
    onNewOutfit,
    onImport,
}: Props) => {
    return (
        <div
            className="w-full flex-1 flex flex-col overflow-hidden"
        >
            <div className="flex gap-[0.5vw] px-[1vw] py-[1.5vh]" style={{ borderBottom: "1px solid #2a2a2a" }}>
                {onNewOutfit && (
                    <button
                        onClick={onNewOutfit}
                        className="flex-1 px-[0.8vw] py-[0.8vh] rounded-[0.3vw] flex items-center justify-center gap-[0.4vw] transition-all"
                        style={{
                            backgroundColor: "rgba(255,140,0,0.15)",
                            border: "1px solid #ff8c00",
                            color: "#ff8c00"
                        }}
                        onMouseEnter={(e) => {
                            e.currentTarget.style.backgroundColor = "rgba(255,140,0,0.25)"
                        }}
                        onMouseLeave={(e) => {
                            e.currentTarget.style.backgroundColor = "rgba(255,140,0,0.15)"
                        }}
                    >
                        <FaPlus style={{ fontSize: "0.7vw" }} />
                        <span className="text-[0.7vw] font-medium">Nowe</span>
                    </button>
                )}

                {onImport && (
                    <button
                        onClick={onImport}
                        className="flex-1 px-[0.8vw] py-[0.8vh] rounded-[0.3vw] flex items-center justify-center gap-[0.4vw] transition-all"
                        style={{
                            backgroundColor: "rgba(40,40,40,0.8)",
                            border: "1px solid #4a4a4a",
                            color: "#b5b5b5"
                        }}
                        onMouseEnter={(e) => {
                            e.currentTarget.style.backgroundColor = "rgba(50,50,50,0.9)"
                            e.currentTarget.style.color = "#e5e5e5"
                        }}
                        onMouseLeave={(e) => {
                            e.currentTarget.style.backgroundColor = "rgba(40,40,40,0.8)"
                            e.currentTarget.style.color = "#b5b5b5"
                        }}
                    >
                        <FaFileImport style={{ fontSize: "0.7vw" }} />
                        <span className="text-[0.7vw] font-medium">Importuj</span>
                    </button>
                )}
            </div>

            <div className="flex-1 overflow-y-auto px-[1vw] py-[2.2vh] space-y-[0.8vh]">
                {outfits.length === 0 ? (
                    <div className="text-center py-[4vh]" style={{ color: "#6a6a6a" }}>
                        <p className="text-[0.75vw]">Brak zapisanych strojów</p>
                        <p className="text-[0.65vw] mt-[1vh]">Kup nowe ubrania w sklepie</p>
                    </div>
                ) : (
                    outfits.map((outfit) => (
                        <OutfitItem
                            key={outfit.id}
                            outfit={outfit}
                            selected={selectedOutfit === outfit.id}
                            onSelect={() => onSelect(outfit.id)}
                            onDelete={(e) => onDelete(outfit.id, e)}
                            onUpdate={onUpdate ? (e) => onUpdate(outfit.id, e) : undefined}
                            onGenerateCode={onGenerateCode ? (e) => onGenerateCode(outfit.id, e) : undefined}
                        />
                    ))
                )}
            </div>
        </div>
    )
}

export default OutfitListPanel
