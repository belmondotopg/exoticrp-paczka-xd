const HELP_CONFIG = {
   messages: {
      show: "HelpNotifyShow",
      hide: "HelpNotifyHide",
      toggle: "HelpNotifyToggle"
   },
   autoHideMs: 10000,
   demoEnabled: true
};

const NOTIFY_CONFIG = {
   messages: {
      show: "NotifyShow",
      hide: "NotifyHide"
   },
   defaultTimeout: 5000,
   demoEnabled: true
};

const HELP_STATE = {
   visible: false,
   timeoutId: null
};

const NOTIFY_STATE = {
   nextId: 1,
   items: {}
};


function setHelpContent(data) {
   const title = data.title || "Pomoc";
   const text = data.text || "";
   const tagline = typeof data.tagline === "string" ? data.tagline.trim() : "";

   $("#help-title").text(title);
   $("#help-text").text(text);

   if (tagline) {
      $("#help-tagline").text(tagline).show();
   } else {
      $("#help-tagline").hide().text("");
   }

   const iconClass = (data.iconFullClass) ?
      data.iconFullClass :
      ("fa-solid " + (data.icon || "fa-circle-info"));

   $("#help-icon").attr("class", iconClass);


   const keys = Array.isArray(data.keys) ? data.keys : null;
   const $row = $("#help-keys-row").empty();

   if (keys && keys.length) {
      keys.forEach(function (k) {
         if (!k) return;


         if (typeof k === "string") {
            $("<span/>", {
               "class": "help-key-pill help-key-plain",
               text: k
            }).appendTo($row);
            return;
         }

         const keyText = k.key || k.k || "";
         const labelText = k.label || k.text || "";

         if (!keyText && !labelText) return;

         const $pill = $('<span class="help-key-pill"></span>');
         if (keyText) {
            $('<span class="help-key-main"></span>').text(keyText).appendTo($pill);
         }
         if (labelText) {
            $('<span class="help-key-label"></span>').text(labelText).appendTo($pill);
         }
         $pill.appendTo($row);
      });

      $row.css("display", "flex");
   } else {
      $row.css("display", "none");
   }
}

function showHelp(data) {
   setHelpContent(data || {});

   if (HELP_STATE.timeoutId) {
      clearTimeout(HELP_STATE.timeoutId);
      HELP_STATE.timeoutId = null;
   }

   $("#help-root").addClass("is-visible");
   HELP_STATE.visible = true;

   const autoMs = typeof data.autoHideMs === "number" ?
      data.autoHideMs :
      HELP_CONFIG.autoHideMs;

   if (autoMs && autoMs > 0) {
      HELP_STATE.timeoutId = setTimeout(function () {
         hideHelp({
            reason: "timeout"
         });
      }, autoMs);
   }
}

function hideHelp(meta) {
   $("#help-root").removeClass("is-visible");
   HELP_STATE.visible = false;

   if (HELP_STATE.timeoutId) {
      clearTimeout(HELP_STATE.timeoutId);
      HELP_STATE.timeoutId = null;
   }

}

function toggleHelp(data) {
   if (HELP_STATE.visible) {
      hideHelp({
         reason: "toggle"
      });
   } else {
      showHelp(data || {});
   }
}


function createNotifyElement(id, data) {
   const type = (data.type || "info").toLowerCase();

   let typeClass = "notify-type-info";
   let defaultIcon = "fa-circle-info";

   if (type === "success") {
      typeClass = "notify-type-success";
      defaultIcon = "fa-check";
   } else if (type === "warning") {
      typeClass = "notify-type-warning";
      defaultIcon = "fa-triangle-exclamation";
   } else if (type === "error") {
      typeClass = "notify-type-error";
      defaultIcon = "fa-xmark";
   }

   const iconClass = (data.iconFullClass) ?
      data.iconFullClass :
      (data.icon ?
         ("fa-solid " + data.icon) :
         ("fa-solid " + defaultIcon));

   const $card = $(`
  <div class="notify-card ${typeClass}" data-notify-id="${id}">
	<div class="notify-icon-wrap">
	  <i class="${iconClass}"></i>
	</div>
	<div class="notify-main">
	  <div class="notify-title"></div>
	  <div class="notify-text"></div>
	</div>
  </div>
`);

   $card.find(".notify-title").text(data.title || "Powiadomienie");
   $card.find(".notify-text").text(data.text || "");

   return $card;
}

function showNotify(data) {
   let id = (typeof data.id !== "undefined" && data.id !== null) ?
      data.id :
      ("n" + (NOTIFY_STATE.nextId++));

   const idKey = String(id);

   const timeoutMs = typeof data.timeout === "number" && data.timeout >= 0 ?
      data.timeout :
      NOTIFY_CONFIG.defaultTimeout;

   const $stack = $("#notify-stack");
   const $card = createNotifyElement(id, data);

   $stack.append($card);

   requestAnimationFrame(() => {
      $card.addClass("is-visible");
   });

   let timeoutId = null;
   if (timeoutMs > 0) {
      timeoutId = setTimeout(() => {
         hideNotifyById(id, {
            reason: "timeout"
         });
      }, timeoutMs);
   }

   NOTIFY_STATE.items[idKey] = {
      timeoutId,
      $el: $card
   };

   return id;
}

function hideNotifyById(id, meta) {
   const idKey = String(id);
   const item = NOTIFY_STATE.items[idKey];
   if (!item) return;

   if (item.timeoutId) clearTimeout(item.timeoutId);

   const $card = item.$el;
   $card.removeClass("is-visible");
   setTimeout(() => {
      $card.remove();
   }, 180);

   delete NOTIFY_STATE.items[idKey];

}

function hideAllNotifications(reason) {
   Object.keys(NOTIFY_STATE.items).forEach(idKey => {
      hideNotifyById(idKey, {
         reason: reason || "bulkHide"
      });
   });
}


window.addEventListener("message", function (event) {
   const item = event.data || {};
   const msg = item.message;


   if (msg === HELP_CONFIG.messages.show) {
      showHelp(item);
   }
   if (msg === HELP_CONFIG.messages.hide) {
      hideHelp({
         reason: "remoteHide"
      });
   }
   if (msg === HELP_CONFIG.messages.toggle) {
      toggleHelp(item);
   }


   if (msg === NOTIFY_CONFIG.messages.show) {
      showNotify(item);
   }
   if (msg === NOTIFY_CONFIG.messages.hide) {
      if (typeof item.id !== "undefined" && item.id !== null) {
         hideNotifyById(item.id, {
            reason: "remoteHideSingle"
         });
      } else {
         hideAllNotifications("remoteHideAll");
      }
   }
});