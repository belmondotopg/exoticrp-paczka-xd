import { memo } from "react";
import type React from "react";

interface Props {
    label: string;
    value: string | null;
    icon: React.ReactNode;
}

export const CharacterStat = memo(({ label, value, icon }: Props) => {
    return (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '0.7vw' }}>
            <span style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
                <p 
                    style={{ 
                        fontSize: '0.65vw', 
                        fontWeight: 'bold', 
                        color: '#B5B5B5',
                        textShadow: '0.1vw 0.1vw 0.3vw rgba(0,0,0,0.6)' 
                    }}
                >
                    {label}
                </p>
                <p 
                    style={{ 
                        fontSize: '0.9vw', 
                        fontWeight: 'bold', 
                        color: '#ffffff',
                        textShadow: '0.15vw 0.15vw 0.4vw rgba(0,0,0,0.8)' 
                    }}
                >
                    {value || "Brak danych"}
                </p>
            </span>
            <div 
                style={{ 
                    color: '#FFD086',
                    background: 'linear-gradient(to bottom, #272727 0%, #4C2F00 100%)',
                    padding: '0.6vw',
                    border: '0.12vw solid #9E6200',
                    borderRadius: '0.3vw',
                    textShadow: '0.15vw 0.15vw 0.4vw rgba(0,0,0,0.8)'
                }}
            >
                {icon}
            </div>
        </div>
    )
}, (prevProps, nextProps) => {
    // Rerenderuj tylko gdy wartość się zmieni
    return prevProps.value === nextProps.value && prevProps.label === nextProps.label;
});

CharacterStat.displayName = 'CharacterStat';
