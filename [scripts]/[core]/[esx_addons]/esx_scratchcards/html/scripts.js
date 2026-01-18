(function() {
	'use strict';

	const CONFIG = {
		canvas: {
			width: 465,
			height: 100
		},
		scratchThreshold: 0.9,
		lineWidth: 20,
		imagePath: 'img/',
		imageExtension: '.png'
	};

	const LOSE_TEXTS = [
		"MEOW?",
		"1 RUBEL",
		"SZARAŁT BYKU",
		"BĘDZIE DOBRZE..",
		"ZDRAPKARZ HAZARDZISTA",
		"0$",
		"TALON NA BALON",
		"SIADŁO?",
		"DAWAJ NEXT?",
		"NASTĘPNA ODDA",
		"DAJ SPOKUJ",
		"BARAŃSKIE POWITANIE!",
		"V ALE SIWADŁO K?",
		"FAJNE TO!",
		"10000$ Z MONOPOLY"
	];

	let isScratched = false;
	let mouseDown = false;
	let canvas = null;
	let ctx = null;
	let eventHandlers = [];

	const elements = {
		html: null,
		layout: null,
		compDiv: null,
		image: null,
		component: null,
		canvas: null
	};

	function initialize() {
		elements.html = document.querySelector('html');
		elements.layout = document.querySelector('.layout');
		elements.compDiv = document.querySelector('.compDiv');
		elements.image = document.getElementById('toChange');
		elements.component = document.getElementById('component');
		elements.canvas = document.getElementById('j-cvs');

		if (!elements.canvas) {
			console.error('Canvas element not found!');
			return false;
		}

		canvas = elements.canvas;
		ctx = canvas.getContext('2d');
		setupCanvas();
		setupEventListeners();

		return true;
	}

	function setupCanvas() {
		canvas.width = CONFIG.canvas.width;
		canvas.height = CONFIG.canvas.height;
		ctx.fillStyle = '#CCC';
		ctx.fillRect(0, 0, canvas.width, canvas.height);
	}

	function getLocalCoords(element, event) {
		let offsetX = 0;
		let offsetY = 0;
		let currentElement = element;

		while (currentElement) {
			offsetX += currentElement.offsetLeft;
			offsetY += currentElement.offsetTop;
			currentElement = currentElement.offsetParent;
		}

		let pageX, pageY;
		if (event.changedTouches) {
			pageX = event.changedTouches[0].pageX;
			pageY = event.changedTouches[0].pageY;
		} else {
			pageX = event.pageX;
			pageY = event.pageY;
		}

		return {
			x: pageX - offsetX,
			y: pageY - offsetY
		};
	}

	function checkScratchProgress(threshold, callback) {
		if (!('getImageData' in ctx)) return;

		threshold = Math.max(0, Math.min(1, threshold || 0.5));
		const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
		const pixels = imageData.data;
		const totalPixels = pixels.length * 0.25;
		let transparentPixels = 0;

		for (let i = 1; i <= totalPixels; i++) {
			if (pixels[4 * i - 1] === 0) {
				transparentPixels++;
			}
		}

		if (transparentPixels > totalPixels * threshold) {
			if (typeof callback === 'function') {
				callback.call(ctx, transparentPixels);
			}
		}
	}

	function drawScratchLine(x, y, isNewPath) {
		ctx.globalCompositeOperation = 'destination-out';
		ctx.lineWidth = CONFIG.lineWidth;
		ctx.lineCap = 'round';
		ctx.lineJoin = 'round';
		ctx.strokeStyle = 'rgba(0,0,0,1)';

		if (isNewPath) {
			ctx.beginPath();
			ctx.moveTo(x + 0.1, y);
		}
		ctx.lineTo(x, y);
		ctx.stroke();

		checkScratchProgress(CONFIG.scratchThreshold, function() {
			if (!isScratched) {
				isScratched = true;
				setTimeout(function() {
					closeNUI();
				}, 300);
			}
		});
	}

	function handleMouseDown(event) {
		const coords = getLocalCoords(canvas, event);
		mouseDown = true;
		drawScratchLine(coords.x, coords.y, true);
		if (event.cancelable) {
			event.preventDefault();
		}
		return false;
	}

	function handleMouseMove(event) {
		if (!mouseDown) return true;
		const coords = getLocalCoords(canvas, event);
		drawScratchLine(coords.x, coords.y, false);
		if (event.cancelable) {
			event.preventDefault();
		}
		return false;
	}

	function handleMouseUp(event) {
		if (mouseDown) {
			mouseDown = false;
			if (event.cancelable) {
				event.preventDefault();
			}
			return false;
		}
		return true;
	}

	function setupCanvasEventListeners() {
		const handlers = [
			{ element: canvas, event: 'mousedown', handler: handleMouseDown },
			{ element: canvas, event: 'touchstart', handler: handleMouseDown },
			{ element: window, event: 'mousemove', handler: handleMouseMove },
			{ element: window, event: 'touchmove', handler: handleMouseMove },
			{ element: window, event: 'mouseup', handler: handleMouseUp },
			{ element: window, event: 'touchend', handler: handleMouseUp }
		];

		handlers.forEach(({ element, event, handler }) => {
			element.addEventListener(event, handler, false);
			eventHandlers.push({ element, event, handler });
		});
	}

	function removeEventListeners() {
		eventHandlers.forEach(({ element, event, handler }) => {
			element.removeEventListener(event, handler, false);
		});
		eventHandlers = [];
	}

	function setupEventListeners() {
		setupCanvasEventListeners();
		window.addEventListener('message', handleMessage);
		document.addEventListener('keyup', handleKeyUp);
	}

	function handleMessage(event) {
		if (!event || !event.data || event.data.type !== 'showNUI') {
			return;
		}

		const data = event.data;

		if (!data.scratch || typeof data.scratch !== 'string') {
			console.error('Invalid scratch type received');
			return;
		}

		const amount = parseInt(data.component, 10);
		if (isNaN(amount)) {
			console.error('Invalid amount received');
			return;
		}

		isScratched = false;
		mouseDown = false;

		if (elements.html) {
			elements.html.style.display = 'block';
		}
		if (elements.layout) {
			elements.layout.style.display = 'block';
		}
		if (elements.compDiv) {
			elements.compDiv.style.display = 'block';
		}

		const imagePath = CONFIG.imagePath + data.scratch + CONFIG.imageExtension;
		if (elements.image) {
			elements.image.src = imagePath;
			elements.image.onerror = function() {
				console.error('Failed to load image: ' + imagePath);
			};
		}

		if (elements.component) {
			elements.component.style.fontFamily = 'Arial';
			if (amount === 0) {
				const randomText = LOSE_TEXTS[Math.floor(Math.random() * LOSE_TEXTS.length)];
				elements.component.textContent = randomText;
			} else if (amount > 0) {
				elements.component.textContent = amount + ' $';
			}
		}

		setupCanvas();
	}

	function handleKeyUp(event) {
		const key = event.which || event.keyCode;
		if ((key === 8 || key === 27) && isScratched) {
			closeNUI();
		}
	}

	function closeNUI() {
		isScratched = false;
		mouseDown = false;

		if (elements.layout) {
			elements.layout.style.display = 'none';
		}
		if (elements.compDiv) {
			elements.compDiv.style.display = 'none';
		}
		if (elements.html) {
			elements.html.style.display = 'none';
		}
		if (document.body) {
			document.body.classList.remove('active');
		}

		if (typeof $ !== 'undefined' && $.post) {
			$.post('https://esx_scratchcards/NUIFocusOff', JSON.stringify({}));
		} else {
			const xhr = new XMLHttpRequest();
			xhr.open('POST', 'https://esx_scratchcards/NUIFocusOff', true);
			xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
			xhr.send(JSON.stringify({}));
		}
	}

	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', initialize);
	} else {
		initialize();
	}
})();
