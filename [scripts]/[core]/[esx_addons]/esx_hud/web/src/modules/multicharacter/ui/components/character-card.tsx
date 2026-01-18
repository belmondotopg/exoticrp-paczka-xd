import { memo } from "react";
import { Button } from "@/components/ui/button";
import type { Character } from "../../types";
import { CircleUserIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface Props {
    character: Character | null;
    isSelected?: boolean;
    onSelect?: () => void;
    onCreate?: () => void;
}

export const CharacterCard = memo(({
    character,
    isSelected = false,
    onSelect,
    onCreate
}: Props) => {
    return (
        <div className="flex flex-col gap-y-3">
            <div className="flex items-center gap-x-4 px-8 py-7 rounded-2xl bg-[hsla(0_0%_15%_/_0.8)] bg-radial to-[hsla(0_0%_0%_/_0.4)] border border-[hsla(0_0%_100%_/_0.15)] shadow">
                {character ? (
                    <img
                        src={character.mugshot}
                        alt=""
                        className="size-14 rounded-lg object-cover object-center"
                    />
                ) : (
                    <CircleUserIcon className="size-14" />
                )}

                <div className="flex flex-col gap-y-0.5">
                    <span className="text-xl font-semibold">
                        {character ? `${character.firstName} ${character.lastName}` : "Pusty Slot"}
                    </span>
                    <span className="font-medium text-muted-foreground">
                        {character ? character.lastLocation : "Możesz utworzyć tą postać"}
                    </span>
                </div>
            </div>
            <Button
                className={cn(isSelected && "pointer-events-none")}
                onClick={character ? onSelect : onCreate}
            >
                {!character && "Stwórz"}
                {(isSelected && character) ? "Wybrano" : "Wybierz"}
            </Button>
        </div>
    )
}, (prevProps, nextProps) => {
    return prevProps.isSelected === nextProps.isSelected &&
           prevProps.character?.id === nextProps.character?.id;
});

CharacterCard.displayName = 'CharacterCard';
