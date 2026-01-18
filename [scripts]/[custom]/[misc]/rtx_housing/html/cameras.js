const CamState = {
	visible: false,
	camName: "CAM 01",
	location: "North Wing",
	mode: "REC",

	time: "",
	externalTime: false

};

const DoorState = {
	visible: false,
	doorName: "Front Door",
	location: "Apartment 3A",
	time: "",
	externalTime: false

};

function renderCameraInfo() {
	$("#cam-name-bottom").text(CamState.camName || "");
	$("#cam-location-bottom").text(CamState.location || "");

	const ghostParts = [];
	if (CamState.camName) ghostParts.push(CamState.camName);
	if (CamState.location) ghostParts.push(CamState.location);

	const modeEl = $("#cam-chip-mode");
	const modeText = $("#cam-mode-text");

	modeEl.removeClass("mode-rec mode-live mode-off");

	if (CamState.mode === "OFFLINE") {
		modeEl.addClass("mode-off");
		modeText.text("OFF");
	} else if (CamState.mode === "LIVE") {
		modeEl.addClass("mode-live");
		modeText.text("LIVE");
	} else {
		modeEl.addClass("mode-rec");
		modeText.text("REC");
	}
}

function renderCamTime() {
	$("#cam-time").text(CamState.time || "00:00:00");
}

function setCamTimeFromMessage(time) {
	if (time) CamState.time = time;
	CamState.externalTime = true;
	renderCamTime();
}

function renderDoorInfo() {
	$("#door-location").text(DoorState.location || "");
}

function renderDoorTime() {
	$("#door-time").text(DoorState.time || "00:00:00");
}

function setDoorTimeFromReal() {
	const now = new Date();
	const pad = n => String(n).padStart(2, "0");
	DoorState.time = `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
	renderDoorTime();
}

function setDoorTimeFromMessage(time) {
	if (time) DoorState.time = time;
	DoorState.externalTime = true;
	renderDoorTime();
}

function showOverlayCamera(opts) {
	$("#cam-root").show();
	opts = opts || {};
	CamState.visible = true;
	DoorState.visible = false;
	$("#door-root").removeClass("visible");

	if (opts.camName) CamState.camName = opts.camName;
	if (opts.location) CamState.location = opts.location;
	CamState.mode = "LIVE";
	renderCameraInfo();
	$("#cam-root").addClass("visible");
}

function hideOverlayCamera() {
	$("#cam-root").hide();
	CamState.visible = false;
	$("#cam-root").removeClass("visible");
}

function closeMain() {
	$("body").css("display", "none");
}

function openMain() {
	$("body").css("display", "block");
}

function showDoorCam(opts) {
	$("#door-root").show();
	opts = opts || {};
	DoorState.visible = true;
	CamState.visible = false;
	$("#cam-root").removeClass("visible");

	if (opts.location) DoorState.location = opts.location;

	setDoorTimeFromMessage(opts.time);

	renderDoorInfo();
	$("#door-root").addClass("visible");
}

function hideDoorCam() {
	$("#door-root").hide();
	DoorState.visible = false;
	$("#door-root").removeClass("visible");
}

function updateDoorCam(opts) {
	opts = opts || {};

	if (typeof opts.location !== "undefined") DoorState.location = opts.location;

	setDoorTimeFromMessage(opts.time);

	if (DoorState.visible) {
		renderDoorInfo();
		renderDoorTime();
	}
}

window.addEventListener("message", function(event) {
	const item = event.data || {};

	if (item.message === "camera:show") {
		showOverlayCamera(item);
	}

	if (item.message === "camera:hide") {
		hideOverlayCamera();
	}

	if (item.message === "camera:update") {
		updateOverlayCamera(item);
	}

	if (item.message === "camera:time") {
		setCamTimeFromMessage(item.time);
	}

	if (item.message === "doorcam:show") {
		showDoorCam(item);
	}

	if (item.message === "doorcam:hide") {
		hideDoorCam();
	}

	if (item.message === "doorcam:update") {
		updateDoorCam(item);
	}

	if (item.message === "doorcam:time") {
		setDoorTimeFromMessage(item.time);
	}
});