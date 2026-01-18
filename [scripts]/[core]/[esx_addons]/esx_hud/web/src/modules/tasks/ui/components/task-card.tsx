import { CircleCheckBigIcon, CircleDashedIcon, CircleOffIcon, HourglassIcon } from "lucide-react";
import type { Task } from "../../types/task";

type Props = Task & {
    isToday: boolean;
}

export const TaskCard = ({
    name,
    progress,
    formatProgress = (p) => p.toString(),
    isToday
}: Props) => {
    const isDone = progress[0] >= progress[1];
    const isInitialized = progress[0] > 0;

    const getColor = () => {
        if (isDone) return "160 100% 37%";
        if (!isInitialized) return "0 0% 63%";

        if (isToday) return "44 100% 50%";

        return "359 100% 70%";
    }

    const getIcon = () => {
        if (isDone) return CircleCheckBigIcon; 
        if (!isInitialized) return HourglassIcon;

        if (isToday) return CircleDashedIcon;
        

        return CircleOffIcon;
    }

    const color = getColor();
    const Icon = getIcon();

    return (
        <div
            className="flex rounded-lg bg-neutral-900 border border-neutral-700 shadow-md"
            style={{
                backgroundImage: `radial-gradient(transparent, hsla(${color} / 0.1))`
            }}
        >
            <div
                className="h-full aspect-square grid place-items-center rounded-lg"
                style={{
                    backgroundImage: `radial-gradient(transparent, hsla(${color} / 0.25))`,
                    border: `1px solid hsl(${color})`
                }}
            >
                <Icon className="size-5 shrink-0" style={{ color: `hsl(${color})` }} />
            </div>
            <div className="flex-1 h-full p-4 flex justify-between gap-x-3 items-center">
                <span className="text-base font-medium">
                    {name}
                </span>
                <div
                    className="px-[9px] py-[3px] rounded-full text-[10px] font-semibold shadow-xs"
                    style={{
                        backgroundColor: `hsla(${color} / 0.2)`,
                        color: `hsl(${color})`
                    }}
                >
                    {progress[0] >= progress[1] && "Zrobione"}
                    {progress[0] === 0 && "Nie Rozpoczęte"}
                    {!isDone && isInitialized && `${formatProgress(progress[0])}/${formatProgress(progress[1])}`}
                </div>
            </div>
        </div>
    )
}