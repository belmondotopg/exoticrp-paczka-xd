var housingresourcename = "rtx_housing";

let COOKING_STATE = {
   stationLabel: "Kitchen",
   stationName: "Property Kitchen",
   recipes: []
};

let selectedRecipeId = null;
let demoProgressTimer = null;
let currentProgressPercent = 0;

function nuiPost(action, data) {
   try {
      const endpoint = "https://" + housingresourcename + "/" + action;
      const payload = JSON.stringify(data || {});


      $.post(endpoint, payload);

   } catch (e) {}
}

function renderRecipeList() {
   const $list = $("#cook-recipe-list").empty();
   const recipes = COOKING_STATE.recipes || [];
   const recipeText = recipes.length === 1 ? "przepis" : recipes.length < 5 ? "przepisy" : "przepisów";
   $("#cook-recipe-count").text(recipes.length + " " + recipeText);

   recipes.forEach((recipe) => {
      const $item = $(`
	<div class="cook-recipe-item" data-recipe-id="${recipe.id}">
	  <div class="cook-recipe-main">
		<div class="cook-recipe-name">${recipe.title}</div>
		<div class="cook-recipe-meta">
		  <span>${recipe.description}</span>
		</div>
	  </div>
	  <div class="cook-recipe-time">
		<i class="fa-regular fa-clock"></i>
		<span>${formatTime(recipe.time)}</span>
	  </div>
	</div>
  `);

      $item.on("click", function () {
         selectRecipe(recipe.id);
      });

      $list.append($item);
   });


   if (!selectedRecipeId && recipes.length > 0) {
      selectRecipe(recipes[0].id);
   } else {
      highlightSelectedRecipe();
   }
}

function highlightSelectedRecipe() {
   $(".cook-recipe-item").removeClass("cook-recipe-item-active");
   if (!selectedRecipeId) return;
   $(`.cook-recipe-item[data-recipe-id="${selectedRecipeId}"]`).addClass("cook-recipe-item-active");
}

function selectRecipe(recipeId) {
   const recipe = (COOKING_STATE.recipes || []).find(r => r.id === recipeId);
   selectedRecipeId = recipeId;
   highlightSelectedRecipe();

   if (!recipe) {
      $("#cook-detail-body").hide();
      $("#cook-detail-empty").show();
      $("#cook-btn-start").prop("disabled", true);
      $("#cook-detail-difficulty").text("Wybierz przepis");
      return;
   }

   $("#cook-detail-empty").hide();
   $("#cook-detail-body").show();

   $("#cook-detail-name").text(recipe.title || "Przepis");
   $("#cook-detail-description").text(recipe.description || "Brak opisu.");
   $("#cook-detail-time").text(formatTime(recipe.time));

   const $ing = $("#cook-ingredients-list").empty();
   (recipe.ingredients || []).forEach((ing, index) => {
      const id = ing.itemId || ("item_" + index);
      const label = ing.label || id;
      const amount = ing.amount || 1;


      const hasItem = (typeof ing.hasItem === "boolean") ? ing.hasItem : true;
      const missingClass = hasItem ? "" : " cook-ingredient-missing";

      const $row = $(`
	<li class="cook-ingredient-item${missingClass}">
	  <div class="cook-ingredient-main">
		<div class="cook-badge-small"><i class="fa-solid fa-utensils"></i></div>
		<span class="cook-ingredient-name">${label}</span>
	  </div>
	  <span class="cook-ingredient-amount">${amount}x</span>
	</li>
  `);

      $ing.append($row);
   });

   $("#cook-btn-start").prop("disabled", false);
   $("#cook-detail-hint").text("Naciśnij Rozpocznij gotowanie, aby zacząć. Możesz anulować z ekranu postępu.");
}

function formatTime(ms) {
   const totalSeconds = ms
   if (totalSeconds <= 0) return "Natychmiast";
   if (totalSeconds < 60) return totalSeconds + "s";
   const minutes = Math.floor(totalSeconds / 60);
   const seconds = totalSeconds % 60;
   return minutes + "m " + (seconds > 0 ? seconds + "s" : "");
}


function openCookingUI() {
   $("#cooking-app").show();
}

function closeCookingUI() {
   $("#cooking-app").hide();
   nuiPost("cook_ui_closed", {});
}


$("#cook-btn-close").on("click", function () {
   closeCookingUI();
});

$("#cook-btn-start").on("click", function () {
   if (!selectedRecipeId) return;
   const recipe = (COOKING_STATE.recipes || []).find(r => r.id === selectedRecipeId);
   nuiPost("cook_start", {
      recipeId: selectedRecipeId,
   });
});

window.addEventListener("message", function (event) {
   const item = event.data || {};


   if (item.message === "CookingOpen") {
      if (Array.isArray(item.recipes)) COOKING_STATE.recipes = item.recipes;

      renderRecipeList();
      openCookingUI();
   }


   if (item.message === "CookingClose") {
      $("#cooking-app").hide();
   }
});