var housingresourcename = "rtx_housing";

const state = {
   currentMenu: null,
   isLocked: true,
   lightsOn: true,
   deliveries: [],
   apartments: [],
   context: {
      propertyName: "",
      propertyAddress: "",
      description: "",
      complexDescription: "",
      hasGarage: false,
      hasWardrobe: false,
      hasStorage: false,
      furnitureEnabledOutside: false,
      furnitureEnabledInside: false,
      hasDoorbell: false,
      isOwnerOrHasKeys: false,
      canUseFurniture: false,
      canManageDeliveries: false,
      hasLockpick: false,
      isPolice: false,
      isRentable: true,
      isPurchasable: true,
      SmartHome: false,
      isMlo: false
   },
   prices: {
      purchasePrice: 0,
      rentPrice: 0,
      rentIntervalLabel: "month",
      electricityPrice: 0,
      electricityRate: "",
      waterPrice: 0,
      waterRate: "",
      internetPrice: 0,
      internetRate: ""
   },
   pendingPurchaseMode: null
};

const money = n => {
   const num = Number(n);
   if (!isFinite(num)) return "$0";
   return "$ " + num.toString();
};

const money2 = n => {
   const num = Number(n);
   if (!isFinite(num)) return "$0";
   return "$" + num.toString();
};

function closeMain() {
   $("body").css("display", "none");
}

function openMain() {
   $("body").css("display", "block");
}

function sendNui(action, data) {
   try {
      const endpoint = "https://" + housingresourcename + "/" + action;
      const payload = JSON.stringify(data || {});


      $.post(endpoint, payload);

   } catch (e) {}
}

function showRoot() {
   $("#housing-app").css("display", "flex");
}

function hideRoot() {
   $("#housing-app").css("display", "none");
}

function setMode(label) {
   $("#chip-mode-text").text(label);
}

function showMenu(name) {
   state.currentMenu = name;
   $(".hsui-menu").each(function () {
      const isActive = this.id === "menu-" + name;
      $(this).toggleClass("hsui-menu-active", isActive);
   });

   if (name === "enter") setMode("Wejście");
   else if (name === "exit") setMode("Wewnątrz");
   else if (name === "purchase") setMode("Zakup");
   else if (name === "apartments") setMode("Mieszkania");
   else if (name === "mlo") setMode("Interakcje");

   if (name === "enter" || name === "exit") {
      $("#chip-lock").css("display", "inline-flex");
   } else {
      $("#chip-lock").css("display", "none");
   }
}

function updateHeader() {
   $("#header-name").text(state.context.propertyName || "Nieruchomość");
   $("#header-address").text(state.context.propertyAddress || "—");
}

function updateLock(locked) {
   state.isLocked = !!locked;
   const text = locked ? "Zamknięte" : "Otwarte";
   $("#chip-lock-text").text(text);
   const $chip = $("#chip-lock");
   $chip.toggleClass("hsui-status-chip-lock-bad", locked);
   $chip.toggleClass("hsui-status-chip-lock-ok", !locked);
}

function updateLights(on) {
   state.lightsOn = !!on;
}

function openModal(id) {
   $("#" + id).addClass("hsui-modal-visible");
}

function closeModal(id) {
   $("#" + id).removeClass("hsui-modal-visible");
}

function closeAllModals() {
   $(".hsui-modal-visible").removeClass("hsui-modal-visible");
}

function renderDeliveries(list) {
   state.deliveries = Array.isArray(list) ? list : [];
   const $wrap = $("#deliveries-list");
   if (!$wrap.length) return;

   if (!state.deliveries.length) {
      $wrap.html('<div class="hsui-list-note">Brak oczekujących dostaw.</div>');
      return;
   }

   const html = state.deliveries.map(d => {
      const title = d.title || d.label || "Dostawa";
      const note = d.note || d.description || "";
      const id = d.id != null ? d.id : "";
      return `
		<div class="hsui-list-item">
		  <div class="hsui-list-main">
			<span style="font-weight:700;">${title}</span>
		  </div>
		  <div class="hsui-actions-row">
			<button class="hsui-button hsui-button-primary hsui-delivery-accept" data-id="${id}">
			  <i class="fa-solid fa-check"></i> Akceptuj
			</button>
			<button class="hsui-button hsui-delivery-reject" data-id="${id}">
			  <i class="fa-solid fa-xmark"></i> Odrzuć
			</button>
		  </div>
		</div>`;
   }).join("");

   $wrap.html(html);
}

function renderApartments(list) {
   state.apartments = Array.isArray(list) ? list : [];
   $("#apartment-count").text(String(state.apartments.length));
   const $wrap = $("#apartment-list");
   if (!$wrap.length) return;

   if (!state.apartments.length) {
      $wrap.html('<div class="hsui-list-note">Brak dostępnych mieszkań.</div>');
      return;
   }

	const html = state.apartments.map(a => {
		const owned = !!a.isOwnedByPlayer;
		const label = a.label;

		let status = "Do Wynajęcia";
		if (owned) {
			status = "Własność";
		} else if (a.forsale === true) {
			status = "Na Sprzedaż";
		}

		return `
			<div class="hsui-list-item">
				<div class="hsui-list-main">
					<span class="hsui-list-text">${label}</span>
					<span class="hsui-list-note">${status}</span>
				</div>
				<button class="hsui-button hsui-button-primary hsui-apartment-view" data-id="${a.id}">
					<i class="fa-solid fa-eye"></i> Zobacz
				</button>
			</div>
		`;
	}).join("");


   $wrap.html(html);
}


function openEnterMenu(options) {
   options = options || {};
   showRoot();

   state.context.propertyName = options.propertyName || state.context.propertyName || "Nieruchomość";
   state.context.propertyAddress = options.propertyAddress || state.context.propertyAddress || "";
   state.context.hasDoorbell = !!options.hasDoorbell;
   state.context.isOwnerOrHasKeys = !!options.isOwnerOrHasKeys;
   state.context.isMlo = !!options.isMlo;

   const mergedFurniturePerm = !!(options.canUseFurniture || options.hasPermissions);
   state.context.canUseFurniture = mergedFurniturePerm;

   state.context.hasLockpick = !!options.hasLockpick;
   state.context.isPolice = !!options.isPolice;
   state.context.furnitureEnabledOutside = !!options.furnitureEnabledOutside;

   if (state.context.isOwnerOrHasKeys) {
      state.context.canUseFurniture = true;
   }

   updateHeader();
   updateLock(typeof options.isLocked === "boolean" ? options.isLocked : state.isLocked);

   const $knockBtn = $("#enter-knock");
   if (state.context.hasDoorbell) {
      $knockBtn.html('<i class="fa-solid fa-bell"></i> Zadzwoń');
   } else {
      $knockBtn.html('<i class="fa-regular fa-hand-back-fist"></i> Zapukaj');
   }

   const noKeys = !state.context.isOwnerOrHasKeys;

   $("#enter-right-note").text("");

   $("#enter-lock-toggle").toggle(state.context.isOwnerOrHasKeys);

   const canOutsideFurniture =
      state.context.furnitureEnabledOutside &&
      (state.context.isOwnerOrHasKeys || state.context.canUseFurniture);

   $("#enter-furniture-outside").toggle(canOutsideFurniture);

   $("#enter-lockpick").toggle(noKeys && state.context.hasLockpick);

   $("#enter-raid").toggle(noKeys && state.context.isPolice);
   if (state.context.isMlo) {
      $("#enter-main").hide();
   } else {
      $("#enter-main").show();
   }

   showMenu("enter");
}

function openExitMenu(options) {
   options = options || {};
   showRoot();

   state.context.propertyName = options.propertyName || state.context.propertyName || "Nieruchomość";
   state.context.propertyAddress = options.propertyAddress || state.context.propertyAddress || "";
   state.context.isOwnerOrHasKeys = !!options.isOwnerOrHasKeys;

   const mergedFurniturePerm = !!(options.canUseFurniture || options.hasPermissions);
   const mergedDeliveryPerm = !!(options.canManageDeliveries || options.hasPermissions);

   state.context.canUseFurniture = mergedFurniturePerm;
   state.context.canManageDeliveries = mergedDeliveryPerm;
   state.context.furnitureEnabledInside = !!options.furnitureEnabledInside;
   state.context.SmartHome = !!options.SmartHome;

   if (state.context.isOwnerOrHasKeys) {
      state.context.canUseFurniture = true;
      state.context.canManageDeliveries = true;
   }

   updateHeader();
   updateLock(typeof options.isLocked === "boolean" ? options.isLocked : state.isLocked);
   updateLights(typeof options.lightsOn === "boolean" ? options.lightsOn : state.lightsOn);

   $("#exit-lock-toggle").toggle(state.context.isOwnerOrHasKeys);

   const canInsideFurniture =
      state.context.furnitureEnabledInside &&
      (state.context.isOwnerOrHasKeys || state.context.canUseFurniture);

   $("#exit-furniture-inside").toggle(canInsideFurniture);

   const canDeliveries =
      (state.context.isOwnerOrHasKeys || state.context.canManageDeliveries);

   $("#exit-deliveries").toggle(canDeliveries);

   if (state.context.SmartHome) {
      $("#exit-cam").show();
      $("#exit-cam").toggle(state.context.isOwnerOrHasKeys);
   } else {
      $("#exit-cam").hide();
   }

   renderDeliveries(options.deliveries || state.deliveries || []);

   showMenu("exit");
}

function openMloMenu(options) {
   options = options || {};
   showRoot();

   state.context.propertyName = options.propertyName || state.context.propertyName || "Nieruchomość";
   state.context.propertyAddress = options.propertyAddress || state.context.propertyAddress || "";
   state.context.isOwnerOrHasKeys = !!options.isOwnerOrHasKeys;

   const mergedFurniturePerm = !!(options.canUseFurniture || options.hasPermissions);
   const mergedDeliveryPerm = !!(options.canManageDeliveries || options.hasPermissions);

   state.context.canUseFurniture = mergedFurniturePerm;
   state.context.hasDoorbell = !!options.hasDoorbell;
   state.context.canManageDeliveries = mergedDeliveryPerm;
   state.context.furnitureEnabledOutside = !!options.furnitureEnabledOutside;
   state.context.hasLockpick = !!options.hasLockpick;
   state.context.isPolice = !!options.isPolice;


   if (state.context.isOwnerOrHasKeys) {
      state.context.canUseFurniture = true;
      state.context.canManageDeliveries = true;
   }

   updateHeader();

   const canOutsideFurniture =
      state.context.furnitureEnabledOutside &&
      (state.context.isOwnerOrHasKeys || state.context.canUseFurniture);

   $("#mlo-furniture").toggle(canOutsideFurniture);

   const $knockBtn = $("#mlo-knock");
   if (state.context.hasDoorbell) {
      $knockBtn.html('<i class="fa-solid fa-bell"></i> Zadzwoń');
   } else {
      $knockBtn.html('<i class="fa-regular fa-hand-back-fist"></i> Zapukaj');
   }

   const noKeys = !state.context.isOwnerOrHasKeys;
   $("#mlo-lockpick").toggle(noKeys && state.context.hasLockpick);

   $("#mlo-raid").toggle(noKeys && state.context.isPolice);

   const canDeliveries =
      (state.context.isOwnerOrHasKeys || state.context.canManageDeliveries);

   $("#mlo-deliveries").toggle(canDeliveries);

   renderDeliveries(options.deliveries || state.deliveries || []);

   showMenu("mlo");
}


function openPurchasePropertyMenu(options) {
   options = options || {};
   showRoot();

   state.context.propertyName = options.propertyName || state.context.propertyName || "Nieruchomość";
   state.context.propertyAddress = options.propertyAddress || state.context.propertyAddress || "";
   state.context.description = options.description || "";
   state.context.hasGarage = !!options.hasGarage;
   state.context.hasWardrobe = !!options.hasWardrobe;
   state.context.hasStorage = !!options.hasStorage;
   state.context.furnitureEnabledInside = !!options.furnitureEnabledInside;
   state.context.furnitureEnabledOutside = !!options.furnitureEnabledOutside;

   state.context.isMlo =
      (typeof options.isMlo === "boolean") ? options.isMlo : state.context.isMlo;


   state.context.isRentable = (typeof options.isRentable === "boolean") ? options.isRentable : true;

   state.context.isPurchasable = (typeof options.isPurchasable === "boolean") ? options.isPurchasable : true;

   state.prices.purchasePrice = options.purchasePrice || 0;
   state.prices.rentPrice = options.rentPriceMonthly || 0;


   state.prices.rentIntervalLabel =
      options.rentIntervalLabel ||
      options.rentPeriodLabel ||
      options.rentInterval ||
      state.prices.rentIntervalLabel ||
      "month";
   state.prices.electricityPrice = options.electricityPrice || state.prices.electricityPrice || 0;
   state.prices.electricityRate = options.electricityRate || state.prices.electricityRate || "";
   state.prices.waterPrice = options.waterPrice || state.prices.waterPrice || 0;
   state.prices.waterRate = options.waterRate || state.prices.waterRate || "";
   state.prices.internetPrice = options.internetPrice || state.prices.internetPrice || 0;
   state.prices.internetRate = options.internetRate || state.prices.internetRate || "";

   updateHeader();

   $("#purchase-price").text(money(state.prices.purchasePrice));

   const rentLabel = state.prices.rentIntervalLabel || "month";

   if (state.context.isRentable) {
      $("#purchase-rent-block").show();

      const rentLabel = state.prices.rentIntervalLabel || "month";
      const rentFormatted = `${money(state.prices.rentPrice)} / ${rentLabel}`;

      $("#purchase-rent").text(rentFormatted);
   } else {
      $("#purchase-rent-block").hide();
   }

   if (state.context.isPurchasable) {
      $("#purchase-block").show();
      $("#purchase-divider").show();
   } else {
      $("#purchase-block").hide();
      $("#purchase-divider").hide();
   }

   $("#util-modal-electricity").text(money(state.prices.electricityPrice));
   $("#util-modal-electricity-rate").text(state.prices.electricityRate || "—");
   $("#util-modal-water").text(money(state.prices.waterPrice));
   $("#util-modal-water-rate").text(state.prices.waterRate || "—");
   $("#util-modal-internet").text(money(state.prices.internetPrice));
   $("#util-modal-internet-rate").text(state.prices.internetRate || "—");

   if (state.context.isMlo) {
      $("#purchase-view").hide();
   } else {
      $("#purchase-view").show();
   }
   showMenu("purchase");
}

function openApartmentComplexMenu(options) {
   options = options || {};
   showRoot();

   state.context.propertyName = options.complexName || options.propertyName || "Kompleks mieszkaniowy";
   state.context.propertyAddress = options.complexAddress || options.propertyAddress || "";
   state.context.complexDescription = options.complexDescription || "";


   updateHeader();
   const apartmentsList = Array.isArray(options.apartments) ?
      options.apartments :
      Object.values(options.apartments || {});

   renderApartments(apartmentsList);

   showMenu("apartments");
}


$(function () {

   $("#btnClose").on("click", () => {
      hideRoot();
      sendNui("closeproperty", {});
   });


   $("#enter-main").on("click", () => sendNui("enter", {
      context: state.context
   }));
   $("#enter-knock").on("click", () => {
      const type = state.context.hasDoorbell ? "doorbell" : "knock";
      sendNui("knockOrRing", {
         type,
         context: state.context
      });
   });
   $("#enter-lock-toggle").on("click", () => {
      sendNui("lockstatus", {});
   });
   $("#enter-furniture-outside").on("click", () => {
      hideRoot();
      sendNui("furnitureOutside", {
         context: state.context
      });
   });
   $("#exit-cam").on("click", () => {
      hideRoot();
      sendNui("doorcam", {
         context: state.context
      });
   });
   $("#mlo-furniture").on("click", () => {
      hideRoot();
      sendNui("furnitureOutside", {
         context: state.context
      });
   });
   $("#enter-lockpick").on("click", () => {
      hideRoot();
      sendNui("lockpick", {
         context: state.context
      });
   });
   $("#enter-raid").on("click", () => {
      hideRoot();
      sendNui("raid", {
         context: state.context
      });
   });

   $("#exit-main").on("click", () => sendNui("exit", {
      context: state.context
   }));
   $("#exit-lock-toggle").on("click", () => {
      sendNui("lockstatus", {});
   });
   $("#exit-lights-toggle").on("click", () => {
      sendNui("lightstatus", {});
   });
   $("#exit-furniture-inside").on("click", () => {
      hideRoot();
      sendNui("furnitureInside", {
         context: state.context
      });
   });
   $("#exit-deliveries").on("click", () => openModal("modal-deliveries"));

   $("#deliveries-list").on("click", ".hsui-delivery-accept", function () {
      const id = $(this).data("id");
      sendNui("deliveryAccept", {
         id,
         context: state.context
      });
      state.deliveries = state.deliveries.filter(d => String(d.id) !== String(id));
      renderDeliveries(state.deliveries);
   });

   $("#deliveries-list").on("click", ".hsui-delivery-reject", function () {
      const id = $(this).data("id");
      sendNui("deliveryReject", {
         id,
         context: state.context
      });
      state.deliveries = state.deliveries.filter(d => String(d.id) !== String(id));
      renderDeliveries(state.deliveries);
   });

   $("#mlo-knock").on("click", () => {
      const type = state.context.hasDoorbell ? "doorbell" : "knock";
      sendNui("knockOrRing", {
         type,
         context: state.context
      });
   });
   $("#mlo-lockpick").on("click", () => {
      hideRoot();
      sendNui("lockpick", {
         context: state.context
      });
   });
   $("#mlo-raid").on("click", () => {
      hideRoot();
      sendNui("raid", {
         context: state.context
      });
   });
   $("#mlo-inside").on("click", () => sendNui("furnitureMlo", {
      context: state.context
   }));
   $("#mlo-deliveries").on("click", () => openModal("modal-deliveries"));


   $("#purchase-description").on("click", () => {
      $("#modal-description-title").text("Informacje o nieruchomości");

      const d = state.context;
      const desc = d.description ?
         `<p>${d.description}</p>` :
         '<p class="hsui-list-note">Brak dostępnego opisu.</p>';

      const boolLabel = v => v ? "Tak" : "Nie";

      const features = `
		<div class="hsui-list" style="margin-top:6px;">
		  <div class="hsui-list-item">
			<div class="hsui-list-main"><span>Garaż</span></div>
			<span class="hsui-list-note">${boolLabel(d.hasGarage)}</span>
		  </div>
		  <div class="hsui-list-item">
			<div class="hsui-list-main"><span>Szafa</span></div>
			<span class="hsui-list-note">${boolLabel(d.hasWardrobe)}</span>
		  </div>
		  <div class="hsui-list-item">
			<div class="hsui-list-main"><span>Magazyn</span></div>
			<span class="hsui-list-note">${boolLabel(d.hasStorage)}</span>
		  </div>
		  <div class="hsui-list-item">
			<div class="hsui-list-main"><span>Meble wewnętrzne</span></div>
			<span class="hsui-list-note">${boolLabel(d.furnitureEnabledInside)}</span>
		  </div>
		  <div class="hsui-list-item">
			<div class="hsui-list-main"><span>Meble zewnętrzne</span></div>
			<span class="hsui-list-note">${boolLabel(d.furnitureEnabledOutside)}</span>
		  </div>
		</div>`;

      $("#modal-description-body").html(desc + features);
      openModal("modal-description");
   });

   $("#purchase-utilities").on("click", () => openModal("modal-utilities"));
   $("#purchase-view").on("click", () => openModal("modal-view"));
   $("#view-btn-confirm").on("click", () => {
      hideRoot();
      closeModal("modal-view");
      sendNui("viewProperty", {
         mode: "view",
         context: state.context
      });
   });

   $("#purchase-buy-btn").on("click", () => {
      if (!state.context.isPurchasable) return;
      state.pendingPurchaseMode = "buy";
      $("#modal-purchase-title").text("Kup nieruchomość");
      $("#modal-purchase-body").html(
         `<p>Czy chcesz kupić tę nieruchomość za <b>${money2(state.prices.purchasePrice)}</b>?</p>`
      );
      openModal("modal-purchase");
   });

   $("#purchase-rent-btn").on("click", () => {
      if (!state.context.isRentable) return;
      state.pendingPurchaseMode = "rent";
      const periodLabel = state.prices.rentIntervalLabel || "miesiąc";
      $("#modal-purchase-title").text("Wynajmij nieruchomość");
      $("#modal-purchase-body").html(
         `<p>Czy chcesz wynająć tę nieruchomość za <b>${money2(state.prices.rentPrice)}</b> na ${periodLabel}?</p>`
      );
      openModal("modal-purchase");
   });

   $("#modal-purchase-yes").on("click", () => {
      const mode = state.pendingPurchaseMode;
      closeModal("modal-purchase");
      if (!mode) return;
      const price = mode === "buy" ? state.prices.purchasePrice : state.prices.rentPrice;
      sendNui("acquireProperty", {
         mode: mode === "buy" ? "purchase" : "rent",
         price,
         context: state.context
      });
      state.pendingPurchaseMode = null;
      hideRoot();
   });


   $("#apartments-info").on("click", () => {
      $("#modal-description-title").text("Opis kompleksu");
      $("#modal-description-body").html(
         state.context.complexDescription || '<span class="hsui-list-note">Brak dostępnego opisu.</span>'
      );
      openModal("modal-description");
   });

   $("#apartment-list").on("click", ".hsui-apartment-view", function () {
      const id = $(this).data("id");
      const apt = state.apartments.find(a => String(a.id) === String(id));
      if (!apt) return;
      hideRoot();

      sendNui("selectedapartment", {
         apartmentid: apt.id
      });
   });


   $("[data-modal-close]").each(function () {
      const modalId = $(this).data("modalClose");
      $(this).on("click", () => closeModal(modalId));
   });

   $(".hsui-modal").on("click", function (e) {
      if (e.target === this) {
         $(this).removeClass("hsui-modal-visible");
      }
   });
});

window.addEventListener("message", function (event) {
   const item = event.data;
   if (item.message === "PropertyEnter") {
      openMain();
      openEnterMenu(item.options || {});
   }

   if (item.message === "PropertyExit") {
      openMain();
      openExitMenu(item.options || {});
   }

   if (item.message === "PropertyPurchase") {
      openMain();
      openPurchasePropertyMenu(item.options || {});
   }

   if (item.message === "PropertyApartmentComplex") {
      openMain();
      openApartmentComplexMenu(item.options || {});
   }

   if (item.message === "PropertyHide") {
      hideRoot();
      closeAllModals();
   }


   if (item.message === "PropertyMlo") {
      openMain();
      openMloMenu(item.options || {});
   }

   if (item.message === "lockupdate") {
      updateLock(item.lockstate);
   }

});