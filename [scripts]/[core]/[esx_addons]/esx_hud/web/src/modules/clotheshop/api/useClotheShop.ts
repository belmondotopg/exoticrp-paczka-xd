import { useNuiMessage } from "@yankes/fivem-react/hooks";
import { useState } from "react";

interface Outfit {
    id: number;
    outfitname: string;
    model: string;
    components: string;
    props: string;
}

const useClotheShop = () => {
    const [visible, setVisible] = useState(false);
    const [selectedOutfit, setSelectedOutfit] = useState<Outfit | null>(null);
    const [outfits, setOutfits] = useState<Outfit[]>([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    useNuiMessage<{ eventName: string, outfits: Outfit[] }>("clotheshop:open", (data) => {
        setVisible(true);
        if (data?.outfits) setOutfits(data.outfits);
        setSelectedOutfit(null);
        setError(null);
    });

    useNuiMessage<{ eventName: string }>("clotheshop:close", () => {
        setVisible(false);
        setSelectedOutfit(null);
        setOutfits([]);
        setError(null);
    });

    const previewOutfit = async (outfit: Outfit) => {
        setIsLoading(true);
        setError(null);
        
        try {
            const response = await fetch(`https://${GetParentResourceName()}/clotheshop:previewOutfit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ id: outfit.id })
            });

            const data = await response.json();
            
            if (data.success) {
                setSelectedOutfit(outfit);
            } else {
                setError(data.error || "Nie udało się załadować podglądu");
            }
        } catch (error) {
            console.error("Błąd podczas ładowania podglądu outfitu:", error);
            setError("Błąd podczas ładowania podglądu");
        } finally {
            setIsLoading(false);
        }
    };

    const wearOutfit = async (outfit: Outfit) => {
        setIsLoading(true);
        setError(null);
        
        try {
            const response = await fetch(`https://${GetParentResourceName()}/clotheshop:wearOutfit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ id: outfit.id })
            });

            const data = await response.json();
            
            if (!data.success) {
                setError(data.error || "Nie udało się założyć stroju");
            }
        } catch (error) {
            console.error("Błąd podczas zakładania outfitu:", error);
            setError("Błąd podczas zakładania outfitu");
        } finally {
            setIsLoading(false);
        }
    };

    const deleteOutfit = async (outfit: Outfit) => {
        setIsLoading(true);
        setError(null);
        
        try {
            const response = await fetch(`https://${GetParentResourceName()}/clotheshop:deleteOutfit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ id: outfit.id })
            });

            const data = await response.json();
            
            if (data.success) {
                if (data.outfits) {
                    setOutfits(data.outfits);
                }
                if (selectedOutfit?.id === outfit.id) {
                    setSelectedOutfit(null);
                }
            } else {
                setError(data.error || "Nie udało się usunąć stroju");
            }
        } catch (error) {
            console.error("Błąd podczas usuwania outfitu:", error);
            setError("Błąd podczas usuwania outfitu");
        } finally {
            setIsLoading(false);
        }
    };

    const updateOutfit = async (outfit: Outfit) => {
        setIsLoading(true);
        setError(null);
        
        try {
            const response = await fetch(`https://${GetParentResourceName()}/clotheshop:updateOutfit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ id: outfit.id })
            });

            const data = await response.json();
            
            if (!data.success) {
                setError(data.error || "Nie udało się zaktualizować stroju");
            }
        } catch (error) {
            console.error("Błąd podczas aktualizacji outfitu:", error);
            setError("Błąd podczas aktualizacji outfitu");
        } finally {
            setIsLoading(false);
        }
    };

    const generateCode = async (outfit: Outfit): Promise<string | null> => {
        setIsLoading(true);
        setError(null);
        
        try {
            const response = await fetch(`https://${GetParentResourceName()}/clotheshop:generateCode`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ id: outfit.id })
            });

            const data = await response.json();
            
            if (data.success && data.code) {
                return data.code;
            } else {
                setError(data.error || "Nie udało się wygenerować kodu");
                return null;
            }
        } catch (error) {
            console.error("Błąd podczas generowania kodu:", error);
            setError("Błąd podczas generowania kodu");
            return null;
        } finally {
            setIsLoading(false);
        }
    };

    const copyOutfitCode = async (code: string) => {
        setIsLoading(true);
        setError(null);
        
        try {
            await fetch(`https://${GetParentResourceName()}/clotheshop:copyOutfitCode`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ code })
            });


        } catch (error) {
            console.error("Błąd podczas kopiowania kodu:", error);
            setError("Błąd podczas kopiowania kodu");
        } finally {
            setIsLoading(false);
        }
    };

    const importOutfit = async (name: string, code: string) => {
        setIsLoading(true);
        setError(null);
        
        try {
            const response = await fetch(`https://${GetParentResourceName()}/clotheshop:importOutfit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ name, code })
            });

            const data = await response.json();
            
            if (data.success) {
                if (data.outfits) {
                    setOutfits(data.outfits);
                }
            } else {
                setError(data.error || "Nie udało się zaimportować stroju");
            }
        } catch (error) {
            console.error("Błąd podczas importowania outfitu:", error);
            setError("Błąd podczas importowania outfitu");
        } finally {
            setIsLoading(false);
        }
    };

    const openShop = async () => {
        try {
            await fetch(`https://${GetParentResourceName()}/clotheshop:openShop`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        } catch (error) {
            console.error("Błąd podczas otwierania sklepu:", error);
        }
    };

    const close = async () => {
        try {
            await fetch(`https://${GetParentResourceName()}/clotheshop:close`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        } catch (error) {
            console.error("Błąd podczas zamykania UI:", error);
        }
        
        setVisible(false);
        setSelectedOutfit(null);
        setOutfits([]);
        setError(null);
    };

    return { 
        visible, 
        outfits, 
        selectedOutfit,
        isLoading,
        error,
        previewOutfit,
        wearOutfit,
        deleteOutfit,
        updateOutfit,
        generateCode,
        importOutfit,
        openShop,
        copyOutfitCode,
        close,
        setVisible 
    };
};

export default useClotheShop;