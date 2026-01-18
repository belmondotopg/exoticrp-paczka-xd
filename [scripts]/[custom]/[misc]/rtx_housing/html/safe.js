var housingresourcename = "rtx_housing";

function nuiPost(name, data) {
   $.post("https://" + housingresourcename + "/" + name, JSON.stringify(data || {}));
}


const PinState = {
   visible: true,
   isOwner: false,
   mode: "unlock",
   buffer: "",
   maxLength: 4
};


function renderDisplay() {
   const display = $("#pin-display");
   display.empty();

   if (!PinState.buffer.length) {
      const ph = $("#pin-placeholder");
      ph.show();
      display.append(ph);
   } else {
      const masked = "•".repeat(PinState.buffer.length);
      $("#pin-placeholder").hide();
      display.text(masked);
   }
}

function setStatus(message, type) {
   const el = $("#pin-status");
   el.removeClass("ok error");
   if (type === "ok") el.addClass("ok");
   if (type === "error") el.addClass("error");
   el.text(message || "");
}

function setMode(mode) {
   PinState.mode = mode === "set" ? "set" : "unlock";

   const btn = $("#btn-pin-set");
   btn.toggleClass("active", PinState.mode === "set");

   if (PinState.mode === "unlock") {
      btn.attr("title", "Ustaw nowy PIN");
      setStatus("Wpisz swój PIN i naciśnij POTWIERDŹ.", null);
   } else {
      btn.attr("title", "Wyjdź z edycji PIN");
      setStatus("Wprowadź nowy kod i naciśnij POTWIERDŹ.", null);
   }
}

function setOwner(isOwner) {
   PinState.isOwner = !!isOwner;
   $("#btn-pin-set").toggle(isOwner);
}

function setTitle(title, subtitle) {
   if (title) $("#pin-title").text(title);
   if (subtitle) $("#pin-subtitle").text(subtitle);
}

function clearBuffer(showHint) {
   PinState.buffer = "";
   renderDisplay();
   if (showHint) setStatus("PIN wyczyszczony.", null);
}

function showPad(opts) {
   opts = opts || {};
   if (typeof opts.maxLength === "number" && opts.maxLength > 0) {
      PinState.maxLength = opts.maxLength;
   }

   setOwner(!!opts.isOwner);
   setMode(opts.mode === "set" ? "set" : "unlock");
   setTitle(opts.title || "Sejf", opts.subtitle || "Wprowadź swój PIN, aby odblokować sejf.");

   clearBuffer(false);

   PinState.visible = true;
   $("#saferoot").show();
}

function hidePad() {
   PinState.visible = false;
   $("#saferoot").hide();
   clearBuffer(false);
   setStatus("", null);
}


function appendDigit(d) {
   if (!PinState.visible) return;
   if (PinState.buffer.length >= PinState.maxLength) return;
   PinState.buffer += String(d);
   renderDisplay();
}

function confirmPin() {
   if (!PinState.buffer.length) {
      setStatus("Musisz najpierw wprowadzić PIN.", "error");
      return;
   }

   if (PinState.mode === "unlock") {
      nuiPost("pin_attempt", {
         pin: PinState.buffer
      });
      setStatus("Wysyłanie kodu...", null);
   } else {
      nuiPost("pin_change", {
         newPin: PinState.buffer
      });
      setStatus("Zapisywanie nowego PIN...", null);
   }
}

function toggleSetMode() {
   if (!PinState.isOwner) return;
   if (PinState.mode === "unlock") {
      setMode("set");
   } else {
      setMode("unlock");
   }
   clearBuffer(false);
}

function closeMain() {
   $("body").css("display", "none");
}

function openMain() {
   $("body").css("display", "block");
}


$(function () {

   $(".pin-key[data-digit]").on("click", function () {
      appendDigit($(this).data("digit"));
   });
   $(".pin-key[data-action='clear']").on("click", function () {
      clearBuffer(true);
   });
   $(".pin-key[data-action='confirm']").on("click", function () {
      confirmPin();
   });


   $("#btn-pin-set").on("click", function () {
      toggleSetMode();
   });


   $("#btn-pin-close").on("click", function () {
      hidePad();
      nuiPost("pin_close", {});
   });


   $(document).on("keydown", function (e) {
      if (!PinState.visible) return;

      const key = e.key;

      if (key === "Enter") {
         confirmPin();
         return;
      }
      if (key === "Backspace") {
         clearBuffer(true);
         return;
      }
      if (/^[0-9]$/.test(key)) {
         appendDigit(key);
      }
   });
});
window.addEventListener("message", function (event) {
   const item = event.data || {};

   if (item.message === "pin:show") {
      openMain();
      showPad(item);
   }

   if (item.message === "pin:hide") {
      hidePad();
   }

   if (item.message === "pin:result") {

      if (item.success) {
         setStatus(item.text || "Dostęp przyznany.", "ok");
      } else {
         setStatus(item.text || "Nieprawidłowy PIN.", "error");
         clearBuffer(false);
      }
   }

   if (item.message === "pin:setOwner") {
      setOwner(!!item.isOwner);
   }

   if (item.message === "pin:pinSet") {
      setStatus(item.text || "PIN został zmieniony", "ok");
   }
   if (item.message === "pin:setMode") {
      setMode(item.mode === "set" ? "set" : "unlock");
      clearBuffer(false);
   }
});