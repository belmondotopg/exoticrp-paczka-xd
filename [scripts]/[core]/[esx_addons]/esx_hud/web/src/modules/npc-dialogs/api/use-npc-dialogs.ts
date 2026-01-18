import { useEffect, useState } from "react";
import { useNuiData, useNuiMessage } from "@yankes/fivem-react/hooks";
import { fetchNui } from "@yankes/fivem-react/utils";

import type { NPCDialogsData } from "@/modules/npc-dialogs/types";

// @ts-ignore
const MOCK_DATA: NPCDialogsData = {
    id: "race",
    showProgress: true,
    pages: [
        {
            name: "car",
            question: {
                userName: "Scott",
                text: "Jakim autem chcesz się ścigać?"
            },
            buttons: [
                { value: "bmw-m4", label: "BMW M4" },
                { value: "toyota-supra", label: "Toyota Supra" },
                { value: "lamborghini-huracan", label: "Lamborghini Huracan" },
                { value: "porshe-911", label: "Porsche 911" }
            ]
        },
        {
            name: "rate",
            question: {
                userName: "Scott",
                text: "Za jaką stawkę chcesz się ścigać?"
            },
            buttons: [
                { value: "5k", label: "$5000" },
                { value: "10k", label: "$10 000" },
                { value: "15k", label: "$15 000" },
                { value: "30k", label: "$30 000" }
            ]
        }
    ]
}

export const useNPCDialogs = () => {
    // const data = useNuiData<NPCDialogsData | null>("npc-dialogs", process.env.NODE_ENV === "development" ? MOCK_DATA : null) ?? null;
    const data = useNuiData<NPCDialogsData | null>("npc-dialogs") ?? null;

    const [answers, setAnswers] = useState<{ [key: string]: string | null } | null>(null);

    const setAnswerValue = (
        page: string,
        value: string | null
    ) => setAnswers(prev => ({ ...prev, [page]: value }));

    const closeDialpg = () => {
        fetchNui("/npc-dialogs:close");
    }
    
    const submitDialog = () => {
        if (!answers || Object.values(answers).some(answer => answer === null)) {
            return;
        }

        fetchNui("/npc-dialogs:submit", JSON.stringify({ id: data?.id ?? null, answers: answers }));
    }

    useEffect(() => {
        if (!data || !data.pages) {
            setAnswers(null);
            return;
        }

        const obj: { [key: string]: string | null } = {};
        data.pages.forEach(page => obj[page.name] = null);

        setAnswers(obj);
    }, [data]);

    useNuiMessage<{ eventName: string; }>("npc-dialogs:cancel", () => closeDialpg());

    return {
        data,
        answers,
        setAnswerValue,
        closeDialpg,
        submitDialog
    }
}