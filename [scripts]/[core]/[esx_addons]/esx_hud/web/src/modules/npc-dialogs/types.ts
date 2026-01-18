export type NPCDialogsButton = {
    value: string;
    label: string;
}

export type NPCDialogsPage = {
    name: string;
    question: {
        userName: string;
        text: string;
    }
    buttons: NPCDialogsButton[];
}

export type NPCDialogsData = {
    id: string;
    showProgress: boolean;
    pages: NPCDialogsPage[];
}

export type NPCDialogsResponse = Record<string, string>;