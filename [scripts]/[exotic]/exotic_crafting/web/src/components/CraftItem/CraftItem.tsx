import { useState } from "react";
import "./CraftItem.css";

interface CraftItemProps {
    name: string;
    label: string;
    amount: number;
    owned: number;
}

const CraftItem = ({ name, label, amount, owned }: CraftItemProps) => {
    const [isHovered, setIsHovered] = useState(false);
    const enough = owned >= amount;
    
    return (
        <div 
            className={`craftItem ${enough ? "enough" : "notenough"}`}
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={() => setIsHovered(false)}
        >
            <img
                className="craftItem__image"
                src={`nui://ox_inventory/web/images/${name}.webp`}
                alt={name}
            />
            <p className="craftItem__quantity">
                {owned}/{amount}
            </p>

            {isHovered && (
                <p className="tooltip">{label}</p>
            )}
        </div>
    );
}

export default CraftItem;
