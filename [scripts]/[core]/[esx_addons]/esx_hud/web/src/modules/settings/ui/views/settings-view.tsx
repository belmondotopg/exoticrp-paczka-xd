import { useMemo, useState } from "react";
import { useVisible } from "@yankes/fivem-react/hooks";

import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import Crosshair from "@/modules/crosshair/views/components/crosshair";

import { CATEGORIES, SETTINGS } from "../../constants";
import { SettingField } from "../components/setting-field";
import { useSettings } from "../../hooks/use-settings";

type Page = "main" | "crosshair" | "hud-personalization";

const CATEGORIES_PER_PAGE: Record<Page, Array<keyof typeof CATEGORIES>> = {
    main: ["notifications", "appearance", "personalization"],
    crosshair: ["crosshair"],
    "hud-personalization": ["hud-personalization"],
}

export const SettingsView = () => {
    const { visible, close } = useVisible("settings", false);
    const { settings, setSettingValue, resetSettings } = useSettings();

    const [page, setPage] = useState<Page>("main");
    const currentCategories = useMemo(() => Object.entries(CATEGORIES).filter(([id]) => CATEGORIES_PER_PAGE[page].includes(id as keyof typeof CATEGORIES)), [page]);

    return (
        <Dialog
            defaultOpen={visible}
            open={visible}
            onOpenChange={(open) => {
                if (!open) {
                    close();
                }
            }}
        >
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>
                        {page === "main" && "Ustawienia Serwerowe"}
                        {page === "crosshair" && "Celownik"}
                        {page === "hud-personalization" && "Personalizacja HUDu"}
                    </DialogTitle>
                    <DialogDescription>
                        {page === "main" && "Zmień swoje preferencje"}
                        {page === "crosshair" && "Zpersonalizuj swój celownik"}
                        {page === "hud-personalization" && "Zmień kolory Twojego HUDu"}
                    </DialogDescription>
                </DialogHeader>
                {page === "crosshair" && (
                    <div className="w-full h-[200px] rounded-2xl border border-neutral-700 bg-cover bg-center flex items-center justify-center" style={{ backgroundImage: "linear-gradient(hsla(0, 0%, 0%, 0.5), hsla(0, 0%, 0%, 0.5)), url(https://c4.wallpaperflare.com/wallpaper/995/831/676/los-santos-los-angeles-naturalvision-evolved-grand-theft-auto-grand-theft-auto-v-hd-wallpaper-preview.jpg)" }}>
                        {settings["crosshair-gta5"] ? (
                            <div
                                className="size-1.5 rounded-full bg-white stroke-2 stroke-neutral-800"
                            />
                        ) : (
                            <Crosshair
                                length={settings["crosshair-lenght"] as number}
                                thickness={settings["crosshair-thickness"] as number}
                                gap={settings["crosshair-gap"] as number}
                                opacity={settings["crosshair-opacity"] as number}
                                color={settings["crosshair-color"] as string}
                                dotOnCenter={settings["crosshair-dot-on-center"] as boolean}
                            />
                        )}
                    </div>
                )}
                <div className="flex flex-col gap-y-7">
                    {currentCategories.map(([id, label]) => (
                        <div
                            key={id}
                            className="flex flex-col gap-y-4"
                        >
                            {currentCategories.length > 1 && (
                                <span className="font-bold text-sm text-muted-foreground uppercase">{label}</span>
                            )}
                            <div className="flex flex-col gap-y-2.5">
                                {SETTINGS.filter(s => s.category === id).map((setting) => (
                                    <SettingField key={setting.name} label={setting.label}>
                                        <setting.component
                                            value={settings[setting.name]}
                                            setValue={(value) => setSettingValue(setting.name, value)}
                                        />
                                    </SettingField>
                                ))}
                            </div>
                        </div>
                    ))}
                </div>
                <DialogFooter className="grid grid-cols-3 gap-2.5 mt-2">
                    {page !== "main" && (
                        <Button
                            variant="secondary"
                            onClick={() => setPage("main")}
                        >
                            Ogólne
                        </Button>
                    )}
                    {page !== "crosshair" && (
                        <Button
                            variant="secondary"
                            onClick={() => setPage("crosshair")}
                        >
                            Celownik
                        </Button>
                    )}
                    {page !== "hud-personalization" && (
                        <Button
                            variant="secondary"
                            onClick={() => setPage("hud-personalization")}
                        >
                            HUD
                        </Button>
                    )}
                    <Button onClick={resetSettings}>
                        Zresetuj
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}