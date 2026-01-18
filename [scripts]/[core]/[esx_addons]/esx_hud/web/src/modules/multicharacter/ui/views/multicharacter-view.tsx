import { useMemo, useState, useEffect, useCallback } from "react";
import { useVisible } from "@yankes/fivem-react/hooks";
import { motion, AnimatePresence } from "framer-motion";
import { 
    MapPin, 
    Banknote, 
    Wallet, 
    Briefcase, 
    Calendar,
    Ruler 
} from 'lucide-react';

import { useMulticharacterData } from "../../api/use-multicharacter-data";
import { cn } from '@/lib/utils';
import { CharacterSlot } from '../components/character-slot';
import { CharacterStat } from '../components/character-stat';

const CHARACTER_STATS = [
    { label: "Praca", dataKey: "job", icon: <Briefcase className="w-[1vw] h-[1.2vw]" /> },
    { label: "Bank", dataKey: "bank", icon: <Banknote className="w-[1vw] h-[1.2vw]" /> },
    { label: "Gotówka", dataKey: "cash", icon: <Wallet className="w-[1vw] h-[1.2vw]" /> },
    { label: "Wzrost", dataKey: "height", icon: <Ruler className="w-[1vw] h-[1.2vw]" /> },
    { label: "Data urodzenia", dataKey: "birthDate", icon: <Calendar className="w-[1vw] h-[1.2vw]" /> },
    { label: "Ostatnia lokacja", dataKey: "lastLocation", icon: <MapPin className="w-[1vw] h-[1.2vw]" /> }
] as const;

const formatStatValue = (dataKey: string, value: any) => {
    switch (dataKey) {
        case 'bank':
        case 'cash':
            return `$${value?.toLocaleString() || '0'}`;
        case 'height':
            return value ? `${value} cm` : 'Brak danych';
        case 'job':
            return value || 'Bezrobotny';
        default:
            return value || 'Brak danych';
    }
};

export const MulticharacterView = () => {
    const { visible } = useVisible("multicharacter", false);
    const data = useMulticharacterData();

    const [currentCharacterId, setCurrentCharacterId] = useState<string | null>(null);
    const [animationKey, setAnimationKey] = useState(0);
    const [hasSwitchedCharacter, setHasSwitchedCharacter] = useState(false);

    useEffect(() => {
        if (visible && data && data.characters && data.characters.length > 0 && !currentCharacterId) {
            const firstCharacter = data.characters[0];
            if (firstCharacter) {
                setCurrentCharacterId(firstCharacter.id);
            }
        }
    }, [visible, data, currentCharacterId]);

    useEffect(() => {
        if (!visible) {
            setCurrentCharacterId(null);
            setHasSwitchedCharacter(false);
        }
    }, [visible]);

    const currentCharacter = useMemo(() => {
        if (!data || !currentCharacterId) return null;
        return data.characters.find(character => character.id === currentCharacterId);
    }, [data, currentCharacterId]);

    const isSelectedSlotEmpty = useMemo(() => {
        if (!currentCharacterId) return false;
        return currentCharacterId.startsWith('slot-');
    }, [currentCharacterId]);

    const handleCharacterSelect = useCallback((id: string) => {
        if (id === currentCharacterId) return;
        
        setCurrentCharacterId(id);
        setAnimationKey(prev => prev + 1);
        setHasSwitchedCharacter(true);
    }, [currentCharacterId]);

    useEffect(() => {
        if (!visible || !currentCharacterId || !hasSwitchedCharacter || process.env.NODE_ENV === "development") {
            return;
        }

        const timeoutId = setTimeout(() => {
            if (currentCharacter) {
                fetch(`https://${GetParentResourceName()}/multicharacter/switchCharacter`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({ 
                        id: currentCharacterId, 
                        character: currentCharacter 
                    })
                }).catch(() => {});
            }
            setHasSwitchedCharacter(false);
        }, 300);

        return () => clearTimeout(timeoutId);
    }, [currentCharacterId, visible, currentCharacter, hasSwitchedCharacter]);

    const onCreateCharacter = useCallback(() => {
        if (process.env.NODE_ENV === "development") return;
        
        fetch(`https://${GetParentResourceName()}/multicharacter/create`, {
            method: "POST"
        }).catch(() => {});
    }, []);

    const onPlay = useCallback(() => {
        if (!currentCharacter || process.env.NODE_ENV === "development") return;
        
        fetch(`https://${GetParentResourceName()}/multicharacter/play`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ 
                id: currentCharacterId, 
                character: currentCharacter 
            })
        }).catch(() => {});
    }, [currentCharacter, currentCharacterId]);

    const handleBottomButtonClick = useCallback(() => {
        if (isSelectedSlotEmpty) {
            onCreateCharacter();
        } else if (currentCharacter) {
            onPlay();
        }
    }, [isSelectedSlotEmpty, currentCharacter, onCreateCharacter, onPlay]);

    const getBottomButtonText = useCallback(() => {
        if (!currentCharacterId) {
            return "WYBIERZ POSTAĆ";
        } else if (isSelectedSlotEmpty) {
            return "STWÓRZ POSTAĆ";
        } else {
            return "WEJDŹ DO GRY";
        }
    }, [currentCharacterId, isSelectedSlotEmpty]);

    const isBottomButtonDisabled = !currentCharacterId;
    const isBottomButtonClickable = currentCharacterId && !isBottomButtonDisabled;

    const slots = useMemo(() => {
        if (!data) return [];
        
        return Array.from({ length: data.maxSlots }).map((_, index) => {
            const characterData = data.characters[index] || null;
            const slotId = characterData ? characterData.id : `slot-${index}`;
            return {
                id: slotId,
                character: characterData,
                index
            };
        });
    }, [data]);

    if (!visible || !data || !data.characters || data.characters.length === 0) {
        return null;
    }

    return (
        <AnimatePresence>
            <motion.div
                style={{ fontFamily: 'Sora' }}
                initial={{ opacity: 0, y: 50 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 50 }}
                transition={{ duration: 0.3 }}
                className="w-full h-full fixed inset-0"
            >
                <AnimatePresence mode="wait">
                    {currentCharacter && (
                        <motion.div
                            key={`name-${animationKey}`}
                            className="flex flex-col items-center absolute top-[4vh] left-1/2 transform -translate-x-1/2"
                            style={{ 
                                lineHeight: '3vh', 
                                fontWeight: '900', 
                                textTransform: 'uppercase' 
                            }}
                            initial={{ scale: 0.8, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            exit={{ scale: 0.8, opacity: 0 }}
                            transition={{ duration: 0.3 }}
                        >
                            <p
                                style={{ fontSize: '1.2vw', textShadow: '0.2vw 0.2vw 0.6vw rgba(0,0,0,0.6)', color: '#ffffff' }}
                            >
                                {currentCharacter.firstName}
                            </p>
                            <p
                                style={{ fontSize: '3vw', textShadow: '0.3vw 0.3vw 0.8vw rgba(0,0,0,0.8)', color: '#ffffff' }}
                            >
                                {currentCharacter.lastName}
                            </p>
                        </motion.div>
                    )}
                </AnimatePresence>

                <div className="flex flex-col items-center absolute bottom-[4vh] left-1/2 transform -translate-x-1/2 gap-[2vh]">
                    <div className="flex gap-[0.6vw]">
                        {slots.map((slot) => {
                            const active = currentCharacterId === slot.id;

                            return (
                                <motion.div
                                    key={slot.id}
                                    whileHover={{ scale: 1.1 }}
                                    whileTap={{ scale: 0.95 }}
                                >
                                    <CharacterSlot
                                        characterData={slot.character}
                                        active={active}
                                        slotIndex={slot.index}
                                        onSelect={handleCharacterSelect}
                                    />
                                </motion.div>
                            );
                        })}
                    </div>

                    <motion.button 
                        className={cn(
                            'px-[3vw] py-[1.2vh] rounded-[0.4vw] border-[0.12vw] font-bold text-[0.8vw]',
                            isBottomButtonClickable 
                                ? "cursor-pointer"
                                : "cursor-not-allowed"
                        )}
                        style={
                            isBottomButtonClickable 
                                ? {
                                    background: 'linear-gradient(90deg, #151515 0%, #674002 100%)',
                                    border: '0.12vw solid #865301',
                                    color: '#ffffff'
                                }
                                : {
                                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                                    border: '0.12vw solid #666666',
                                    color: '#666666'
                                }
                        }
                        disabled={isBottomButtonDisabled}
                        onClick={handleBottomButtonClick}
                        whileHover={isBottomButtonClickable ? { scale: 1.05 } : {}}
                        whileTap={isBottomButtonClickable ? { scale: 0.95 } : {}}
                    >
                        {getBottomButtonText()}
                    </motion.button>
                </div>

                <AnimatePresence mode="wait">
                    {currentCharacter && (
                        <motion.div 
                            key={`stats-${animationKey}`}
                            className="flex flex-col gap-[4vh] absolute right-[2vw] top-1/2 transform -translate-y-1/2"
                            initial={{ x: 50, opacity: 0 }}
                            animate={{ x: 0, opacity: 1 }}
                            exit={{ x: 50, opacity: 0 }}
                            transition={{ duration: 0.3 }}
                        >
                            <span className="flex flex-col items-end" style={{ lineHeight: '2.5rem' }}>
                                <p style={{ color: '#ffffff', fontSize: '0.9vw', fontWeight: 'bold' }}>INFORMACJE O</p>
                                <p style={{ color: '#ffffff', fontSize: '2.4vw', fontWeight: '900' }}>POSTACI</p>
                            </span>
                            <div className="flex flex-col gap-[1.4vh]">
                                {CHARACTER_STATS.map((stat) => (
                                    <CharacterStat 
                                        key={stat.dataKey}
                                        label={stat.label}
                                        value={formatStatValue(stat.dataKey, currentCharacter[stat.dataKey as keyof typeof currentCharacter])}
                                        icon={stat.icon}
                                    />
                                ))}
                            </div>
                        </motion.div>
                    )}
                </AnimatePresence>
            </motion.div>
        </AnimatePresence>
    );
};
