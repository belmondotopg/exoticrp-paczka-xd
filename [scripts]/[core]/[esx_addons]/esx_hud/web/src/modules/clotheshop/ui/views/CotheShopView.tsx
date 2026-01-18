import { useState, useEffect } from "react"
import OutfitListPanel from "../components/OutfitListPanel"
import useClotheShop from "../../api/useClotheShop"

const ClotheShopView = () => {
    const {
        visible,
        outfits,
        selectedOutfit,
        isLoading,
        error,
        previewOutfit,
        wearOutfit,
        deleteOutfit,
        copyOutfitCode,
        updateOutfit,
        generateCode,
        importOutfit,
        openShop,
        close
    } = useClotheShop()

    const [showImportDialog, setShowImportDialog] = useState(false)
    const [importName, setImportName] = useState("")
    const [importCode, setImportCode] = useState("")
    const [showCodeDialog, setShowCodeDialog] = useState(false)
    const [generatedCode, setGeneratedCode] = useState("")

    useEffect(() => {
        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.key === "Escape") {
                setShowImportDialog(false)
                setShowCodeDialog(false)
                close()
            }
        }

        window.addEventListener("keydown", handleKeyDown)
        return () => window.removeEventListener("keydown", handleKeyDown)
    }, [showImportDialog, showCodeDialog, close])

    if (!visible) return null

    const handleSelect = (id: number) => {
        const outfit = outfits.find(o => o.id === id)
        if (outfit) {
            previewOutfit(outfit)
        }
    }

    const handleDelete = (id: number, e: React.MouseEvent) => {
        e.stopPropagation()
        const outfit = outfits.find(o => o.id === id)
        if (outfit) {
            deleteOutfit(outfit)
        }
    }

    const handleUpdate = (id: number, e: React.MouseEvent) => {
        e.stopPropagation()
        const outfit = outfits.find(o => o.id === id)
        if (outfit) {
            updateOutfit(outfit)
        }
    }

    const handleGenerateCode = async (id: number, e: React.MouseEvent) => {
        e.stopPropagation()
        const outfit = outfits.find(o => o.id === id)
        if (outfit) {
            const code = await generateCode(outfit)
            if (code) {
                setGeneratedCode(code)
                setShowCodeDialog(true)
            }
        }
    }

    const handleImport = () => {
        setShowImportDialog(true)
    }

    const handleImportSubmit = () => {
        if (importName && importCode) {
            importOutfit(importName, importCode)
            setShowImportDialog(false)
            setImportName("")
            setImportCode("")
        }
    }

    const handleEquip = () => {
        if (selectedOutfit) {
            wearOutfit(selectedOutfit)
        }
    }

    const copyToClipboard = (text: string) => {
        copyOutfitCode(text)
        setShowCodeDialog(false)
    }

    return (
        <main className="min-h-screen flex items-center justify-start pl-[3vw]">
            <div
                className="w-[25vw] h-[90vh] flex overflow-hidden relative"
                style={{
                    backgroundColor: "rgba(17,17,17,0.98)",
                    border: "2px solid #2a2a2a",
                    borderRadius: "0.6vw",
                    boxShadow: "0 25px 50px rgba(0,0,0,0.6)",
                    backgroundImage:
                        "linear-gradient(to top, rgba(255,140,0,0.08), transparent)",
                }}
            >
                <div className="flex flex-col w-full h-full">
                    <header
                        className="flex justify-between items-center px-[1.5vw] py-[2vh]"
                        style={{ borderBottom: "1px solid #2a2a2a" }}
                    >
                        <div>
                            <p className="text-[0.9vw] font-semibold" style={{ color: "#e5e5e5" }}>
                                Przebieralnia
                            </p>
                            <p className="text-[0.7vw]" style={{ color: "#8a8a8a" }}>
                                {selectedOutfit ? `Podgląd: ${selectedOutfit.outfitname}` : "Wybierz strój z listy"}
                            </p>
                        </div>
                        <button
                            onClick={close}
                            className="text-[0.9vw] transition-colors hover:text-white"
                            style={{ color: "#9a9a9a" }}
                        >
                            ✕
                        </button>
                    </header>

                    <OutfitListPanel
                        outfits={outfits.map(o => ({ id: o.id, name: o.outfitname }))}
                        selectedOutfit={selectedOutfit?.id || null}
                        onSelect={handleSelect}
                        onDelete={handleDelete}
                        onUpdate={handleUpdate}
                        onGenerateCode={handleGenerateCode}
                        onNewOutfit={openShop}
                        onImport={handleImport}
                    />

                    {isLoading && (
                        <div className="px-[1.5vw] py-[1vh] text-[0.75vw]" style={{ color: "#ff8c00" }}>
                            Ładowanie...
                        </div>
                    )}
                    
                    {error && (
                        <div className="px-[1.5vw] py-[1vh] text-[0.75vw]" style={{ color: "#ff4444" }}>
                            {error}
                        </div>
                    )}

                    {selectedOutfit && !isLoading && (
                        <div className="px-[1.5vw] py-[2vh]" style={{ borderTop: "1px solid #2a2a2a" }}>
                            <button
                                onClick={handleEquip}
                                className="w-full px-[1vw] py-[1.2vh] rounded-[0.3vw] text-[0.8vw] font-medium transition-all hover:bg-[rgba(255,140,0,1)] hover:shadow-[0_0_15px_rgba(255,140,0,0.4)]"
                                style={{
                                    backgroundColor: "rgba(255,140,0,0.8)",
                                    border: "1px solid #ff8c00",
                                    color: "#fff"
                                }}
                            >
                                Ubierz się
                            </button>
                        </div>
                    )}
                </div>

            </div>

            {showImportDialog && (
                <div
                    className="fixed inset-0 z-50 flex items-center justify-center"
                    style={{ backgroundColor: "rgba(0,0,0,0.85)" }}
                    onClick={() => setShowImportDialog(false)}
                >
                    <div
                        className="p-[2vw] rounded-[0.5vw]"
                        style={{
                            backgroundColor: "rgba(12, 12, 12, 0.98)",
                            border: "2px solid rgb(28, 28, 28)",
                            minWidth: "25vw"
                        }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <h2 className="text-[1vw] font-bold mb-[2vh]" style={{ color: "#e5e5e5" }}>
                            Importuj strój
                        </h2>
                        
                        <div className="space-y-[1.5vh]">
                            <div>
                                <label className="text-[0.75vw] block mb-[0.5vh]" style={{ color: "#b5b5b5" }}>
                                    Nazwa stroju
                                </label>
                                <input
                                    type="text"
                                    value={importName}
                                    onChange={(e) => setImportName(e.target.value)}
                                    placeholder="Mój nowy strój"
                                    className="w-full px-[0.8vw] py-[1vh] rounded-[0.3vw] text-[0.75vw] outline-none transition-all placeholder:text-[#3a3a3a] focus:ring-2 focus:ring-[#ff8c00] focus:border-[#ff8c00]"
                                    style={{
                                        backgroundColor: "rgba(30,30,30,0.8)",
                                        border: "1px solid #3a3a3a",
                                        color: "#e5e5e5"
                                    }}
                                />
                            </div>
                            
                            <div>
                                <label className="text-[0.75vw] block mb-[0.5vh]" style={{ color: "#b5b5b5" }}>
                                    Kod stroju
                                </label>
                                <input
                                    type="text"
                                    value={importCode}
                                    onChange={(e) => setImportCode(e.target.value)}
                                    placeholder="fAaBlCsDzEyFwGyHsIsJiKeL"
                                    className="w-full px-[0.8vw] py-[1vh] rounded-[0.3vw] text-[0.75vw] outline-none transition-all placeholder:text-[#3a3a3a] focus:ring-2 focus:ring-[#ff8c00] focus:border-[#ff8c00]"
                                    style={{
                                        backgroundColor: "rgba(30,30,30,0.8)",
                                        border: "1px solid #3a3a3a",
                                        color: "#e5e5e5"
                                    }}
                                />
                            </div>
                        </div>
                        
                        <div className="flex gap-[0.8vw] mt-[2vh]">
                            <button
                                onClick={() => setShowImportDialog(false)}
                                className="flex-1 px-[1vw] py-[1vh] rounded-[0.3vw] text-[0.75vw] transition-all hover:bg-[rgba(50,50,50,0.9)] hover:border-[#5a5a5a]"
                                style={{
                                    backgroundColor: "rgba(30,30,30,0.8)",
                                    border: "1px solid #3a3a3a",
                                    color: "#b5b5b5"
                                }}
                            >
                                Anuluj
                            </button>
                            <button
                                onClick={handleImportSubmit}
                                disabled={!importName || !importCode}
                                className={`flex-1 px-[1vw] py-[1vh] rounded-[0.3vw] text-[0.75vw] transition-all ${importName && importCode ? "hover:bg-[rgba(255,140,0,1)] hover:shadow-[0_0_15px_rgba(255,140,0,0.4)]" : ""}`}
                                style={{
                                    backgroundColor: importName && importCode ? "rgba(255,140,0,0.8)" : "rgba(50,50,50,0.5)",
                                    border: importName && importCode ? "1px solid #ff8c00" : "1px solid #3a3a3a",
                                    color: importName && importCode ? "#fff" : "#5a5a5a",
                                    cursor: importName && importCode ? "pointer" : "not-allowed"
                                }}
                            >
                                Importuj
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {showCodeDialog && (
                <div
                    className="fixed inset-0 z-50 flex items-center justify-center"
                    style={{ backgroundColor: "rgba(0,0,0,0.85)" }}
                    onClick={() => setShowCodeDialog(false)}
                >
                    <div
                        className="p-[2vw] rounded-[0.5vw]"
                        style={{
                            backgroundColor: "rgba(12, 12, 12, 0.98)",
                            border: "2px solid rgb(28, 28, 28)",
                            minWidth: "25vw"
                        }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <h2 className="text-[1vw] font-bold mb-[2vh]" style={{ color: "#e5e5e5" }}>
                            Kod stroju
                        </h2>
                        
                        <div className="mb-[2vh]">
                            <div
                                className="px-[1vw] py-[1.5vh] rounded-[0.3vw] text-center font-mono text-[0.8vw] break-all"
                                style={{
                                    backgroundColor: "rgba(30,30,30,0.8)",
                                    border: "1px solid #ff8c00",
                                    color: "#ff8c00"
                                }}
                            >
                                {generatedCode}
                            </div>
                        </div>
                        
                        <div className="flex gap-[0.8vw]">
                            <button
                                onClick={() => setShowCodeDialog(false)}
                                className="flex-1 px-[1vw] py-[1vh] rounded-[0.3vw] text-[0.75vw] transition-all hover:bg-[rgba(50,50,50,0.9)] hover:border-[#5a5a5a]"
                                style={{
                                    backgroundColor: "rgba(30,30,30,0.8)",
                                    border: "1px solid #3a3a3a",
                                    color: "#b5b5b5"
                                }}
                            >
                                Zamknij
                            </button>
                            <button
                                onClick={() => copyToClipboard(generatedCode)}
                                className="flex-1 px-[1vw] py-[1vh] rounded-[0.3vw] text-[0.75vw] transition-all hover:bg-[rgba(255,140,0,1)] hover:shadow-[0_0_15px_rgba(255,140,0,0.4)]"
                                style={{
                                    backgroundColor: "rgba(255,140,0,0.8)",
                                    border: "1px solid #ff8c00",
                                    color: "#fff"
                                }}
                            >
                                Skopiuj
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </main>
    )
}

export default ClotheShopView