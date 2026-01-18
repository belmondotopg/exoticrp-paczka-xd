import { memo, useCallback } from "react";
import { Plus } from "lucide-react";

import { cn } from "@/lib/utils";
import type { Character } from "../../types";

interface CharacterSlotProps {
    characterData: Character | null;
    active: boolean;
    onSelect: (id: string) => void;
    slotIndex: number;
}

export const CharacterSlot = memo<CharacterSlotProps>(({ 
    characterData, 
    active, 
    onSelect, 
    slotIndex 
}) => {
    
    const handleClick = useCallback(() => {
        if (characterData) {
            onSelect(characterData.id);
        } else {
            onSelect(`slot-${slotIndex}`);
        }
    }, [characterData, onSelect, slotIndex]);

    return (
        <button
            className={cn(
                "w-[2.3vw] h-[2.3vw] flex justify-center items-center rounded-[0.3vw] cursor-pointer"
            )}
            style={
                active 
                    ? {
                        background: 'linear-gradient(180deg, #151515 0%, #674002 100%)',
                        border: '0.12vw solid #865301'
                    }
                    : {
                        backgroundColor: 'rgba(0, 0, 0, 0.6)',
                        border: '0.12vw solid #363636'
                    }
            }
            onClick={handleClick}
        >
            {characterData ? (
                <p
                    style={{
                        fontSize: '0.85vw',
                        fontWeight: 'bold',
                        color: active ? '#ffffff' : '#4A4A4A'
                    }}
                >
                    {characterData.id}
                </p>
            ) : (
                <Plus style={{
                    width: '1vw',
                    color: active ? '#ffffff' : '#4A4A4A'
                }} />
            )}
        </button>
    )
}, (prevProps, nextProps) => {
    // Optymalizacja - rerenderuj tylko gdy active się zmieni lub charakterData.id
    return prevProps.active === nextProps.active && 
           prevProps.characterData?.id === nextProps.characterData?.id;
});

CharacterSlot.displayName = 'CharacterSlot';
