export function hslToHex (hsl: string): string {
  const match = hsl.match(/^(\d+)\s+(\d+)%\s+(\d+)%$/);
  if (!match) throw new Error("Invalid HSL format");
  let [_, hStr, sStr, lStr] = match;
  let h = parseInt(hStr), s = parseInt(sStr) / 100, l = parseInt(lStr) / 100;
  let c = (1 - Math.abs(2 * l - 1)) * s;
  let x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  let m = l - c / 2;
  let r = 0, g = 0, b = 0;
  if (h < 60) [r, g, b] = [c, x, 0];
  else if (h < 120) [r, g, b] = [x, c, 0];
  else if (h < 180) [r, g, b] = [0, c, x];
  else if (h < 240) [r, g, b] = [0, x, c];
  else if (h < 300) [r, g, b] = [x, 0, c];
  else [r, g, b] = [c, 0, x];
  const toHex = (v: number) => Math.round((v + m) * 255).toString(16).padStart(2, "0");
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

export function hexToHsl(hex: string): string {
  let r = parseInt(hex.slice(1, 3), 16) / 255;
  let g = parseInt(hex.slice(3, 5), 16) / 255;
  let b = parseInt(hex.slice(5, 7), 16) / 255;
  let max = Math.max(r, g, b), min = Math.min(r, g, b);
  let h = 0, s = 0, l = (max + min) / 2;
  let d = max - min;
  if (d !== 0) {
    s = d / (1 - Math.abs(2 * l - 1));
    switch (max) {
      case r: h = ((g - b) / d + (g < b ? 6 : 0)) * 60; break;
      case g: h = ((b - r) / d + 2) * 60; break;
      case b: h = ((r - g) / d + 4) * 60; break;
    }
  }
  return `${Math.round(h)} ${Math.round(s * 100)}% ${Math.round(l * 100)}%`;
}

export function isValidHsl (hsl: string): boolean {
  const match = hsl.match(/^(\d+)\s+(\d+)%\s+(\d+)%$/);
  if (!match) return false;
  let [_, hStr, sStr, lStr] = match;
  let h = parseInt(hStr), s = parseInt(sStr), l = parseInt(lStr);
  return h >= 0 && h <= 360 && s >= 0 && s <= 100 && l >= 0 && l <= 100;
}

export function parseHSL(hslString: string): { h: number; s: number; l: number } {
  const regex = /^(\d+)\s+(\d+)%\s+(\d+)%$/;
  const match = hslString.match(regex);

  if (!match) {
    throw new Error("Invalid HSL format. Expected format: 'h s% l%'");
  }

  const [, h, s, l] = match;

  return {
    h: parseInt(h, 10),
    s: parseInt(s, 10),
    l: parseInt(l, 10),
  };
}