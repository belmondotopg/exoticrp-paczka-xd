let STATE = {
   meta: {
      address: "",
      owner: "",
      type: "Dom",
      status: "",
      bankSellPrice: 0,
      bankSellPercent: 70,
      canSellToPlayer: true,
      canSellToBank: true,
      canListRealEstate: true,
      propertyId: null,
      cleanlinessPercent: 0,
      robotVacuumPurchased: false,
      vacuumInProgress: false,
      orderKeyPrice: 0,
      changeLockPrice: 0,
      lastWarning: false,
      canCancelRent: false,
      canCancelTenancy: false,
   },

   bills: [],
   furniture: [],
   keys: [],
   services: {},
   permissionDefs: [],
   permissions: [],
   sectionPermissions: {},
   permissionsToggled: {},

   upgrades: [],
   doorbell: {
      currentId: 1,
      list: []
   },
   positionTypes: [],
   positions: [],
   tenants: [],

   deliveryCategories: [],

   visitorLog: [],
   nearbyPlayers: [],
   tips: [],

   cleanlinessPercent: 0,
};


const housingResourceName = "rtx_housing";

function moneymanagment(n) {
   return `$${Number(n || 0).toLocaleString()}`;
}

function sendNui(action, data) {
   try {
      const endpoint = "https://" + housingResourceName + "/" + action;
      const payload = JSON.stringify(data || {});


      $.post(endpoint, payload);
   } catch (e) {}
}


function hexToRgb(hex) {
   const s = hex.replace("#", "");
   return {
      r: parseInt(s.substr(0, 2), 16),
      g: parseInt(s.substr(2, 2), 16),
      b: parseInt(s.substr(4, 2), 16),
   };
}

function rgba(hex, a) {
   const c = hexToRgb(hex);
   return `rgba(${c.r}, ${c.g}, ${c.b}, ${a})`;
}

function lighten(hex, amt = 0.18) {
   const s = hex.replace("#", "");
   if (s.length !== 6) return hex;
   const to = i =>
      Math.min(255, Math.round(parseInt(s.substr(i, 2), 16) * (1 + amt)));
   const h = n => n.toString(16).padStart(2, "0");
   return `#${h(to(0))}${h(to(2))}${h(to(4))}`;
}

function setTheme(accentHex) {
   const acc2 = lighten(accentHex, 0.12);

   $(":root")
      .css("--accent", accentHex)
      .css("--accent-2", acc2)
      .css("--accent-a20", rgba(accentHex, 0.2))
      .css("--accent-a10", rgba(accentHex, 0.1))
      .css("--accent-glow", rgba(accentHex, 0.18));

   const $grad = $("#hmh-pinkwave");
   if ($grad.length) {
      const $stops = $grad.find("stop");
      $stops
         .eq(0)
         .attr("stop-color", accentHex)
         .attr("stop-opacity", ".55");
      $stops
         .eq(1)
         .attr("stop-color", acc2)
         .attr("stop-opacity", ".32");
   }
}


function hasPayBillsPermission() {
   const sp = STATE.sectionPermissions || {};

   return sp.payBills !== false;
}

function applyButtonPermission($btn, allowed) {
   $btn.prop("disabled", !allowed);
   if (allowed) {
      $btn.css({
         opacity: "",
         cursor: ""
      });
   } else {
      $btn.css({
         opacity: 0.5,
         cursor: "not-allowed"
      });
   }
}

function updatePermissionedButtons() {
   const canPay = hasPayBillsPermission();
   applyButtonPermission($("#dash-bills-manage"), canPay);
   applyButtonPermission($("#bills-payall"), canPay);
   applyButtonPermission($("#services-pay"), canPay);
   $('[data-action="bill-pay"]').each(function () {
      applyButtonPermission($(this), canPay);
   });
}

function getCurrentDoorbellEntry() {
   const d = STATE.doorbell || {};
   const list = d.list || [];


   if (d.currentId != null) {
      const cid = String(d.currentId);
      const byId = list.find(x => String(x.id) === cid);
      if (byId) return byId;
   }


   if (d.current != null) {
      const cname = String(d.current);
      const byName = list.find(x => String(x.label) === cname);
      if (byName) return byName;
   }


   return list[0] || null;
}

function getCurrentDoorbellName() {
   const e = getCurrentDoorbellEntry();
   return e ? e.label : "";
}


function injectUI() {
   $("#house-ui").html(`
    <aside class="hmh-nav">
      <div class="hmh-nav-scroll">
        ${
          [
            ["dashboard","house","Panel"],
            ["furniture","couch","Meble"],
            ["keys","key","Klucze"],
            ["services","plug","Usługi"],
            ["permissions","user-shield","Uprawnienia"],
            ["cameras","camera","Kamery"],
            ["upgrades","arrow-up-right-dots","Ulepszenia"],
            ["doorbell","bell","Dzwonek"],
            ["positions","location-dot","Pozycje"],
            ["tenants","people-roof","Najemcy"],
            ["sell","tag","Sprzedaj"],
            ["delivery","truck-fast","Dostawy"],
            ["clean","broom","Czyszczenie"]
          ].map(
            ([t,ic,lab],i)=>
              `<button class="hmh-nav-item ${i===0?'active':''}" data-tab="${t}">
                 <i class="fa-solid fa-${ic}"></i><span>${lab}</span>
               </button>`
          ).join("")
        }
      </div>
    </aside>

    <section class="hmh-panel">
      <header class="hmh-topbar">
        <div class="hmh-property-card">
          <div class="hmh-property-line">
            <i class="fa-solid fa-location-dot"></i>
            <span id="prop-address">Popular St 12</span>
          </div>
          <div class="hmh-property-meta">
            <span id="prop-owner"><i class="fa-solid fa-user"></i> Nina Ko</span>
            <span class="hmh-chip" id="prop-type">Dom</span>
            <span class="hmh-chip hmh-chip-owned" id="prop-status">Własność</span>
          </div>
        </div>
        <div class="hmh-top-actions">
          <button class="hmh-icon-btn" id="hm-settings" title="Ustawienia">
            <i class="fa-solid fa-sliders"></i>
          </button>
          <button class="hmh-icon-btn hmh-icon-btn-close" id="hm-close" title="Zamknij">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
      </header>

      <main class="hmh-content">
        <!-- Dashboard -->
        <section class="hmh-tab active" id="tab-dashboard">
          <div class="hmh-hero">
            <svg class="hmh-hero-bg" viewBox="0 0 600 220" preserveAspectRatio="none" aria-hidden="true">
              <defs>
                <linearGradient id="hmh-pinkwave" x1="0" y1="0" x2="1" y2="1">
                  <stop offset="0%"  stop-color="#ff66ff" stop-opacity=".55"/>
                  <stop offset="100%" stop-color="#ff8ad6" stop-opacity=".32"/>
                </linearGradient>
              </defs>
              <path d="M0,140 C120,100 180,200 300,170 C420,140 480,40 600,90 L600,0 L0,0 Z" fill="url(#hmh-pinkwave)"/>
            </svg>
            <div>
              <div class="hmh-hero-title">Witaj w domu</div>
              <div class="hmh-hero-sub">Wszystko w jednym miejscu.</div>
            </div>
          </div>

          <div class="hmh-grid hmh-grid-3">
            <!-- Bills -->
            <div class="hmh-card hmh-card-equal" id="dash-bills">
              <div class="hmh-card-head">
                <i class="fa-solid fa-receipt"></i><b>Rachunki</b>
              </div>
              <div class="hmh-highlight">
                <div class="hmh-highlight-label">Do zapłaty</div>
                <div class="hmh-highlight-value" id="bill-total">$0</div>
              </div>
              <ul class="hmh-bullets" id="bills-list"></ul>
              <div class="hmh-row hmh-row-right hmh-mt8">
                <button class="hmh-btn hmh-btn-primary" id="dash-bills-manage">
                  <i class="fa-solid fa-wallet"></i> Zarządzaj i Płać
                </button>
              </div>
            </div>

            <!-- Access Activity -->
            <div class="hmh-card hmh-card-equal">
              <div class="hmh-card-head">
                <i class="fa-solid fa-door-open"></i><b>Aktywność dostępu</b>
              </div>
              <div class="hmh-list" id="visitor-log"></div>
            </div>

            <!-- Tips -->
            <div class="hmh-card hmh-card-equal">
              <div class="hmh-card-head">
                <i class="fa-solid fa-lightbulb"></i><b>Wskazówki</b>
              </div>
              <ul class="hmh-tips" id="tips-list"></ul>
            </div>
          </div>
		  <div class="hmh-card hmh-card-soft hmh-mt12" id="last-warning-box" style="display:none;">
			<div class="hmh-card-head">
			  <i class="fa-solid fa-triangle-exclamation"></i>
			  <b>Ostatnie Ostrzeżenie Płatności</b>
			</div>
			<p class="hmh-text-muted">
			  To jest twoje ostatnie ostrzeżenie dotyczące zapłaty zaległych rachunków za nieruchomość.
			  Kontynuacja braku płatności może prowadzić do zawieszenia usług i możliwego przejęcia nieruchomości.
			</p>
			<div class="hmh-row hmh-row-right hmh-mt8">
			  <button class="hmh-btn hmh-btn-primary" id="warning-open-bills">
				<i class="fa-solid fa-wallet"></i> Zapłać Rachunki Teraz
			  </button>
			</div>
		  </div>	
          <!-- RENTER: Cancel Rent -->
          <div class="hmh-card hmh-card-soft hmh-mt12" id="cancel-rent-box" style="display:none;">
            <div class="hmh-card-head">
              <i class="fa-solid fa-house-circle-xmark"></i>
              <b>Anuluj Wynajem</b>
            </div>
            <p class="hmh-text-muted">
              Wynajmujesz tę nieruchomość. Możesz zakończyć umowę najmu w dowolnym momencie.
            </p>
            <div class="hmh-row hmh-row-right hmh-mt8">
              <button class="hmh-btn hmh-btn-primary" id="btn-cancel-rent">
                <i class="fa-solid fa-ban"></i> Zakończ Wynajem
              </button>
            </div>
          </div>

          <!-- TENANT: Leave Tenancy -->
          <div class="hmh-card hmh-card-soft hmh-mt12" id="cancel-tenancy-box" style="display:none;">
            <div class="hmh-card-head">
              <i class="fa-solid fa-user-slash"></i>
              <b>Opuść Najem</b>
            </div>
            <p class="hmh-text-muted">
              Jesteś wymieniony jako najemca. Możesz usunąć się z tej nieruchomości.
            </p>
            <div class="hmh-row hmh-row-right hmh-mt8">
              <button class="hmh-btn hmh-btn-primary" id="btn-cancel-tenancy">
                <i class="fa-solid fa-right-from-bracket"></i> Opuść
              </button>
            </div>
          </div>

		  
        </section>

<!-- Furniture -->
<section class="hmh-tab" id="tab-furniture">
  <div class="hmh-section-head">
    <h2><i class="fa-solid fa-couch"></i> Meble</h2>
  </div>

<div class="furn-wrapper">
  <div class="hmh-card hmh-card-soft hmh-section-block hmh-furn-card">
    <div class="hmh-furn-text">
      <b>Tryb Dekoracji</b>
      <p class="hmh-text-muted">
        Dostosuj i ułóż meble w swoim domu.
      </p>
    </div>

    <div class="hmh-furn-action">
      <button class="hmh-btn hmh-btn-primary" id="furn-open-menu">
        <i class="fa-solid fa-couch"></i> Meble
      </button>
    </div>
  </div>
</div>

</section>


		
        <!-- Keys -->
		<section class="hmh-tab" id="tab-keys">
		  <div class="hmh-section-head">
			<h2><i class="fa-solid fa-key"></i> Klucze</h2>
			<div class="hmh-head-actions">
			  <button class="hmh-btn hmh-btn-primary" id="key-order">
				<i class="fa-solid fa-key"></i> Zamów Klucz
			  </button>
			  <button class="hmh-btn hmh-btn-primary" id="key-change-lock">
				<i class="fa-solid fa-lock" style="margin-right: 3px;"></i> Zmień Zamek
			  </button>
			</div>
		  </div>
		  <div class="hmh-list hmh-section-block" id="keys-list"></div>
		</section>


        <!-- Services -->
        <section class="hmh-tab" id="tab-services">
          <div class="hmh-section-head">
            <h2><i class="fa-solid fa-plug"></i> Usługi</h2>
            <div class="hmh-head-actions">
              <button class="hmh-btn hmh-btn-primary" id="services-pay">
                <i class="fa-solid fa-credit-card"></i> Zapłać Wszystko
              </button>
            </div>
          </div>
          <div class="hmh-grid hmh-grid-3 hmh-section-block" id="services-cards"></div>
        </section>

        <!-- Permissions -->
        <section class="hmh-tab" id="tab-permissions">
          <div class="hmh-section-head">
            <h2><i class="fa-solid fa-user-shield"></i> Uprawnienia</h2>
            <div class="hmh-head-actions">
              <button class="hmh-btn hmh-btn-primary" id="perm-add">
                <i class="fa-solid fa-user-plus"></i> Dodaj Gracza
              </button>
            </div>
          </div>
          <div class="hmh-list hmh-section-block" id="perm-names"></div>
        </section>

<!-- Cameras -->
<section class="hmh-tab" id="tab-cameras">
  <div class="hmh-section-head">
    <h2><i class="fa-solid fa-video"></i> Kamery</h2>
  </div>

  <div class="hmh-grid hmh-grid-2 hmh-section-block hmh-cam-grid">
    <!-- Inside cameras -->
    <div class="hmh-card hmh-card-soft hmh-cam-card" id="camera-inside-card">
      <div class="hmh-card-head">
        <b>Kamery Wewnętrzne</b>
      </div>
      <p class="hmh-text-muted">
        Monitoruj pomieszczenia i aktywność wewnątrz swojej nieruchomości.
      </p>
      <div class="hmh-cam-action">
        <button class="hmh-btn hmh-btn-primary" id="cam-view-inside">
          <i class="fa-solid fa-eye"></i> Zobacz Wewnątrz
        </button>
      </div>
    </div>

    <!-- Outside cameras -->
    <div class="hmh-card hmh-card-soft hmh-cam-card" id="camera-outside-card">
      <div class="hmh-card-head">
        <b>Kamery Zewnętrzne</b>
      </div>
      <p class="hmh-text-muted">
        Miej oko na podjazd, wejście i obszary na zewnątrz.
      </p>
      <div class="hmh-cam-action">
        <button class="hmh-btn hmh-btn-primary" id="cam-view-outside">
          <i class="fa-solid fa-eye"></i> Zobacz Na Zewnątrz
        </button>
      </div>
    </div>
  </div>
    <!-- Mlo cameras -->
    <div class="hmh-card hmh-card-soft hmh-cam-card" id="camera-mlo-card">
      <div class="hmh-card-head">
        <b>Kamery</b>
      </div>
      <p class="hmh-text-muted">
        Monitoruj wszystkie swoje kamery w czasie rzeczywistym z wysokiej jakości transmisją i natychmiastową widocznością w każdym obszarze swojej nieruchomości.
      </p>
      <div class="hmh-cam-action">
        <button class="hmh-btn hmh-btn-primary" id="cam-view-mlo">
          <i class="fa-solid fa-eye"></i> Zobacz
        </button>
      </div>
    </div>
  </div>  
   <div id="camera-empty" class="hmh-empty-state" style="display:none;">
    <span class="hmh-text-muted">Brak zainstalowanych kamer dla tej nieruchomości.</span>
  </div> 
</section>



        <!-- Upgrades -->
        <section class="hmh-tab" id="tab-upgrades">
          <div class="hmh-section-head">
            <h2><i class="fa-solid fa-arrow-up-right-dots"></i> Ulepszenia</h2>
          </div>
          <div class="hmh-grid hmh-grid-3 hmh-section-block" id="upgrade-list"></div>
        </section>

        <!-- Doorbell -->
        <section class="hmh-tab" id="tab-doorbell">
          <div class="hmh-section-head">
            <h2><i class="fa-solid fa-bell"></i> Dzwonek</h2>
          </div>
          <div class="hmh-card hmh-card-soft hmh-section-block">
            <div class="hmh-row hmh-row-between">
              <div class="hmh-row">
                <span class="hmh-text-muted">Aktualny</span>
                <b id="ringtone-current" style="margin-left:8px">Klasyczny Dzwonek</b>
              </div>
              <button class="hmh-btn hmh-btn-ghost" id="ringtone-preview-current">
                <i class="fa-solid fa-play" style="margin-right: 3px;"></i> Podgląd
              </button>
            </div>
          </div>
          <div class="hmh-table hmh-mt12 hmh-section-block">
            <div class="hmh-thead">
              <div>Nazwa</div><div>Podgląd</div><div>Ustaw</div>
            </div>
            <div class="hmh-tbody" id="ringtone-list"></div>
          </div>
        </section>

		<!-- Positions -->
		<section class="hmh-tab" id="tab-positions">
		  <div class="hmh-section-head">
			<h2><i class="fa-solid fa-location-dot"></i> Pozycje</h2>
			<!-- no head actions, positions are driven from Lua -->
		  </div>

		  <div class="hmh-list hmh-section-block" id="position-list"></div>
		</section>


		<!-- Tenants -->
		<section class="hmh-tab" id="tab-tenants">
		  <div class="hmh-section-head">
			<h2><i class="fa-solid fa-people-roof"></i> Najemcy</h2>
			<div class="hmh-head-actions">
			  <button class="hmh-btn hmh-btn-primary" id="tenant-open-add">
				<i class="fa-solid fa-user-plus"></i> Dodaj Najemcę
			  </button>
			</div>
		  </div>
		  <div class="hmh-table hmh-section-block">
			<div class="hmh-thead">
			  <div>Najemca</div><div>Czynsz</div><div></div>
			</div>
			<div class="hmh-tbody" id="tenant-list"></div>
		  </div>
		</section>


		<!-- Sell -->
		<section class="hmh-tab" id="tab-sell">
		  <div class="hmh-section-head">
			<h2><i class="fa-solid fa-tag"></i> Sprzedaj</h2>
		  </div>
		  <div class="hmh-grid hmh-grid-3 hmh-section-block" id="sell-cards">
			<div class="hmh-card" id="sell-card-player">
			  <div class="hmh-card-head">
				<i class="fa-solid fa-user"></i><b>Sprzedaj Graczowi</b>
			  </div>
			  <p class="hmh-text-muted">Przenieś własność swojej nieruchomości na innego gracza.</p>
			  <button class="hmh-btn hmh-btn-primary" id="sell-open">
				<i class="fa-solid fa-user"></i> Otwórz Pobliskich
			  </button>
			</div>
			<div class="hmh-card" id="sell-card-bank">
			  <div class="hmh-card-head">
				<i class="fa-solid fa-landmark"></i><b>Sprzedaj Bankowi</b>
			  </div>
			  <p class="hmh-text-muted" id="sell-bank-desc">
				Otrzymaj ~70% ceny zakupu.
			  </p>
			  <button class="hmh-btn hmh-btn-primary" id="sell-bank-btn"
					  style="width:100%; justify-content:center;">
				<i class="fa-solid fa-dollar-sign"></i> Sprzedaj
			  </button>
			</div>
			<div class="hmh-card" id="sell-card-realtor">
			  <div class="hmh-card-head">
				<i class="fa-solid fa-store"></i><b>Wystaw w Biurze Nieruchomości</b>
			  </div>
			  <p class="hmh-text-muted" id="sell-realtor-desc">
				Wystaw swoją nieruchomość na sprzedaż na rynku.
			  </p>
			  <button class="hmh-btn hmh-btn-primary" id="sell-realtor-btn"
					  style="width:100%; justify-content:center;">
				<i class="fa-solid fa-sign-hanging"></i> Wystaw
			  </button>
			</div>
		  </div>
		</section>


        <!-- Delivery -->
        <section class="hmh-tab" id="tab-delivery">
          <div class="hmh-section-head">
            <h2><i class="fa-solid fa-truck-fast"></i> Dostawy</h2>
          </div>
          <div class="hmh-grid hmh-grid-3 hmh-section-block" id="delivery-list"></div>
        </section>

<!-- Clean -->
<section class="hmh-tab" id="tab-clean">
  <div class="hmh-section-head">
    <h2><i class="fa-solid fa-broom"></i> Czyszczenie</h2>
  </div>

  <div class="hmh-card hmh-card-soft hmh-clean-card">
    <!-- Hlavička -->
    <div class="hmh-clean-head">
      <div class="hmh-row hmh-row-gap8">
        <b>Stan Nieruchomości</b>
      </div>
      <span id="clean-percent" class="hmh-pill hmh-pill-soft">0%</span>
    </div>

    <!-- Popis -->
<p class="hmh-clean-desc">
  Niższa czystość prowadzi do większego bałaganu, szkodników i nieprzyjemnych zapachów w twojej nieruchomości.
  Utrzymuj swój dom w czystości regularnie, aby wszystko było pod kontrolą.
</p>
    <!-- Progress bar -->
    <div class="hmh-progress hmh-clean-progress">
      <div id="clean-progress" style="width:0%"></div>
    </div>

    <!-- Akce -->
    <div class="hmh-clean-actions">
      <button class="hmh-btn hmh-btn-ghost" id="clean-manual">
        <i class="fa-solid fa-hand"></i> Ręcznie
      </button>
      <button class="hmh-btn hmh-btn-primary" id="clean-robot">
        <i class="fa-solid fa-robot"></i> Robot Odsysający
      </button>
    </div>
  </div>
</section>

      </main>
    </section>

    <!-- Modals -->
    <div class="hmh-modal" id="modal-perm" style="display:none;">
      <div class="hmh-modal-card">
        <div class="hmh-modal-head">
          <b>Zarządzaj Uprawnieniami</b>
          <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-perm">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
        <div id="perm-toggles" class="hmh-perm-grid"></div>
        <div class="hmh-modal-footer">
          <button class="hmh-btn hmh-btn-primary" id="perm-save">
            <i class="fa-solid fa-save"></i> Zapisz
          </button>
        </div>
      </div>
    </div>

    <div class="hmh-modal" id="modal-nearby" style="display:none;">
      <div class="hmh-modal-card">
        <div class="hmh-modal-head">
          <b id="nearby-title">Wybierz Gracza</b>
          <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-nearby">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
        <div class="hmh-list" id="nearby-list"></div>
      </div>
    </div>

	<div class="hmh-modal" id="modal-delivery" style="display:none;">
	  <div class="hmh-modal-card hmh-modal-card-wide">
		<div class="hmh-modal-head">
		  <b id="delivery-title">Dostawa</b>

		  <div id="delivery-cart-row" style="margin-left:auto; display:none; display:flex; align-items:center; gap:12px;">
			<div>
			  <span class="hmh-text-muted">Koszyk:</span>
			  <b><span id="delivery-cart-count">0</span> przedmiotów</b>
			</div>

			<div>
			  <span class="hmh-text-muted">Razem:</span>
			  <b><span id="delivery-cart-total">$0</span></b>
			</div>
		  </div>

		  <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-delivery">
			<i class="fa-solid fa-xmark"></i>
		  </button>
		</div>

		<div class="hmh-catalog" id="delivery-catalog"></div>

		<div class="hmh-modal-footer hmh-modal-footer-sticky">
		  <button class="hmh-btn hmh-btn-primary" id="delivery-order">
			<i class="fa-solid fa-paper-plane"></i> Zamów
		  </button>
		</div>
	  </div>
	</div>

    <div class="hmh-modal" id="modal-position" style="display:none;">
      <div class="hmh-modal-card">
        <div class="hmh-modal-head">
          <b>Dodaj Pozycję</b>
          <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-position">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
        <div class="hmh-choice-grid" id="pos-choice"></div>
        <div class="hmh-modal-footer">
          <button class="hmh-btn hmh-btn-primary" id="pos-confirm" disabled>
            <i class="fa-solid fa-plus"></i> Dodaj
          </button>
        </div>
      </div>
    </div>

    <div class="hmh-modal" id="modal-rent" style="display:none;">
      <div class="hmh-modal-card">
        <div class="hmh-modal-head">
          <b id="rent-title">Ustaw Czynsz</b>
          <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-rent">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
        <div class="hmh-input-stack">
          <input type="number" id="rent-input" placeholder="Czynsz za okres"/>
        </div>
        <div class="hmh-modal-footer">
          <button class="hmh-btn hmh-btn-primary" id="rent-confirm">
            <i class="fa-solid fa-check"></i> Zapisz
          </button>
        </div>
      </div>
    </div>

    <div class="hmh-modal" id="modal-bills" style="display:none;">
      <div class="hmh-modal-card">
        <div class="hmh-modal-head">
          <b>Zarządzaj i Płać Rachunki</b>
          <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-bills">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
        <div class="hmh-table">
          <div class="hmh-thead">
            <div>Rachunek</div><div>Kwota</div><div></div>
          </div>
          <div class="hmh-tbody" id="bills-table"></div>
        </div>
        <div class="hmh-modal-footer">
          <button class="hmh-btn hmh-btn-primary" id="bills-payall">
            <i class="fa-solid fa-credit-card"></i> Zapłać Wszystko
          </button>
        </div>
      </div>
    </div>


    <div class="hmh-modal" id="modal-sell-bank" style="display:none;">
      <div class="hmh-modal-card">
        <div class="hmh-modal-head">
          <b>Potwierdź Sprzedaż</b>
          <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-sell-bank">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
        <p id="sell-bank-text" class="hmh-text-muted">Czy jesteś pewien?</p>
        <div class="hmh-modal-footer">
          <button class="hmh-btn hmh-btn-ghost" data-close="#modal-sell-bank">
            <i class="fa-solid fa-xmark"></i> Nie
          </button>
          <button class="hmh-btn hmh-btn-primary" id="sell-bank-yes">
            <i class="fa-solid fa-check"></i> Tak, sprzedaj
          </button>
        </div>
      </div>
    </div>

    <div class="hmh-modal" id="modal-sell-player" style="display:none;">
      <div class="hmh-modal-card">
        <div class="hmh-modal-head">
          <b>Przenieś Własność</b>
          <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-sell-player">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
        <p id="sell-player-text" class="hmh-text-muted">Are you sure?</p>
        <div class="hmh-modal-footer">
          <button class="hmh-btn hmh-btn-ghost" data-close="#modal-sell-player">
            <i class="fa-solid fa-xmark"></i> Cancel
          </button>
          <button class="hmh-btn hmh-btn-primary" id="sell-player-yes">
            <i class="fa-solid fa-check"></i> Confirm Transfer
          </button>
        </div>
      </div>
    </div>
	<!-- Order Key -->
	<div class="hmh-modal" id="modal-key-order" style="display:none;">
	  <div class="hmh-modal-card">
		<div class="hmh-modal-head">
		  <b>Zamów Klucz</b>
		  <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-key-order">
			<i class="fa-solid fa-xmark"></i>
		  </button>
		</div>
		<p id="key-order-text" class="hmh-text-muted"></p>
		<div class="hmh-modal-footer">
		  <button class="hmh-btn hmh-btn-ghost" data-close="#modal-key-order">
			<i class="fa-solid fa-xmark"></i> Anuluj
		  </button>
		  <button class="hmh-btn hmh-btn-primary" id="key-order-confirm">
			<i class="fa-solid fa-key"></i> Zamów
		  </button>
		</div>
	  </div>
	</div>

	<!-- Change Lock -->
	<div class="hmh-modal" id="modal-key-lock" style="display:none;">
	  <div class="hmh-modal-card">
		<div class="hmh-modal-head">
		  <b>Zmień Zamek</b>
		  <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-key-lock">
			<i class="fa-solid fa-xmark"></i>
		  </button>
		</div>
		<p id="key-lock-text" class="hmh-text-muted"></p>
		<div class="hmh-modal-footer">
		  <button class="hmh-btn hmh-btn-ghost" data-close="#modal-key-lock">
			<i class="fa-solid fa-xmark"></i> Anuluj
		  </button>
		  <button class="hmh-btn hmh-btn-primary" id="key-lock-confirm">
			<i class="fa-solid fa-rotate"></i> Potwierdź
		  </button>
		</div>
	  </div>
	</div>
	
<div class="hmh-modal" id="modal-tenant-details" style="display:none;">
  <div class="hmh-modal-card">
    <div class="hmh-modal-head">
      <b>Szczegóły Najemcy</b>
      <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-tenant-details">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>
    <div class="hmh-detail-stack">
      <div><span class="hmh-text-muted">Najemca</span><br><b id="tenant-det-name"></b></div>
      <div><span class="hmh-text-muted">Czynsz</span><br><b id="tenant-det-rent"></b></div>
      <div><span class="hmh-text-muted">Od</span><br><b id="tenant-det-since"></b></div>
    </div>
    <div class="hmh-modal-footer">
      <button class="hmh-btn hmh-btn-ghost" data-close="#modal-tenant-details">
        <i class="fa-solid fa-xmark"></i> Zamknij
      </button>
      <button class="hmh-btn hmh-btn-primary" id="tenant-det-cancel">
        <i class="fa-solid fa-ban"></i> Anuluj Najem
      </button>
    </div>
  </div>
</div>
<!-- Upgrade Info -->
<div class="hmh-modal" id="modal-upgrade-info" style="display:none;">
  <div class="hmh-modal-card">
    <div class="hmh-modal-head">
      <b id="upgrade-info-title">Szczegóły ulepszenia</b>
      <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-upgrade-info">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>
    <div class="hmh-modal-body">
      <p id="upgrade-info-text" class="hmh-text-muted"></p>
    </div>
    <div class="hmh-modal-footer">
      <button class="hmh-btn hmh-btn-ghost" data-close="#modal-upgrade-info">
        <i class="fa-solid fa-xmark"></i> Zamknij
      </button>
    </div>
  </div>
</div>
<!-- Upgrade Buy Confirm -->
<div class="hmh-modal" id="modal-upgrade-confirm" style="display:none;">
  <div class="hmh-modal-card">
    <div class="hmh-modal-head">
      <b>Kup ulepszenie</b>
      <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-upgrade-confirm">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>
    <div class="hmh-modal-body">
      <p id="upgrade-confirm-text" class="hmh-text-muted"></p>
    </div>
    <div class="hmh-modal-footer">
      <button class="hmh-btn hmh-btn-ghost" data-close="#modal-upgrade-confirm">
        <i class="fa-solid fa-xmark"></i> Anuluj
      </button>
      <button class="hmh-btn hmh-btn-primary" id="upgrade-confirm-yes">
        <i class="fa-solid fa-cart-shopping"></i> Kup
      </button>
    </div>
  </div>
</div>
	

    <div class="hmh-modal" id="modal-settings" style="display:none;">
      <div class="hmh-modal-card">
        <div class="hmh-modal-head">
          <b>Ustawienia Interfejsu</b>
          <button class="hmh-icon-btn hmh-icon-btn-close" data-close="#modal-settings">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>
        <div class="hmh-settings-row">
          <label for="accent-picker">Kolor główny</label>
          <input id="accent-picker" type="color" value="#ff66ff" />
        </div>
        <div class="hmh-modal-footer">
          <button class="hmh-btn hmh-btn-primary" id="resetuicolor">
            Resetuj
          </button>		
          <button class="hmh-btn hmh-btn-primary" id="saveuicolor" data-close="#modal-settings">
            Gotowe
          </button>
        </div>
      </div>
    </div>
  `);
}


function activateTab(key) {
   $(".hmh-nav-item").removeClass("active");
   $(`.hmh-nav-item[data-tab="${key}"]`).addClass("active");
   $(".hmh-content > .hmh-tab").removeClass("active");
   $(`#tab-${key}`).addClass("active");
}


const billsTotalDue = () =>
   (STATE.bills || [])
   .filter(b => !b.paid)
   .reduce((a, b) => a + Number(b.amount || 0), 0);

function renderBillsDashboard() {
   const due = billsTotalDue();
   $("#bill-total").text(moneymanagment(due));
   const $ul = $("#bills-list").empty();
   const unpaid = (STATE.bills || []).filter(b => !b.paid);

   if (unpaid.length === 0) {
      $ul.append(`<li class="hmh-text-muted">Wszystkie rachunki opłacone</li>`);
   } else {
      unpaid.forEach(b => {
         $ul.append(`<li><span>${b.name}</span><span>${moneymanagment(b.amount)}</span></li>`);
      });
   }
}

function renderBillsModal() {
   const $tb = $("#bills-table").empty();
   (STATE.bills || [])
   .filter(b => !b.paid)
      .forEach(b => {
         $tb.append(`
        <div class="hmh-tbody-row">
          <div>${b.name}</div>
          <div>${moneymanagment(b.amount)}</div>
          <div class="hmh-row hmh-row-right">
            <button class="hmh-btn hmh-btn-primary" data-action="bill-pay" data-id="${b.id}">
              <i class="fa-solid fa-check"></i> Zapłać
            </button>
          </div>
        </div>
      `);
      });
   updatePermissionedButtons();
}


function renderTop() {
   $("#prop-address").text(STATE.meta.address || "");
   $("#prop-owner").html(`<i class="fa-solid fa-user"></i> ${STATE.meta.owner || ""}`);
   $("#prop-type").text(STATE.meta.type || "Nieruchomość");
   $("#prop-status").text(STATE.meta.status || "");
}

function renderDashboard() {
   renderBillsDashboard();

   if (STATE.lastWarning) {
      $("#last-warning-box").show();
   } else {
      $("#last-warning-box").hide();
   }


   if (STATE.canCancelRent) {
      $("#cancel-rent-box").show();
   } else {
      $("#cancel-rent-box").hide();
   }


   if (STATE.canCancelTenancy) {
      $("#cancel-tenancy-box").show();
   } else {
      $("#cancel-tenancy-box").hide();
   }


   const $log = $("#visitor-log").empty();
   (STATE.visitorLog || []).forEach(e => {
      $log.append(`
      <div class="hmh-list-item">
        <span>${e.text}</span>
        <span class="hmh-time">${e.ago}</span>
      </div>
    `);
   });

   const $tips = $("#tips-list").empty();
   if (!STATE.tips || !STATE.tips.length) {
      $tips.append('<li class="hmh-text-muted">Brak wskazówek.</li>');
   } else {
      STATE.tips.forEach(t => {
         $tips.append(`<li>${t}</li>`);
      });
   }
}

function renderFurniture() {}

function renderKeys() {
   const $l = $("#keys-list").empty();
   (STATE.keys || []).forEach(k => {
      const label = k.identifier || k.label || k.name || `Klucz #${k.id}`;
      $l.append(`
      <div class="hmh-list-item">
        <div style="padding: 6px;"><i class="fa-solid fa-key" style="margin-right: 5px;"></i> ${label}</div>
      </div>
    `);
   });
}

function serviceCard(key, icon, label, connected, rowsHtml) {
   const chipClass = connected ?
      "hmh-service-chip hmh-service-chip-on" :
      "hmh-service-chip hmh-service-chip-off";
   return `
    <div class="hmh-service-card">
      <div class="hmh-service-head">
        <div class="hmh-service-title">
          <i class="fa-solid ${icon}"></i> ${label}
        </div>
        <span class="${chipClass}">${connected ? "Podłączone" : "Rozłączone"}</span>
      </div>
      <div class="hmh-service-rows">${rowsHtml}</div>
      <div class="hmh-row hmh-row-right">
        <button class="hmh-btn hmh-btn-ghost" data-action="toggle-service" data-key="${key}">
          <i class="fa-solid fa-power-off"></i> ${connected ? "Rozłącz" : "Podłącz"}
        </button>
      </div>
    </div>
  `;
}

function renderServices() {
   const s = STATE.services || {};
   const $g = $("#services-cards").empty();

   if (s.electricity) {
      $g.append(
         serviceCard(
            "electricity",
            "fa-bolt",
            "Electricity",
            s.electricity.connected,
            `<div>Zużycie: <b>${s.electricity.consumption}${s.electricity.unit}</b></div>
         <div>Stawka ${s.electricity.unit}: <b>${moneymanagment(s.electricity.ratePerUnit)}</b></div>`
         )
      );
   }
   if (s.water) {
      $g.append(
         serviceCard(
            "water",
            "fa-droplet",
            "Water",
            s.water.connected,
            `<div>Zużycie: <b>${s.water.consumption}${s.water.unit}</b></div>
         <div>Stawka ${s.water.unit}: <b>${moneymanagment(
           s.water.ratePerUnit
         )}</b></div>`
         )
      );
   }
   if (s.internet) {
      $g.append(
         serviceCard(
            "internet",
            "fa-wifi",
            "Internet",
            s.internet.connected,
            `<div>Zużycie: <b>${s.internet.consumption}${s.internet.unit}</b></div>
         <div>Stawka ${s.internet.unit}: <b>${moneymanagment(s.internet.ratePerUnit)}</b></div>`
         )
      );
   }
}

function renderPermissionsNames() {
   const $l = $("#perm-names").empty();
   (STATE.permissions || []).forEach(p => {
      $l.append(`
      <div class="hmh-list-item">
        <div class="hmh-who"><i class="fa-solid fa-user" style="margin-right: 2px;"></i> ${p.name}</div>
        <div class="hmh-row">
          <button class="hmh-btn hmh-btn-ghost" data-action="perm-manage" data-id="${p.id}">
            <i class="fa-solid fa-sliders"></i> Zarządzaj
          </button>
          <button class="hmh-btn hmh-btn-ghost" data-action="perm-remove" data-id="${p.id}">
            <i class="fa-solid fa-trash"></i>
          </button>
        </div>
      </div>
    `);
   });
}

function renderPermToggles(id) {
   const pl = (STATE.permissions || []).find(p => String(p.id) === String(id));
   const $g = $("#perm-toggles").empty();
   if (!pl) return;

   pl.toggles = pl.toggles || {};

   const visCfg = STATE.permissionsToggled || {};

   let anyRendered = false;

   (STATE.permissionDefs || []).forEach(def => {

      if (visCfg.hasOwnProperty(def.key) && visCfg[def.key] === false) {
         return;
      }

      if (typeof pl.toggles[def.key] === "undefined") {
         pl.toggles[def.key] = false;
      }
      const checked = !!pl.toggles[def.key];

      $g.append(`
      <div class="hmh-perm-item">
        <span>${def.label}</span>
        <label class="hmh-switch">
          <input type="checkbox"
                 data-action="perm-toggle"
                 data-id="${pl.id}"
                 data-key="${def.key}"
                 ${checked ? "checked" : ""}/>
          <span></span>
        </label>
      </div>
    `);

      anyRendered = true;
   });

   if (!STATE.permissionDefs.length || !anyRendered) {
      $g.append(`<div class="hmh-text-muted">Brak skonfigurowanych definicji uprawnień.</div>`);
   }
}

function renderCameras() {}


function renderUpgrades() {
   const $g = $("#upgrade-list").empty();

   (STATE.upgrades || []).forEach(u => {
      const owned = !!u.owned;

      const label = owned ?
         "Ulepszenie zainstalowane" :
         `Cena: ${moneymanagment(u.price)}`;

      const rightButton = owned ?
         `<button class="hmh-btn hmh-btn-primary hmh-upgrade-btn-placeholder" disabled>
           <i class="fa-solid fa-cart-plus"></i> Kup
         </button>` :
         `<button class="hmh-btn hmh-btn-primary"
                 data-action="upgrade-buy"
                 data-id="${u.id}">
           <i class="fa-solid fa-cart-plus"></i> Kup
         </button>`;

      $g.append(`
      <div class="hmh-card hmh-upgrade-card">
        <div class="hmh-card-head hmh-row hmh-row-between">
          <div class="hmh-row hmh-row-gap8">
            <i class="fa-solid fa-screwdriver-wrench"></i>
            <b>${u.name}</b>
          </div>
          <button class="hmh-upgrade-info-icon"
                  title="Szczegóły"
                  data-action="upgrade-info"
                  data-id="${u.id}">
            <i class="fa-solid fa-circle-info"></i>
          </button>
        </div>

        <div class="hmh-upgrade-footer">
          <span class="hmh-text-muted">${label}</span>
          <div class="hmh-upgrade-footer-right">
            ${rightButton}
          </div>
        </div>
      </div>
    `);
   });
}


function renderDoorbell() {
   $("#ringtone-current").text(getCurrentDoorbellName() || "");
   const $tb = $("#ringtone-list").empty();
   (STATE.doorbell.list || []).forEach(r => {
      $tb.append(`
      <div class="hmh-tbody-row">
        <div>${r.label}</div>
        <div>
          <button class="hmh-btn hmh-btn-ghost" data-action="ringtone-preview" data-src="${r.sound}">
            <i class="fa-solid fa-play" style="margin-right: 3px;"></i> Podgląd
          </button>
        </div>
        <div>
          <button class="hmh-btn hmh-btn-primary" data-action="ringtone-set" data-id="${r.id}">
            <i class="fa-solid fa-bell"></i> Ustaw
          </button>
        </div>
      </div>
    `);
   });
}

function renderPositions() {
   const $list = $("#position-list").empty();

   (STATE.positions || []).forEach(pos => {


      let label = pos.label;
      if (!label && pos.type) {
         const t = String(pos.type);
         label = t.charAt(0).toUpperCase() + t.slice(1);
      }
      if (!label) {
         label = "Pozycja";
      }

      $list.append(`
      <div class="hmh-list-item">
        <div>${label}</div>
        <div class="hmh-row">
          <button class="hmh-btn hmh-btn-ghost"
                  data-action="position-change"
                  data-id="${pos.id}">
            <i class="fa-solid fa-location-dot" style="margin-right: 3px;"></i> Zmień pozycję
          </button>
        </div>
      </div>
    `);
   });

   if (!STATE.positions || !STATE.positions.length) {
      $list.append(`
      <div class="hmh-list-item">
        <div class="hmh-text-muted">Brak zdefiniowanych pozycji dla tej nieruchomości.</div>
      </div>
    `);
   }
}


function renderTenants() {
   const $tb = $("#tenant-list").empty();

   (STATE.tenants || []).forEach(t => {
      const start =
         t.startDate || t.startedAt || t.since || t.sinceLabel || "";
      $tb.append(`
      <div class="hmh-tbody-row">
        <div>${t.name}</div>
        <div>${moneymanagment(t.rent)}</div>
        <div class="hmh-row hmh-row-right">
          <button class="hmh-btn hmh-btn-ghost" data-action="tenant-details" data-id="${t.id}">
            <i class="fa-solid fa-circle-info" style="margin-right: 1px;"></i> Szczegóły
          </button>
        </div>
      </div>
    `);
   });
}

let TENANT_DETAILS_ID = null;


function renderDelivery() {
   const $g = $("#delivery-list").empty();
   (STATE.deliveryCategories || []).forEach(cat => {
      const iconClass = cat.icon ?
         cat.icon :
         cat.id === "food" ?
         "fa-utensils" :
         cat.id === "groceries" ?
         "fa-basket-shopping" :
         "fa-truck-fast";

      $g.append(`
      <div class="hmh-card">
        <div class="hmh-card-head">
          <i class="fa-solid ${iconClass}"></i><b>${cat.name}</b>
        </div>
        <div class="hmh-text-muted">${cat.description || ""}</div>
        <div class="hmh-row hmh-row-right">
          <button class="hmh-btn hmh-btn-primary" data-action="open-delivery" data-id="${cat.id}">
             <i class="fa-solid fa-paper-plane"></i> Order
          </button>
        </div>
      </div>
    `);
   });
}


function renderCleanliness() {
   const raw = Number(STATE.cleanlinessPercent || 0);
   const pct = Math.max(0, Math.min(100, Math.round(raw)));

   $("#clean-percent").text(`${pct}%`);
   $("#clean-progress").css("width", pct + "%");

   const $robotBtn = $("#clean-robot");


   if (!STATE.robotVacuumPurchased) {
      $robotBtn.hide();
      return;
   }


   if (STATE.vacuumInProgress) {
      $robotBtn
         .show()
         .prop("disabled", false)
         .removeClass("hmh-btn-ghost")
         .addClass("hmh-btn-primary")
         .html('<i class="fa-solid fa-robot"></i> Zatrzymaj Odsysanie');
   } else {
      $robotBtn
         .show()
         .prop("disabled", false)
         .removeClass("hmh-btn-ghost")
         .addClass("hmh-btn-primary")
         .html('<i class="fa-solid fa-robot"></i> Robot Odsysający');
   }
}


function renderSell() {
   const meta = STATE.meta || {};
   const pct = Number(meta.bankSellPercent || 0);
   const clampedPct = Math.max(0, Math.min(100, pct));
   $("#sell-bank-desc").text(
      clampedPct ?
      `Otrzymaj około ${clampedPct}% pierwotnej ceny zakupu.` :
      "Otrzymaj zwrot pieniędzy od banku."
   );

   $("#sell-card-player").toggle(meta.canSellToPlayer !== false);
   $("#sell-card-bank").toggle(meta.canSellToBank !== false);
   $("#sell-card-realtor").toggle(meta.canListRealEstate !== false);
}

function renderAll() {
   renderTop();
   renderDashboard();
   renderFurniture();
   renderKeys();
   renderServices();
   renderPermissionsNames();
   renderCameras();
   renderUpgrades();
   renderDoorbell();
   renderPositions();
   renderTenants();
   renderDelivery();
   renderCleanliness();
   renderSell();
}


let DELIVERY_CART = {};
let CURRENT_CAT = null;
let CURRENT_CAT_CONFIG = null;

function updateDeliveryCartCount() {
   let totalQty = 0;
   let totalPrice = 0;

   Object.entries(DELIVERY_CART).forEach(([itemId, qty]) => {
      totalQty += qty;

      const item =
         CURRENT_CAT_CONFIG &&
         Array.isArray(CURRENT_CAT_CONFIG.items) ?
         CURRENT_CAT_CONFIG.items.find(i => String(i.id) === String(itemId)) :
         null;

      if (item && typeof item.price === "number") {
         totalPrice += item.price * qty;
      }
   });

   $("#delivery-cart-count").text(totalQty);

   const formattedTotal =
      totalPrice > 0 ? `$${totalPrice.toLocaleString("en-US")}` : "$0";

   $("#delivery-cart-total").text(formattedTotal);
}

function fillCatalog(cat) {
   const $c = $("#delivery-catalog").empty();
   if (!cat || !Array.isArray(cat.items)) return;

   const useCart = !!cat.useCart;
   const allowQty = !!cat.allowQuantity;


   const categoryIconClass = cat.icon ?
      cat.icon :
      cat.id === "food" ?
      "fa-utensils" :
      cat.id === "groceries" ?
      "fa-basket-shopping" :
      "fa-box";

   cat.items.forEach(item => {
      const priceText =
         typeof item.price === "number" ? `$${item.price}` : "";


      const shouldUseImage =
         item.useImage === true ||
         (typeof item.useImage === "undefined" && !!item.image);
      const thumbHtml = shouldUseImage && item.image ?
         `<img src="${item.image}" alt="${item.title || ""}"/>` :
         `<i class="fa-solid ${categoryIconClass}"></i>`;
      const thumbBlock = item.useImage === true && item.image ?
         `<div class="hmh-cat-thumb">${thumbHtml}</div>` :
         "";

      if (!useCart) {

         $c.append(`
        <div class="hmh-cat-card">
          <div class="hmh-cat-thumb">
            ${thumbHtml}
          </div>
          <div class="hmh-cat-title">${item.title || "Przedmiot"}</div>
          <div class="hmh-cat-desc">${item.description || ""}</div>
          <div class="hmh-row hmh-row-between hmh-mt8">
            <span class="hmh-text-muted">
              <strong style="color:#ffffff;font-weight:700;">${priceText}</strong>
            </span>
            <button class="hmh-btn hmh-btn-primary"
                    data-action="catalog-pick"
                    data-id="${item.id}">
              <i class="fa-solid fa-paper-plane"></i> Zamów
            </button>
          </div>
        </div>
      `);
      } else {

         $c.append(`
        <div class="hmh-cat-card">
			${thumbBlock}

          <div class="hmh-cat-title">${item.title || "Przedmiot"}</div>
          <div class="hmh-cat-desc">${item.description || ""}</div>
          <div class="hmh-row hmh-row-between hmh-mt8">
            <span class="hmh-text-muted">
              <strong style="color:#ffffff;font-weight:700;">${priceText}</strong>
            </span>
            ${
              allowQty
                ? `<div class="hmh-row">
                     <button class="hmh-btn hmh-btn-ghost"
                             data-action="cart-dec"
                             data-id="${item.id}">
                       -
                     </button>
                     <span id="cart-qty-${item.id}">0</span>
                     <button class="hmh-btn hmh-btn-ghost"
                             data-action="cart-inc"
                             data-id="${item.id}">
                       +
                     </button>
                   </div>`
                : `<button class="hmh-btn hmh-btn-primary"
                           data-action="catalog-add"
                           data-id="${item.id}">
                     Dodaj
                   </button>`
            }
          </div>
        </div>
      `);
      }
   });
}


function openDeliveryCategory(catId) {
   const cat = (STATE.deliveryCategories || []).find(c => c.id === catId);
   if (!cat) return;

   CURRENT_CAT = catId;
   CURRENT_CAT_CONFIG = cat;
   DELIVERY_CART = {};

   $("#delivery-title").text(cat.name || "Dostawa");

   if (cat.useCart) {
      $("#delivery-cart-row").show();
      $("#delivery-order").show();
   } else {
      $("#delivery-cart-row").hide();
      $("#delivery-order").hide();
   }

   fillCatalog(cat);
   $("#modal-delivery").show();
   updateDeliveryCartCount();
}


let NEARBY_MODE = null;
let SELL_TARGET = null;

function openNearbyPicker(mode, title) {
   NEARBY_MODE = mode;
   $("#nearby-title").text(title || "Wybierz Gracza");

   const $l = $("#nearby-list").empty().append(`
    <div class="hmh-text-muted">Ładowanie pobliskich graczy…</div>
  `);


   $.post(`https://${GetParentResourceName()}/nearby_fetch_players`, JSON.stringify({}), function (players) {
      STATE.nearbyPlayers = players || [];
      renderNearbyList();
      $("#modal-nearby").show();
   });
}

function renderNearbyList() {
   const $l = $("#nearby-list").empty();
   (STATE.nearbyPlayers || []).forEach(p => {
      $l.append(`
      <div class="hmh-list-item" data-id="${p.id}">
        <div class="hmh-who">
          <i class="fa-solid fa-user"></i> ${p.name}
          <span class="hmh-text-muted">(ID ${p.id})</span>
        </div>
        <button class="hmh-btn hmh-btn-ghost" data-action="nearby-pick" data-id="${p.id}">
          Wybierz
        </button>
      </div>
    `);
   });
}


function mergeStateFromServer(data) {
   if (!data) return;

   Object.assign(STATE.meta, data.meta || {});

   STATE.bills = data.bills || [];
   STATE.furniture = data.furniture || [];
   STATE.keys = data.keys || [];
   STATE.services = data.services || {};
   STATE.permissionDefs = data.permissionDefs || [];
   STATE.permissions = data.permissions || [];
   STATE.sectionPermissions = data.sectionPermissions || {};
   STATE.permissionsToggled = data.permissionsToggled || data.permissionToggles || STATE.permissionsToggled || {};
   STATE.cameraLocations = data.cameraLocations || STATE.cameraLocations;
   STATE.upgrades = data.upgrades || [];
   STATE.doorbell = data.doorbell || {
      currentId: 1,
      list: []
   };
   STATE.positionTypes = data.positionTypes || [];
   STATE.positions = data.positions || [];
   STATE.tenants = data.tenants || [];
   STATE.deliveryCategories = data.deliveryCategories || [];
   STATE.visitorLog = data.visitorLog || [];
   STATE.nearbyPlayers = data.nearbyPlayers || [];
   STATE.tips = data.tips || [];
   STATE.cleanlinessPercent =
      typeof data.cleanlinessPercent !== "undefined" ?
      data.cleanlinessPercent :
      typeof data.cleanliness !== "undefined" ?
      data.cleanliness :
      STATE.cleanlinessPercent;


   STATE.robotVacuumPurchased =
      typeof data.robotVacuumPurchased !== "undefined" ?
      data.robotVacuumPurchased :
      typeof data.robotvacuum !== "undefined" ?
      data.robotvacuum :
      STATE.robotVacuumPurchased;

   STATE.vacuumInProgress =
      typeof data.vacuumInProgress !== "undefined" ?
      data.vacuumInProgress :
      typeof data.vacuuminprogress !== "undefined" ?
      data.vacuuminprogress :
      STATE.vacuumInProgress;

   STATE.cleanlinessPercent =
      typeof data.cleanlinessPercent !== "undefined" ?
      data.cleanlinessPercent :
      typeof data.cleanliness !== "undefined" ?
      data.cleanliness :
      STATE.cleanlinessPercent;


   STATE.robotVacuumPurchased =
      typeof data.robotVacuumPurchased !== "undefined" ?
      data.robotVacuumPurchased :
      typeof data.robotvacuum !== "undefined" ?
      data.robotvacuum :
      STATE.robotVacuumPurchased;

   STATE.vacuumInProgress =
      typeof data.vacuumInProgress !== "undefined" ?
      data.vacuumInProgress :
      typeof data.vacuuminprogress !== "undefined" ?
      data.vacuuminprogress :
      STATE.vacuumInProgress;


   STATE.orderKeyPrice =
      typeof data.orderKeyPrice !== "undefined" ?
      data.orderKeyPrice :
      STATE.orderKeyPrice;

   STATE.changeLockPrice =
      typeof data.changeLockPrice !== "undefined" ?
      data.changeLockPrice :
      STATE.changeLockPrice;


   STATE.lastWarning =
      typeof data.lastWarning !== "undefined" ?
      data.lastWarning :
      typeof data.lastwarning !== "undefined" ?
      data.lastwarning :
      STATE.lastWarning;

   STATE.canCancelRent =
      typeof data.canCancelRent !== "undefined" ?
      !!data.canCancelRent :
      STATE.canCancelRent;

   STATE.canCancelTenancy =
      typeof data.canCancelTenancy !== "undefined" ?
      !!data.canCancelTenancy :
      STATE.canCancelTenancy;


   if (typeof STATE.meta.canSellToPlayer === "undefined") {
      STATE.meta.canSellToPlayer = true;
   }
   if (typeof STATE.meta.canSellToBank === "undefined") {
      STATE.meta.canSellToBank = true;
   }
   if (typeof STATE.meta.canListRealEstate === "undefined") {
      STATE.meta.canListRealEstate = true;
   }

   if (STATE.doorbell.currentId == null && STATE.doorbell.list && STATE.doorbell.list.length > 0) {
      const byName = STATE.doorbell.current ?
         STATE.doorbell.list.find(x => String(x.label) === String(STATE.doorbell.current)) :
         null;

      STATE.doorbell.currentId = byName ? byName.id : STATE.doorbell.list[0].id;
   }


   if (!Array.isArray(STATE.permissionDefs)) {
      const obj = STATE.permissionDefs;
      STATE.permissionDefs = [];
      if (obj && typeof obj === "object") {
         Object.keys(obj).forEach(k => {
            STATE.permissionDefs.push({
               key: k,
               label: String(obj[k])
            });
         });
      }
   }


   if (
      (!STATE.permissionDefs || !STATE.permissionDefs.length) &&
      STATE.permissions &&
      STATE.permissions.length > 0 &&
      STATE.permissions[0].toggles
   ) {
      STATE.permissionDefs = Object.keys(STATE.permissions[0].toggles).map(k => ({
         key: k,
         label: k
            .replace(/([A-Z])/g, " $1")
            .replace(/^./, c => c.toUpperCase()),
      }));
   }


   if (!STATE.permissionDefs || !STATE.permissionDefs.length) {
      STATE.permissionDefs = [{
            key: "furnitureMenu",
            label: "Menu Mebli"
         },
         {
            key: "unlocking",
            label: "Otwieranie"
         },
         {
            key: "wardrobe",
            label: "Szafa"
         },
         {
            key: "storage",
            label: "Magazyn"
         },
         {
            key: "manageKeys",
            label: "Zarządzaj Kluczami"
         },
         {
            key: "upgrades",
            label: "Ulepszenia"
         },
         {
            key: "payBills",
            label: "Płać Rachunki"
         },
         {
            key: "garage",
            label: "Dostęp do Garażu"
         },
         {
            key: "orderServices",
            label: "Zamów Usługi"
         },
         {
            key: "tenants",
            label: "Dostęp Najemców"
         },
         {
            key: "cameras",
            label: "Kamery"
         },
         {
            key: "doorbell",
            label: "Dzwonek"
         },
         {
            key: "clean",
            label: "Czyszczenie"
         },
         {
            key: "services",
            label: "Usługi"
         },
         {
            key: "positions",
            label: "Pozycje"
         },
      ];
   }
}

function applySectionPermissions() {
   const perms = STATE.sectionPermissions || {};
   $(".hmh-nav-item").each(function () {
      const key = $(this).data("tab");
      const allowed = perms[key] !== false;
      $(this).toggle(allowed);

      if (!allowed) {
         $(`#tab-${key}`).removeClass("active");
      }
   });

   const $active = $(".hmh-nav-item.active:visible");
   if (!$active.length) {
      activateTab("dashboard");
   }
}

function updateCameraUI(insideEnabled, outsideEnabled, mloenabled) {


   $("#camera-inside-card").toggle(insideEnabled);


   $("#camera-outside-card").toggle(outsideEnabled);
   $("#camera-mlo-card").toggle(mloenabled);


   $("#camera-empty").toggle(!insideEnabled && !outsideEnabled && !mloenabled);
}


function openHouseManagementUI(serverState) {
   activateTab("dashboard");
   $("#house-ui").css("display", "flex");
   mergeStateFromServer(serverState || {});
   updateCameraUI(
      !!serverState.cameraInsideEnabled,
      !!serverState.cameraOutsideEnabled,
      !!serverState.cameraMloEnabled,
   );
   renderAll();
   applySectionPermissions();
   updatePermissionedButtons();
}


let TENANT_PICK = null;
let TENANT_EDIT_ID = null;
let POS_SELECTED = null;

let PENDING_UPGRADE_ID = null;


$(document).on("click", ".hmh-nav-item", function () {
   const tab = $(this).data("tab");


   activateTab(tab);
});


$("#house-ui").on("click", "#hm-close", () => {
   $("#house-ui").hide();
   sendNui("hm_close", {
      property: STATE.meta
   });
});


$("#house-ui").on("click", "#warning-open-bills", () => {
   if (!hasPayBillsPermission()) return;
   renderBillsModal();
   $("#modal-bills").show();
});

$("#house-ui").on("click", "#btn-cancel-rent", () => {
   sendNui("CancelRent", {
      houseId: STATE.meta.propertyId
   });
});

$("#house-ui").on("click", "#btn-cancel-tenancy", () => {
   sendNui("CancelTenancy", {
      houseId: STATE.meta.propertyId
   });
});


$("#house-ui").on("click", "#cam-view-inside", () => {

   sendNui("viewCameraInside", {
      property: STATE.meta
   });
});


$("#house-ui").on("click", "#cam-view-outside", () => {


   sendNui("viewCameraOutside", {
      property: STATE.meta
   });
});


$("#house-ui").on("click", "#cam-view-mlo", () => {

   sendNui("viewCameraOutside", {
      property: STATE.meta
   });

});

$("#house-ui").on("click", "#saveuicolor", function () {
    const accent = $("#accent-picker").val();
    setTheme(accent);
    localStorage.setItem("housing_theme", accent);
});

$("#house-ui").on("click", "#resetuicolor", function () {
    const accent = "#ff66ff";
    setTheme(accent);
    localStorage.setItem("housing_theme", accent);
});



$("#house-ui").on("click", "#hm-settings", () => $("#modal-settings").show());
$("#house-ui").on("input change", "#accent-picker", function () {
   setTheme($(this).val());
});


$("#house-ui").on("click", "#dash-bills-manage", () => {
   if (!hasPayBillsPermission()) return;
   renderBillsModal();
   $("#modal-bills").show();
});


$("#house-ui").on("click", "#services-pay", () => {
   if (!hasPayBillsPermission()) return;
   renderBillsModal();
   $("#modal-bills").show();
});

$("#house-ui").on("click", "#furn-open-menu", () => {
   sendNui("hm_openFurnitureMenu", {
      property: STATE.meta
   });
});


$("#house-ui").on("click", '[data-action="bill-pay"]', function () {
   if (!hasPayBillsPermission()) return;
   const id = $(this).data("id");
   const b = (STATE.bills || []).find(x => x.id === id);
   if (b) {
      sendNui("hm_payBill", {
         billId: id,
         amount: b.amount,
         property: STATE.meta,
      });
   }
   updatePermissionedButtons();
});

$("#house-ui").on("click", '[data-action="upgrade-buy"]', function () {
   const id = $(this).data("id");
   const upg = (STATE.upgrades || []).find(u => String(u.id) === String(id));
   if (!upg) return;

   PENDING_UPGRADE_ID = upg.id;

   $("#upgrade-confirm-text").html(
      `Czy chcesz kupić <strong>${upg.name}</strong> za <strong>${moneymanagment(
      upg.price || 0
    )}</strong>?`
   );

   $("#modal-upgrade-confirm").show();
});

$("#house-ui").on("click", "#upgrade-confirm-yes", () => {
   if (!PENDING_UPGRADE_ID) return;

   const id = PENDING_UPGRADE_ID;
   const upg = (STATE.upgrades || []).find(u => String(u.id) === String(id));
   if (!upg) return;

   sendNui("hm_buyUpgrade", {
      upgradeId: upg.id,
      price: upg.price || 0,
      property: STATE.meta
   });

   PENDING_UPGRADE_ID = null;
   $("#modal-upgrade-confirm").hide();
});


$("#house-ui").on("click", "#bills-payall", function () {
   if (!hasPayBillsPermission()) return;
   sendNui("hm_payAllBills", {
      property: STATE.meta,
   });
   updatePermissionedButtons();
});


$("#house-ui").on("click", '[data-action="remove-furn"]', function () {
   const id = Number($(this).data("id"));
   STATE.furniture = (STATE.furniture || []).filter(f => f.id !== id);
   sendNui("hm_removeFurniture", {
      furnitureId: id,
      property: STATE.meta,
   });
   renderFurniture();
});

$("#house-ui").on("click", '[data-action="upgrade-info"]', function () {
   const id = $(this).data("id");
   const upg = (STATE.upgrades || []).find(u => String(u.id) === String(id));
   if (!upg) return;

   $("#upgrade-info-title").text(upg.name || "Szczegóły ulepszenia");
   $("#upgrade-info-text").text(
      upg.description ||
      "Brak opisu dla tego ulepszenia."
   );

   $("#modal-upgrade-info").show();
});


$("#house-ui").on("click", "#key-order", () => {
   const price = Number(STATE.orderKeyPrice || 0);
   if (price > 0) {
      $("#key-order-text").html(
         `Czy chcesz zamówić nowy klucz za <strong style="font-weight:700;">${moneymanagment(
        price
      )}</strong>?`
      );
   } else {
      $("#key-order-text").text("Czy chcesz zamówić nowy klucz?");
   }
   $("#modal-key-order").show();
});


$("#house-ui").on("click", "#key-order-confirm", () => {

   sendNui("hm_orderKey", {
      property: STATE.meta,
   });

   $("#modal-key-order").hide();
});


$("#house-ui").on("click", "#key-change-lock", () => {
   const price = Number(STATE.changeLockPrice || 0);
   if (price > 0) {
      $("#key-lock-text").html(
         `Czy chcesz zmienić zamek za <strong style="font-weight:700;">${moneymanagment(
        price
      )}</strong>? Wszystkie istniejące klucze zostaną unieważnione.`
      );
   } else {
      $("#key-lock-text").text(
         "Czy chcesz zmienić zamek? Wszystkie istniejące klucze zostaną unieważnione."
      );
   }
   $("#modal-key-lock").show();
});

$("#house-ui").on("click", "#key-lock-confirm", () => {
   sendNui("hm_changeLock", {
      property: STATE.meta,
   });

   $("#modal-key-lock").hide();
});


$("#house-ui").on("click", '[data-action="toggle-service"]', function () {
   const key = $(this).data("key");
   const s = STATE.services[key];
   if (!s) return;
   sendNui("hm_toggleService", {
      service: key,
      property: STATE.meta,
   });
});


$("#house-ui").on("click", "#perm-add", () =>
   openNearbyPicker("perm", "Dodaj Gracza — Pobliskich")
);

$("#house-ui").on("click", '[data-action="tenant-details"]', function () {
   const id = $(this).data("id");
   const t = (STATE.tenants || []).find(
      x => String(x.id) === String(id)
   );
   if (!t) return;

   TENANT_DETAILS_ID = t.id;

   const start =
      t.startDate || t.startedAt || t.since || t.sinceLabel || "Nieznane";

   $("#tenant-det-name").text(t.name || `Najemca #${t.id}`);
   $("#tenant-det-rent").text(moneymanagment(t.rent || 0));
   $("#tenant-det-since").text(start);

   $("#modal-tenant-details").show();
});


$("#house-ui").on("click", "#tenant-det-cancel", () => {
   if (!TENANT_DETAILS_ID) return;
   const id = TENANT_DETAILS_ID;

   STATE.tenants = (STATE.tenants || []).filter(
      x => String(x.id) !== String(id)
   );
   renderTenants();

   sendNui("hm_removeTenant", {
      tenantId: id,
      property: STATE.meta,
   });
   TENANT_DETAILS_ID = null;
   $("#modal-tenant-details").hide();
});


$("#house-ui").on("click", '[data-action="perm-remove"]', function () {
   const id = $(this).data("id");
   STATE.permissions = (STATE.permissions || []).filter(p => p.id !== id);
   sendNui("hm_removePermissionPlayer", {
      playerId: id,
      property: STATE.meta,
   });
   renderPermissionsNames();
});

$("#house-ui").on("click", '[data-action="perm-manage"]', function () {
   const id = $(this).data("id");
   renderPermToggles(id);
   $("#modal-perm").data("pid", id).show();
});

$("#house-ui").on("change", '[data-action="perm-toggle"]', function () {
   const id = $(this).data("id");
   const key = $(this).data("key");
   const pl = (STATE.permissions || []).find(p => String(p.id) === String(id));
   if (pl) {
      pl.toggles = pl.toggles || {};
      pl.toggles[key] = this.checked;
   }
});

$("#house-ui").on("click", "#perm-save", () => {
   const pid = $("#modal-perm").data("pid");
   const pl = (STATE.permissions || []).find(p => String(p.id) === String(pid));
   if (pl) {
      sendNui("hm_savePermissions", {
         playerId: pl.id,
         toggles: pl.toggles,
         property: STATE.meta,
      });
   }
   $("#modal-perm").hide();
});


$("#house-ui").on("click", '[data-action="buy-upgrade"]', function () {
   const id = $(this).data("id");
   const u = (STATE.upgrades || []).find(x => x.id === id);
   if (u && !u.owned) {
      sendNui("hm_buyUpgrade", {
         upgradeId: id,
         price: u.price,
         property: STATE.meta,
      });
      u.owned = true;
      renderUpgrades();
   }
});


$("#house-ui").on("click", "#ringtone-preview-current", () => {
   const cur = getCurrentDoorbellEntry();
   if (cur) {
      $.post(
         'https://' + housingresourcename + '/playsound',
         JSON.stringify({
            soundsrc: cur.sound
         })
      );
   }
});

$("#house-ui").on("click", '[data-action="ringtone-preview"]', function () {
   $.post(
      'https://' + housingresourcename + '/playsound',
      JSON.stringify({
         soundsrc: $(this).data("src")
      })
   );
});

$("#house-ui").on("click", '[data-action="ringtone-set"]', function () {
   const id = $(this).data("id");
   const r = (STATE.doorbell.list || []).find(x => x.id === id);
   if (r) {
      sendNui("hm_setDoorbell", {
         ringtoneId: id,
         property: STATE.meta,
      });
   }
});

$("#house-ui").on("click", '[data-action="position-change"]', function () {
   const id = $(this).data("id");

   sendNui("hm_changePosition", {
      positionId: id,
      property: STATE.meta,
   });
});


$("#house-ui").on("click", "#tenant-open-add", () =>
   openNearbyPicker("tenant", "Dodaj Najemcę — Pobliskich")
);

$("#house-ui").on("click", '[data-action="tenant-edit"]', function () {
   const id = $(this).data("id");
   const t = (STATE.tenants || []).find(x => x.id === id);
   if (!t) return;
   TENANT_EDIT_ID = id;
   TENANT_PICK = null;
   $("#rent-title").text(`Edytuj Czynsz — ${t.name}`);
   $("#rent-input").val(t.rent);
   $("#modal-rent").show();
});

$("#house-ui").on("click", "#rent-confirm", () => {
   const rent = Number($("#rent-input").val());
   if (!rent || !TENANT_PICK) return;

   sendNui("hm_addTenant", {
      tenant: String(TENANT_PICK.id),
      rent: rent,
   });

   TENANT_PICK = null;
   $("#modal-rent").hide();
   renderTenants();
});

$("#house-ui").on("click", '[data-action="tenant-remove"]', function () {
   const id = $(this).data("id");
   STATE.tenants = (STATE.tenants || []).filter(t => t.id !== id);
   sendNui("hm_removeTenant", {
      tenantId: id,
      property: STATE.meta,
   });
   TENANT_DETAILS_ID = null;
   $("#modal-tenant-details").hide();
   renderTenants();
});


$("#house-ui").on("click", "#sell-open", () =>
   openNearbyPicker("sell", "Sprzedaj Graczowi — Pobliskich")
);

$("#house-ui").on("click", "#sell-bank-btn", () => {
   const price = moneymanagment(STATE.meta.bankSellPrice);

   $("#sell-bank-text").html(`
        Czy na pewno chcesz sprzedać nieruchomość bankowi za 
        <strong style="font-weight:700;">${price}</strong>?
    `);

   $("#modal-sell-bank").show();
});

$("#house-ui").on("click", "#sell-bank-yes", () => {
   sendNui("hm_sellToBank", {
      property: STATE.meta,
   });
   $("#modal-sell-bank").hide();
});


$("#house-ui").on("click", "#sell-realtor-btn", () => {
   sendNui("hm_listAtRealEstate", {
      property: STATE.meta,
   });
});


$("#house-ui").on("click", "#clean-manual", () => {
   sendNui("hm_cleanManual", {
      property: STATE.meta
   });
});

$("#house-ui").on("click", "#clean-robot", () => {
   STATE.vacuumInProgress = !STATE.vacuumInProgress;

   sendNui("hm_cleanRobot", {
      property: STATE.meta
   });


   renderCleanliness();
});


$("#house-ui").on("click", '[data-action="open-delivery"]', function () {
   const catId = $(this).data("id");
   openDeliveryCategory(catId);
});


$("#house-ui").on("click", '[data-action="cart-inc"]', function () {
   const id = String($(this).data("id"));
   const old = DELIVERY_CART[id] || 0;
   const qty = old + 1;
   DELIVERY_CART[id] = qty;
   $(`#cart-qty-${id}`).text(qty);
   updateDeliveryCartCount();
});

$("#house-ui").on("click", '[data-action="cart-dec"]', function () {
   const id = String($(this).data("id"));
   const old = DELIVERY_CART[id] || 0;
   const qty = Math.max(0, old - 1);
   DELIVERY_CART[id] = qty;
   $(`#cart-qty-${id}`).text(qty);
   if (qty === 0) {
      delete DELIVERY_CART[id];
   }
   updateDeliveryCartCount();
});

$("#house-ui").on("click", '[data-action="catalog-add"]', function () {
   const id = String($(this).data("id"));
   const old = DELIVERY_CART[id] || 0;
   const qty = old + 1;
   DELIVERY_CART[id] = qty;
   updateDeliveryCartCount();
});


$("#house-ui").on("click", '[data-action="catalog-pick"]', function () {
   const id = String($(this).data("id"));
   if (!CURRENT_CAT_CONFIG) return;

   const payload = {
      categoryId: CURRENT_CAT_CONFIG.id,
      items: {
         [id]: 1
      },
      property: STATE.meta,
   };

   sendNui("hm_deliveryOrder", payload);
   $("#modal-delivery").hide();
});


$("#house-ui").on("click", "#delivery-order", () => {
   if (!CURRENT_CAT_CONFIG || !CURRENT_CAT_CONFIG.useCart) return;

   const items = {};
   Object.keys(DELIVERY_CART).forEach(id => {
      const qty = DELIVERY_CART[id];
      if (qty > 0) items[id] = qty;
   });

   if (!Object.keys(items).length) return;

   sendNui("hm_deliveryOrder", {
      categoryId: CURRENT_CAT_CONFIG.id,
      items,
      property: STATE.meta,
   });

   DELIVERY_CART = {};
   updateDeliveryCartCount();
   $("#modal-delivery").hide();
});


$("#house-ui").on("click", '[data-action="nearby-pick"]', function () {
   const pickedId = String($(this).data("id"));
   const player = (STATE.nearbyPlayers || []).find(
      x => String(x.id) === pickedId
   );
   if (!player) return;

   if (NEARBY_MODE === "tenant") {
      TENANT_PICK = player;
      TENANT_EDIT_ID = null;
      $("#modal-nearby").hide();
      $("#rent-title").text(`Ustaw Czynsz — ${TENANT_PICK.name}`);
      $("#rent-input").val("");
      $("#modal-rent").show();
   } else if (NEARBY_MODE === "perm") {
      $.post(
         'https://' + housingresourcename + '/nearby_perm_pick',
         JSON.stringify({
            playerId: pickedId
         })
      );
      $("#modal-nearby").hide();
   } else if (NEARBY_MODE === "sell") {
      SELL_TARGET = player;
      $("#modal-nearby").hide();
      $("#sell-player-text").text(
         `Czy na pewno chcesz przenieść własność tej nieruchomości na ${player.name}?`
      );
      $("#modal-sell-player").show();
   } else {
      $("#modal-nearby").hide();
   }
});

$("#house-ui").on("click", "#sell-player-yes", () => {
   if (!SELL_TARGET) return;
   sendNui("hm_sellToPlayer", {
      targetPlayerId: SELL_TARGET.id,
      property: STATE.meta,
   });
   SELL_TARGET = null;
   $("#modal-sell-player").hide();
});


$("#house-ui").on("click", "[data-close]", function () {
   $($(this).attr("data-close")).hide();
});


window.addEventListener("message", function (event) {
   const item = event.data || {};
   if (item.message === "HouseManagementOpen") {
      openHouseManagementUI(item.state || {});
   }

   if (item.message === "HouseManagementShow") {
      $("#house-ui").show();
   }

   if (item.message === "HouseManagementHide") {
      $("#house-ui").hide();
   }


   if (item.message === "HmUpdateBills") {
      STATE.bills = item.bills || [];
      renderBillsDashboard();
      renderBillsModal();
      updatePermissionedButtons();
   }


   if (item.message === "HmUpdateServices") {
      STATE.services = item.services || {};
      renderServices();
   }


   if (item.message === "updateWarning") {
      if (item.warning) {
         $("#last-warning-box").show();
      } else {
         $("#last-warning-box").hide();
      }
   }

   if (item.message === "HmUpdateKeys") {
      STATE.keys = item.keys || [];
      renderKeys();
   }


   if (item.message === "HmUpdatePermissions") {
      STATE.permissions = item.permissions || [];
      renderPermissionsNames();
   }

   if (item.message === "HmUpdatePermissionsGlobal") {
      STATE.permissionDefs = item.permissionDefs || STATE.permissionDefs;
      STATE.permissionsToggled = item.permissionsToggled || STATE.permissionsToggled;
      STATE.sectionPermissions = item.sectionPermissions || STATE.sectionPermissions;
      applySectionPermissions();
      updatePermissionedButtons();
   }


   if (item.message === "HmUpdateRobotVacuum") {
      STATE.robotVacuumPurchased = item.robotVacuumPurchased || STATE.robotVacuumPurchased;
      const $robotBtn = $("#clean-robot");
      if (!STATE.robotVacuumPurchased) {
         $robotBtn.hide();
      }
      if (STATE.robotVacuumPurchased) {
         if (STATE.vacuumInProgress) {
            $robotBtn
               .show()
               .prop("disabled", false)
               .removeClass("hmh-btn-ghost")
               .addClass("hmh-btn-primary")
               .html('<i class="fa-solid fa-robot"></i> Zatrzymaj Odsysanie');
         } else {
            $robotBtn
               .show()
               .prop("disabled", false)
               .removeClass("hmh-btn-ghost")
               .addClass("hmh-btn-primary")
               .html('<i class="fa-solid fa-robot"></i> Robot Odsysający');
         }
      }
   }


   if (item.message === "HmUpdateUpgrades") {
      STATE.upgrades = item.upgrades || [];
      renderUpgrades();
   }


   if (item.message === "HmUpdateCameras") {
      const insideEnabled = !!item.cameraInsideEnabled;
      const outsideEnabled = !!item.cameraOutsideEnabled;
      updateCameraUI(insideEnabled, outsideEnabled);
   }


   if (item.message === "HmUpdateDoorbell") {
      STATE.doorbell = item.doorbell || STATE.doorbell;
      renderDoorbell();
   }


   if (item.message === "HmUpdateTenants") {
      STATE.tenants = item.tenants || [];
      renderTenants();
   }


   if (item.message === "HmUpdateVisitorLog") {
      STATE.visitorLog = item.visitorLog || [];
      renderDashboard();
   }

});


$(function () {
   injectUI();
   const current =
      getComputedStyle(document.documentElement)
      .getPropertyValue("--accent")
      .trim() || "#ff66ff";
   setTheme(current);
   $("#accent-picker").val(current.startsWith("#") ? current : "#ff66ff");
});