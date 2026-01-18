import { useVisible } from "@yankes/fivem-react/hooks"

import { useSettings } from "@/modules/settings/hooks/use-settings";
import Crosshair from "../components/crosshair";

export const CrosshairView = () => {
    const { visible } = useVisible("crosshair", false);
    const { settings } = useSettings();

    if (!visible) {
        return null;
    }

    if (settings["crosshair-gta5"]) {
        return (
            <div className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
                <div className="size-1.5 rounded-full bg-white stroke-2 stroke-neutral-800" />
            </div>
        );
    }

    return (
        <Crosshair
            className="fixed top-1/2 left-1/2 -translate-1/2"
            length={settings["crosshair-lenght"] as number}
            thickness={settings["crosshair-thickness"] as number}
            gap={settings["crosshair-gap"] as number}
            opacity={settings["crosshair-opacity"] as number}
            color={settings["crosshair-color"] as string}
            dotOnCenter={settings["crosshair-dot-on-center"] as boolean}
        />
    )
}