import { useEffect, useState } from "react";

import Header from "./components/Header/Header";
import ItemView from "./components/ItemView/ItemView";
import RecipeList from "./components/RecipeList/RecipeList";

import { useUserStore } from "./store/useUserStore";
import { useRecipesStore } from "./store/useRecipesStore";

import "./App.css";

const App = () => {
    const [display, setDisplay] = useState(false);
    const { setRecipes } = useRecipesStore();
    const { setProfile, setInventory, setMugshot } = useUserStore();
    
    const handleMessageEvent = (e: MessageEvent) => {
        const data = e.data;

        switch (data.action) {
            case "init":
                setRecipes(data.payload.recipes);
                break;

            case "changeDisplay": 
                if (data.payload.display && data.payload.inventory && data.payload.profile) {
                    setProfile(data.payload.profile);
                    setInventory(data.payload.inventory);
                    if (data.payload.mugshot) {
                        setMugshot(data.payload.mugshot);
                    }
                }
                setDisplay(data.payload.display);
                break;

            case "craftingStarted":
                break;

            case "craftingComplete":
                if (data.payload) {
                    setProfile({
                        ...data.payload.profile || {},
                        level: data.payload.level,
                        xp: data.payload.xp,
                        levelProgress: data.payload.levelProgress
                    });
                }
                break;

            case "updateInventory":
                if (data.payload && data.payload.inventory) {
                    setInventory(data.payload.inventory);
                }
                break;
        }
    };

    useEffect(() => {
        window.addEventListener("message", handleMessageEvent);
        
        const handleEscape = (e: KeyboardEvent) => {
            if (e.key === "Escape" && display) {
                fetch(`https://${(window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'crafting_system'}/escape`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            }
        };

        window.addEventListener("keydown", handleEscape);

        return () => {
            window.removeEventListener("message", handleMessageEvent);
            window.removeEventListener("keydown", handleEscape);
        };
    }, [display]);

    return (
        display && (
            <main>
                <Header />
                <div className="content">
                    <RecipeList />
                    <ItemView />
                </div>
            </main>
        )
    );
};

export default App;