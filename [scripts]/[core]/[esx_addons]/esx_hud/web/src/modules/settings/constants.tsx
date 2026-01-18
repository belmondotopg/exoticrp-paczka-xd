import z from "zod";

import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";

import { booleanStringSchema, hslStringSchema, numberStringSchema } from "./schemas";
import type { Setting } from "./types/settings";
import { SliderWithDisplayedValue } from "./ui/components/slider-with-displayed-value";
import { ColorInput } from "./ui/components/color-input";
import { hexToHsl, hslToHex, parseHSL } from "./lib/utils";

export const CATEGORIES = {
    "notifications": "Powiadomienia",
    "appearance": "Wygląd",
    "personalization": "Personalizacja",
    "crosshair": "Celownik",
    "hud-personalization": "Personalizacja HUDu",
}

export const SETTINGS: Setting[] = [
    // Notifications
    {
        name: "show-chat",
        category: "notifications",
        label: "Pokazuj Chat",
        defaultValue: true,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },
    {
        name: "show-events-notifications",
        category: "notifications",
        label: "Pokazuj powiadomienia o eventach",
        defaultValue: true,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },
    {
        name: "show-general-notifications",
        category: "notifications",
        label: "Pokazuj ogólne powiadomienia",
        defaultValue: true,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },

    // Appearance
    {
        name: "primary-color",
        category: "appearance",
        label: "Kolor Główny",
        defaultValue: "32 100% 50%",
        schema: hslStringSchema,
        component: ({ value, setValue }) => (
            <ColorInput
                value={hslToHex(value as string)}
                onValueChange={(hex) => setValue(hexToHsl(hex))}
            />
        ),
        onValueChange: (value) => {
            document.body.style.setProperty("--primary-hsl", value.toString());
            document.body.style.setProperty("--primary", `hsl(${value})`);
            document.body.style.setProperty("--color-primary", `hsl(${value})`);

            const { h, s, l } = parseHSL(value.toString());
            const darkerColor = `hsl(${h} ${s}% ${Math.max(0, l - 10)}%)`;

            document.body.style.setProperty("--primary-darker", darkerColor);
            document.body.style.setProperty("--color-primary-darker", darkerColor);
        }
    },
    {
        name: "show-watermark",
        category: "appearance",
        label: "Pokazuj znak wodny",
        defaultValue: true,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },
    {
        name: "show-bodycam",
        category: "appearance",
        label: "Pokazuj BodyCam",
        defaultValue: true,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },
    {
        name: "show-hud",
        category: "appearance",
        label: "Pokazuj HUD",
        defaultValue: true,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },
    // {
    //     name: "show-info-in-veh",
    //     category: "appearance",
    //     label: "Pokazuj informacje w pojeździe <span class='text-red-400'>TODO</span>",
    //     defaultValue: true,
    //     schema: booleanStringSchema,
    //     component: ({ value, setValue }) => (
    //         <Switch checked={value as boolean} onCheckedChange={setValue} />
    //     ),
    // },
    {
        name: "radio-appearance",
        category: "appearance",
        label: "Wygląd Radia <span class='text-red-400'>TODO</span>",
        defaultValue: "1",
        schema: z.enum(["1", "2"]),
        component: ({ value, setValue }) => (
            <Select
                value={value as string}
                onValueChange={setValue}
                defaultValue={value as string}
            >
                <SelectTrigger className="w-16">
                    <SelectValue />
                </SelectTrigger>
                <SelectContent className="min-w-16 w-16">
                    <SelectItem value="1">1</SelectItem>
                    <SelectItem value="2">2</SelectItem>
                </SelectContent>
            </Select>
        ),
    },
    {
        name: "hud-appearance",
        category: "appearance",
        label: "Wygląd HUDu <span class='text-red-400'>TODO</span>",
        defaultValue: "new",
        schema: z.enum(["new", "old"]),
        component: ({ value, setValue }) => (
            <Select
                value={value as string}
                onValueChange={setValue}
                defaultValue={value as string}
            >
                <SelectTrigger className="w-24">
                    <SelectValue />
                </SelectTrigger>
                <SelectContent className="min-w-24 w-24">
                    <SelectItem value="new">Nowy</SelectItem>
                    <SelectItem value="old">Stary</SelectItem>
                </SelectContent>
            </Select>
        ),
    },
    {
        name: "carhud-appearance",
        category: "appearance",
        label: "Wygląd Carhudu",
        defaultValue: "digital",
        schema: z.enum(["digital", "analog", "hide"]),
        component: ({ value, setValue }) => (
            <Select
                value={value as string}
                onValueChange={setValue}
                defaultValue={value as string}
            >
                <SelectTrigger className="w-32">
                    <SelectValue />
                </SelectTrigger>
                <SelectContent className="min-w-32 w-32">
                    <SelectItem value="digital">Cyfrowy</SelectItem>
                    <SelectItem value="analog">Analogowy</SelectItem>
                    <SelectItem value="hide">Ukryj</SelectItem>
                </SelectContent>
            </Select>
        ),
    },

    // Personalization
    {
        name: "radio-volume",
        category: "personalization",
        label: "Głośność Radia",
        defaultValue: 75,
        schema: numberStringSchema,
        component: ({ value, setValue }) => (
            <SliderWithDisplayedValue
                value={[value as number]}
                onValueChange={([value]) => setValue(value)}
                min={0}
                max={100}
                formatValue={(value) => `${value}%`}
                containerClassName="w-52"
            />
        )
    },
    {
        name: "play-radio-sound-effect",
        category: "personalization",
        label: "Słyszalny Efekt Dźwiękowy Radia",
        defaultValue: true,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },
    {
        name: "interface-refresh-frequency",
        category: "personalization",
        label: "Częstotliwość Odświeżania Interfejsu",
        defaultValue: "1",
        schema: z.enum(["1", "2", "3"]),
        component: ({ value, setValue }) => (
            <Select
                value={value as string}
                onValueChange={setValue}
                defaultValue={value as string}
            >
                <SelectTrigger className="w-16">
                    <SelectValue />
                </SelectTrigger>
                <SelectContent className="min-w-16 w-16">
                    <SelectItem value="1">1</SelectItem>
                    <SelectItem value="2">2</SelectItem>
                    <SelectItem value="3">3</SelectItem>
                </SelectContent>
            </Select>
        ),
    },

    // Hud Personalization
    {
        name: "health-color",
        category: "hud-personalization",
        label: "Zdrowie",
        defaultValue: "357 96% 58%",
        schema: hslStringSchema,
        component: ({ value, setValue }) => (
            <ColorInput
                value={hslToHex(value as string)}
                onValueChange={(hex) => setValue(hexToHsl(hex))}
            />
        )
    },
    {
        name: "armour-color",
        category: "hud-personalization",
        label: "Pancerz",
        defaultValue: "273 100% 64%", // 199 100% 48%
        schema: hslStringSchema,
        component: ({ value, setValue }) => (
            <ColorInput
                value={hslToHex(value as string)}
                onValueChange={(hex) => setValue(hexToHsl(hex))}
            />
        )
    },
    {
        name: "hunger-color",
        category: "hud-personalization",
        label: "Głód",
        defaultValue: "25 100% 50%",
        schema: hslStringSchema,
        component: ({ value, setValue }) => (
            <ColorInput
                value={hslToHex(value as string)}
                onValueChange={(hex) => setValue(hexToHsl(hex))}
            />
        )
    },
    {
        name: "thirst-color",
        category: "hud-personalization",
        label: "Pragnienie",
        defaultValue: "199 100% 48%",
        schema: hslStringSchema,
        component: ({ value, setValue }) => (
            <ColorInput
                value={hslToHex(value as string)}
                onValueChange={(hex) => setValue(hexToHsl(hex))}
            />
        )
    },
    {
        name: "oxygen-color",
        category: "hud-personalization",
        label: "Tlen",
        defaultValue: "190 100% 43%",
        schema: hslStringSchema,
        component: ({ value, setValue }) => (
            <ColorInput
                value={hslToHex(value as string)}
                onValueChange={(hex) => setValue(hexToHsl(hex))}
            />
        )
    },

    // Crosshair
    {
        name: "crosshair-lenght",
        category: "crosshair",
        label: "Wielkość",
        defaultValue: 10,
        schema: numberStringSchema,
        component: ({ value, setValue }) => (
            <SliderWithDisplayedValue
                value={[value as number]}
                onValueChange={([value]) => setValue(value)}
                min={5}
                max={20}
                containerClassName="w-52"
            />
        )
    },
    {
        name: "crosshair-thickness",
        category: "crosshair",
        label: "Grubość",
        defaultValue: 2,
        schema: numberStringSchema,
        component: ({ value, setValue }) => (
            <SliderWithDisplayedValue
                value={[value as number]}
                onValueChange={([value]) => setValue(value)}
                min={2}
                max={10}
                containerClassName="w-52"
            />
        )
    },
    {
        name: "crosshair-gap",
        category: "crosshair",
        label: "Odstęp między liniami",
        defaultValue: 4,
        schema: numberStringSchema,
        component: ({ value, setValue }) => (
            <SliderWithDisplayedValue
                value={[value as number]}
                onValueChange={([value]) => setValue(value)}
                min={0}
                max={10}
                containerClassName="w-52"
            />
        )
    },
    {
        name: "crosshair-opacity",
        category: "crosshair",
        label: "Widoczność",
        defaultValue: 1,
        schema: numberStringSchema,
        component: ({ value, setValue }) => (
            <SliderWithDisplayedValue
                value={[(value as number) * 100]}
                onValueChange={([value]) => setValue(value / 100)}
                min={50}
                max={100}
                formatValue={(value) => `${value}%`}
                containerClassName="w-52"
            />
        )
    },
    {
        name: "crosshair-color",
        category: "crosshair",
        label: "Kolor celownika",
        defaultValue: "#ff0000",
        schema: z.string(),
        component: ({ value, setValue }) => (
            <ColorInput
                value={value as string}
                onValueChange={setValue}
            />
        )
    },
    {
        name: "crosshair-dot-on-center",
        category: "crosshair",
        label: "Kropka na Środku",
        defaultValue: false,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },
    {
        name: "crosshair-gta5",
        category: "crosshair",
        label: "Celownik z GTA V",
        defaultValue: true,
        schema: booleanStringSchema,
        component: ({ value, setValue }) => (
            <Switch checked={value as boolean} onCheckedChange={setValue} />
        ),
    },
];