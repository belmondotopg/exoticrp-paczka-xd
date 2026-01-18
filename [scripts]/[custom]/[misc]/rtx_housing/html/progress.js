let RTX_PROGRESS = {
   active: false,
   timer: null,
   startTime: 0,
   duration: 0,
   canCancel: true,
};


function nuiPost(name, data = {}) {
   if (typeof GetParentResourceName === "function") {
      fetch(`https://${GetParentResourceName()}/${name}`, {
         method: "POST",
         headers: {
            "Content-Type": "application/json"
         },
         body: JSON.stringify(data)
      });
   } else {
      console.log("[RTX PROGRESS DEBUG]", name, data);
   }
}


function openRtxProgress(opts) {
   if (RTX_PROGRESS.active) return;

   RTX_PROGRESS.active = true;
   RTX_PROGRESS.startTime = Date.now();
   RTX_PROGRESS.duration = Number(opts.timeMs || 0);
   RTX_PROGRESS.canCancel = opts.canCancel !== false;


   $("#rtx-progress-title").text(opts.title || "Postęp");
   $("#rtx-progress-label").text(opts.label || "");
   $("#rtx-progress-icon").attr("class", opts.icon || "fa-solid fa-spinner");

   $("#rtx-progress-inner").css("width", "0%");
   $("#rtx-progress-percent").text("0%");

   $("#rtx-progress-overlay").addClass("show");


   nuiPost("rtxProgressStart");

   if (RTX_PROGRESS.duration > 0) {
      startRtxProgressTimer();
   } else {
      finishRtxProgress(true);
   }
}


function startRtxProgressTimer() {
   if (RTX_PROGRESS.timer) clearInterval(RTX_PROGRESS.timer);

   RTX_PROGRESS.timer = setInterval(() => {
      const elapsed = Date.now() - RTX_PROGRESS.startTime;
      const percent = Math.min(
         100,
         Math.floor((elapsed / RTX_PROGRESS.duration) * 100)
      );

      $("#rtx-progress-inner").css("width", percent + "%");
      $("#rtx-progress-percent").text(percent + "%");

      if (percent >= 100) {
         finishRtxProgress(true);
      }
   }, 80);
}


function finishRtxProgress(success) {
   if (!RTX_PROGRESS.active) return;

   if (RTX_PROGRESS.timer) {
      clearInterval(RTX_PROGRESS.timer);
      RTX_PROGRESS.timer = null;
   }

   RTX_PROGRESS.active = false;

   $("#rtx-progress-overlay").removeClass("show");

   if (success) {
      nuiPost("rtxProgressDone");
   } else {
      nuiPost("rtxProgressCancel");
   }
}

function cancelRtxProgress() {
   if (!RTX_PROGRESS.active) return;
   if (!RTX_PROGRESS.canCancel) return;

   finishRtxProgress(false);
}


$("#rtx-progress-cancel").on("click", function () {
   cancelRtxProgress();
});


window.addEventListener("message", function (event) {
   const data = event.data || {};

   if (data.message === "RTX_PROGRESS_START") {
      openRtxProgress(data);
   }

   if (data.message === "RTX_PROGRESS_CANCEL") {
      cancelRtxProgress();
   }

   if (data.message === "RTX_PROGRESS_CLOSE") {
      finishRtxProgress(false);
   }
});