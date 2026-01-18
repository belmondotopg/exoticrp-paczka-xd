import { useRecipesStore } from "../../store/useRecipesStore"
import RecipeItem from "../RecipeItem/RecipeItem";
import "./RecipeList.css";

const RecipeList = () => {
    const { recipes } = useRecipesStore();

    return (
        <div className="recipeList">
            <p>Wszystkie receptury</p>

            <div className="recipes">
                {recipes?.map((recipe) => (
                    <RecipeItem
                        key={recipe.itemName}
                        recipe={recipe}
                    />
                ))}
            </div>
        </div>
    )
}

export default RecipeList;