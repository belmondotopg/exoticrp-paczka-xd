const PM_RESOURCE = "rtx_housing";

const PM_FALLBACK_IMAGE = "img/noimage.webp";

const PM_FALLBACK_IMAGE2 = "img/noimage2.webp";

const PM_EVENTS = {
   closeMenu: "property_market_close",
   refresh: "property_market_request_data",
   gps: "property_market_mark_gps",
   buy: "property_market_buy",
   rent: "property_market_rent",
   view: "property_market_view"
};

function pmPost(event, data) {
   $.post(`https://${PM_RESOURCE}/${event}`, JSON.stringify(data || {}));
}

const PM_STATE = {
   properties: [],
   filtered: [],
   selectedId: null,
   filters: {
      query: "",
      status: "all",
      seller: "all",
      type: "all",
      minPrice: null,
      maxPrice: null
   }
};

const pmMoney = n => "$" + Number(n || 0).toLocaleString();


function pmDemoProperties() {
   return [{
         id: "p1",
         name: "Luxury Hillside Mansion",
         address: "Vinewood Hills, Hillside Dr",
         type: "MLO",
         forSale: true,
         salePrice: 2200000,
         forRent: true,
         rentPrice: 12000,
         rentIntervalLabel: "week",
         seller: {
            kind: "agency",
            name: "Dynasty 8"
         },
         description: "A modern hillside villa with infinity pool, large garage and cinematic views over the city.",
         hasGarage: true,
         hasWardrobe: true,
         hasStorage: true,
         furnitureEnabledInside: true,
         furnitureEnabledOutside: true,
         electricityPrice: 250,
         electricityRate: "per billing cycle",
         waterPrice: 120,
         waterRate: "per billing cycle",
         internetPrice: 90,
         internetRate: "per month",
         images: [
            "https://picsum.photos/seed/mansion1/900/450",
            "https://picsum.photos/seed/mansion2/900/450",
            "https://picsum.photos/seed/mansion3/900/450"
         ]
      },
      {
         id: "p2",
         name: "Mirror Park Family Home",
         address: "Mirror Park Blvd",
         type: "SHELL",
         forSale: true,
         salePrice: 350000,
         forRent: false,
         rentPrice: null,
         seller: {
            kind: "player",
            name: "Nina Inou",
            phone: "555-0199"
         },
         description: "Cozy shell interior with backyard and two parking spots. Perfect starter home.",
         hasGarage: false,
         hasWardrobe: true,
         hasStorage: true,
         furnitureEnabledInside: true,
         furnitureEnabledOutside: false,
         electricityPrice: 160,
         electricityRate: "per billing cycle",
         waterPrice: 90,
         waterRate: "per billing cycle",
         internetPrice: 70,
         internetRate: "per month",
         images: [
            "https://picsum.photos/seed/shell1/900/450",
            "https://picsum.photos/seed/shell2/900/450"
         ]
      },
      {
         id: "p3",
         name: "Del Perro Apartment #21",
         address: "Del Perro, Bay City Ave",
         type: "IPL",
         forSale: false,
         salePrice: null,
         forRent: true,
         rentPrice: 2800,
         rentIntervalLabel: "month",
         seller: {
            kind: "agency",
            name: "Dynasty 8"
         },
         description: "High floor apartment with ocean view. Access to building gym and shared rooftop.",
         hasGarage: false,
         hasWardrobe: true,
         hasStorage: false,
         furnitureEnabledInside: true,
         furnitureEnabledOutside: false,
         electricityPrice: 210,
         electricityRate: "per billing cycle",
         waterPrice: 110,
         waterRate: "per billing cycle",
         internetPrice: 80,
         internetRate: "per month",
         images: [
            "https://picsum.photos/seed/apt1/900/450",
            "https://picsum.photos/seed/apt2/900/450"
         ]
      }
   ];
}


function pmApplyFilters() {
   const f = PM_STATE.filters;
   const q = (f.query || "").toLowerCase();

   PM_STATE.filtered = PM_STATE.properties.filter(p => {
      const hasSale = !!p.forSale && p.salePrice != null;
      const hasRent = !!p.forRent && p.rentPrice != null;

      if (q) {
         const hay = (p.name + " " + p.address).toLowerCase();
         if (!hay.includes(q)) return false;
      }

      if (f.status === "sale" && !hasSale) return false;
      if (f.status === "rent" && !hasRent) return false;
      if (f.status === "sale_or_rent" && !(hasSale || hasRent)) return false;
      if (f.status === "rent_only" && (hasSale || !hasRent)) return false;

      if (f.seller === "agency" && p.seller?.kind !== "agency") return false;
      if (f.seller === "player" && p.seller?.kind !== "player") return false;

      if (f.type !== "all" && p.type !== f.type) return false;

      if (f.minPrice != null && hasSale && p.salePrice < f.minPrice) return false;
      if (f.maxPrice != null && hasSale && p.salePrice > f.maxPrice) return false;

      return true;
   });

   pmRenderList();
   pmRenderCount();
}

function pmResetFilters() {
   PM_STATE.filters = {
      query: "",
      status: "all",
      seller: "all",
      type: "all",
      minPrice: null,
      maxPrice: null
   };
   $("#pm-search").val("");
   $("#pm-filter-status").val("all");
   $("#pm-filter-seller").val("all");
   $("#pm-filter-type").val("all");
   $("#pm-price-min").val("");
   $("#pm-price-max").val("");
   pmApplyFilters();
}

function pmRenderCount() {
   const total = PM_STATE.filtered.length;
   $("#pm-count-label").text(`${total} wynik${total===1?"":"ów"}`);
   $("#pm-subtitle").text(total ? "Przeglądaj nieruchomości na sprzedaż i wynajem." : "Brak nieruchomości pasujących do filtrów.");
}


function pmRenderList() {
   const $list = $("#pm-list").empty();
   const props = PM_STATE.filtered;

   if (!props.length) {
      $list.append(`
	<div class="pm-card" style="padding:14px; text-align:center; font-size:.84rem;">
	  <span class="pm-small-muted"><i class="fa-solid fa-circle-xmark"></i> Brak nieruchomości pasujących do aktualnych filtrów.</span>
	</div>
  `);
      return;
   }

   props.forEach(p => {
      const hasSale = !!p.forSale && p.salePrice != null;
      const hasRent = !!p.forRent && p.rentPrice != null;
      let imgSrc = (p.images && p.images.length && p.images[0]) ?
         p.images[0] :
         PM_FALLBACK_IMAGE;
      const type = p.type || "-";

      let sellerText = "Sprzedawca nie ustawiony";
      if (p.seller?.kind === "agency") {
         const agencyName = p.seller.name || "Biuro nieruchomości";
         sellerText = `Sprzedawane przez ${agencyName}`;
      } else if (p.seller?.kind === "player") {
         const rpName = p.seller.name || "Gracz";
         sellerText = `Sprzedawane przez ${rpName}`;
      }

      const saleChip = hasSale ?
         `<span class="pm-chip"><span class="pm-chip-label">Sprzedaż</span> ${pmMoney(p.salePrice)}</span>` :
         "";
      const rentLabel = p.rentIntervalLabel ? `/${p.rentIntervalLabel}` : "";
      const rentChip = hasRent ?
         `<span class="pm-chip"><span class="pm-chip-label">Wynajem</span> ${pmMoney(p.rentPrice)}${rentLabel}</span>` :
         "";


      const isSelected = PM_STATE.selectedId === p.id;

      $list.append(`
	<article class="pm-item ${isSelected ? "pm-item-active" : ""}" data-id="${p.id}">
	  <div class="pm-thumb">
		<img src="${imgSrc}" alt=""
     onerror="this.onerror=null;this.src='img/noimage.webp';">
	  </div>
	  <div class="pm-main-info">
		<div>
		  <div class="pm-name">${p.name || "Nienazwana nieruchomość"}</div>
		  <div class="pm-address">
			<i class="fa-solid fa-location-dot"></i>
			<span>${p.address || "Adres nie ustawiony"}</span>
		  </div>
		  <div class="pm-price-row">
			${saleChip}
			${rentChip}
		  </div>
		</div>
		<div class="pm-bottom">
		  <span class="pm-seller-badge">${sellerText}</span>
		</div>
	  </div>
	  <div class="pm-side-actions">
		<span class="pm-type-tag">${type}</span>
		<button class="pm-btn pm-btn-primary pm-btn-inline" data-action="view-property" data-id="${p.id}">
		  <i class="fa-solid fa-eye"></i> Zobacz
		</button>
	  </div>
	</article>
  `);
   });
}

function pmGetProperty(id) {
   id = String(id);
   return PM_STATE.properties.find(p => String(p.id) === id);
}


function pmOpenModal(sel) {
   $(sel).css("display", "flex");
}

function pmCloseModal(sel) {
   $(sel).hide();
}


function pmOpenDetail(id) {
   id = String(id);
   const p = pmGetProperty(id);
   if (!p) return;
   PM_STATE.selectedId = id;

   $("#pm-detail-title").text(p.name || "Nieruchomość");

   const address = p.address || "Adres nie ustawiony";
   const type = p.type || "-";
   $("#pm-detail-sub").html(
      `<i class="fa-solid fa-location-dot"></i> ${address}   •   Typ: <b>${type}</b>`
   );


   const $slider = $(".pm-detail-slider");


   let images = Array.isArray(p.images) ? p.images.filter(Boolean) : [];
   if (!images.length) {
      images = ["img/noimage2.webp"];
   }


   $slider.data("images", images);
   $slider.attr("data-id", p.id);
   $slider.attr("data-index", 0);


   const first = images[0];
   $slider.find(".pm-slider-img")
      .attr("src", first)
      .attr("onerror", "this.onerror=null;this.src='img/noimage2.webp';");


   $("#pm-detail-dots").html(
      images.map((_, i) =>
         `<span class="pm-dot ${i === 0 ? "pm-dot-active" : ""}" data-idx="${i}"></span>`
      ).join("")
   );


   const hasSale = !!p.forSale && p.salePrice != null;
   const hasRent = !!p.forRent && p.rentPrice != null;
   const prices = [];
   if (hasSale) {
      prices.push(`<span class="pm-chip"><span class="pm-chip-label">Sprzedaż</span> ${pmMoney(p.salePrice)}</span>`);
   }
   if (hasRent) {
      const rentLabel = p.rentIntervalLabel ? `/${p.rentIntervalLabel}` : "";
      prices.push(
         `<span class="pm-chip"><span class="pm-chip-label">Wynajem</span> ${pmMoney(p.rentPrice)}${rentLabel}</span>`
      );
   }

   $("#pm-detail-prices").html(prices.join(" "));


   let sellerText = "Sprzedawca nie ustawiony";
   if (p.seller?.kind === "agency") {
      const agencyName = p.seller.name || "Biuro nieruchomości";
      sellerText = `Sprzedawane przez ${agencyName}`;
   } else if (p.seller?.kind === "player") {
      const rpName = p.seller.name || "Gracz";
      sellerText = `Sprzedawane przez ${rpName}`;
   }
   $("#pm-detail-seller").text(sellerText);
   const phoneText = (p.seller?.kind === "player" && p.seller.phone) ? p.seller.phone : "—";
   $("#pm-detail-phone").text(phoneText);

   $("#pm-detail-type").text(type);
   const flags = [];
   if (hasSale) flags.push("For sale");
   if (hasRent) flags.push("For rent");
   $("#pm-detail-flags").text(flags.length ? flags.join(" • ") : "—");

   $("#pm-detail-description").text(p.description || "Brak opisu.");

   const isPlayerSeller = p.seller?.kind === "player";

   if (isPlayerSeller) {

      $("#pm-btn-detail-buy").hide();
      $("#pm-btn-detail-rent").hide();
   } else {

      $("#pm-btn-detail-buy").toggle(hasSale);
      $("#pm-btn-detail-rent").toggle(hasRent);
   }


   const boolLabel = v => v ? "Tak" : "Nie";
   const descHtml = p.description ?
      `<p>${p.description}</p>` :
      '<p class="pm-list-note">Brak dostępnego opisu.</p>';

   const features = `
  <div class="pm-list-plain" style="margin-top:6px;">
	<div class="pm-list-item">
	  <div class="pm-list-main"><span>Garaż</span></div>
	  <span class="pm-list-note">${boolLabel(p.hasGarage)}</span>
	</div>
	<div class="pm-list-item">
	  <div class="pm-list-main"><span>Szafa</span></div>
	  <span class="pm-list-note">${boolLabel(p.hasWardrobe)}</span>
	</div>
	<div class="pm-list-item">
	  <div class="pm-list-main"><span>Magazyn</span></div>
	  <span class="pm-list-note">${boolLabel(p.hasStorage)}</span>
	</div>
	<div class="pm-list-item">
	  <div class="pm-list-main"><span>Meble wewnętrzne</span></div>
	  <span class="pm-list-note">${boolLabel(p.furnitureEnabledInside)}</span>
	</div>
	<div class="pm-list-item">
	  <div class="pm-list-main"><span>Meble zewnętrzne</span></div>
	  <span class="pm-list-note">${boolLabel(p.furnitureEnabledOutside)}</span>
	</div>
  </div>`;
   $("#pm-info-body").html(descHtml + features);


   $("#pm-util-electricity").text(pmMoney(p.electricityPrice || 0));
   $("#pm-util-electricity-rate").text(p.electricityRate || "—");
   $("#pm-util-water").text(pmMoney(p.waterPrice || 0));
   $("#pm-util-water-rate").text(p.waterRate || "—");
   $("#pm-util-internet").text(pmMoney(p.internetPrice || 0));
   $("#pm-util-internet-rate").text(p.internetRate || "—");


   if (hasSale) {
      $("#pm-confirm-buy-text").text(
         `Czy na pewno chcesz kupić "${p.name}" za ${pmMoney(p.salePrice)}?`
      );
   }
   if (hasRent) {
      const rentLabel = p.rentIntervalLabel ? `/${p.rentIntervalLabel}` : "";
      $("#pm-confirm-rent-text").text(
         `Czy na pewno chcesz wynająć "${p.name}" za ${pmMoney(p.rentPrice)}${rentLabel}?`
      );
   }


   pmOpenModal("#pm-modal-detail");
}

function pmUpdateSlider($slider, newIndex) {

   let images = $slider.data("images") || [];
   if (!Array.isArray(images) || !images.length) return;

   const max = images.length;
   let idx = newIndex;

   if (idx < 0) idx = max - 1;
   if (idx >= max) idx = 0;

   $slider.attr("data-index", idx);

   const src = images[idx] || "img/noimage2.webp";
   $slider.find(".pm-slider-img")
      .attr("src", src)
      .attr("onerror", "this.onerror=null;this.src='img/noimage2.webp';");

   $("#pm-detail-dots .pm-dot").removeClass("pm-dot-active");
   $("#pm-detail-dots .pm-dot[data-idx='" + idx + "']").addClass("pm-dot-active");
}


function pmShowMarket(payload) {
   if (payload && Array.isArray(payload.properties)) {
      PM_STATE.properties = payload.properties;
   } else if (!PM_STATE.properties.length) {
      PM_STATE.properties = pmDemoProperties();
   }
   PM_STATE.selectedId = null;
   pmApplyFilters();
   $("#pm-root").show();
}

function pmHideMarket() {
   $("#pm-root").hide();
   pmCloseModal("#pm-modal-detail");
   pmCloseModal("#pm-modal-info");
   pmCloseModal("#pm-modal-utilities");
   pmCloseModal("#pm-modal-confirm-buy");
   pmCloseModal("#pm-modal-confirm-rent");
   PM_STATE.selectedId = null;
}

window.addEventListener("message", function (e) {
   const item = e.data || {};
   if (item.message === "openPropertyMenu") {
      PM_STATE.properties = Array.isArray(item.properties) ? item.properties : pmDemoProperties();
      pmApplyFilters();
      $("#pm-root").show();
   }
   if (item.message === "closePropertyMenu") {
      pmHideMarket();
   }
   if (item.message === "setPropertyData") {
      PM_STATE.properties = Array.isArray(item.properties) ? item.properties : PM_STATE.properties;
      pmApplyFilters();
   }
});


$(function () {

   PM_STATE.properties = pmDemoProperties();
   pmApplyFilters();


   $("#pm-search").on("input", function () {
      PM_STATE.filters.query = $(this).val().trim();
      pmApplyFilters();
   });
   $("#pm-filter-status").on("change", function () {
      PM_STATE.filters.status = $(this).val();
      pmApplyFilters();
   });
   $("#pm-filter-seller").on("change", function () {
      PM_STATE.filters.seller = $(this).val();
      pmApplyFilters();
   });
   $("#pm-filter-type").on("change", function () {
      PM_STATE.filters.type = $(this).val();
      pmApplyFilters();
   });
   $("#pm-price-min").on("change", function () {
      const v = $(this).val();
      PM_STATE.filters.minPrice = v ? Number(v) : null;
      pmApplyFilters();
   });
   $("#pm-price-max").on("change", function () {
      const v = $(this).val();
      PM_STATE.filters.maxPrice = v ? Number(v) : null;
      pmApplyFilters();
   });
   $("#pm-btn-clear").on("click", pmResetFilters);
   $("#pm-btn-apply").on("click", pmApplyFilters);


   $("#pm-list").on("click", "[data-action='view-property']", function (e) {
      e.stopPropagation();
      pmOpenDetail($(this).data("id"));
   });
   $("#pm-list").on("click", ".pm-item", function (e) {
      if ($(e.target).closest("[data-action]").length) return;
      pmOpenDetail($(this).data("id"));
   });


   $(document).on("click", ".pm-slider-arrow", function () {
      const $slider = $(this).closest(".pm-detail-slider");
      const dir = Number($(this).data("dir")) || 0;
      const current = Number($slider.attr("data-index")) || 0;
      pmUpdateSlider($slider, current + dir);
   });
   $(document).on("click", "#pm-detail-dots .pm-dot", function () {
      const idx = Number($(this).data("idx")) || 0;
      const $slider = $(".pm-detail-slider");
      pmUpdateSlider($slider, idx);
   });


   $("#pm-btn-detail-info").on("click", () => pmOpenModal("#pm-modal-info"));
   $("#pm-btn-detail-utilities").on("click", () => pmOpenModal("#pm-modal-utilities"));
   $("#pm-btn-detail-gps").on("click", function () {
      if (!PM_STATE.selectedId) return;
      pmPost(PM_EVENTS.gps, {
         id: PM_STATE.selectedId
      });
   });
   $("#pm-btn-detail-buy").on("click", function () {
      if (!PM_STATE.selectedId) return;
      pmOpenModal("#pm-modal-confirm-buy");
   });
   $("#pm-btn-detail-rent").on("click", function () {
      if (!PM_STATE.selectedId) return;
      pmOpenModal("#pm-modal-confirm-rent");
   });


   $("#pm-btn-confirm-buy-yes").on("click", function () {
      if (!PM_STATE.selectedId) return;
      pmPost(PM_EVENTS.buy, {
         id: PM_STATE.selectedId
      });
      pmCloseModal("#pm-modal-confirm-buy");
   });
   $("#pm-btn-confirm-rent-yes").on("click", function () {
      if (!PM_STATE.selectedId) return;
      pmPost(PM_EVENTS.rent, {
         id: PM_STATE.selectedId
      });
      pmCloseModal("#pm-modal-confirm-rent");
   });


   $(document).on("click", ".pm-modal-close", function () {
      const sel = $(this).data("close");
      pmCloseModal(sel);
   });
   $(".pm-modal").on("click", function (e) {
      if (e.target === this) $(this).hide();
   });


   $("#pm-btn-close").on("click", function () {
      pmPost(PM_EVENTS.closeMenu, {});
      pmHideMarket();
   });


   $(document).on("keydown", function (e) {
      if (e.key === "Escape") {
         if ($("#pm-modal-confirm-rent").is(":visible")) {
            pmCloseModal("#pm-modal-confirm-rent");
            return;
         }
         if ($("#pm-modal-confirm-buy").is(":visible")) {
            pmCloseModal("#pm-modal-confirm-buy");
            return;
         }
         if ($("#pm-modal-utilities").is(":visible")) {
            pmCloseModal("#pm-modal-utilities");
            return;
         }
         if ($("#pm-modal-info").is(":visible")) {
            pmCloseModal("#pm-modal-info");
            return;
         }
         if ($("#pm-modal-detail").is(":visible")) {
            pmCloseModal("#pm-modal-detail");
            return;
         }
         pmPost(PM_EVENTS.closeMenu, {});
         pmHideMarket();
      }
   });
});