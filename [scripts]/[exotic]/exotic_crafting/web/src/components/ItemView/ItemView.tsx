import { useState, useEffect } from "react";
import { useRecipesStore } from "../../store/useRecipesStore";
import { useUserStore } from "../../store/useUserStore";
import { fetchNui } from "../../utils/fetchNui";
import CraftItem from "../CraftItem/CraftItem";
import "./ItemView.css";

const ItemView = () => {
    const [isPending, setIsPending] = useState(false);
    const { inventory, profile } = useUserStore();
    const { selectedRecipe } = useRecipesStore();
    
    useEffect(() => {
        const handleMessage = (e: MessageEvent) => {
            if (e.data.action === "craftingStarted") {
                setIsPending(true);
            } else if (e.data.action === "craftingComplete" || e.data.action === "updateInventory") {
                setIsPending(false);
            }
        };
        
        window.addEventListener("message", handleMessage);
        return () => window.removeEventListener("message", handleMessage);
    }, []);
    
    if (!selectedRecipe) {
        return (
            <div className="noSelectedItem">
                <p className="heading">NIE WYBRANO RECEPTURY</p>
                <p className="desc">
                    Z panelu po lewej stronie wybierz interesującą cię recepturę 
                    aby wytworzyć przedmiot. Po wybraniu wyświetli ci się więcej informacji o danej recepturze.
                </p>
            </div>
        );
    }

    const canCraft = Object.entries(selectedRecipe.craftItems)
        .every(([name, data]) => (inventory[name] || 0) >= data.quantity) && 
        profile.level >= selectedRecipe.requiredLevel;

    const handleCraft = async () => {
        if (!canCraft || isPending) return;
        
        try {
            await fetchNui("craftItem", { itemName: selectedRecipe.itemName });
        } catch (error) {
            console.error("Crafting error:", error);
            setIsPending(false);
        }
    };

    return (
        <div className="itemView">
            <div className="itemView__heading">
                <p>Aktualnie wybrany przedmiot</p>
                <h2>{selectedRecipe.label}</h2>
                <p>{selectedRecipe.fullDescription}</p>
            </div>

            <div className="itemView__craftItems">
                {Object.entries(selectedRecipe.craftItems).map(([name, data]) => {
                    const owned = inventory[name] || 0;
                    return (
                        <CraftItem 
                            key={name}
                            name={name} 
                            label={data.label}
                            amount={data.quantity} 
                            owned={owned}
                        />
                    );
                })}
            </div>

            <button 
                disabled={!canCraft || isPending}
                onClick={handleCraft}
            >
                {isPending ? "Trwa wytwarzanie przedmiotu..." : "Kliknij aby wytworzyć przedmiot"}
            </button>

            <img 
                src={`nui://ox_inventory/web/images/${selectedRecipe.itemName}.webp`} 
                alt={selectedRecipe.label} 
                className="itemView__image" 
            />
        </div>
    );
}

export default ItemView;