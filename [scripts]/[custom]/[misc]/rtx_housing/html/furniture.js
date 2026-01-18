const ICON = "img/furnitures/apa_mp_h_din_chair_04.webp";

let FURNITURE_UI_OPEN = false;

const STATEFURNITURE = {
   mode: "krapea",
   lastNonCartMode: "shop",
   shopDisabled: false,
   viewAllEnabled: false,

   favorites: new Set(),
   query: "",
   sort: "name",
   filter: "all",


   incarts: [],
   houses: [],
   selectedHouseId: null,
   selectedPlacement: null,


   categories: [{
         key: "all",
         icon: "fa-layer-group",
         name: "Zobacz Wszystko",
         subs: []
      },

   ],


   presets: [{
         id: "default",
         name: "Default",
         items: [{
               id: 12,
               code: "apa_mp_h_stn_sofa2seat_02",
               name: "Two-Seat Sofa 02",
               img: "img/furnitures/apa_mp_h_stn_sofa2seat_02.webp",
               placed: false
            },
            {
               id: 25,
               code: "prop_couch_lg_02",
               name: "Large Fabric Couch",
               img: "img/furnitures/prop_couch_lg_02.webp",
               placed: true
            },
            {
               id: 31,
               code: "prop_tv_flat_02b",
               name: "Flat TV 02B",
               img: "img/furnitures/prop_tv_flat_02b.webp",
               placed: false
            },
         ]
      },
      {
         id: "p-main",
         name: "Main Home",
         items: [{
               id: 44,
               code: "prop_table_03",
               name: "Glass Coffee Table",
               img: "img/furnitures/prop_table_03.webp",
               placed: true
            },
            {
               id: 47,
               code: "apa_mp_h_din_table_06",
               name: "Wood Dining Table",
               img: "img/furnitures/apa_mp_h_din_table_06.webp",
               placed: true
            },
            {
               id: 58,
               code: "xm_prop_x17_tv_ceiling_01",
               name: "Ceiling-Mounted TV",
               img: "img/furnitures/xm_prop_x17_tv_ceiling_01.webp",
               placed: false
            },
            {
               id: 63,
               code: "prop_cs_tv_stand",
               name: "TV Stand Unit",
               img: "img/furnitures/prop_cs_tv_stand.webp",
               placed: true
            },
         ]
      }
   ],
   currentPresetId: "default",
   activePresetId: "default",
}


const $ui = {
   root: $('#furn-ui-root'),
   breadcrumb: $('#furn-breadcrumb'),
   modeSwitch: $('#furn-mode-switch'),
   search: $('#furn-search'),
   sort: $('#furn-sort'),
   filter: $('#furn-filter'),
   sections: $('#furn-sections'),
   categoryList: $('#furn-category-list'),
   toggleSidebar: $('#furn-toggle-sidebar'),

   presetBar: $('#furn-preset-bar'),
   presetSelect: $('#furn-preset-select'),
   presetNew: $('#furn-preset-new'),
   presetDelete: $('#furn-preset-delete'),
   presetSetActive: $('#furn-preset-set-active'),


   invModal: $('#furn-inventory-modal'),
   invTitle: $('#furn-inventory-title'),
   invBody: $('#furn-inventory-body'),
   invClose: $('#furn-inventory-close'),
   transferMini: $('#furn-transfer-mini'),
   transferPanel: $('#furn-transfer-panel'),
   transferTarget: $('#furn-transfer-target'),
   btnTransfer: $('#furn-transfer-confirm'),
   btnEdit: $('#furn-edit-item'),
   btnPlace: $('#furn-place-item'),
   btnRemove: $('#furn-remove-item'),


   buyModal: $('#furn-buy-modal'),
   buyTitle: $('#furn-buy-title'),
   buyBody: $('#furn-buy-body'),
   buyClose: $('#furn-buy-close'),
   buyCancel: $('#furn-buy-cancel'),
   buyConfirm: $('#furn-buy-confirm'),
   buyConfirmLabel: $('#furn-buy-confirm-label'),


   cartFooter: $('#furn-cart-footer'),
   cartTotal: $('#furn-cart-total'),
   cartPurchase: $('#furn-cart-purchase'),
   cartClear: $('#furn-cart-clear'),
   cartDestModal: $('#furn-cart-dest-modal'),
   cartDestClose: $('#furn-cart-dest-close'),
   cartDestCancel: $('#furn-cart-dest-cancel'),
   cartDestConfirm: $('#furn-cart-dest-confirm'),
   cartDestSummary: $('#furn-cart-dest-summary'),
   cartHouse: $('#furn-cart-house'),
   cartPlacementGroup: $('#furn-cart-placement-group'),
   cartPlacementInside: $('#furn-cart-placement-inside'),
   cartPlacementOutside: $('#furn-cart-placement-outside'),
   cartPlacementField: $('#furn-cart-placement-field'),
   cartPlacementSelect: $('#furn-cart-placement-select'),

   cartDestHint: $('#furn-cart-dest-hint'),

   presetModal: $('#furn-preset-modal'),
   presetName: $('#furn-preset-name'),
   presetCancel: $('#furn-preset-cancel'),
   presetCreate: $('#furn-preset-create'),
   presetClose: $('#furn-preset-close'),


   confirmModal: $('#furn-confirm-modal'),
   confirmTitle: $('#furn-confirm-title'),
   confirmText: $('#furn-confirm-text'),
   confirmCancel: $('#furn-confirm-cancel'),
   confirmOk: $('#furn-confirm-ok'),
   confirmClose: $('#furn-confirm-close'),
};

let CUR_CAT = null;
let modalCtx = null;
let confirmResolve = null;
let shopCtx = null;


var housingresourcename = "rtx_housing";

const moneyfurniture = n => "$" + Number(n).toLocaleString();


function sendNui(action, data) {
   try {
      if (!housingResourceName) {
         return;
      }
      const endpoint = "https://" + housingResourceName + "/" + action;
      const payload = JSON.stringify(data || {});


      $.post(endpoint, payload);
   } catch (e) {}
}


function buildCategoriesFromConfig(furnConfig) {
   const categories = [];
   const allItems = [];
   const includeViewAll = !!STATEFURNITURE.viewAllEnabled;

   if (!furnConfig) return categories;


   const catEntries = Object.entries(furnConfig).map(([key, def]) => ({
      key,
      def
   }));
   catEntries.sort((a, b) => {
      const idA = (typeof a.def.id === 'number') ? a.def.id : 9999;
      const idB = (typeof b.def.id === 'number') ? b.def.id : 9999;
      if (idA !== idB) return idA - idB;

      const nameA = (a.def.label || a.key || "").toString();
      const nameB = (b.def.label || b.key || "").toString();
      return nameA.localeCompare(nameB);
   });

   catEntries.forEach(({
      key: catKey,
      def: catDef
   }) => {
      const cat = {
         key: catKey,
         icon: (catDef.icon || "fa-couch").replace(/^fa[sbrl]\s+/, ""),
         name: catDef.label || catKey,
         subs: [],
      };

      const subs = catDef.subcategory || {};


      const subEntries = Object.entries(subs).map(([subKey, subDef]) => ({
         subKey,
         subDef
      }));
      subEntries.sort((a, b) => {
         const nameA = (a.subDef.label || a.subKey || "").toString();
         const nameB = (b.subDef.label || b.subKey || "").toString();
         return nameA.localeCompare(nameB);
      });

      subEntries.forEach(({
         subKey,
         subDef
      }) => {
         const sub = {
            key: subKey,
            name: subDef.label || subKey,
            items: [],
         };


         const objects = (subDef.objects || []).slice().sort((a, b) => {
            const nameA = (a.label || a.object || "").toString();
            const nameB = (b.label || b.object || "").toString();
            return nameA.localeCompare(nameB);
         });

         objects.forEach((obj) => {

            const imgPath = obj.img || `img/furnitures/${obj.object}.webp`;

            const item = {
               id: obj.object,
               name: obj.label || obj.object,
               price: obj.price || 0,
               img: imgPath,
               interactable: !!obj.interactable,
               interaction: obj.interactabletext || "",
            };
            sub.items.push(item);
            allItems.push(item);
         });

         cat.subs.push(sub);
      });

      categories.push(cat);
   });


   if (includeViewAll && allItems.length) {
      categories.unshift({
         key: "all",
         icon: "fa-layer-group",
         name: "Zobacz Wszystko",
         subs: [{
            key: "allitems",
            name: "Wszystkie przedmioty",
            items: allItems,
         }],
      });
   }

   return categories;
}


function buildPresetsFromLua(luaPresets) {
   const presets = (luaPresets || []).map(p => ({
      id: p.id || p.presetId,
      name: p.label || p.name || p.id || p.presetId,
      items: (p.items || []).map(it => ({
         id: it.id,
         code: it.object || it.code,
         name: it.label || it.name || (it.object || ""),
         img: it.img || `img/furnitures/${(it.object || it.code || "").toString()}.webp`,
         placed: !!it.placed,
      })),
   }));
   return presets;
}


function setBreadcrumb(cat) {
   if (STATEFURNITURE.mode === 'inventory') {
      $ui.breadcrumb.html('<b>Moje Meble</b>');
      return;
   }
   if (STATEFURNITURE.mode === 'cart') {
      $ui.breadcrumb.html('<b>Koszyk</b>');
      return;
   }
   $ui.breadcrumb.html(cat ? `<b>${cat.name}</b>` : 'Wybierz kategorię');
}


function setSortOptions() {
   $ui.sort.empty();
   if (STATEFURNITURE.mode === "inventory") {
      $('<option>', {
         text: "Sortuj: Nazwa",
         value: "name",
         selected: STATEFURNITURE.sort === "name"
      }).appendTo($ui.sort);
      $('<option>', {
         text: "Sortuj: ID",
         value: "id",
         selected: STATEFURNITURE.sort === "id"
      }).appendTo($ui.sort);
   } else if (STATEFURNITURE.mode === "cart") {
      $('<option>', {
         text: "Sortuj: Nazwa",
         value: "name",
         selected: STATEFURNITURE.sort === "name"
      }).appendTo($ui.sort);
      $('<option>', {
         text: "Sortuj: Cena",
         value: "price",
         selected: STATEFURNITURE.sort === "price"
      }).appendTo($ui.sort);
   } else {
      $('<option>', {
         text: "Sortuj: Nazwa",
         value: "name",
         selected: STATEFURNITURE.sort === "name"
      }).appendTo($ui.sort);
      $('<option>', {
         text: "Sortuj: Cena",
         value: "price",
         selected: STATEFURNITURE.sort === "price"
      }).appendTo($ui.sort);
   }
}

const bySortShop = (a, b) => STATEFURNITURE.sort === "price" ?
   (a.price ?? 0) - (b.price ?? 0) :
   a.name.localeCompare(b.name);


function renderCategories() {
   $ui.categoryList.empty();
   STATEFURNITURE.categories.forEach((c, i) => {
      const isActive = (!CUR_CAT && i === 0) || (CUR_CAT === c.key);
      const $item = $('<div>', {
         'class': 'furn-category-item' + (isActive ? ' furn-is-active' : ''),
         'data-key': c.key,
         html: `<i class="fa-solid ${c.icon}"></i><span>${c.name}</span>`
      });
      $item.on('click', () => selectCategory(c.key));
      $ui.categoryList.append($item);
   });
}

function renderFilterOptions(cat) {
   $ui.filter.empty();
   $('<option>', {
      text: 'Wszystko',
      value: 'all',
      selected: STATEFURNITURE.filter === 'all'
   }).appendTo($ui.filter);
   $('<option>', {
      text: 'Ulubione',
      value: 'fav',
      selected: STATEFURNITURE.filter === 'fav'
   }).appendTo($ui.filter);
   cat.subs.forEach(sub => {
      $('<option>', {
         text: sub.name,
         value: sub.key,
         selected: STATEFURNITURE.filter === sub.key
      }).appendTo($ui.filter);
   });
}


const SHOP_BATCH_SIZE = 32;

function appendItemTile($grid, it) {
   const isFav = STATEFURNITURE.favorites.has(it.id);
   const $tile = $(`
    <div class="furn-item-tile">
      <img class="furn-item-thumb" src="${it.img}"
           alt="${it.name}"
           onerror="this.onerror=null;this.src='${ICON}'">
      <div class="furn-favorite-badge ${isFav ? '' : 'furn-is-off'}" data-furn-fav="${it.id}">
        <i class="fa-solid fa-star"></i>
      </div>
      <div class="furn-item-price">${moneyfurniture(it.price)}</div>
      <div class="furn-item-caption">${it.name}</div>
    </div>
  `);


   $tile.on('click', function (e) {
      const $favBtn = $(e.target).closest('[data-furn-fav]');
      if ($favBtn.length) {
         e.stopPropagation();
         const id = $favBtn.data('furn-fav');
         if (STATEFURNITURE.favorites.has(id)) {
            STATEFURNITURE.favorites.delete(id);
         } else {
            STATEFURNITURE.favorites.add(id);
         }
         $favBtn.toggleClass('furn-is-off', !STATEFURNITURE.favorites.has(id));
         return;
      }
      onPreview(it);
   });


   $tile.on('mouseenter', function () {
      if (STATEFURNITURE.mode === 'krapea') {

         const objectName = it.object || it.model || it.prop || it.name;

         if (objectName) {
            sendNui("furniture_hover_preview", {
               object: objectName,
               id: it.id
            });
         }
      }
   });


   $tile.on('mouseleave', function () {
      if (STATEFURNITURE.mode === 'krapea') {
         sendNui("furniture_hover_preview_clear", {
            id: it.id
         });
      }
   });

   $grid.append($tile);
}

function renderSectionChunk($section) {
   const items = $section.data('items');
   if (!items) return;
   let index = $section.data('renderIndex') || 0;
   if (index >= items.length) return;

   const $grid = $section.find('.furn-item-grid');
   const end = Math.min(index + SHOP_BATCH_SIZE, items.length);
   for (let i = index; i < end; i++) {
      appendItemTile($grid, items[i]);
   }
   $section.data('renderIndex', end);
}

function handleSectionsScrollLazy() {
   const viewportTop = $ui.sections.scrollTop();
   const viewportBottom = viewportTop + $ui.sections.innerHeight();
   const thresholdBottom = viewportBottom + 200;

   $ui.sections.children('.furn-section').each(function () {
      const $section = $(this);
      const items = $section.data('items');
      if (!items) return;
      const rendered = $section.data('renderIndex') || 0;
      if (rendered >= items.length) return;

      const offsetTop = $section.position().top;
      const height = $section.outerHeight();
      const sectionBottom = offsetTop + height;

      if (sectionBottom < thresholdBottom) {
         renderSectionChunk($section);
      }
   });
}

let CART_PENDING_TOTAL = 0;

function renderCartDestinationModal() {
   const houses = STATEFURNITURE.houses || [];
   const hasHouses = houses.length > 0;


   if (!hasHouses) {
      $ui.cartHouse.empty().append(
         $('<option>', {
            value: "",
            text: "Nie posiadasz żadnej nieruchomości"
         })
      );
      $ui.cartHouse.prop('disabled', true);
      $ui.cartPlacementGroup.hide();
      $ui.cartDestHint.text("Musisz posiadać nieruchomość, zanim będziesz mógł przypisać meble.");
      $ui.cartDestConfirm.prop('disabled', true);
      $ui.cartDestSummary.text('');
      return;
   }


   $ui.cartHouse.empty();
   houses.forEach(h => {
      const label = `${h.label || ('House '+h.id)} — ${h.adress || 'No address'}`;
      $('<option>', {
         value: String(h.id),
         text: label
      }).appendTo($ui.cartHouse);
   });

   if (!STATEFURNITURE.selectedHouseId) {
      STATEFURNITURE.selectedHouseId = String(houses[0].id);
   }
   $ui.cartHouse.val(String(STATEFURNITURE.selectedHouseId));

   const current = houses.find(h => String(h.id) === String(STATEFURNITURE.selectedHouseId));
   if (!current) {
      $ui.cartPlacementGroup.hide();
      $ui.cartDestHint.text('');
      $ui.cartDestConfirm.prop('disabled', true);
      return;
   }

   let placement = STATEFURNITURE.selectedPlacement || null;


   if (current.ismlo) {
      $ui.cartPlacementGroup.hide();
      placement = null;
      STATEFURNITURE.selectedPlacement = placement;

      $ui.cartDestHint.text("Nieruchomość MLO – meble zostaną dostarczone do tej nieruchomości.");
      $ui.cartDestConfirm.prop('disabled', false);

   } else {
      const canInside = !!current.inside;
      const canOutside = !!current.outside;

      const any = canInside || canOutside;
      const both = canInside && canOutside;


      if (!any) {
         $ui.cartPlacementGroup.hide();
         STATEFURNITURE.selectedPlacement = null;
         $ui.cartDestHint.text("Ta nieruchomość nie akceptuje kategorii mebli.");
         $ui.cartDestConfirm.prop('disabled', true);
         updateCartSummary();
         return;
      }


      if (both) {

         if (placement !== 'inside' && placement !== 'outside') {
            placement = 'inside';
         }
         $ui.cartPlacementGroup.show();
         $ui.cartPlacementInside
            .toggleClass('furn-is-active', placement === 'inside')
            .show();
         $ui.cartPlacementOutside
            .toggleClass('furn-is-active', placement === 'outside')
            .show();
      } else if (canInside && !canOutside) {

         placement = 'inside';
         $ui.cartPlacementGroup.hide();
      } else if (!canInside && canOutside) {

         placement = 'outside';
         $ui.cartPlacementGroup.hide();
      }


      STATEFURNITURE.selectedPlacement = placement;


      if (placement === 'inside') {
         $ui.cartDestHint.text("Meble zostaną dodane do wnętrza (wewnątrz) tej nieruchomości.");
         $ui.cartDestConfirm.prop('disabled', false);
      } else if (placement === 'outside') {
         $ui.cartDestHint.text("Meble zostaną dodane na zewnątrz tej nieruchomości.");
         $ui.cartDestConfirm.prop('disabled', false);
      } else {

         $ui.cartDestHint.text("Wybierz, gdzie umieścić meble w tej nieruchomości.");
         $ui.cartDestConfirm.prop('disabled', true);
      }
   }

   updateCartSummary();
}

function updateCartSummary() {
   const count = STATEFURNITURE.incarts.length;
   const totalLabel = moneyfurniture(CART_PENDING_TOTAL || 0);
   $ui.cartDestSummary.text(`${count} przedmiot${count === 1 ? '' : count < 5 ? 'y' : 'ów'} – Razem: ${totalLabel}`);
}


function openCartDestinationModal(total) {
   CART_PENDING_TOTAL = total || 0;
   $ui.cartDestModal.addClass('furn-is-open');
   renderCartDestinationModal();
}

function closeCartDestinationModal() {
   $ui.cartDestModal.removeClass('furn-is-open');
}

$ui.cartDestClose.on('click', closeCartDestinationModal);
$ui.cartDestCancel.on('click', closeCartDestinationModal);

$ui.cartHouse.on('change', function () {
   const val = $(this).val();
   STATEFURNITURE.selectedHouseId = val || null;

   STATEFURNITURE.selectedPlacement = null;

   renderCartDestinationModal();
});


$ui.cartPlacementInside.on('click', function () {
   STATEFURNITURE.selectedPlacement = 'inside';
   renderCartDestinationModal();
});
$ui.cartPlacementOutside.on('click', function () {
   STATEFURNITURE.selectedPlacement = 'outside';
   renderCartDestinationModal();
});


function renderContent(cat) {
   setBreadcrumb(cat);
   renderFilterOptions(cat);
   $ui.sections.empty();

   const q = STATEFURNITURE.query.toLowerCase();
   const onlyFav = STATEFURNITURE.filter === 'fav';
   const showSub = sub => STATEFURNITURE.filter === 'all' || STATEFURNITURE.filter === sub.key || onlyFav;

   cat.subs.forEach(sub => {
      if (!showSub(sub)) return;

      let items = sub.items
         .filter(i => !onlyFav || STATEFURNITURE.favorites.has(i.id))
         .filter(i => !q || i.name.toLowerCase().includes(q))
         .slice()
         .sort(bySortShop);

      if (!items.length) return;

      items = items.map(i => ({
         ...i,
         categoryKey: cat.key,
         subcategoryKey: sub.key,
      }));

      const $section = $(`
      <div class="furn-section">
        <div class="furn-section-header">
          <div class="furn-section-title">
            <span>${sub.name}</span>
            <span class="furn-section-count">${items.length}</span>
          </div>
          <button class="furn-collapse-button" title="Collapse">
            <i class="fa-solid fa-chevron-up"></i>
          </button>
        </div>
        <div class="furn-item-grid"></div>
      </div>
    `);

      $section.data('items', items);
      $section.data('renderIndex', 0);

      const $grid = $section.find('.furn-item-grid');
      renderSectionChunk($section);

      $section.find('.furn-collapse-button').on('click', function () {
         const $btn = $(this);
         const opened = $grid.css('display') !== 'none';
         $grid.css('display', opened ? 'none' : 'grid');
         $btn.html(`<i class="fa-solid fa-chevron-${opened ? 'down' : 'up'}"></i>`);
      });

      $ui.sections.append($section);
   });

   if ($ui.sections.children().length === 0) {
      $ui.sections.html('<div style="opacity:.75; padding:8px;">Brak przedmiotów pasujących do filtrów.</div>');
   }


   $ui.sections.off('scroll.lazy').on('scroll.lazy', handleSectionsScrollLazy);
}

function selectCategory(key) {
   if (key === CUR_CAT) {} else {
      STATEFURNITURE.filter = "all";
   }
   CUR_CAT = key;
   $ui.categoryList.children().each(function () {
      const $item = $(this);
      $item.toggleClass('furn-is-active', $item.data('key') === key);
   });
   const cat = STATEFURNITURE.categories.find(c => c.key === key);
   if (!cat) return;
   renderContent(cat);
}


function getCurrentPreset() {
   return STATEFURNITURE.presets.find(p => p.id === STATEFURNITURE.currentPresetId) || STATEFURNITURE.presets[0];
}

function renderPresetsBar() {
   if (!$ui.presetSelect.length) return;

   $ui.presetSelect.empty();
   STATEFURNITURE.presets.forEach(p => {
      const text = (p.id === STATEFURNITURE.activePresetId) ?
         `${p.name} (Active)` :
         p.name;

      $('<option>', {
         text,
         value: p.id,
         selected: p.id === STATEFURNITURE.currentPresetId
      }).appendTo($ui.presetSelect);
   });
   const current = getCurrentPreset();
   const cannotDelete = !current || current.id === 'default' || STATEFURNITURE.presets.length <= 1;
   $ui.presetDelete.prop('disabled', cannotDelete);

   if ($ui.presetSetActive && $ui.presetSetActive.length) {
      const canSet = !!current && current.id !== STATEFURNITURE.activePresetId;
      $ui.presetSetActive.prop('disabled', !canSet);
   }
}


function renderInventory() {
   $ui.breadcrumb.html('<b>My Furniture</b>');
   $ui.sections.empty();
   renderPresetsBar();

   const preset = getCurrentPreset();
   const q = STATEFURNITURE.query.toLowerCase();
   let items = (preset?.items || [])
      .filter(i => !q || i.name.toLowerCase().includes(q) || String(i.id).includes(q))
      .slice()
      .sort((a, b) => {
         if (STATEFURNITURE.sort === 'id') return Number(a.id) - Number(b.id);
         return a.name.localeCompare(b.name);
      });

   if (!items.length) {
      $ui.sections.html('<div style="opacity:.75; padding:8px;">Ten preset jest pusty.</div>');
      return;
   }

   const $section = $(`
    <div class="furn-section">
      <div class="furn-section-header">
        <div class="furn-section-title">
          <span>${preset.name}</span>
          <span class="furn-section-count">${items.length}</span>
        </div>
      </div>
      <div class="furn-item-grid"></div>
    </div>
  `);
   const $grid = $section.find('.furn-item-grid');

   items.forEach(item => {
      const $tile = $(`
      <div class="furn-item-tile">
        <img class="furn-item-thumb" src="${item.img}"
             alt="${item.name}"
             onerror="this.onerror=null;this.src='${ICON}'">
        ${item.placed ? '' : '<div class="furn-unplaced-badge"><i class="fa-solid fa-box-archive"></i></div>'}
        <div class="furn-id-badge">#${item.id}</div>
        <div class="furn-item-caption">${item.name}</div>
      </div>
    `);
      $tile.on('click', () => onPreview(item));
      $grid.append($tile);
   });

   $ui.sections.append($section);
}


function renderCartPage() {
   $ui.sections.empty();
   const q = STATEFURNITURE.query.toLowerCase();
   let items = STATEFURNITURE.incarts
      .filter(i => !q || i.name.toLowerCase().includes(q))
      .slice()
      .sort((a, b) => STATEFURNITURE.sort === 'price' ?
         (a.price || 0) - (b.price || 0) :
         a.name.localeCompare(b.name)
      );

   const $section = $(`
    <div class="furn-section">
      <div class="furn-section-header">
        <div class="furn-section-title">
          <span>Cart Items</span>
          <span class="furn-section-count">${items.length}</span>
        </div>
        ${items.length ? '<button class="furn-collapse-button" id="furn-cart-collapse"><i class="fa-solid fa-chevron-up"></i></button>' : ''}
      </div>
      <div class="furn-item-grid" id="furn-cart-grid"></div>
      ${!items.length ? '<div style="opacity:.75; padding:8px;">Twój koszyk jest pusty.</div>' : ''}
    </div>
  `);
   $ui.sections.append($section);

   const $grid = $('#furn-cart-grid');
   items.forEach((it, idx) => {
      const $tile = $(`
      <div class="furn-item-tile" title="Kliknij, aby usunąć z koszyka">
        <img class="furn-item-thumb" src="${it.img}"
             alt="${it.name}"
             onerror="this.onerror=null;this.src='${ICON}'">
        <div class="furn-item-price">${moneyfurniture(it.price)}</div>
        <div class="furn-item-caption">${it.name}</div>
      </div>
    `);
      $tile.on('click', () => {
         STATEFURNITURE.incarts.splice(idx, 1);
         sendNui("furniture_cart_update", {
            items: STATEFURNITURE.incarts
         });
         renderRoot();
      });
      $grid.append($tile);
   });

   const total = STATEFURNITURE.incarts.reduce((s, i) => s + (i.price || 0), 0);
   $ui.cartTotal.text(`Razem: ${moneyfurniture(total)}`);
   $ui.cartFooter.show();
}


function updateModeUI() {
   const isInv = STATEFURNITURE.mode === "inventory";
   const isKrapea = STATEFURNITURE.mode === "krapea";
   const isCart = STATEFURNITURE.mode === "cart";

   $ui.root.toggleClass('furn-mode-cart', isCart);
   if (isCart) {
      $ui.cartFooter.show();
   } else {
      $ui.cartFooter.hide();
   }

   const $shopBtn = $ui.modeSwitch.find('.furn-mode-button-shop');
   const $invBtn = $ui.modeSwitch.find('.furn-mode-button-inventory');

   if (isKrapea) {
      $ui.modeSwitch.addClass('furn-is-hidden');
      $ui.root.removeClass('furn-mode-inventory').addClass('furn-mode-krapea');
   } else {
      $ui.root.removeClass('furn-mode-krapea');
      if (STATEFURNITURE.shopDisabled) {
         STATEFURNITURE.mode = "inventory";
         $ui.modeSwitch.addClass('furn-is-hidden');
      } else {
         $ui.modeSwitch.toggleClass('furn-is-hidden', isCart);
         $shopBtn.toggleClass('furn-is-active', !isInv && !isCart);
         $invBtn.toggleClass('furn-is-active', isInv);
      }
   }

   $ui.root.toggleClass('furn-mode-inventory', isInv);
   setSortOptions();
   if (isInv) renderPresetsBar();
}

function renderRoot() {
   updateModeUI();
   if (STATEFURNITURE.mode === "inventory") {
      renderInventory();
   } else if (STATEFURNITURE.mode === "cart") {
      setBreadcrumb();
      renderCartPage();
   } else {
      renderCategories();
      if (STATEFURNITURE.categories.length) {
         selectCategory(CUR_CAT || STATEFURNITURE.categories[0].key);
      } else {
         $ui.sections.html('<div style="opacity:.75; padding:8px;">No categories.</div>');
      }
      $ui.cartFooter.hide();
   }
}


function openConfirm({
   title = "Potwierdź",
   text = "Czy jesteś pewien?",
   okLabel = "Usuń"
}) {
   $ui.confirmTitle.text(title);
   $ui.confirmText.text(text);
   $ui.confirmOk.text(okLabel);
   $ui.confirmModal.addClass('furn-is-open');
   return new Promise(resolve => {
      confirmResolve = resolve;
   });
}

function closeConfirm(answer = false) {
   $ui.confirmModal.removeClass('furn-is-open');
   if (confirmResolve) {
      const r = confirmResolve;
      confirmResolve = null;
      r(answer);
   }
}
$ui.confirmCancel.on('click', () => closeConfirm(false));
$ui.confirmOk.on('click', () => closeConfirm(true));
$ui.confirmClose.on('click', () => closeConfirm(false));
$ui.confirmModal.on('click', e => {
   if (e.target === $ui.confirmModal[0]) closeConfirm(false);
});


function populateTransferTargets(excludeId) {
   $ui.transferTarget.empty();
   const list = STATEFURNITURE.presets.filter(p => p.id !== excludeId);
   list.forEach(p => {
      $('<option>', {
         text: p.name,
         value: p.id
      }).appendTo($ui.transferTarget);
   });
   $ui.btnTransfer.prop('disabled', list.length === 0);
}

function openInvModal(item) {
   const preset = getCurrentPreset();
   modalCtx = {
      item,
      presetId: preset?.id
   };
   $ui.invTitle.text(item.name);
   $ui.invBody.text(`ID: #${item.id} • Code: ${item.code}`);

   if (item.placed) {
      $ui.btnEdit.show();
      $ui.btnPlace.hide();
   } else {
      $ui.btnEdit.hide();
      $ui.btnPlace.show();
   }

   populateTransferTargets(modalCtx.presetId);
   $ui.transferPanel.removeClass('furn-is-open');
   $ui.invModal.addClass('furn-is-open');
}

function closeInvModal() {
   $ui.invModal.removeClass('furn-is-open');
   modalCtx = null;
}
$ui.invModal.on('click', e => {
   if (e.target === $ui.invModal[0]) closeInvModal();
});
$ui.invClose.on('click', closeInvModal);

$ui.transferMini.on('click', () => {
   $ui.transferPanel.toggleClass('furn-is-open');
});

$ui.btnEdit.on('click', () => {
   if (!modalCtx) return;
   sendNui("furniture_inv_edit", {
      presetId: modalCtx.presetId,
      itemId: modalCtx.item.id,
      object: modalCtx.item.code,
   });
   closeInvModal();
});
$ui.btnPlace.on('click', () => {
   if (!modalCtx) return;
   sendNui("furniture_inv_place", {
      presetId: modalCtx.presetId,
      itemId: modalCtx.item.id,
      object: modalCtx.item.code,
   });
   closeInvModal();
});
$ui.btnRemove.on('click', async () => {
   if (!modalCtx) return;
   const preset = STATEFURNITURE.presets.find(p => p.id === modalCtx.presetId);
   if (!preset) return;
   const yes = await openConfirm({
      title: "Usuń przedmiot",
      text: `Usunąć "${modalCtx.item.name}" z presetu "${preset.name}"?`,
      okLabel: "Usuń"
   });
   if (!yes) return;
   preset.items = preset.items.filter(i => !(i.id === modalCtx.item.id && i.code === modalCtx.item.code));

   sendNui("furniture_inv_remove", {
      presetId: modalCtx.presetId,
      itemId: modalCtx.item.id,
      object: modalCtx.item.code,
   });

   closeInvModal();
   renderRoot();
});

$ui.btnTransfer.on('click', () => {
   if (!modalCtx) return;
   const targetId = $ui.transferTarget.val();
   const from = STATEFURNITURE.presets.find(p => p.id === modalCtx.presetId);
   const to = STATEFURNITURE.presets.find(p => p.id === targetId);
   if (!from || !to || !modalCtx.item) return;

   from.items = from.items.filter(i => !(i.id === modalCtx.item.id && i.code === modalCtx.item.code));
   to.items.push(modalCtx.item);

   sendNui("furniture_inv_transfer", {
      fromPresetId: from.id,
      toPresetId: to.id,
      itemId: modalCtx.item.id,
      object: modalCtx.item.code,
   });

   modalCtx.presetId = to.id;
   populateTransferTargets(modalCtx.presetId);
   renderRoot();
});


function openBuyModal(item) {
   shopCtx = {
      item
   };
   const isKrapea = STATEFURNITURE.mode === 'krapea';
   $ui.buyTitle.text(isKrapea ? 'Dodaj do koszyka' : 'Zakup');
   $ui.buyConfirmLabel.text(isKrapea ? 'Dodaj do koszyka' : 'Kup');

   const interact = item.interactable ? `
    <div class="furn-interaction">
      <div class="furn-label"><i class="fa-solid fa-bolt"></i>Interaktywne</div>
      ${item.interaction ? `<div class="furn-description">${item.interaction}</div>` : ``}
    </div>
  ` : ``;

   $ui.buyBody.html(isKrapea ?
      `Czy chcesz dodać <b>${item.name}</b> za <b>${moneyfurniture(item.price)}</b> do koszyka?${interact}` :
      `Czy chcesz kupić <b>${item.name}</b> za <b>${moneyfurniture(item.price)}</b>?${interact}`
   );

   $ui.buyModal.addClass('furn-is-open');
}

function closeBuyModal() {
   $ui.buyModal.removeClass('furn-is-open');
   shopCtx = null;
}
$ui.buyClose.on('click', closeBuyModal);
$ui.buyCancel.on('click', closeBuyModal);
$ui.buyModal.on('click', e => {
   if (e.target === $ui.buyModal[0]) closeBuyModal();
});
$ui.buyConfirm.on('click', () => {
   if (!shopCtx) return;
   if (STATEFURNITURE.mode === 'krapea') {

      sendNui("furniture_add_to_cart", {
         object: shopCtx.item.id,
         name: shopCtx.item.name,
         price: shopCtx.item.price,
         categoryKey: shopCtx.item.categoryKey,
         subcategoryKey: shopCtx.item.subcategoryKey,
      });

   } else {
      sendNui("furniture_purchase", {
         object: shopCtx.item.id,
         name: shopCtx.item.name,
         price: shopCtx.item.price,
         categoryKey: shopCtx.item.categoryKey,
         subcategoryKey: shopCtx.item.subcategoryKey,
      });
   }
   closeBuyModal();
});

$ui.cartPurchase.on('click', () => {
   if (!STATEFURNITURE.incarts.length) return;

   const total = STATEFURNITURE.incarts.reduce((s, i) => s + (i.price || 0), 0);
   openCartDestinationModal(total);
});


$ui.cartClear.on('click', async () => {
   if (!STATEFURNITURE.incarts.length) return;
   const yes = await openConfirm({
      title: 'Wyczyść koszyk',
      text: 'Usunąć wszystkie przedmioty z koszyka?',
      okLabel: 'Wyczyść'
   });
   if (!yes) return;
   STATEFURNITURE.incarts = [];

   sendNui("furniture_cart_clear", {});

   renderRoot();
});


function onPreview(item) {
   if (STATEFURNITURE.mode === "inventory") {
      openInvModal(item);
   } else {
      openBuyModal(item);
   }
}


$ui.modeSwitch.on('click', '.furn-mode-button', function () {
   if (STATEFURNITURE.shopDisabled) return;
   const mode = $(this).data('mode');
   if (mode && (mode === 'shop' || mode === 'inventory')) {
      STATEFURNITURE.lastNonCartMode = mode;
      STATEFURNITURE.mode = mode;
      renderRoot();
   }
});

$ui.search.on('input', function () {
   STATEFURNITURE.query = $(this).val() || '';
   renderRoot();
});
$ui.sort.on('change', function () {
   STATEFURNITURE.sort = $(this).val();
   renderRoot();
});
$ui.filter.on('change', function () {
   STATEFURNITURE.filter = $(this).val();
   renderRoot();
});
$ui.toggleSidebar.on('click', function () {
   $ui.root.toggleClass('furn-is-collapsed');
});


$ui.presetSelect.on('change', function () {
   STATEFURNITURE.currentPresetId = $(this).val();
   renderRoot();
});
$ui.presetNew.on('click', () => {
   $ui.presetName.val('');
   $ui.presetModal.addClass('furn-is-open');
   $ui.presetName.trigger('focus');
});
$ui.presetCreate.on('click', () => {
   const name = ($ui.presetName.val() || '').trim();
   if (!name) return;


   sendNui("furniture_preset_create", {
      name: name
   });

   $ui.presetModal.removeClass('furn-is-open');

});

$ui.presetDelete.on('click', async () => {
   const current = getCurrentPreset();
   if (!current || current.id === 'default') return;

   const yes = await openConfirm({
      title: "Usuń preset",
      text: `Usunąć preset "${current.name}"?`,
      okLabel: "Usuń"
   });
   if (!yes) return;


   sendNui("furniture_preset_delete", {
      presetId: current.id,
   });
});


if ($ui.presetSetActive && $ui.presetSetActive.length) {
   $ui.presetSetActive.on('click', async () => {
      const current = getCurrentPreset();
      if (!current) return;
      if (current.id === STATEFURNITURE.activePresetId) return;

      const yes = await openConfirm({
         title: "Ustaw aktywny preset",
         text: `Czy chcesz ustawić preset "${current.name}" jako aktywny w swojej nieruchomości?`,
         okLabel: "Ustaw preset"
      });
      if (!yes) return;


      sendNui("furniture_set_active_preset", {
         presetId: current.id,
      });
   });
}

$ui.presetCancel.on('click', () => $ui.presetModal.removeClass('furn-is-open'));
$ui.presetClose.on('click', () => $ui.presetModal.removeClass('furn-is-open'));
$ui.presetModal.on('click', e => {
   if (e.target === $ui.presetModal[0]) $ui.presetModal.removeClass('furn-is-open');
});


$ui.cartDestConfirm.on('click', () => {
   const houses = STATEFURNITURE.houses || [];
   const houseId = STATEFURNITURE.selectedHouseId;
   const house = houses.find(h => String(h.id) === String(houseId));

   if (!house) {
      $ui.cartDestHint.text("Proszę wybrać nieruchomość.");
      return;
   }
   if (!house.ismlo && !STATEFURNITURE.selectedPlacement) {
      $ui.cartDestHint.text("Proszę wybrać wewnątrz lub na zewnątrz dla tej nieruchomości.");
      return;
   }

   const total = CART_PENDING_TOTAL || 0;

   sendNui("furniture_cart_purchase", {
      items: STATEFURNITURE.incarts,
      total: total,
      houseId: house.id,
      placement: house.ismlo ? null : STATEFURNITURE.selectedPlacement,
      houseLabel: house.label,
      houseAdress: house.adress,
      isMlo: !!house.ismlo,
   });

   STATEFURNITURE.incarts = [];
   closeCartDestinationModal();
   renderRoot();
});


$(function () {
   if (window.location.hash.toLowerCase() === '#krapea') STATEFURNITURE.mode = 'krapea';
   if (STATEFURNITURE.shopDisabled && STATEFURNITURE.mode !== 'krapea') STATEFURNITURE.mode = 'inventory';
   setSortOptions();
   renderRoot();
});

document.addEventListener("keydown", function (e) {
   if (e.key === "Escape") {
      if (!FURNITURE_UI_OPEN) return;


      closeAllModals();
      $("#furn-ui-main").hide();
      $('#furn-ui-root').hide();
      FURNITURE_UI_OPEN = false;


      sendNui("furniture_close", {
         mode: STATEFURNITURE.mode
      });
   }
});


window.addEventListener("message", function (event) {
   const msg = event.data;
   if (!msg || !msg.message) return;

   if (msg.message === "FurnitureSetMeta") {
      STATEFURNITURE.shopDisabled = msg.shopDisabled;

      if (typeof msg.viewAll === 'boolean') {
         STATEFURNITURE.viewAllEnabled = msg.viewAll;
      }

      STATEFURNITURE.activePresetId = msg.activePresetId || STATEFURNITURE.activePresetId || STATEFURNITURE.currentPresetId;

      if (STATEFURNITURE.shopDisabled) {
         STATEFURNITURE.mode = "inventory";
      } else {
         const defaultMode = msg.defaultMode || STATEFURNITURE.mode;
         STATEFURNITURE.mode = defaultMode;
      }
      FURNITURE_UI_OPEN = true;
      $("#furn-ui-main").show();
      $('#furn-ui-root').show();
      renderRoot();
   }

   if (msg.message === "FurnitureEditMode") {
      FURNITURE_UI_OPEN = false;
   }


   if (msg.message === "FurnitureSetConfig") {
      STATEFURNITURE.categories = buildCategoriesFromConfig(msg.furnitures);
      CUR_CAT = null;
      $("#furn-ui-main").show();
      $('#furn-ui-root').show();
      STATEFURNITURE.filter = "all";
      renderRoot();
   }

   if (msg.message === "FurnitureAddCategory") {
      const cfg = {};
      cfg[msg.categoryKey] = msg.category;
      let newCats = buildCategoriesFromConfig(cfg).filter(c => c.key !== "all");

      if (msg.replaceExisting) {

         const allCat = STATEFURNITURE.categories.find(c => c.key === "all");
         STATEFURNITURE.categories = [];
         if (allCat) STATEFURNITURE.categories.push(allCat);
         STATEFURNITURE.categories = STATEFURNITURE.categories.concat(newCats);
      } else {
         const existingAll = STATEFURNITURE.categories.filter(c => c.key === "all");
         const others = STATEFURNITURE.categories.filter(c => c.key !== "all");
         const newKeys = newCats.map(c => c.key);
         const filteredOthers = others.filter(c => !newKeys.includes(c.key));
         STATEFURNITURE.categories = [...existingAll, ...filteredOthers, ...newCats];
      }
      $("#furn-ui-main").show();
      $('#furn-ui-root').show();
      renderRoot();
   }

   if (msg.message === "FurnitureResetCategories") {
      if (STATEFURNITURE.viewAllEnabled) {
         STATEFURNITURE.categories = [{
            key: "all",
            icon: "fa-layer-group",
            name: "View All",
            subs: []
         }];
      } else {
         STATEFURNITURE.categories = [];
      }
      CUR_CAT = null;
      renderRoot();
   }

   if (msg.message === "FurnitureResetPresets") {
      STATEFURNITURE.presets = [];
      STATEFURNITURE.currentPresetId = null;
      STATEFURNITURE.activePresetId = null;
      renderRoot();
   }

   if (msg.message === "FurnitureOpenShop") {
      if (msg.options && msg.options.furnitures) {
         STATEFURNITURE.categories = buildCategoriesFromConfig(msg.options.furnitures);
      }
      if (STATEFURNITURE.shopDisabled) {
         STATEFURNITURE.mode = "inventory";
      } else {
         STATEFURNITURE.mode = (msg.options && msg.options.mode) || "krapea";
      }
      FURNITURE_UI_OPEN = true;
      $("#furn-ui-main").show();
      $('#furn-ui-root').show();
      renderRoot();
   }

   if (msg.message === "FurnitureOpenInventory") {
      const opts = msg.options || {};
      const presets = buildPresetsFromLua(opts.presets || []);
      if (presets.length) {
         STATEFURNITURE.presets = presets;
         STATEFURNITURE.currentPresetId = opts.currentPresetId ||
            opts.activePresetId ||
            presets[0].id;
         STATEFURNITURE.activePresetId = opts.activePresetId || STATEFURNITURE.activePresetId || STATEFURNITURE.currentPresetId;
      }
      FURNITURE_UI_OPEN = true;
      $("#furn-ui-main").show();
      $('#furn-ui-root').show();
      STATEFURNITURE.mode = "inventory";
      renderRoot();
   }

   if (msg.message === "FurnitureLoadInventory") {
      const opts = msg.options || {};
      const presets = buildPresetsFromLua(opts.presets || []);
      if (presets.length) {
         STATEFURNITURE.presets = presets;
         STATEFURNITURE.currentPresetId = opts.currentPresetId ||
            opts.activePresetId ||
            presets[0].id;
         STATEFURNITURE.activePresetId = opts.activePresetId || STATEFURNITURE.activePresetId || STATEFURNITURE.currentPresetId;
      }
      renderRoot();
   }
   if (msg.message === "FurnitureOpenCart") {
      const opts = msg.options || {};

      STATEFURNITURE.houses = opts.houses || [];
      STATEFURNITURE.selectedHouseId = null;
      STATEFURNITURE.selectedPlacement = null;

      STATEFURNITURE.lastNonCartMode = STATEFURNITURE.mode;
      STATEFURNITURE.mode = "cart";

      FURNITURE_UI_OPEN = true;
      $("#furn-ui-main").show();
      $('#furn-ui-root').show();
      renderRoot();
   }


   if (msg.message === "FurnitureSetActivePreset") {
      STATEFURNITURE.activePresetId = msg.activePresetId;
      renderPresetsBar();
      renderRoot();
   }

   if (msg.message === "FurnitureHide") {
      $("#furn-ui-main").hide();
      $('#furn-ui-root').hide();
      $ui.invModal.removeClass('furn-is-open');
      $ui.buyModal.removeClass('furn-is-open');
      $ui.confirmModal.removeClass('furn-is-open');
      $ui.presetModal.removeClass('furn-is-open');
   }
   if (msg.message === "FurniturePresetAddItem") {
      const presetId = msg.presetId;
      const item = msg.item || {};


      let preset = STATEFURNITURE.presets.find(p => p.id === presetId);
      if (!preset) {

         preset = {
            id: presetId,
            name: presetId,
            items: []
         };
         STATEFURNITURE.presets.push(preset);
      }


      const imgPath = item.img || `img/furnitures/${(item.object || item.code || "").toString()}.webp`;

      const newItem = {
         id: item.id,
         code: item.object || item.code,
         name: item.label || item.name || (item.object || ""),
         img: imgPath,
         placed: !!item.placed,
      };

      preset.items.push(newItem);


      if (STATEFURNITURE.mode === "inventory") {
         if (!STATEFURNITURE.currentPresetId) {
            STATEFURNITURE.currentPresetId = preset.id;
         }
         renderRoot();
      }
   }
   if (msg.message === "FurnitureCartAddItem") {
      const it = msg.item || {};
      const imgPath = it.img || `img/furnitures/${(it.object || "").toString()}.webp`;

      const cartItem = {
         id: it.object,
         name: it.label || it.name || (it.object || ""),
         price: it.price || 0,
         img: imgPath,
      };

      STATEFURNITURE.incarts.push(cartItem);


      if (STATEFURNITURE.mode === "cart") {
         renderRoot();
      }
   }
   if (msg.message === "FurniturePresetCreate") {
      const p = msg.preset || {};
      if (!p.id) return;


      let existing = STATEFURNITURE.presets.find(x => x.id === p.id);
      if (!existing) {
         const preset = {
            id: p.id,
            name: p.name || p.label || p.id,
            items: (p.items || []).map(it => ({
               id: it.id,
               code: it.object || it.code,
               name: it.label || it.name || (it.object || ""),
               img: it.img || `img/furnitures/${(it.object || it.code || "").toString()}.webp`,
               placed: !!it.placed,
            })),
         };
         STATEFURNITURE.presets.push(preset);


         if (!STATEFURNITURE.currentPresetId) {
            STATEFURNITURE.currentPresetId = preset.id;
         }
      }

      renderRoot();
   }

   if (msg.message === "FurniturePresetDelete") {
      const presetId = msg.presetId;
      if (!presetId) return;

      const wasCurrent = (STATEFURNITURE.currentPresetId === presetId);
      const wasActive = (STATEFURNITURE.activePresetId === presetId);

      STATEFURNITURE.presets = STATEFURNITURE.presets.filter(p => p.id !== presetId);

      if (wasCurrent) {
         STATEFURNITURE.currentPresetId = STATEFURNITURE.presets[0]?.id || null;
      }
      if (wasActive) {
         STATEFURNITURE.activePresetId = STATEFURNITURE.presets[0]?.id || null;
      }

      renderRoot();
   }

   if (msg.message === "FurniturePresetRemoveItem") {
      const presetId = msg.presetId;
      const itemId = msg.itemId;
      if (!presetId || itemId == null) return;

      const preset = STATEFURNITURE.presets.find(p => p.id === presetId);
      if (!preset) return;

      preset.items = preset.items.filter(i => i.id !== itemId);

      if (STATEFURNITURE.mode === "inventory") {
         renderRoot();
      }
   }

   if (msg.message === "FurniturePresetUpdateItem") {
      const presetId = msg.presetId;
      const item = msg.item || {};
      if (!presetId || item.id == null) return;

      const preset = STATEFURNITURE.presets.find(p => p.id === presetId);
      if (!preset) return;

      const idx = preset.items.findIndex(i => i.id === item.id);
      if (idx === -1) return;

      const imgPath = item.img || `img/furnitures/${(item.object || item.code || "").toString()}.webp`;

      preset.items[idx] = {
         ...preset.items[idx],
         code: item.object || item.code || preset.items[idx].code,
         name: item.label || item.name || preset.items[idx].name,
         img: imgPath,
         placed: item.placed != null ? !!item.placed : preset.items[idx].placed,
      };

      if (STATEFURNITURE.mode === "inventory") {
         renderRoot();
      }
   }

   if (msg.message === "FurniturePresetTransferItem") {
      const fromId = msg.fromPresetId;
      const toId = msg.toPresetId;
      const it = msg.item || {};
      if (!fromId || !toId || it.id == null) return;

      const from = STATEFURNITURE.presets.find(p => p.id === fromId);
      const to = STATEFURNITURE.presets.find(p => p.id === toId);
      if (!from || !to) return;


      from.items = from.items.filter(i => i.id !== it.id);


      const imgPath = it.img || `img/furnitures/${(it.object || it.code || "").toString()}.webp`;
      const newItem = {
         id: it.id,
         code: it.object || it.code,
         name: it.label || it.name || (it.object || ""),
         img: imgPath,
         placed: !!it.placed,
      };

      const existingIdx = to.items.findIndex(i => i.id === it.id);
      if (existingIdx === -1) {
         to.items.push(newItem);
      } else {
         to.items[existingIdx] = newItem;
      }

      if (STATEFURNITURE.mode === "inventory") {
         renderRoot();
      }
   }

});