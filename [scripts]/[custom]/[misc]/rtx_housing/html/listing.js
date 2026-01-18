const PL_RESOURCE = "rtx_housing";

const PL_DEFAULT_STATE = {
   propertyId: null,
   isListed: false,
   description: "",
   phone: "",
   purchasable: false,
   purchasePrice: 0,
   rentable: false,
   rentPrice: 0
};

let PL_STATE = {
   ...PL_DEFAULT_STATE
};

function plUpdateSwitch(selector, enabled) {
   const $sw = $(selector);
   $sw.attr("data-on", enabled ? "true" : "false");
   $sw.find(".pl-switch-label").text(enabled ? "Włączone" : "Wyłączone");
}

function plRefreshUI() {
   $("#pl-input-description").val(PL_STATE.description || "");
   $("#pl-input-phone").val(PL_STATE.phone || "");


   plUpdateSwitch("#pl-switch-purchase", PL_STATE.purchasable);
   $("#pl-input-purchase-price")
      .prop("disabled", !PL_STATE.purchasable)
      .val(PL_STATE.purchasable ? (PL_STATE.purchasePrice || "") : "");


   plUpdateSwitch("#pl-switch-rent", PL_STATE.rentable);
   $("#pl-input-rent-price")
      .prop("disabled", !PL_STATE.rentable)
      .val(PL_STATE.rentable ? (PL_STATE.rentPrice || "") : "");

   if (PL_STATE.isListed) {
      $("#pl-status-label").text("Ta oferta jest obecnie widoczna na rynku nieruchomości.");
      $("#pl-btn-remove").show();
      $("#pl-btn-save").html('<i class="fa-solid fa-cloud-arrow-up"></i> Aktualizuj ofertę');
   } else {
      $("#pl-status-label").text("Oferta nie jest jeszcze na rynku.");
      $("#pl-btn-remove").hide();
      $("#pl-btn-save").html('<i class="fa-solid fa-cloud-arrow-up"></i> Wystaw na rynek');
   }
}

function plApplyFromPayload(payload) {
   const p = payload || {};
   PL_STATE.propertyId = p.propertyId ?? null;
   PL_STATE.isListed = !!p.isListed;
   PL_STATE.description = p.description || "";
   PL_STATE.phone = p.phone || "";
   PL_STATE.purchasable = !!p.purchasable;
   PL_STATE.purchasePrice = Number(p.purchasePrice) || 0;
   PL_STATE.rentable = !!p.rentable;
   PL_STATE.rentPrice = Number(p.rentPrice) || 0;
   plRefreshUI();
}

function plCollectForm() {
   return {
      propertyId: PL_STATE.propertyId,
      isListed: PL_STATE.isListed,
      description: $("#pl-input-description").val().trim(),
      phone: $("#pl-input-phone").val().trim(),
      purchasable: $("#pl-switch-purchase").attr("data-on") === "true",
      purchasePrice: Number($("#pl-input-purchase-price").val()) || 0,
      rentable: $("#pl-switch-rent").attr("data-on") === "true",
      rentPrice: Number($("#pl-input-rent-price").val()) || 0
   };
}

function plPost(name, data) {

   $.post(`https://${PL_RESOURCE}/${name}`, JSON.stringify(data || {}));
}

function plOpenWrapper() {
   $("#listing-root").css("display", "flex");
}

function plCloseWrapper() {
   $("#listing-root").css("display", "none");
}


window.addEventListener("message", function (e) {
   const item = e.data || {};

   if (item.message === "openPlayerListing") {

      PL_STATE = {
         ...PL_DEFAULT_STATE
      };
      plApplyFromPayload(item.listing || {});
      plOpenWrapper();
   }

   if (item.message === "closePlayerListing") {
      plCloseWrapper();
   }
});


$(function () {

   $("#listing-root").css("display", "none");


   $("#pl-switch-purchase").on("click", function () {
      const enabled = $(this).attr("data-on") !== "true";
      PL_STATE.purchasable = enabled;
      plUpdateSwitch("#pl-switch-purchase", PL_STATE.purchasable);
      $("#pl-input-purchase-price")
         .prop("disabled", !PL_STATE.purchasable)
         .val(PL_STATE.purchasable ? (PL_STATE.purchasePrice || "") : "");
   });

   $("#pl-switch-rent").on("click", function () {
      const enabled = $(this).attr("data-on") !== "true";
      PL_STATE.rentable = enabled;
      plUpdateSwitch("#pl-switch-rent", PL_STATE.rentable);
      $("#pl-input-rent-price")
         .prop("disabled", !PL_STATE.rentable)
         .val(PL_STATE.rentable ? (PL_STATE.rentPrice || "") : "");
   });


   $("#pl-btn-save").on("click", function () {
      const payload = plCollectForm();
      payload.isListed = true;
      PL_STATE = payload;

      plPost("player_listing_save", payload);
      if (PL_STATE.isListed) {
         $("#pl-status-label").text("Ta oferta jest obecnie widoczna na rynku nieruchomości.");
         $("#pl-btn-remove").show();
         $("#pl-btn-save").html('<i class="fa-solid fa-cloud-arrow-up"></i> Aktualizuj ofertę');
      } else {
         $("#pl-status-label").text("Oferta nie jest jeszcze na rynku.");
         $("#pl-btn-remove").hide();
         $("#pl-btn-save").html('<i class="fa-solid fa-cloud-arrow-up"></i> Wystaw na rynek');
      }
   });


   $("#pl-btn-remove").on("click", function () {
      const id = PL_STATE.propertyId;
      PL_STATE.isListed = false;
      plRefreshUI();

      plPost("player_listing_remove", {
         propertyId: id
      });
   });


   $("#pl-btn-close").on("click", function () {
      plPost("player_listing_close", {
         propertyId: PL_STATE.propertyId
      });
      plCloseWrapper();
   });

});