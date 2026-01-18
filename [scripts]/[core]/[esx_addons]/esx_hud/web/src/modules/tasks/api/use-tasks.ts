import { useNuiData } from "@yankes/fivem-react/hooks";
import type { Task } from "../types/task";
import { useMemo } from "react";

const MOCK_DATA: Task[] = [
    {
        id: "1",
        name: "Zabij 5 graczy",
        progress: [5,5],
        ts: Date.parse("2025-08-11T00:00:00.000Z") / 1000
    },
    {
        id: "2",
        name: "Zabij 5 graczy",
        progress: [3,5],
        ts: Date.parse("2025-08-11T00:00:00.000Z") / 1000
    },
    {
        id: "3",
        name: "Zabij 5 graczy",
        progress: [0,5],
        ts: Date.parse("2025-08-11T00:00:00.000Z") / 1000
    },
    {
        id: "4",
        name: "Zabij 5 graczy",
        progress: [5,5],
        ts: Date.parse("2025-08-10T00:00:00.000Z") / 1000
    },
    {
        id: "5",
        name: "Zabij 5 graczy",
        progress: [3,5],
        ts: Date.parse("2025-08-10T00:00:00.000Z") / 1000
    },
    {
        id: "6",
        name: "Zabij 5 graczy",
        progress: [3,5],
        ts: Date.parse("2025-08-10T00:00:00.000Z") / 1000
    },
    {
        id: "7",
        name: "Zabij 5 graczy",
        progress: [5,5],
        ts: Date.parse("2025-08-09T00:00:00.000Z") / 1000
    },
    {
        id: "8",
        name: "Zabij 5 graczy",
        progress: [3,5],
        ts: Date.parse("2025-08-09T00:00:00.000Z") / 1000
    },
    {
        id: "9",
        name: "Zabij 5 graczy",
        progress: [3,5],
        ts: Date.parse("2025-08-09T00:00:00.000Z") / 1000
    },
    {
        id: "10",
        name: "Zabij 5 graczy",
        progress: [5,5],
        ts: Date.parse("2025-08-08T00:00:00.000Z") / 1000
    },
    {
        id: "11",
        name: "Zabij 5 graczy",
        progress: [3,5],
        ts: Date.parse("2025-08-08T00:00:00.000Z") / 1000
    },
    {
        id: "12",
        name: "Zabij 5 graczy",
        progress: [3,5],
        ts: Date.parse("2025-08-08T00:00:00.000Z") / 1000
    },
]

const groupTasksByDay = (
    tasks: Task[]
): { label: string; tasks: Task[]; diffDays: number }[] => {
    const dayNames = ["Niedziela", "Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota"];
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const getDiffDays = (taskDate: Date): number =>
        Math.floor(
            (startOfToday -
                new Date(taskDate.getFullYear(), taskDate.getMonth(), taskDate.getDate()).getTime()) /
                (1000 * 60 * 60 * 24)
        );
    const getLabel = (diffDays: number, dayIndex: number): string => {
        if (diffDays === 0) return "Dzisiaj";
        if (diffDays === 1) return "Wczoraj";
        if (diffDays === 2) return "Przedwczoraj";
        return dayNames[dayIndex];
    };
    const sorted = [...tasks].filter(task => task.ts && !isNaN(task.ts)).sort((a, b) => b.ts - a.ts);
    const groups: Record<string, { diffDays: number; tasks: Task[] }> = {};
    for (const task of sorted) {
        if (!task.ts || isNaN(task.ts)) continue;
        const date = new Date(task.ts * 1000);
        if (isNaN(date.getTime())) continue;
        const diffDays = getDiffDays(date);
        const label = getLabel(diffDays, date.getDay());
        if (!groups[label]) groups[label] = { diffDays, tasks: [] };
        groups[label].tasks.push(task);
    }
    return Object.keys(groups)
        .sort((a, b) => groups[b].tasks[0].ts - groups[a].tasks[0].ts)
        .map(label => ({
            label,
            diffDays: groups[label].diffDays,
            tasks: groups[label].tasks
        }));
};

export const useTasks = () => {
    const data = useNuiData<Task[]>("tasks", process.env.NODE_ENV === "development" ? MOCK_DATA : []) ?? [];
    const formattedData = useMemo(() => groupTasksByDay(data), [data]);

    return formattedData;
}