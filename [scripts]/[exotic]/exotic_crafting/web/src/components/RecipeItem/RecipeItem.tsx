import { useRecipesStore } from "../../store/useRecipesStore";
import { useUserStore } from "../../store/useUserStore";
import type { Recipe } from "../../types";
import "./RecipeItem.css";

interface RecipeItemProps {
    recipe: Recipe;
}

const RecipeItem = ({ recipe }: RecipeItemProps) => {
    const { profile } = useUserStore();
    const { selectedRecipe, selectRecipe } =  useRecipesStore();

    const disabled = profile.level < recipe.requiredLevel;
    const active = selectedRecipe?.itemName == recipe.itemName; 
    
    return (
        <div 
            className={`recipe ${active && "active"} ${disabled && "disabled"}`} 
            onClick={() => {
                if (disabled || active) return;
                selectRecipe(recipe);
            }}
        >
            <img src={`nui://ox_inventory/web/images/${recipe.itemName}.webp`} alt="" />
            <span>
                <p>{recipe.label}</p>
                <p>{recipe.shortDescription}</p>
            </span>
            <p className="recipe__level">
                LEVEL {recipe.requiredLevel}
            </p>
        </div>
    );
};

export default RecipeItem;
