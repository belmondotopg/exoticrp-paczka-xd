import { useEffect } from "react";
import { useVisible } from "@yankes/fivem-react/hooks";
import { XIcon } from "lucide-react";

import { Box } from "@/components/box";
import { Separator } from "@/components/ui/separator";

import { useTasks } from "../../api/use-tasks";
import { TaskCard } from "../components/task-card";
import { cn } from "@/lib/utils";

export const TasksView = () => {
    const { visible, close: onClose } = useVisible("tasks", false);
    const tasksGroups = useTasks();

    useEffect(() => {
        const onKeyDown = (e: KeyboardEvent) => {
            if (e.key === "Escape") onClose();
        };

        window.addEventListener("keydown", onKeyDown);
        return () => window.removeEventListener("keydown", onKeyDown);
    }, []);

    return (
        <>
            {visible && <div className="fixed top-0 left-0 w-screen h-screen z-50" onClick={onClose} />}
            <Box
                className={cn("w-[410px] h-screen top-0 left-0 fixed border-0 border-r-2 p-8 flex flex-col gap-y-7 rounded-l-none transition-[transform,opacity] duration-300 z-[51]", !visible && "-translate-x-full scale-0 opacity-0 pointer-events-none")}
            >
                <div className="flex items-center justify-between gap-x-3.5">
                    <span className="text-lg font-bold">
                        Zadania
                    </span>
                    <button className="text-muted-foreground hover:text-foreground transition cursor-pointer" onClick={onClose}>
                        <XIcon className="size-4 shrink-0" />
                    </button>
                </div>
                <Separator />
                <div className="flex-1 flex flex-col gap-y-5 overflow-y-hidden hover:overflow-y-auto">
                    {tasksGroups.map((group, groupIndex) => (
                        <div className="flex flex-col gap-y-4" key={`${group.label}-${groupIndex}`}>
                            <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                                {group.label}
                            </span>
                            <div className="flex flex-col gap-y-3">
                                {group.tasks.map((task) => (
                                    <TaskCard
                                        key={task.id}
                                        isToday={group.diffDays === 0}
                                        {...task}
                                    />
                                ))}
                            </div>
                        </div>
                    ))}
                </div>
            </Box>
        </>
    )
}