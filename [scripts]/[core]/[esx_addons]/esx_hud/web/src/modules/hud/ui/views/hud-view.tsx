import { useVisible } from "@yankes/fivem-react/hooks";
import { GlassWaterIcon, HamburgerIcon, HeartIcon, ShieldIcon } from "lucide-react";
import { FaMaskVentilator } from "react-icons/fa6";

import { cn } from "@/lib/utils";
import { useHudData } from "@/modules/hud/api/use-hud-data";
import { HudBox } from "@/modules/hud/ui/components/hud-box";
import { useSettings } from "@/modules/settings/hooks/use-settings";

export const HudView = () => {
    const { visible } = useVisible("hud", false);
    const data = useHudData();
    const { settings } = useSettings();

    if (settings["hud-appearance"] === "old") {
        return <></>
    }

    return data && (
        <div
            className={cn(
                "fixed bottom-8 left-1/2 -translate-x-1/2 flex items-center gap-x-5 transition-opacity duration-300",
                (!visible || !settings["show-hud"]) && "opacity-0 scale-0 pointer-events-none"
            )}
        >
            <HudBox icon={HeartIcon} value={data.health} color={settings["health-color"] as string} />
            {data.armour > 0 && <HudBox icon={ShieldIcon} value={data.armour} color={settings["armour-color"] as string} />}
            <HudBox icon={HamburgerIcon} value={data.hunger} color={settings["hunger-color"] as string} />
            <HudBox icon={GlassWaterIcon} value={data.thirst} color={settings["thirst-color"] as string} />
            {data.oxygen < 100 && <HudBox icon={FaMaskVentilator} value={data.oxygen} color={settings["oxygen-color"] as string} />}
        </div>
    )
}