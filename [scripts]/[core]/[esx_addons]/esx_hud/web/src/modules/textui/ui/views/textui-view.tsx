import { useMemo } from "react";
import { useVisible } from "@yankes/fivem-react/hooks";
import { InfoIcon } from "lucide-react";

import { Box } from "@/components/box";
import { cn } from "@/lib/utils";
import { useFormattedText } from "@/modules/textui/hooks/use-formatted-text";
import { useTextui } from "@/modules/textui/api/use-textui";
import { Button } from "@/components/ui/button";

export const TextUIView = () => {
    const { visible } = useVisible("textui", false);
    const textui = useTextui();
    const formattedText = useFormattedText(textui ?? null);

    const renderedText = useMemo(() => {
        if (!formattedText) return null;
        
        return formattedText.map((t, k) => 
            t.type === "text" 
                ? <span key={k} className="mr-0.5">{t.value}</span> 
                : <Button 
                    key={k} 
                    className="size-5.5 p-0 rounded-[3px] !opacity-100 mr-0.5 text-xs" 
                    variant="secondary" 
                    disabled
                  >
                    {t.value}
                  </Button>
        );
    }, [formattedText]);

    return formattedText && (
        <Box
            className={cn(
                "w-[338px] flex items-center gap-x-2.5 px-5 py-4 rounded-xl transition-opacity duration-300 fixed left-1/2 -translate-x-1/2 bottom-28",
                !visible && "opacity-0 scale-0 pointer-events-none"
            )}
        >
            <InfoIcon className="size-4 text-primary shrink-0" />
            <div className="text-sm font-medium">
                {renderedText}
            </div>
        </Box>
    )
}
