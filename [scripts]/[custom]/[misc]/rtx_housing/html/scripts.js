function closeMain() {
   $("body").css("display", "none");
}

function openMain() {
   $("body").css("display", "block");
}

createjs.Sound.registerPlugins([createjs.WebAudioPlugin, createjs.HTMLAudioPlugin]);
createjs.Sound.alternateExtensions = ["mp3", "wav", "ogg"];

const registered = new Set();

let currentSoundInstance = null;

function playSound(src, volume = 1, channels = 6) {
   const id = src;

   if (!registered.has(id)) {
      registered.add(id);
      createjs.Sound.registerSound({
         src,
         id,
         data: channels
      });
   }

   if (createjs.Sound.loadComplete(id)) {
      return createjs.Sound.play(id, {
         interrupt: createjs.Sound.INTERRUPT_ANY,
         volume
      });
   }

   const onLoad = function (e) {
      if (e.id !== id) return;
      createjs.Sound.off("fileload", onLoad);
      createjs.Sound.play(id, {
         interrupt: createjs.Sound.INTERRUPT_ANY,
         volume
      });
   };
   createjs.Sound.on("fileload", onLoad);

   return null;
}

function playSoundOnly(src, volume = 1, channels = 6) {
   const id = src;


   if (currentSoundInstance) {
      currentSoundInstance.stop();
      currentSoundInstance = null;
   }


   if (!registered.has(id)) {
      registered.add(id);
      createjs.Sound.registerSound({
         src,
         id,
         data: channels
      });
   }


   if (createjs.Sound.loadComplete(id)) {
      currentSoundInstance = createjs.Sound.play(id, {
         interrupt: createjs.Sound.INTERRUPT_ANY,
         volume
      });
      return currentSoundInstance;
   }


   const onLoad = function (e) {
      if (e.id !== id) return;

      createjs.Sound.off("fileload", onLoad);


      if (currentSoundInstance) {
         currentSoundInstance.stop();
      }

      currentSoundInstance = createjs.Sound.play(id, {
         interrupt: createjs.Sound.INTERRUPT_ANY,
         volume
      });
   };

   createjs.Sound.on("fileload", onLoad);
   return null;
}

function processScreenshot(imageDataUri, filename, imgType) {
   const img = new Image();

   img.onload = () => {
      const canvas = document.getElementById("canvas");
      const ctx = canvas.getContext("2d");

      const originalWidth = img.width;
      const originalHeight = img.height;

      const cropX = originalWidth / 4.5;
      const cropWidth = originalHeight;
      const cropHeight = originalHeight;

      canvas.width = cropWidth;
      canvas.height = cropHeight;

      ctx.drawImage(
         img,
         cropX, 0,
         cropWidth, cropHeight,
         0, 0,
         cropWidth, cropHeight
      );

      const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);
      const d = imgData.data;

      for (let i = 0; i < d.length; i += 4) {
         const r = d[i];
         const g = d[i + 1];
         const b = d[i + 2];

         if (g > (r + b)) {
            d[i] = 255;
            d[i + 1] = 255;
            d[i + 2] = 255;
            d[i + 3] = 0;
         }
      }

      ctx.putImageData(imgData, 0, 0);

      const resultDataUri = canvas.toDataURL("image/webp");
      fetch(`https://${GetParentResourceName()}/screenshotProcessed`, {
         method: 'POST',
         headers: {
            'Content-Type': 'application/json; charset=utf-8'
         },
         body: JSON.stringify({
            filename,
            imgType,
            image: resultDataUri
         })
      });
   };

   img.src = imageDataUri;
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

window.addEventListener("message", function (event) {
   const item = event.data;
   if (item.message == "infonotifyshow") {
      document.getElementsByClassName("infonotifytext")[0].innerHTML = item.infonotifytext;
      openMain();
      $("#infonotifyshow").show();
   }

   if (item.message == "hidenotify") {
      $("#infonotifyshow").hide();
   }

   if (item.message == "playsound") {
      playSound(item.soundsrc, item.soundvolume);
   }

   if (item.message == "playsoundonly") {
      playSoundOnly(item.soundsrc, item.soundvolume);
   }

   if (item.message === "screenshot") {


      processScreenshot(item.image, item.filename, item.imgType);
   }
   
	if (item.message === "updateinterfacedata") {
		let theme = item.interfacecolordata;

		try {
			const storedTheme = localStorage.getItem("housing_theme");
			if (storedTheme) {
				theme = storedTheme;
			}
		} catch (e) {
		}

		setTheme(theme);
	}


});