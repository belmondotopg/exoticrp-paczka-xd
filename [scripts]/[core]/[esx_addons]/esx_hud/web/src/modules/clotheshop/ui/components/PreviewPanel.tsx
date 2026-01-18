import { FaX } from "react-icons/fa6"
import { Button } from "@/components/ui/button"

type Props = {
    selectedOutfit: number | null
    selectedOutfitName?: string
    isLoading?: boolean
    error?: string | null
    onEquip: () => void
    onClose: () => void
}

const PreviewPanel = ({ 
    selectedOutfit, 
    selectedOutfitName,
    isLoading = false,
    error = null,
    onEquip, 
    onClose 
}: Props) => {
    return (
        <div className="w-[67%] h-full relative flex flex-col">
            <header
                className="flex justify-between items-center px-[1.5vw] py-[2.2vh]"
                style={{ borderBottom: "1px solid #2a2a2a" }}
            >
                <div>
                    <p
                        className="text-[0.9vw] font-semibold"
                        style={{ color: "#e5e5e5" }}
                    >
                        Przebieralnia
                    </p>
                    <p
                        className="text-[0.75vw]"
                        style={{ color: "#8a8a8a" }}
                    >
                        {selectedOutfit && selectedOutfitName 
                            ? `Podgląd: ${selectedOutfitName}` 
                            : "Wybierz outfit aby go założyć"}
                    </p>
                </div>

                <button
                    onClick={onClose}
                    style={{ color: "#9a9a9a" }}
                    onMouseEnter={(e) =>
                        (e.currentTarget.style.color = "#e5e5e5")
                    }
                    onMouseLeave={(e) =>
                        (e.currentTarget.style.color = "#9a9a9a")
                    }
                >
                    <FaX style={{ fontSize: "0.9vw" }} />
                </button>
            </header>

            <div
                className="flex-1 flex items-center justify-center text-[0.9vw] flex-col gap-2"
                style={{ color: "#7a7a7a" }}
            >
                {isLoading && (
                    <div className="text-center">
                        <p>Ładowanie...</p>
                    </div>
                )}
                
                {error && (
                    <div className="text-center" style={{ color: "#ff4444" }}>
                        <p>{error}</p>
                    </div>
                )}
                
                {!isLoading && !error && selectedOutfit && (
                    <div className="text-center">
                        <p>Podgląd 3D postaci</p>
                        <p className="text-[0.7vw] mt-2">
                            Twoja postać w grze pokazuje wybrany strój
                        </p>
                    </div>
                )}
                
                {!isLoading && !error && !selectedOutfit && (
                    <p>Nie wybrano outfitu</p>
                )}
            </div>

            {selectedOutfit && !isLoading && (
                <Button
                    onClick={onEquip}
                    className="absolute bottom-[2vh] right-[2vw] px-[2.5vw] py-[1.2vh]"
                >
                    Ubierz się
                </Button>
            )}
        </div>
    )
}

export default PreviewPanel
