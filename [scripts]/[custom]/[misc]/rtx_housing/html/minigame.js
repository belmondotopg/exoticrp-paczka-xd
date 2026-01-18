var housingresourcename = "rtx_housing";

const LOCK_STATE = {
   active: false,
   difficulty: 'normal',

   configByDiff: {
      easy: {
         pins: 3,
         speed: 0.9,
         sweetSize: 0.35,
         failLimit: 5,
         timeLimit: 0
      },
      normal: {
         pins: 4,
         speed: 1.1,
         sweetSize: 0.25,
         failLimit: 4,
         timeLimit: 0
      },
      hard: {
         pins: 5,
         speed: 1.5,
         sweetSize: 0.18,
         failLimit: 3,
         timeLimit: 25
      },
      nightmare: {
         pins: 6,
         speed: 1.9,
         sweetSize: 0.14,
         failLimit: 2,
         timeLimit: 18
      }
   },

   currentCfg: null,
   pins: [],
   currentIndex: 0,
   progress: 0,
   direction: 1,
   fails: 0,
   tickHandle: null,
   timerHandle: null,
   timeRemaining: 0
};


function nuiPostMinigame(name, data) {
   const resName = housingresourcename
   $.post(`https://${resName}/${name}`, JSON.stringify(data || {}));
}


const LockpickGame = {
   open(difficulty, meta, overrideCfg) {
      const diffKey = (difficulty || 'normal').toLowerCase();
      LOCK_STATE.difficulty = LOCK_STATE.configByDiff[diffKey] ? diffKey : 'normal';
      LOCK_STATE.active = true;
      LOCK_STATE.fails = 0;
      LOCK_STATE.currentIndex = 0;
      LOCK_STATE.progress = Math.random();
      LOCK_STATE.direction = Math.random() > 0.5 ? 1 : -1;

      const baseCfg = LOCK_STATE.configByDiff[LOCK_STATE.difficulty];
      LOCK_STATE.currentCfg = $.extend({}, baseCfg, overrideCfg || {});

      this._buildPins();
      this._updateStaticUI();
      this._startLoops();

      $('#lockpick-ui').css('display', 'flex');
   },

   close(sendCancel) {
      this._stopLoops();
      LOCK_STATE.active = false;
      $('#lockpick-ui').hide();

      if (sendCancel) {
         this._sendResult(false, 'cancel');
      }
   },

   finish(success, reason) {
      this._stopLoops();
      LOCK_STATE.active = false;
      $('#lockpick-ui').hide();
      this._sendResult(success, reason || (success ? 'success' : 'fail'));
   },

   _buildPins() {
      const cfg = LOCK_STATE.currentCfg;
      LOCK_STATE.pins = [];

      for (let i = 0; i < cfg.pins; i++) {
         const center = 0.15 + Math.random() * 0.7;
         const half = cfg.sweetSize / 2;
         const sweetStart = Math.max(0, center - half);
         const sweetEnd = Math.min(1, center + half);

         LOCK_STATE.pins.push({
            index: i,
            solved: false,
            sweetStart,
            sweetEnd
         });
      }

      this._loadCurrentPinVisual();
   },

   _loadCurrentPinVisual() {
      const pin = LOCK_STATE.pins[LOCK_STATE.currentIndex] || LOCK_STATE.pins[LOCK_STATE.pins.length - 1];
      if (!pin) return;

      const left = pin.sweetStart * 100;
      const width = (pin.sweetEnd - pin.sweetStart) * 100;
      $('#lp-sweet-range').css({
         left: left + '%',
         width: width + '%'
      });

      $('#lp-marker').css('left', (LOCK_STATE.progress * 100) + '%');

      const total = LOCK_STATE.pins.length;
      const done = LOCK_STATE.pins.filter(p => p.solved).length;
      $('#lp-circle-pins').text(done + ' / ' + total);
   },

   _startLoops() {
      const cfg = LOCK_STATE.currentCfg;

      if (LOCK_STATE.tickHandle) clearInterval(LOCK_STATE.tickHandle);
      LOCK_STATE.tickHandle = setInterval(() => {
         if (!LOCK_STATE.active) return;
         this._tickMovement();
      }, 16);

      if (LOCK_STATE.timerHandle) {
         clearInterval(LOCK_STATE.timerHandle);
         LOCK_STATE.timerHandle = null;
      }

      if (cfg.timeLimit && cfg.timeLimit > 0) {
         LOCK_STATE.timeRemaining = cfg.timeLimit;
         LOCK_STATE.timerHandle = setInterval(() => {
            if (!LOCK_STATE.active) return;
            LOCK_STATE.timeRemaining -= 1;
            if (LOCK_STATE.timeRemaining <= 0) {
               LOCK_STATE.timeRemaining = 0;
               this.finish(false, 'time_limit');
            }
         }, 1000);
      }
   },

   _stopLoops() {
      if (LOCK_STATE.tickHandle) {
         clearInterval(LOCK_STATE.tickHandle);
         LOCK_STATE.tickHandle = null;
      }
      if (LOCK_STATE.timerHandle) {
         clearInterval(LOCK_STATE.timerHandle);
         LOCK_STATE.timerHandle = null;
      }
   },

   _tickMovement() {
      const cfg = LOCK_STATE.currentCfg;
      const delta = 0.016;
      LOCK_STATE.progress += LOCK_STATE.direction * cfg.speed * delta;

      if (LOCK_STATE.progress > 1) {
         LOCK_STATE.progress = 1;
         LOCK_STATE.direction = -1;
      } else if (LOCK_STATE.progress < 0) {
         LOCK_STATE.progress = 0;
         LOCK_STATE.direction = 1;
      }

      $('#lp-marker').css('left', (LOCK_STATE.progress * 100) + '%');
   },

   attemptHit() {
      if (!LOCK_STATE.active) return;
      const cfg = LOCK_STATE.currentCfg;
      const pin = LOCK_STATE.pins[LOCK_STATE.currentIndex];
      if (!pin) return;

      const p = LOCK_STATE.progress;
      const hit = p >= pin.sweetStart && p <= pin.sweetEnd;

      if (hit) {
         pin.solved = true;
         LOCK_STATE.currentIndex++;
         this._flashResult(true);
      } else {
         LOCK_STATE.fails++;
         this._flashResult(false);
      }

      this._updateStatusUI();

      if (hit) {
         if (LOCK_STATE.currentIndex >= LOCK_STATE.pins.length) {
            this.finish(true, 'all_pins');
         } else {
            this._loadCurrentPinVisual();
         }
      } else {
         if (LOCK_STATE.fails >= cfg.failLimit) {
            this.finish(false, 'too_many_fails');
         }
      }
   },

   _updateStaticUI() {
      const cfg = LOCK_STATE.currentCfg;

      $('#lp-circle-pins').text('0 / ' + cfg.pins);
      $('#lp-circle-fails').text('Błędy: 0');
   },

   _updateStatusUI() {
      const cfg = LOCK_STATE.currentCfg;
      const done = LOCK_STATE.pins.filter(p => p.solved).length;
      const total = LOCK_STATE.pins.length;

      $('#lp-circle-pins').text(done + ' / ' + total);
      $('#lp-circle-fails').text('Błędy: ' + LOCK_STATE.fails);
   },

   _flashResult(success) {
      const $c = $('.lp-circle-ring');
      $c.stop(true, true);
      if (success) {
         $c.animate({
            opacity: 0.55
         }, 80).animate({
            opacity: 1
         }, 120);
      } else {
         $c.animate({
               marginTop: "-4px"
            }, 60)
            .animate({
               marginTop: "2px"
            }, 60)
            .animate({
               marginTop: "0px"
            }, 70);
      }
   },

   _sendResult(success, reason) {
      nuiPostMinigame('lockpick:finish', {
         success: success,
         reason: reason || null,
         difficulty: LOCK_STATE.difficulty,
         settings: LOCK_STATE.currentCfg
      });
   }
};


$(function () {
   $('#lp-hit-btn').on('click', function () {
      LockpickGame.attemptHit();
   });

   $(document).on('keydown.lockpick', function (e) {
      if (!LOCK_STATE.active) return;

      if (e.key === ' ' || e.code === 'Space') {
         e.preventDefault();
         LockpickGame.attemptHit();
      } else if (e.key === 'Escape' || e.code === 'Escape') {
         e.preventDefault();
         LockpickGame.close(true);
         nuiPostMinigame('lockpick:exit', {});
      }
   });

});


window.addEventListener('message', function (event) {
   const data = event.data || {};

   if (data.action === 'lockpick:open') {
      const diff = data.difficulty || 'normal';
      const settings = data.settings || null;
      if (data.pinsshow) {
         $("#pins").show();
      } else {
         $("#pins").hide();
      }

      LockpickGame.open(diff, {}, settings);
   }

   if (data.action === 'lockpick:close') {
      if (LOCK_STATE.active) {
         LockpickGame.close(true);
      }
   }
});


window.addEventListener("message", function (event) {
   const item = event.data;
   if (item.message == "lockpick:open") {
      const diff = item.difficulty || 'normal';
      const settings = item.settings || null;
      LockpickGame.open(diff, {}, settings);
   }

   if (item.message == "lockpick:close") {
      if (LOCK_STATE.active) {
         LockpickGame.close(true);
      }
   }
});