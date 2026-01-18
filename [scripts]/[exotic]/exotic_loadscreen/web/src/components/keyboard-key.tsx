import { useState } from "react";
import type { LucideIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import type { KeyboardType } from "@/types";

import { useKeyboard } from "./keyboard";

interface Props {
  buttonKey: string;
  icon?: LucideIcon;
  className?: string;
}

const findKey = (key: string, data: KeyboardType) => {
  const array = Object.entries(data);
  const index = array.findIndex(
    ([keyName]) => keyName.toLowerCase() === key.toLowerCase()
  );

  if (index === -1) return null;

  return {
    key: array[index][0],
    value: array[index][1],
  };
};

export const KeyboardKey = ({ buttonKey, icon: Icon, className }: Props) => {
  const data = useKeyboard();
  const foundKey = findKey(buttonKey, data);

  const [hovered, setHovered] = useState(false);

  return (
    <div
      className={cn("relative size-15", className)}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      <div
        className={cn(
          "size-full rounded-lg grid place-items-center bg-neutral-800 font-bold uppercase text-center select-none",
          foundKey && "bg-primary"
        )}
        style={{
          boxShadow: foundKey
            ? "0 2px 8px hsla(0 0% 0% / 0.1), inset 0 -6px 0 0 hsla(0 0% 0% / 0.15)"
            : "0 2px 8px hsla(0 0% 0% / 0.1), inset 0 -6px 0 0 hsla(0 0% 100% / 0.1)",
        }}
      >
        {Icon ? <Icon className="size-5" /> : buttonKey}
      </div>

      {foundKey && (
        <div className={cn("absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-4 py-1.5 rounded-md bg-[hsla(0_0%_15%_/_0.8)] border border-[hsla(0_0%_33%_/_0.5)] backdrop-blur-sm text-white text-sm font-medium whitespace-nowrap z-10 transition origin-bottom", !hovered && "opacity-100 scale-0")}>
          {foundKey.value.toLocaleString("pl-PL")}
        </div>
      )}
    </div>
  );
};