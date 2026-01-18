const IMG1="https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?q=80&w=1200&auto=format&fit=crop";
const IMG2="https://images.unsplash.com/photo-1519710164239-da123dc03ef4?q=80&w=1200&auto=format&fit=crop";
const IMG3="https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop";

function closeMain() {
    $("body").css("display", "none");
}

function openMain() {
    $("body").css("display", "block");
}

var housingresourcename = "rtx_housing";

let pcPickSearchTimer = null;

var defaultslots = 40;

var defaultweight = 100000;

$(function(){

  
  function defaultCfg(){
    return {
      address:"",name:"",desc:"",price:0,images:[],purchasable:true,rentable:false,rentPrice:0,inComplex:false,complexId:"",
      showBlip:false,furniture:{inside:true,outside:false},
      zone:null,enter:null,garage:false,garagePoint:null,wardrobe:false,wardrobePoint:null,
      storage:{enabled:false,point:null,slots:defaultslots,weight:defaultweight},
      sell:{enabled:false,point:null},island:{enabled:false,point:null},building:{enabled:false,point:null},
      iplId:"",shellId:"",iplTheme:"modern",mgmtPoint:null,doors:[],
      apt:{enter:null,garage:false,garagePoint:null,name:""}
    };
  }

  
  const S={
    view:"home",
    type:null,
    pick:null,
    editId:null,
    shells:[{id:"medium",name:"Medium Housing",images:[IMG1,IMG2,IMG3]},{id:"suburban",name:"Suburban Shell",images:[IMG2,IMG1]},{id:"studio",name:"Studio Shell",images:[IMG3,IMG2]}],
    ipls:[
      {
        id:"eclipse",
        name:"Eclipse Towers",
        images:[IMG2,IMG1],
        themes:[
          { id:"modern",     label:"Modern" },
          { id:"moody",      label:"Moody" },
          { id:"vibrant",    label:"Vibrant" },
          { id:"sharp",      label:"Sharp" },
          { id:"monochrome", label:"Monochrome" },
          { id:"seductive",  label:"Seductive" },
          { id:"regal",      label:"Regal" },
          { id:"aqua",       label:"Aqua" }
        ]
      },
      {
        id:"delperro",
        name:"Del Perro",
        images:[IMG3,IMG2],
        themes:[
          { id:"modern",  label:"Modern" },
          { id:"classic", label:"Classic" }
        ]
      }
    ],
    complexes:[],
    cfg: defaultCfg(),
    created:[
    ],
    list:{page:1, perPage:7, query:""},
  pickFilters: {
    SHELL: { search: "", tag: "all" },
    IPL:   { search: "", tag: "all" }
  }	
  };
  
   
  const Images = {
    ensureArray(){
      if (!Array.isArray(S.cfg.images)) S.cfg.images = [];
      return S.cfg.images;
    },
    list(){
      return this.ensureArray();
    },
    set(list){
      S.cfg.images = Array.isArray(list) ? list.slice() : [];
    },
    add(url){
      if (!url) return;
      const list = this.ensureArray();
      list.push(url);
    },
    remove(idx){
      const list = this.ensureArray();
      if (idx < 0 || idx >= list.length) return;
      list.splice(idx, 1);
    },
    clear(){
      S.cfg.images = [];
    }
  };
 

  const $pcStage = $('#pcStage');
  const $pcBrandType = $('#pcBrandType');

  
  function showNotification(message,type="success"){
    const $wrap = $('#pcToastWrap');
    if(!$wrap.length) return;

    const typeClass = type === "error" ? "pc-toast-error" : "pc-toast-success";
    const title = type==="success" ? "Sukces" : "Problem z walidacją";
    const icon  = type==="success"
      ? '<i class="fa-regular fa-circle-check"></i>'
      : '<i class="fa-regular fa-circle-xmark"></i>';

    const $toast = $(`
      <div class="pc-toast ${typeClass}">
        <div class="pc-toast-icon">${icon}</div>
        <div class="pc-toast-body">
          <div class="pc-toast-title">${title}</div>
          <div class="pc-toast-msg">${message}</div>
        </div>
      </div>
    `);

    $wrap.append($toast);

    const hideDelay = type==="error" ? 4200 : 3200;
    setTimeout(()=>{ $toast.addClass('pc-toast-hide'); }, hideDelay);
    setTimeout(()=>{ $toast.remove(); }, hideDelay+320);
  }

  
  const setBrandTag = () => {
    $pcBrandType.text((S.view==="config"||S.view==="pick") && S.type ? `` : "");
  };

	const back = () => {
	  
	  if (S.editId) {
		if (S.view === "review") {
		  S.view = "config";
		} else {
		  
		  S.view = "config";
		}
		render();
		return;
	  }

	  
	  if (S.view === "type" || S.view === "home") S.view = "home";
	  else if (S.view === "pick") S.view = "type";
	  else if (S.view === "config") S.view = (S.type === "SHELL" || S.type === "IPL") ? "pick" : "type";
	  else if (S.view === "review") S.view = "config";
	  else S.view = "home";
	  render();
	};


  function render(){
    if(S.view==="home") renderHome();
    else if(S.view==="type") renderType();
    else if(S.view==="pick") renderPick();
    else if(S.view==="config") renderConfig();
    else if(S.view==="review") renderReview();
    else if(S.view==="list") renderList();
    setBrandTag();
  }

function setCoord(id, has, ph = 'nie wybrano', labelText){
  const $el = $('#'+id);
  if(!$el.length) return;
  if (has) {
    const text = (typeof labelText === 'string' && labelText.length)
      ? labelText
      : ($el.val() || '(coords)');

    $el.val(text);
    $el.attr('placeholder', text);
    $el.removeClass('pc-is-empty');
  } else {
    $el.val('');
    $el.attr('placeholder', ph);
    $el.addClass('pc-is-empty');
  }
}

  const disableEls = (ids,disabled)=>{
    ids.forEach(id=>{
      const $el=$('#'+id);
      if(!$el.length) return;
      $el.prop('disabled', disabled).css('opacity', disabled?'.55':'1');
    });
  };

  
  const linkToggle = (tid,ids)=>{
    const $t = $('#'+tid);
    if(!$t.length) return;
    const apply = ()=>disableEls(ids, !$t.prop('checked'));
    apply();
    $t.on('change.pcLinkToggle', function(){ apply(); });
  };

  const byId = (arr,id)=>arr.find(x=>x.id===id);

  
function setCoordField(path, value="(coords from game)"){
  if(!path)return;
  const parts=path.split('.');
  let obj=S.cfg;
  for(let i=0;i<parts.length-1;i++){
    if(obj[parts[i]]==null) obj[parts[i]]={};
    obj=obj[parts[i]];
  }
  obj[parts[parts.length-1]] = value;
}

  function hasCoordField(path){
    if(!path)return false;
    const parts=path.split('.');
    let obj=S.cfg;
    for(let i=0;i<parts.length;i++){
      if(obj==null) return false;
      obj=obj[parts[i]];
    }
    return !!obj;
  }

function getCoordField(path){
  if(!path) return null;
  const parts = path.split('.');
  let obj = S.cfg;
  for(let i=0; i<parts.length; i++){
    if(obj == null) return null;
    obj = obj[parts[i]];
  }
  return obj;
}

  
  function renderHome(){
  const app = document.querySelector('.pc-app');
  app.classList.remove('is-ipl');	  
    app.classList.remove('is-list');  	    
    const total=S.created.length;
    const owned=S.created.filter(p=>p.owner).length;
    const forsale=total-owned;

    $pcStage.html(`
      <div class="pc-hero">
        <div class="pc-hero-left">
          <div class="pc-title">Witaj ponownie</div>
          <p class="pc-muted" style="margin:0 0 12px">Utwórz nowe nieruchomości lub zarządzaj już utworzonymi.</p>
          <div class="pc-hero-cards">
            <div class="pc-hero-card"><span class="pc-muted">Razem</span><b>${total}</b></div>
            <div class="pc-hero-card"><span class="pc-muted">Własność</span><b>${owned}</b></div>
            <div class="pc-hero-card"><span class="pc-muted">Na sprzedaż</span><b>${forsale}</b></div>
          </div>
          <div class="pc-hero-actions">
            <button class="pc-btn pc-btn-primary" id="goCreate"><i class="fa-solid fa-layer-group"></i> Utwórz Nieruchomość</button>
            <button class="pc-btn" id="goAll"><i class="fa-regular fa-rectangle-list"></i> Nieruchomości</button>
          </div>
        </div>
        <div class="pc-hero-right">

          <div class="pc-hero-tip" style="display: flex; align-items: flex-start; gap: 10px;">
            <i class="fa-solid fa-house" style="color:var(--accent); font-size: 18px; margin-top: 2px;"></i>
            <div>
              <b>Kreator Nieruchomości</b>
              <div class="pc-muted" style="margin-top: 2px;">
                Utwórz nową nieruchomość bezpośrednio w grze — wybierz typ i skonfiguruj wszystko tak, jak potrzebujesz.
              </div>
            </div>
          </div>

          <div class="pc-hero-tip" style="display: flex; align-items: flex-start; gap: 10px;">
            <i class="fa-solid fa-folder-open" style="color:var(--accent); font-size: 18px; margin-top: 2px;"></i>
            <div>
              <b>Zarządzanie Nieruchomościami</b>
              <div class="pc-muted" style="margin-top: 2px;">
                Edytuj swoje nieruchomości, zarządzaj własnością lub usuń je.
              </div>
            </div>
          </div>

        </div>
      </div>
    `);

    $('#goCreate').on('click', function(){
      S.cfg=defaultCfg();
      S.type=null;
      S.pick=null;
      S.editId=null;
      S.view='type'; render();
    });
    $('#goAll').on('click', function(){
      S.view='list'; render();
    });
  }

  
  function renderType(){
  const app = document.querySelector('.pc-app');
  app.classList.remove('is-ipl');	  
    $.post('https://'+housingresourcename+'/resetcreator', JSON.stringify({}));
	const T=[
      {k:"SHELL",name:"Shell",img:"img/shell.webp",desc:"Utwórz indywidualną nieruchomość."},
      {k:"IPL",name:"IPL",img:"img/ipl.webp", desc:"Utwórz indywidualną nieruchomość."},
      {k:"MLO",name:"MLO",img:"img/mlo.webp",desc:"Utwórz indywidualną nieruchomość."},
      {k:"APARTMENT",name:"Apartment Building",img:"img/apartment.webp",desc:"Utwórz kompleks mieszkaniowy."}
    ];
    $pcStage.html(`
      <div class="pc-panel pc-stack">
        <div class="pc-head"><i class="fa-solid fa-layer-group"></i> Wybierz typ nieruchomości</div>
        <div class="pc-type-grid">
          ${T.map(t=>`
            <div class="pc-type-card">
              <div class="pc-title">${t.name}</div>
              <div class="pc-muted">${t.desc}</div>
              <div class="pc-slider"><div class="pc-slider-slides"><img src="${t.img}"/></div></div>
              <button class="pc-btn pc-btn-primary" data-k="${t.k}">Wybierz</button>
            </div>`).join('')}
        </div>
        <div class="pc-footer"><button class="pc-btn" id="backHome"><i class="fa-solid fa-arrow-left"></i> Wstecz</button></div>
      </div>`);

    $pcStage.find('[data-k]').each(function(){
      const $b=$(this);
      $b.on('click', function(){
        S.type=$b.data('k');
        S.cfg=defaultCfg();
        S.pick=null;
        S.editId=null;
        S.view=(S.type==="SHELL"||S.type==="IPL")?"pick":"config";
        render();
      });
    });

    $('#backHome').on('click', function(){
      S.view='home'; render();
    });
  }

function renderPick(){
  const app = document.querySelector('.pc-app');
  app.classList.remove('is-ipl');	
  const isShell = S.type === "SHELL";
  const items   = isShell ? S.shells : S.ipls;

  const f = (S.pickFilters[S.type] ||= { search: "", tag: "all" });

  
  const allTags = Array.from(
    new Set(
      items.flatMap(it => Array.isArray(it.tags) ? it.tags : [])
    )
  ).sort();

  $pcStage.html(`
    <div class="pc-panel pc-stack">
      <div class="pc-head pc-head-pick">
        <div class="pc-head-left">
          <span><i class="fa-regular fa-images"></i> Wybierz ${S.type}</span>
          <span class="pc-muted pc-head-sub" id="pcPickResults"></span>
        </div>
        <div class="pc-pick-filters">
          <input id="pcPickSearch"
                 class="pc-pick-input"
                 placeholder="Szukaj po nazwie lub tagu..."
                 value="${f.search || ""}">
          <select id="pcPickTag" class="pc-pick-select">
            <option value="all">Wszystkie tagi</option>
            ${allTags.map(t => `
              <option value="${t}" ${f.tag === t ? "selected" : ""}>${t}</option>
            `).join("")}
          </select>
        </div>
      </div>

      <div class="pc-type-grid" style="grid-template-columns:repeat(3,minmax(0,1fr))">
        ${items.map(it => {
          const tags = Array.isArray(it.tags) ? it.tags : [];
          const tagStr = tags.join(" ").toLowerCase();
          const nameStr = (it.name || "").toLowerCase();

          const imgs = (it.images && it.images.length ? it.images : ["img/noimage.webp"]);

          return `
            <div class="pc-type-card"
                 data-name="${nameStr}"
                 data-tags="${tagStr}">
              <div class="pc-title">
                <span class="pc-ellipsis">${it.name}</span>
              </div>
              <div class="pc-pick-tags">
                ${tags.map(t => `<span class="pc-pick-tag">${t}</span>`).join("")}
              </div>

              <div class="pc-slider" data-uid="${it.id}">
                <div class="pc-slider-slides">
                  ${imgs.map(src => `<img src="${src}">`).join("")}
                </div>
                <div class="pc-slider-arrow l"><i class="fa-solid fa-chevron-left"></i></div>
                <div class="pc-slider-arrow r"><i class="fa-solid fa-chevron-right"></i></div>
                <div class="pc-slider-nav">
                  ${imgs.map((_,i)=>`<div class="pc-slider-dot ${i===0?'active':''}"></div>`).join("")}
                </div>
              </div>

              <div class="pc-field-wrap" style="justify-content:space-between">
                <button class="pc-btn" data-preview="${it.id}">
                  <i class="fa-regular fa-eye"></i> Podgląd
                </button>
                <button class="pc-btn pc-btn-primary" data-pick="${it.id}">
                  Wybierz
                </button>
              </div>
            </div>
          `;
        }).join("")}
      </div>

      <div class="pc-footer">
        <button class="pc-btn" id="backType">
          <i class="fa-solid fa-arrow-left"></i> Wstecz
        </button>
      </div>
    </div>
  `);


  
  $pcStage.find('.pc-slider').each(function(){
    const $sl=$(this);
    let i=0;
    const $slides=$sl.find('.pc-slider-slides');
    const $dots=$sl.find('.pc-slider-dot');
    const max=$dots.length || 1;
    const set=(n)=>{
      i=(n+max)%max;
      $slides.css('transform',`translateX(${-i*100}%)`);
      $dots.each(function(k){
        $(this).toggleClass('active',k===i);
      });
    };
    $sl.find('.pc-slider-arrow.l').on('click', ()=>set(i-1));
    $sl.find('.pc-slider-arrow.r').on('click', ()=>set(i+1));
    $dots.each(function(di){
      $(this).on('click', ()=>set(di));
    });
  });

  
  $pcStage.find('[data-preview]').each(function () {
    const $b = $(this);

    $b.off('click').on('click', function () {
      const presetId = String($b.data('preview'));

      if (S.type === 'SHELL') {
        $.post('https://' + housingresourcename + '/previewshell',
          JSON.stringify({ shellid: presetId })
        );
      } else if (S.type === 'IPL') {
        $.post('https://' + housingresourcename + '/previewipl',
          JSON.stringify({
            iplid:      presetId,
            iplthemeid: S.cfg.iplTheme || null
          })
        );
      }
    });
  });

  
  $pcStage.find('[data-pick]').each(function(){
    const $b=$(this);
    $b.on('click', function(){
      const arr = isShell ? S.shells : S.ipls;
      const id  = $b.data('pick');
      S.pick    = arr.find(x=>x.id===id) || null;
      if(isShell) S.cfg.shellId = S.pick?.id || "";
      if(!isShell) S.cfg.iplId  = S.pick?.id || "";
      S.view='config'; render();
    });
  });

  $('#backType').on('click', function(){
    S.view = 'type';
    render();
  });

  
  $('#pcPickSearch').off('input').on('input', function(){
    S.pickFilters[S.type].search = $(this).val();
    pcApplyPickFilters();
  });

  $('#pcPickTag').off('change').on('change', function(){
    S.pickFilters[S.type].tag = $(this).val();
    pcApplyPickFilters();
  });

  
  pcApplyPickFilters();

}

function pcApplyPickFilters(){
  const isShell = (S.type === "SHELL");
  const items   = isShell ? S.shells : S.ipls;
  const f = (S.pickFilters[S.type] ||= { search:"", tag:"all" });

  const q   = (f.search || "").trim().toLowerCase();
  const tag = (f.tag || "all").toLowerCase();

  let shown = 0;

  $('.pc-type-card').each(function(){
    const $card = $(this);
    const name  = ($card.data('name') || "").toString();
    const tags  = ($card.data('tags') || "").toString();

    let visible = true;

    if (tag !== "all") {
      const tagList = tags.split(/\s+/).filter(Boolean);
      if (!tagList.includes(tag)) visible = false;
    }

    if (visible && q) {
      const hay = (name + " " + tags);
      if (!hay.includes(q)) visible = false;
    }

    $card.toggle(visible);
    if (visible) shown++;
  });

  const total = items.length;
  let label = `${total} ${isShell ? "shelli" : "IPL-i"}`;
  if (shown !== total) {
    label += ` · ${shown} wynik${shown === 1 ? "" : shown < 5 ? "i" : "ów"}`;
  }
  $('#pcPickResults').text(label);
}


  
  function renderConfig(){
    const c=S.cfg,
      isS=S.type==="SHELL",
      isI=S.type==="IPL",
      isM=S.type==="MLO",
      isA=S.type==="APARTMENT";
  const app = document.querySelector('.pc-app');
  if (!app) return;

  if (isI) {
    app.classList.add('is-ipl');
  } else {
    app.classList.remove('is-ipl');
  }	  
    const currentIpl = isI ? byId(S.ipls, c.iplId || S.pick?.id) : null;
    let iplThemes = currentIpl && Array.isArray(currentIpl.themes) ? currentIpl.themes : [];
	$.post('https://'+housingresourcename+'/doorcreatorreset', JSON.stringify({}));
      $.post(
        'https://' + housingresourcename + '/setiplshelldata',
        JSON.stringify({
          typehousing: S.type,
		  shellpreset: S.cfg.shellId,
		  iplreset: S.cfg.iplId
        })
      );		
    
    if (isI && iplThemes.length && !iplThemes.some(function(t){ return t.id === c.iplTheme; })) {
      c.iplTheme = iplThemes[0].id;
    }

    const row=(label,inner,opts={pin:true,id:''})=>`
      <div class="pc-row">
        <div class="pc-label">${label}</div>
        <div class="pc-field-wrap">${inner}</div>
        <div>${opts.pin?`<button class="pc-pin" id="pin_${opts.id}"><i class="fa-solid fa-location-dot"></i></button>`:""}</div>
        <div>${opts.id==="storage"?`<button class="pc-gear" id="extra_storage"><i class="fa-solid fa-gear"></i></button>`:""}</div>
      </div>`;
    const readonly=(id,ph='nie wybrano')=>`<input id="${id}" readonly class="pc-is-empty" placeholder="${ph}">`;
    const toggle=(id,checked)=>`<label class="pc-switch"><input id="${id}" type="checkbox" ${checked?'checked':''}><span class="pc-switch-track"><span class="pc-switch-knob"></span></span></label>`;

    if(isA){
      $pcStage.html(`
        <div class="pc-config">
          <div class="pc-stack"><div class="pc-panel pc-panel-fill pc-stack">
            <div class="pc-group-title"><i style="color:var(--accent);" class="fa-regular fa-id-card"></i> Szczegóły i Opcje</div>
            <div class="pc-grid pc-grid-2">
              <div>
                <div class="pc-group-title">Adres</div>
                <div class="pc-inline-ctl">
                  <input id="address" value="${c.address}">
                  <button class="pc-pin" id="pin_address"><i class="fa-solid fa-location-dot"></i></button>
                </div>
              </div>
              <div><div class="pc-group-title">Nazwa kompleksu mieszkaniowego</div><input id="aptName" value="${c.apt.name}"></div>
            </div>
            <div><div class="pc-group-title">Opis</div><textarea id="pdesc">${c.desc}</textarea></div>
            <div><div class="pc-group-title">Pokaż znacznik na mapie</div>${toggle('showBlip',c.showBlip)}</div>
          </div></div>

          <div class="pc-stack"><div class="pc-panel pc-panel-fill pc-stack">
            <div class="pc-group-title"><i style="color:var(--accent);"class="fa-solid fa-gear"></i> Konfiguracja</div>
            ${row('Strefa nieruchomości',readonly('zone'),{pin:true,id:'propertyzone'})}
            ${row('Punkt wejścia',readonly('enter'),{pin:true,id:'enter'})}
            ${row('Garaż mieszkaniowy',`${toggle('aptGarage',c.apt.garage)}${readonly('aptGaragePt')}`,{pin:true,id:'aptgarage'})}
          </div></div>
        </div>
        <div class="pc-footer">
          ${S.editId ? '' : `
            <button class="pc-btn" id="goBack">
              <i class="fa-solid fa-arrow-left"></i> Wstecz
            </button>
          `}
          <button class="pc-btn pc-btn-primary" id="goReview">
            <i class="fa-regular fa-circle-check"></i> Przejdź do Zakończenia
          </button>
        </div>

      `);
    } else {
      $pcStage.html(`
        <div class="pc-config">
          <div class="pc-stack"><div class="pc-panel pc-panel-fill pc-stack">
            <div class="pc-group-title"><i style="color:var(--accent);" class="fa-solid fa-gear"></i> Konfiguracja</div>

            ${(isS||isI)?`
              <div>
                <div class="pc-group-title">Preset ${isS?'Shell':'IPL'}</div>
                <div class="pc-inline-ctl">
                  <select id="presetSelect">
                    ${(isS?S.shells:S.ipls).map(p=>`<option value="${p.id}" ${ (isS?c.shellId:c.iplId)===p.id || (S.pick?.id===p.id && !(isS?c.shellId:c.iplId)) ? 'selected':'' }>${p.name}</option>`).join('')}
                  </select>
                  <button class="pc-btn pc-btn-h40" id="presetPreview"><i class="fa-regular fa-eye"></i></button>
                </div>
						  </div>
			${isI?`
			  <div style="margin-top:-6px">
				<div class="pc-group-title">Motyw IPL</div>
				<select id="iplTheme">
				  ${iplThemes.map(function(t){
					const id = String(t.id);
					const label = t.label || id;
					const sel = (c.iplTheme === id) ? 'selected' : '';
					return `<option value="${id}" ${sel}>${label}</option>`;
				  }).join('')}
				</select>
			  </div>
			`:""}

            `:""}

            ${(isS||isI)?row('Punkt wejścia',readonly('enter'),{pin:true,id:'enter'}):""}
            ${(isS||isI)?row('Strefa nieruchomości',readonly('zone'),{pin:true,id:'propertyzone'}):""}

            ${isM?row('Punkt zarządzania',readonly('mgmt'),{pin:true,id:'mgmt'}):""}
            ${isM?row('Strefa nieruchomości',readonly('zone'),{pin:true,id:'propertyzone'}):""}

            ${row('Garaż',`${toggle('hasGarage',c.garage)}${readonly('garagePt')}`,{pin:true,id:'garage'})}
            ${row('Szafa',`${toggle('hasWardrobe',c.wardrobe)}${readonly('wardrobePt')}`,{pin:true,id:'wardrobe'})}
            ${row('Punkt magazynu',`${toggle('storeOn',c.storage.enabled)}${readonly('storagePt')}`,{pin:true,id:'storage'})}
            ${row('Znak sprzedaży',`${toggle('sellOn',c.sell.enabled)}${readonly('sellInput','nie umieszczono')}`,{pin:true,id:'sell'})}
            ${row('Umieść Wyspę',`${toggle('islandOn',c.island.enabled)}${readonly('islandInput','nie umieszczono')}`,{pin:true,id:'island'})}
            ${row('Umieść Budynek',`${toggle('buildingOn',c.building.enabled)}${readonly('buildingInput','nie umieszczono')}`,{pin:true,id:'building'})}

            ${isM?`
              <div class="pc-row" style="margin-top:-6px">
                <div class="pc-label">Drzwi</div>
                <div class="pc-field-wrap"><button class="pc-btn pc-btn-doors" id="openDoors"><i class="fa-solid fa-sliders"></i> Konfiguruj drzwi</button></div>
                <div></div><div></div>
              </div>`:""}
          </div></div>

          <div class="pc-stack"><div class="pc-panel pc-panel-fill pc-stack">
            <div class="pc-group-title"><i style="color:var(--accent);" class="fa-regular fa-id-card"></i> Szczegóły i Opcje</div>
            <div class="pc-grid pc-grid-2">
              <div>
                <div class="pc-group-title">Adres</div>
                <div class="pc-inline-ctl">
                  <input id="address" value="${c.address}">
                  <button class="pc-pin" id="pin_address"><i class="fa-solid fa-location-dot"></i></button>
                </div>
              </div>
              <div><div class="pc-group-title">Nazwa nieruchomości</div><input id="pname" value="${c.name}"></div>
            </div>
            <div><div class="pc-group-title">Opis</div><textarea id="pdesc">${c.desc}</textarea></div>
            <div class="pc-grid pc-grid-2">
              <div><div class="pc-group-title">Do kupna</div><div class="pc-field-wrap">${toggle('purchasable',c.purchasable)}<div class="pc-input-prefix"><span>$</span><input id="price" type="number" value="${c.price}" ${c.rentable?'':'disabled'}"></div></div></div>
              <div><div class="pc-group-title">Do wynajęcia</div><div class="pc-field-wrap">${toggle('rentable',c.rentable)}<div class="pc-input-prefix" style="flex:1"><span>$</span><input id="rentPrice" type="number" value="${c.rentPrice}" ${c.rentable?'':'disabled'}></div></div></div>
            </div>

            ${(isS||isI)?`
            <div class="pc-field-wrap"><span style="font-weight:800">Część kompleksu</span>${toggle('inComplex',c.inComplex)}</div>
            <select id="complexSel">${[{id:"",label:"Wybierz kompleks"},...S.complexes].map(o=>`<option value="${o.id}" ${c.complexId===o.id?'selected':''}>${o.label}</option>`).join('')}</select>
            `:""}

            <div class="pc-grid pc-grid-2" style="margin-top:6px">
              <div><div class="pc-group-title">Pokaż znacznik na mapie</div>${toggle('showBlip',c.showBlip)}</div>
              <div>
                <div class="pc-group-title">Meble</div>
                <div class="pc-field-wrap">
                  <span class="pc-muted">Wewnątrz</span>${toggle('furnIn',c.furniture.inside)}
                  <span class="pc-muted">Na zewnątrz</span>${toggle('furnOut',c.furniture.outside)}
                </div>
              </div>
            </div>
<div class="pc-row" style="margin-top:-6px">
    <div class="pc-field-wrap">
        <button class="pc-btn pc-btn-doors" id="pcImagesOpen">
            <i class="fa-solid fa-images"></i> Zarządzaj obrazami
        </button>
    </div>
    <div></div>
    <div></div>
    <div></div>
</div>


          </div></div>
        </div>

        <div class="pc-footer">
          ${S.editId ? '' : `
            <button class="pc-btn" id="goBack">
              <i class="fa-solid fa-arrow-left"></i> Wstecz
            </button>
          `}
          <button class="pc-btn pc-btn-primary" id="goReview">
            <i class="fa-regular fa-circle-check"></i> Przejdź do Zakończenia
          </button>
        </div>

      `);
    }

    
    const B=(id,ev,fn)=>{
      const $el=$('#'+id);
      if(!$el.length) return;
      const evtName = ev.replace(/^on/,'');
      $el.on(evtName, fn);
    };

    
    const coordMap={
      zone:'zone',
      enter:'enter',
      garagePt:'garagePoint',
      wardrobePt:'wardrobePoint',
      storagePt:'storage.point',
      sellInput:'sell.point',
      islandInput:'island.point',
      buildingInput:'building.point',
      mgmt:'mgmtPoint',
      aptGaragePt:'apt.garagePoint'
    };
Object.keys(coordMap).forEach(id=>{
  const value = getCoordField(coordMap[id]);   
  const has   = !!value;
  setCoord(id, has, 'nie wybrano', value);    
});


	
	B('address','oninput', e => {
	  S.cfg.address = e.target.value;
	});

	
	const $pinAddr = $('#pin_address');
	if ($pinAddr.length) {
	  $pinAddr.off('click').on('click', function () {
		$.post(
		  'https://' + housingresourcename + '/pointcreator',
		  JSON.stringify({
			action:  'address_point', 
			pinId:   'pin_address',
			fieldId: 'address',       
			fieldKey:'address'        
		  })
		);
	  });
	}

    B('pname','oninput',e=>{ S.cfg.name=e.target.value; });
    B('pdesc','oninput',e=>{ S.cfg.desc=e.target.value; });
    B('price','oninput',e=>{ S.cfg.price=+e.target.value||0; });
    B('rentable','onchange',e=>{
      S.cfg.rentable=e.target.checked;
      const $rp=$('#rentPrice');
      if($rp.length) $rp.prop('disabled', !e.target.checked);
    });
    B('purchasable','onchange',e=>{
      S.cfg.purchasable=e.target.checked;
      const $rp=$('#price');
      if($rp.length) $rp.prop('disabled', !e.target.checked);
    });	
    B('rentPrice','oninput',e=>{ S.cfg.rentPrice=+e.target.value||0; });
    B('showBlip','onchange',e=>{ S.cfg.showBlip=e.target.checked; });
    B('furnIn','onchange',e=>{ S.cfg.furniture.inside=e.target.checked; });
    B('furnOut','onchange',e=>{ S.cfg.furniture.outside=e.target.checked; });
    B('complexSel','onchange',e=>{ S.cfg.complexId=e.target.value; });

    B('inComplex','onchange',e=>{
      S.cfg.inComplex = e.target.checked;
      applyComplexLocks();
    });

    B('hasGarage','onchange',e=>{ S.cfg.garage=e.target.checked; });
    B('hasWardrobe','onchange',e=>{ S.cfg.wardrobe=e.target.checked; });
    B('storeOn','onchange',e=>{ S.cfg.storage.enabled=e.target.checked; });
    B('sellOn','onchange',e=>{ S.cfg.sell.enabled=e.target.checked; });
	
	B('islandOn','onchange', e => {
	  const enabled = e.target.checked;
	  S.cfg.island.enabled = enabled;

	  $.post(
		'https://' + housingresourcename + '/toggleIsland',
		JSON.stringify({
		  enabled: enabled
		})
	  );
	});

	
	B('buildingOn','onchange', e => {
	  const enabled = e.target.checked;
	  S.cfg.building.enabled = enabled;

	  $.post(
		'https://' + housingresourcename + '/toggleBuilding',
		JSON.stringify({
		  enabled: enabled
		})
	  );
	});

    B('aptGarage','onchange',e=>{ S.cfg.apt.garage=e.target.checked; });

    if(isI){ B('iplTheme','onchange',e=>{ S.cfg.iplTheme=e.target.value; }); }
    if(isA){ B('aptName','oninput',e=>{ S.cfg.apt.name=e.target.value; }); }

    function applyComplexLocks(){
      const $complexToggle=$('#inComplex');
      if(!$complexToggle.length || !(isS||isI)) return;
      const complex=$complexToggle.prop('checked');

      const $blip=$('#showBlip');
      const $out=$('#furnOut');
      if($blip.length){
        $blip.prop('disabled', !!complex);
        const $wrap=$blip.closest('div');
        if($wrap.length) $wrap.css('opacity', complex?0.5:1);
        if(complex){
          $blip.prop('checked', false);
          S.cfg.showBlip=false;
        }
      }
      if($out.length){
        $out.prop('disabled', !!complex);
        const $fw=$out.closest('.pc-field-wrap');
        if($fw.length) $fw.css('opacity', complex?0.6:1);
        if(complex){
          $out.prop('checked', false);
          S.cfg.furniture.outside=false;
        }
      }

      const lockIDs=['hasGarage','sellOn','islandOn','buildingOn'];
      lockIDs.forEach(id=>{
        const $t=$('#'+id);
        if(!$t.length) return;
        const disable=!!complex;
        $t.prop('disabled', disable);
        const $row=$t.closest('.pc-row');
        if($row.length){
          const $fw=$row.find('.pc-field-wrap').first();
          if($fw.length) $fw.css('opacity', disable?0.55:1);
        }
        if(disable){
          $t.prop('checked', false);
        }
      });

      ['garagePt','sellInput','islandInput','buildingInput','enter'].forEach(i=>{
        const $el=$('#'+i);
        if($el.length){
          $el.prop('disabled', !!complex)
             .css('opacity', complex?0.55:1);
          if(complex){
            $el.val('');
            $el.attr('placeholder','nie wybrano')
               .addClass('pc-is-empty');
          }
        }
      });

      const $zoneInput=$('#zone');
      const $zonePin=$('#pin_propertyzone');
      if($zoneInput.length){
        $zoneInput.prop('disabled', complex).css('opacity', complex?0.55:1);
      }
      if($zonePin.length){
        $zonePin.prop('disabled', complex).css('opacity', complex?0.55:1);
      }
     const $enterInput=$('#enter');
	 const $enterPin=$('#pin_enter');
      if($enterInput.length){
        $enterInput.prop('disabled', complex).css('opacity', complex?0.55:1);
      }
      if($enterPin.length){
        $enterPin.prop('disabled', complex).css('opacity', complex?0.55:1);
      }	  
    }
    applyComplexLocks();

const $presetSel = $('#presetSelect');
const $presetPreview = $('#presetPreview');

if ($presetSel.length) {
  
  if (isS && !S.cfg.shellId) S.cfg.shellId = $presetSel.val();
  if (isI && !S.cfg.iplId)   S.cfg.iplId   = $presetSel.val();

  $presetSel.off('change').on('change', function (e) {
    const val = $(this).val();

    if (isS) {
      S.cfg.shellId = val;

      const idx = S.shells.findIndex(function (sh) {
        return String(sh.id) === String(val);
      });

      $.post(
        'https://' + housingresourcename + '/setiplshelldata',
        JSON.stringify({
          typehousing: S.type,
		  shellpreset: S.cfg.shellId,
		  iplreset: S.cfg.iplId
        })
      );		  

    } else if (isI) {
      S.cfg.iplId = val;

      const idx = S.ipls.findIndex(function (it) {
        return String(it.id) === String(val);
      });

      $.post(
        'https://' + housingresourcename + '/setiplshelldata',
        JSON.stringify({
          typehousing: S.type,
		  shellpreset: S.cfg.shellId,
		  iplreset: S.cfg.iplId
        })
      );		  
    }

    
    renderConfig();
  });
}

if ($presetPreview.length) {
  $presetPreview.off('click').on('click', function () {
    if (!$presetSel.length) return;

    const id = String($presetSel.val()); 
    const themeId = S.cfg.iplTheme || null; 

    if (isS) {

      
      $.post(
        'https://' + housingresourcename + '/previewshell',
        JSON.stringify({
          shellid: id
        })
      );

    } else if (isI) {

      
      $.post(
        'https://' + housingresourcename + '/previewipl',
        JSON.stringify({
          iplid: id,
          iplthemeid: themeId
        })
      );

    } else {
    }
  });
}



	
	function registerPin(id, fieldId, fieldKey, nuiAction){
	  const $el = $('#'+id);
	  if(!$el.length) return;

	  $el.off('click').on('click', function(){
		const propertyType = S.type || null;

		
		const payload = {
		  action:     nuiAction,   
		  pinId:      id,          
		  fieldId:    fieldId,     
		  fieldKey:   fieldKey,    
		  propertyType: propertyType,
		  shellId:    null,
		  iplId:      null,
		  iplThemeId: null
		};

		
		if (propertyType === 'SHELL') {
		  payload.shellId = S.cfg.shellId || null;
		} else if (propertyType === 'IPL') {
		  payload.iplId      = S.cfg.iplId   || null;
		  payload.iplThemeId = S.cfg.iplTheme || null;
		}


		$.post(
		  'https://' + housingresourcename + '/pointcreator',
		  JSON.stringify(payload)
		);
	  });
	}


	
	registerPin('pin_propertyzone', 'zone',        'zone',           'property_zone');
	registerPin('pin_enter',        'enter',       'enter',          'enter_point');
	registerPin('pin_garage',       'garagePt',    'garagePoint',    'garage_point');
	registerPin('pin_wardrobe',     'wardrobePt',  'wardrobePoint',  'wardrobe_point');
	registerPin('pin_storage',      'storagePt',   'storage.point',  'storage_point');
	registerPin('pin_sell',         'sellInput',   'sell.point',     'sell_point');
	registerPin('pin_island',       'islandInput', 'island.point',   'island_point');
	registerPin('pin_building',     'buildingInput','building.point','building_point');
	registerPin('pin_mgmt',         'mgmt',        'mgmtPoint',      'management_point');
	registerPin('pin_aptgarage',    'aptGaragePt', 'apt.garagePoint','apt_garage_point');


    linkToggle('hasGarage',['garagePt','pin_garage']);
    linkToggle('hasWardrobe',['wardrobePt','pin_wardrobe']);
    linkToggle('storeOn',['storagePt','pin_storage','extra_storage']);
    linkToggle('sellOn',['sellInput','pin_sell']);
    linkToggle('islandOn',['islandInput','pin_island']);
    linkToggle('buildingOn',['buildingInput','pin_building']);
    linkToggle('aptGarage',['aptGaragePt','pin_aptgarage']);

    const $gear=$('#extra_storage');
    if($gear.length){
      $gear.on('click', openStorage);
    }

    if(isM){
      const $b=$('#openDoors');
      if($b.length){
        $b.on('click', openDoorsModal);
      }
    }

    $('#goBack').on('click', back);
    $('#goReview').on('click', function(){
      S.view='review'; render();
    });
  }

  
  function validateCurrentConfig(){
    const c = S.cfg;
    const errors = [];
    const reqText = (val,label)=>{
      if(!val || !String(val).trim()) errors.push(label+' jest wymagany');
    };

    if (S.type === "SHELL" || S.type === "IPL") {
      reqText(c.address,'Adres');
      reqText(c.name,'Nazwa nieruchomości');
      reqText(c.desc,'Opis');

      if (!c.inComplex && !c.enter) {
        errors.push('Punkt wejścia jest wymagany');
      }

      if (!c.inComplex && !c.zone) {
        errors.push('Strefa jest wymagana');
      }

    } else if (S.type === "MLO") {
      reqText(c.address,'Adres');
      reqText(c.name,'Nazwa nieruchomości');
      reqText(c.desc,'Opis');
      if (!c.mgmtPoint) errors.push('Punkt zarządzania jest wymagany');
      if (!c.zone) errors.push('Strefa jest wymagana');
      if (!c.doors || !c.doors.length) {
        errors.push('Wymagane jest co najmniej 1 drzwi dla nieruchomości MLO');
      }

    } else if (S.type === "APARTMENT") {
      reqText(c.address,'Adres');
      reqText(c.apt.name,'Nazwa kompleksu mieszkaniowego');
      reqText(c.desc,'Opis');
      if (!c.zone) errors.push('Strefa jest wymagana');
      if (!c.enter) errors.push('Punkt wejścia jest wymagany');
    }

    return errors;
  }

  
  function renderReview(){
  const app = document.querySelector('.pc-app');
  app.classList.remove('is-ipl');	  
    const c=S.cfg;
    const rawType=S.type || "UNKNOWN";
    const displayType=rawType==="APARTMENT"?"Kompleks Mieszkaniowy":rawType;
    const fallbackName = S.pick ? S.pick.name :
      (rawType === "APARTMENT" ? (S.cfg.apt.name || "Kompleks Mieszkaniowy") : rawType);
    const finalName = S.cfg.name || fallbackName;

    $pcStage.html(`
      <div class="pc-panel pc-stack">
        <div class="pc-head"><i class="fa-regular fa-circle-check"></i> Przegląd i ${S.editId ? 'Zapisz zmiany' : 'Utwórz'}</div>
        <div class="pc-grid pc-grid-3">
          <div class="pc-panel">Typ: <b>${displayType}</b></div>
          <div class="pc-panel">Nazwa: <b>${finalName}</b></div>
          <div class="pc-panel">Adres: <b>${c.address||'—'}</b></div>
        </div>
        <div class="pc-footer">
          <button class="pc-btn" id="backCfg"><i class="fa-solid fa-arrow-left"></i> Wstecz</button>
          <button class="pc-btn pc-btn-primary" id="create">${S.editId ? 'Zapisz' : 'Utwórz'}</button>
        </div>
      </div>
    `);

    $('#backCfg').on('click', function(){
      S.view='config'; render();
    });

   $('#create').on('click', function(){
    const errors = validateCurrentConfig();
    if (errors.length) {
      const msg = "Proszę wypełnić wszystkie wymagane pola:\n- " + errors.join("\n- ");
      showNotification(msg, "error");
      return;
    }

    const rawType = S.type || "UNKNOWN";
    const snapshot  = JSON.parse(JSON.stringify(S.cfg));

    let payload = null;   
    let mode    = null;   

    if (S.editId) {
      mode = 'edit';
      const idx = S.created.findIndex(p => p.id === S.editId);
      if (idx !== -1) {
        const before = JSON.parse(JSON.stringify(S.created[idx]));
        S.created[idx] = {
          ...S.created[idx],
          type: rawType,
          name: finalName,
          address: S.cfg.address || '—',
          cfg: snapshot
        };
        const after = JSON.parse(JSON.stringify(S.created[idx]));

        if (rawType === "APARTMENT") {
          const cx = S.complexes.find(c => c.id === `apt-${S.created[idx].id}`);
          if (cx) cx.label = finalName;
        }
        showNotification("Nieruchomość zapisana pomyślnie.", "success");

        payload = JSON.parse(JSON.stringify(S.created[idx]));
      }
    } else {
      mode = 'create';
      const rec = {
        id: Date.now().toString(),
        type: rawType,
        name: finalName,
        address: S.cfg.address || '—',
        owner: null,
        status: "Na Sprzedaż",
        cfg: snapshot
      };
      showNotification("Nieruchomość utworzona pomyślnie.", "success");

      payload = JSON.parse(JSON.stringify(rec));
    }

    
    if (payload) {
      $.post(
        'https://' + housingresourcename + '/propertycreatorSave',
        JSON.stringify({
          mode:   mode,    
          record: payload  
        })
      );
    }

    
    S.cfg = defaultCfg();
    S.type = null;
    S.pick = null;
    S.editId = null;
    S.view = 'home';
    render();
  });

  }

  
  function renderList(){
  const app = document.querySelector('.pc-app');
  app.classList.remove('is-ipl');	  
    app.classList.add('is-list');  	  
    S.created.sort(function(a, b) {
        return Number(a.id) - Number(b.id);
    });    
	const q=S.list.query.toLowerCase().trim();
    const filtered = !q ? S.created.slice() :
      S.created.filter(p=>{
        const s=[p.name,p.address,p.type,(p.owner?.name||""),(p.owner?.identifier||"")].join(' ').toLowerCase();
        return s.includes(q);
      });
    const per=S.list.perPage;
    const maxPages=Math.max(1, Math.ceil(filtered.length/per));
    S.list.page = Math.min(Math.max(1,S.list.page), maxPages);
    const start=(S.list.page-1)*per, end=start+per;
    const pageItems = filtered.slice().reverse().slice(start,end);

    $pcStage.html(`
      <div class="pc-panel pc-stack">
        <div class="pc-head"><i class="fa-regular fa-rectangle-list"></i> Utworzone Nieruchomości</div>

        <div>
          <div class="pc-group-title">Szukaj</div>
          <input id="searchInput" placeholder="Szukaj po nazwie, adresie, typie lub właścicielu…" value="${S.list.query}">
        </div>

        <div class="pc-table">
          <div class="pc-thead">
            <div>Typ</div><div>Nazwa</div><div>Adres</div><div>Właściciel</div><div style="text-align:right">Akcje</div>
          </div>
          <div id="rowsWrap">
            ${renderTableRows(pageItems)}
          </div>
        </div>

        <div class="pc-pager">
          <span class="pc-pager-info">Strona ${S.list.page} / ${maxPages}</span>
          <button class="pc-btn pc-btn-small" id="pgPrev"><i class="fa-solid fa-chevron-left"></i></button>
          <button class="pc-btn pc-btn-small" id="pgNext"><i class="fa-solid fa-chevron-right"></i></button>
        </div>

        <div class="pc-footer"><button class="pc-btn" id="backHome"><i class="fa-solid fa-arrow-left"></i> Wstecz</button></div>
      </div>
    `);

    $('#searchInput').on('input', function(e){
      S.list.query=e.target.value;
      S.list.page=1;
      updateListFromState();
    });
    $('#pgPrev').on('click', function(){
      if(S.list.page>1){ S.list.page--; updateListFromState(); }
    });
    $('#pgNext').on('click', function(){
      S.list.page++; updateListFromState();
    });
    bindRowActions();
    $('#backHome').on('click', function(){
      S.view='home'; render();
    });
  }

  function updateListFromState(){
    const q=S.list.query.toLowerCase().trim();
    const filtered = !q ? S.created.slice() :
      S.created.filter(p=>{
        const s=[p.name,p.address,p.type,(p.owner?.name||""),(p.owner?.identifier||"")].join(' ').toLowerCase();
        return s.includes(q);
      });

    const per=S.list.perPage;
    const maxPages=Math.max(1, Math.ceil(filtered.length/per));
    S.list.page = Math.min(Math.max(1,S.list.page), maxPages);
    const start=(S.list.page-1)*per, end=start+per;
    const pageItems = filtered.slice().reverse().slice(start,end);

    const $wrap=$('#rowsWrap');
    if($wrap.length) $wrap.html(renderTableRows(pageItems));
    const $info=$('.pc-pager .pc-pager-info');
    if($info.length) $info.text(`Strona ${S.list.page} / ${maxPages}`);
    bindRowActions();
  }

  function renderTableRows(items){
    if(!items.length) return `<div class="pc-trow"><div class="pc-muted" style="grid-column:1/-1">Nic tu jeszcze nie ma.</div></div>`;
    return items.map(p=>{
      const ownerTxt = p.owner ? `<span class="pc-owner-id">${p.owner.identifier}</span>` : "";
      return `
        <div class="pc-trow">
          <div><span class="pc-badge pc-toast-success">${p.type}</span></div>
			<div><b class="pc-ellipsis">${p.name}</b></div>
			<div class="pc-ellipsis">${p.address}</div>
			<div class="pc-ellipsis">${ownerTxt}</div>
          <div class="pc-cell-actions">
            ${p.owner?`<button class="pc-btn pc-btn-icon" title="Własność" data-owner="${p.id}"><i class="fa-regular fa-id-badge"></i></button>`:""}
            <button class="pc-btn pc-btn-icon" title="Teleportuj" data-tp="${p.id}"><i class="fa-solid fa-location-crosshairs"></i></button>
            <button class="pc-btn pc-btn-icon" title="Edytuj" data-open="${p.id}"><i class="fa-solid fa-pen"></i></button>
            <button class="pc-btn pc-btn-icon" title="Usuń" data-del="${p.id}"><i class="fa-regular fa-trash-can"></i></button>
          </div>
        </div>`;
    }).join('');
  }
function findPropertyById(id) {
  const sid = String(id);
  return S.created.find(p => String(p.id) === sid) || null;
}

	function bindRowActions(){
	  
	  $pcStage.find('[data-del]').each(function(){
		const $b = $(this);
		$b.off('click').on('click', function(){
		  const id = $b.data('del');
		  const p  = findPropertyById(id);

		  if (!p) {
			return;
		  }


		  RTXHousingUI.showConfirm({
			header: 'Usuń Nieruchomość',
			text: `Czy na pewno chcesz usunąć nieruchomość:\n${p.name || p.id}?`,
			confirm: {
			  label: 'Usuń',
			  icon: 'fa-trash-can'
			},
			cancel: {
			  label: 'Anuluj',
			  icon: 'fa-xmark'
			},
			onConfirm: function () {
			  const sid = String(id);

			  
			  S.created = S.created.filter(x => String(x.id) !== sid);

			  showNotification("Nieruchomość usunięta", "success");

			  
			  $.post(
				'https://' + housingresourcename + '/propertycreatorremove',
				JSON.stringify({
				  propertyid: p.id
				})
			  );

			  
			  renderList();
			},
			onCancel: function () {
			}
		  });
		});
	  });


	  $pcStage.find('[data-open]').each(function(){
		const $b=$(this);
		$b.off('click').on('click', function(){
		  const id = $b.data('open');
		  const p  = findPropertyById(id);
		  if (!p) {
			return;
		  }
		  S.type   = p.type || "MLO";
		  S.editId = p.id;
		  S.cfg    = p.cfg ? JSON.parse(JSON.stringify(p.cfg)) : defaultCfg();
		  S.pick   = null;
		  $.post(
			'https://' + housingresourcename + '/propertycreatorloaddata',
			JSON.stringify({
			  propertyid:   p.id
			})
		  );		  
		  S.view='config'; render();
		});
	  });

	  $pcStage.find('[data-tp]').each(function(){
		const $b=$(this);
		$b.off('click').on('click', function(){
		  const id = $b.data('tp');
		  teleportProperty(id);
		});
	  });

	  $pcStage.find('[data-owner]').each(function(){
		const $b=$(this);
		$b.off('click').on('click', function(){
		  const id = $b.data('owner');
		  openOwnerModal(id);
		});
	  });
	}


function teleportProperty(id){
  const p = findPropertyById(id);
  if (!p) {
    return;
  }
  $.post(
	'https://' + housingresourcename + '/propertycreatortp',
	JSON.stringify({
	  propertyid:   p.id
	})
  );	

  
}


  
	let _ownerTarget = null;
	function openOwnerModal(id){
	  _ownerTarget = findPropertyById(id);
	  if (!_ownerTarget || !_ownerTarget.owner) return;

	  $('#pcOwnerProp').text(_ownerTarget.name);
	  $('#pcOwnerId').text(_ownerTarget.owner.identifier || "—");
	  $('#pcOwnerName').text(_ownerTarget.owner.name || "—");

	  const $m = $('#pcOwnerModal');
	  $m.css('display','grid');

	  $('#pcOwnerClose').off('click').on('click', function(){ $m.css('display','none'); });
	  $('#pcOwnerRemove').off('click').on('click', function(){
		removeOwnership(_ownerTarget.id);
		$m.css('display','none');
	  });
	}

	function removeOwnership(id){
	  const p = findPropertyById(id);
	  if (!p) return;

	  p.owner  = null;
	  p.status = "Na Sprzedaż";
	 showNotification("Własność nieruchomości usunięta.", "success");
	 $.post(
		'https://' + housingresourcename + '/propertycreatorownershipremove',
		JSON.stringify({
		  propertyid:   p.id
		})
	  );		  
	  renderList();
	}

  
	
	function openDoorsModal(){
	  const $m    = $('#pcDoorsModal');
	  const $list = $('#pcDoorsList');

	  const draw = () => {
		const doors = Array.isArray(S.cfg.doors) ? S.cfg.doors : [];

		$list.html(doors.map(function(d, i){
		  const id   = d.id || ('idx_'+i);
		  const type = d.type || (d.doubledoor ? 'double' : 'single') || 'single';

		  return `
			<div class="pc-trow" style="grid-template-columns:1fr auto">
			  <div>
				Drzwi #${i+1}
				<span class="pc-muted">(${type})</span>
			  </div>
			  <button class="pc-btn pc-btn-small" data-door-id="${id}">
				<i class="fa-regular fa-trash-can"></i>
			  </button>
			</div>`;
		}).join(''));

		
		$list.find('[data-door-id]').off('click').on('click', function(){
		  const $btn   = $(this);
		  const doorId = String($btn.data('door-id'));


		  
		  $.post(
			'https://' + housingresourcename + '/doorcreatorDeleteDoor',
			JSON.stringify({
			  doorId: doorId
			})
		  );

		  
		  S.cfg.doors = (Array.isArray(S.cfg.doors) ? S.cfg.doors : []).filter(function(d){
			return String(d.id) !== doorId;
		  });

		  draw();
		});
	  };

	  $('#pcDoorsAdd').off('click').on('click', function(){
			$.post('https://'+housingresourcename+'/doorcreator', JSON.stringify({}));
	  });


	  $('#pcDoorsClose').off('click').on('click', function(){
		$m.css('display','none');
	  });

	  draw();
	  $m.css('display','grid');
	}


  
  function openStorage(){
    const $m=$('#pcStorageModal');
    const $slots=$('#pcStorageSlots');
    const $weight=$('#pcStorageWeight');
    const $save=$('#pcStorageSave');
    const $close=$('#pcStorageClose');
    $slots.val(S.cfg.storage.slots);
    $weight.val(S.cfg.storage.weight);
    $save.off('click').on('click', function(){
      S.cfg.storage.slots=+($slots.val()||0);
      S.cfg.storage.weight=+($weight.val()||0);
      $m.css('display','none');
    });
    $close.off('click').on('click', function(){
      $m.css('display','none');
    });
    $m.css('display','grid');
  }
  
  

 function renderImagesList() {
  const list    = Images.list();
  const $list   = $('#pcImagesList');
  const $badge  = $('#pcImagesBadge');   
  const $count  = $('#pcImagesCount');   

  if ($list.length) {
    $list.empty();

    if (!list.length) {
      $list
        .removeClass('pc-images-grid')
        .html(`
          <div class="pc-muted" style="font-size:.8rem;">
            Brak obrazów. Dodaj jeden przez URL lub zrób zrzut ekranu.
          </div>
        `);
    } else {
      $list
        .addClass('pc-images-grid')
        .html(
          list.map((url, idx) => `
            <div class="pc-image-card">
              <div class="pc-image-thumb">
                <img src="${url}" alt="Obraz nieruchomości ${idx + 1}">
              </div>
              <div class="pc-image-meta">
                <span class="pc-muted pc-ellipsis" title="${url}">
                  ${url}
                </span>
                <button class="pc-btn pc-btn-small" data-img-remove="${idx}">
                  <i class="fa-regular fa-trash-can"></i>
                </button>
              </div>
            </div>
          `).join('')
        );
    }
  }

  const label = `${list.length} obraz${list.length === 1 ? '' : list.length < 5 ? 'y' : 'ów'}`;

  if ($count.length) {
    $count.text(label);
  }
  if ($badge.length) {
    
    $badge.find('span').last().text(label);
  }
}


  function openImagesModal() {
    renderImagesList();
    $('#pcImagesModal').css('display', 'grid');
  }

  function closeImagesModal() {
    $('#pcImagesModal').css('display', 'none');
  }

  
  $(document).on('click', '#pcImagesOpen', function () {
    openImagesModal();
  });

  $(document).on('click', '#pcImagesClose', function () {
    closeImagesModal();
  });

  $(document).on('click', '#pcImagesAddUrl', function () {
    const $input = $('#pcImagesUrl');
    const url = ($input.val() || '').trim();
    if (!url) return;

    Images.add(url);
    $input.val('');
    renderImagesList();

    
    if (S.view === 'config') {
      renderConfig();
    }
  });

  $(document).on('click', '#pcImagesClear', function () {
    Images.clear();
    renderImagesList();
    if (S.view === 'config') {
      renderConfig();
    }
  });

  $(document).on('click', '[data-img-remove]', function () {
    const idx = Number($(this).data('img-remove'));
    Images.remove(idx);
    renderImagesList();
    if (S.view === 'config') {
      renderConfig();
    }
  });

  
  $(document).on('click', '#pcImagesScreenshot', function () {
    $.post(
      'https://' + housingresourcename + '/propertycreatorTakeScreenshot',
      JSON.stringify({
          typehousing: S.type,
		  shellpreset: S.cfg.shellId,
		  iplpreset: S.cfg.iplId,
		  ipltheme: S.cfg.iplTheme,
      })
    );
  });
  
  

  
  $('#pcBtnList').on('click', function(){
    S.view='list'; render();
  });
  $('#pcBtnClose').on('click', function(){
    S.view='home';
	$('.propertycreator-container').hide();
	 $.post('https://'+housingresourcename+'/closepropertycreator', JSON.stringify({}));
  });
  
  
  
window.addEventListener("message", function (event) {
  const item = event.data;
	if (item.message == "hidepropertycreator") {
		$('.propertycreator-container').hide();
	}	
	if (item.message == "propertycreator") {
		$("#gizmoshow").hide();
		$('.propertycreator-container').show();
	}		
  if (item.message == "propertycreatorshow") {
    $('.propertycreator-container').show(); 
    render();
  }
  
  if (item.message == "propertycreator:setStorageData") {
    S.cfg.storage.slots = item.storageslots;
	S.cfg.storage.weight = item.storageweight;
    defaultslots = item.storageslots;
	defaultweight = item.storageweight;	
  }  
  
  if (item.message === "propertycreator:setShells") {
    if (Array.isArray(item.shells)) {

		S.shells = item.shells.map(function (s) {
		  var imgs = Array.isArray(s.images)
			? s.images.map(function (img) {
				if (img && typeof img === 'object' && img.url) return img.url;
				return img;
			  })
			: [];

		  var tags = Array.isArray(s.tags) ? s.tags.slice() : [];

		  return {
			id: String(s.id || s.object || s.name || ''),   
			name: s.name || s.label || s.id || 'Shell',
			images: imgs,
			tags: tags
		  };
		});

      S.shells.sort(function(a, b) {
        return a.name.localeCompare(b.name);
      });

    }
  }
  if (item.message === "propertycreator:setIpls") {
    if (Array.isArray(item.ipls)) {

      S.ipls = item.ipls.map(function (it) {
        
        var imgs = Array.isArray(it.images)
          ? it.images.map(function (img) {
              if (img && typeof img === 'object' && img.url) return img.url;
              return img;
            })
          : [];

        
        var themes = Array.isArray(it.themes)
          ? it.themes.map(function (t) {
              if (t && typeof t === 'object') {
                var tid = String(t.id || t.value || '');
                return {
                  id: tid,
                  label: t.label || tid
                };
              } else {
                var tid = String(t);
                return { id: tid, label: tid };
              }
            })
          : [];

		var tags = Array.isArray(it.tags) ? it.tags.slice() : [];

		return {
		  id: String(it.id || it.name || ''),               
		  name: it.name || it.label || it.id || 'IPL',      
		  images: imgs,
		  themes: themes,
		  tags: tags
		};

      });
      S.ipls.sort(function(a, b) {
        return a.name.localeCompare(b.name);
      });


    }
  }


  if (item.message === "propertycreator:updateCoord") {
    const fieldKey  = item.fieldKey;   
    const fieldId   = item.fieldId;    
    const labelText = item.label || "(coords from game)";

    
    if (fieldKey) {
      setCoordField(fieldKey, labelText); 
    }

    
    if (fieldId) {
      const $input = $('#'+fieldId);
      if ($input.length) {
        $input
          .val(labelText)
          .attr('placeholder', labelText)
          .removeClass('pc-is-empty');
      }
    }
	$('.propertycreator-container').show();
  }
	if (item.message == "gizmoshow") {
		openMain();
		$("#gizmoshow").show();
	}	  
  if (item.message === "setDoors") {
    if (Array.isArray(item.doors)) {
      S.cfg.doors = item.doors.map(function(d){
        return {
          id: String(d.id || ''),                       
          type: d.type || (d.doubledoor ? 'double' : 'single'),
          doubledoor: !!d.doubledoor,
          door1: d.door1 || null,
          door2: d.door2 || null,
        };
      });
	openDoorsModal();
    }
  }
  if (item.message === "setDoorsManual") {
    if (Array.isArray(item.doors)) {
      S.cfg.doors = item.doors.map(function(d){
        return {
          id: String(d.id || ''),                       
          type: d.type || (d.doubledoor ? 'double' : 'single'),
          doubledoor: !!d.doubledoor,
          door1: d.door1 || null,
          door2: d.door2 || null,
        };
      });
    }
  }  
  
 if (item.message === "setPropertyImages") {
    if (Array.isArray(item.images)) {
        S.cfg.images = item.images.slice();
        Images.set(S.cfg.images);
    }
}
 
	if (item.message == "resetlist") {
		S.created   = [];
		S.complexes = [];
	}	  
  if (item.message === 'rtx:propertyCreator:addFromClient') {
    const rec = item.record;
    if (!rec) return;

    
    if (!rec.address && rec.cfg && rec.cfg.address) {
      rec.address = rec.cfg.address;
    }

    S.created.push(rec);
	

    
    if (rec.type === 'APARTMENT') {
      S.complexes.push({
        id: rec.id,
        label: rec.name || ('Mieszkanie ' + rec.id)
      });
    }

  }  
  if (item.message === "propertycreator:imageScreenshotReady") {
    
    const url = item.url || item.image;
    if (!url) {
      return;
    }

    
    Images.add(url);

    
    if ($("#pcImagesModal").is(":visible")) {
      renderImagesList();
    }

  }

  
});

});
