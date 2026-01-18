import { createContext, useContext, useEffect } from "react";
import { ArrowDownIcon, ArrowLeftIcon, ArrowRightIcon, ArrowUpIcon, DeleteIcon, XIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import type { KeyboardType } from "@/types";

import { KeyboardKey } from "./keyboard-key";
import { Button } from "./ui/button";

const KeyboardContext = createContext<KeyboardType | null>(null);

interface Props {
    data: KeyboardType;
    isOpen: boolean;
    onOpenChange: (isOpen: boolean) => void;
}

export const Keyboard = ({ data, isOpen, onOpenChange }: Props) => {
    useEffect(() => {
        if (isOpen) {
            const onKeyDown = (e: KeyboardEvent) => {
                if (e.key === "Escape") onOpenChange(false);
            }

            window.addEventListener("keydown", onKeyDown);
            return () => window.removeEventListener("keydown", onKeyDown);
        }
    }, [isOpen]);

    return (
        <KeyboardContext.Provider value={data}>
            <div
                onClick={() => onOpenChange(false)}
                className={cn(
                    "w-screen h-screen z-50 fixed top-0 left-0 bg-[hsla(0_0%_0%_/_0.8)] transition-opacity duration-300",
                    !isOpen && "opacity-0 scale-0 pointer-events-none"
                )}
            />
            <Button
                onClick={() => onOpenChange(false)}
                className={cn(
                    "size-10 absolute top-14 right-14 z-50 transition-opacity duration-300 p-0",
                    !isOpen && "opacity-0 scale-0 pointer-events-none"
                )}
            >
                <XIcon />
            </Button>
            <div
                className={cn(
                    "flex gap-x-9 fixed z-[60] top-1/2 left-1/2 -translate-1/2 transition-opacity duration-300 h-102.5",
                    !isOpen && "opacity-0 scale-0 pointer-events-none"
                )}
            >
                <div className="flex flex-col gap-y-2.5">
                    <div className="flex justify-between">
                        <KeyboardKey buttonKey="ESC" />
                        <div className="flex gap-x-2.5">
                            <KeyboardKey buttonKey="F1" />
                            <KeyboardKey buttonKey="F2" />
                            <KeyboardKey buttonKey="F3" />
                            <KeyboardKey buttonKey="F4" />
                        </div>
                        <div className="flex gap-x-2.5">
                            <KeyboardKey buttonKey="F5" />
                            <KeyboardKey buttonKey="F6" />
                            <KeyboardKey buttonKey="F7" />
                            <KeyboardKey buttonKey="F8" />
                        </div>
                        <div className="flex gap-x-2.5">
                            <KeyboardKey buttonKey="F9" />
                            <KeyboardKey buttonKey="F10" />
                            <KeyboardKey buttonKey="F11" />
                            <KeyboardKey buttonKey="F12" />
                        </div>
                    </div>
                    <div className="flex gap-x-2.5">
                        <KeyboardKey buttonKey="~" />
                        <KeyboardKey buttonKey="1" />
                        <KeyboardKey buttonKey="2" />
                        <KeyboardKey buttonKey="3" />
                        <KeyboardKey buttonKey="4" />
                        <KeyboardKey buttonKey="5" />
                        <KeyboardKey buttonKey="6" />
                        <KeyboardKey buttonKey="7" />
                        <KeyboardKey buttonKey="8" />
                        <KeyboardKey buttonKey="9" />
                        <KeyboardKey buttonKey="0" />
                        <KeyboardKey buttonKey="-" />
                        <KeyboardKey buttonKey="+" />
                        <KeyboardKey buttonKey="Backspace" icon={DeleteIcon} className="w-32" />
                    </div>
                    <div className="flex gap-x-2.5">
                        <KeyboardKey buttonKey="Tab" className="w-21" />
                        <KeyboardKey buttonKey="Q" />
                        <KeyboardKey buttonKey="W" />
                        <KeyboardKey buttonKey="E" />
                        <KeyboardKey buttonKey="R" />
                        <KeyboardKey buttonKey="T" />
                        <KeyboardKey buttonKey="Y" />
                        <KeyboardKey buttonKey="U" />
                        <KeyboardKey buttonKey="I" />
                        <KeyboardKey buttonKey="O" />
                        <KeyboardKey buttonKey="P" />
                        <KeyboardKey buttonKey="[" />
                        <KeyboardKey buttonKey="]" />
                        <KeyboardKey buttonKey="\" className="flex-1" />
                    </div>
                    <div className="flex gap-x-2.5">
                        <KeyboardKey buttonKey="Caps" className="w-23" />
                        <KeyboardKey buttonKey="A" />
                        <KeyboardKey buttonKey="S" />
                        <KeyboardKey buttonKey="D" />
                        <KeyboardKey buttonKey="F" />
                        <KeyboardKey buttonKey="G" />
                        <KeyboardKey buttonKey="H" />
                        <KeyboardKey buttonKey="J" />
                        <KeyboardKey buttonKey="K" />
                        <KeyboardKey buttonKey="L" />
                        <KeyboardKey buttonKey=";" />
                        <KeyboardKey buttonKey="'" />
                        <KeyboardKey buttonKey="Enter" className="flex-1" />
                    </div>
                    <div className="flex gap-x-2.5">
                        <KeyboardKey buttonKey="L. Shift" className="flex-1" />
                        <KeyboardKey buttonKey="Z" />
                        <KeyboardKey buttonKey="X" />
                        <KeyboardKey buttonKey="C" />
                        <KeyboardKey buttonKey="V" />
                        <KeyboardKey buttonKey="B" />
                        <KeyboardKey buttonKey="N" />
                        <KeyboardKey buttonKey="M" />
                        <KeyboardKey buttonKey="<" />
                        <KeyboardKey buttonKey=">" />
                        <KeyboardKey buttonKey="/" />
                        <KeyboardKey buttonKey="P. Shift" className="flex-1" />
                    </div>
                    <div className="flex gap-x-2.5">
                        <KeyboardKey buttonKey="L. Ctrl" className="w-25" />
                        <KeyboardKey buttonKey="L. Alt" className="w-22.5" />
                        <KeyboardKey buttonKey="Space" className="flex-1" />
                        <KeyboardKey buttonKey="L. Alt" className="w-22.5" />
                        <KeyboardKey buttonKey="P. Ctrl" className="w-25" />
                    </div>
                </div>
                <div className="h-full pt-17.5 flex flex-col justify-between">
                    <div className="grid grid-cols-3 gap-2.5 w-50">
                        <KeyboardKey buttonKey="INS" />
                        <KeyboardKey buttonKey="HM" />
                        <KeyboardKey buttonKey="PU" />
                        <KeyboardKey buttonKey="DEL" />
                        <KeyboardKey buttonKey="END" />
                        <KeyboardKey buttonKey="PD" />
                    </div>
                    <div className="grid grid-cols-3 gap-2.5 w-50">
                        <div />
                        <KeyboardKey buttonKey="ArrowUp" icon={ArrowUpIcon} />
                        <div />
                        <KeyboardKey buttonKey="ArrowLeft" icon={ArrowLeftIcon} />
                        <KeyboardKey buttonKey="ArrowDown" icon={ArrowDownIcon} />
                        <KeyboardKey buttonKey="ArrowRight" icon={ArrowRightIcon} />
                    </div>
                </div>
            </div>
        </KeyboardContext.Provider>
    )
}

export const useKeyboard = () => {
    return useContext(KeyboardContext)!;
}