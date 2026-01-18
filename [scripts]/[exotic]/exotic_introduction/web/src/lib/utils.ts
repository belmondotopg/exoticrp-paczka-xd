import { clsx, type ClassValue } from "clsx";
import { marked } from "marked";
import { twMerge } from "tailwind-merge";

declare function GetParentResourceName(): string;

export function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs))
}

export function isInGame(): boolean {
    try {
        return typeof (window as any).GetParentResourceName === 'function' && 
               typeof GetParentResourceName() !== 'undefined';
    } catch {
        return false;
    }
}

export function GetResourceName() {
    if (!isInGame()) {
        return '';
    }
    return `https://${GetParentResourceName()}`;
}

export async function sendAction(
    action: string,
    data?: any
) {
    if (!isInGame()) {
        console.log(`[Dev Mode] Action: ${action}`, data);
        return;
    }
    const name = GetResourceName();
    const requestBody = data ? JSON.stringify(data) : undefined;

    return fetch(`${name}/exotic-introduction:nui:${action}`, {
        method: "POST",
        body: requestBody,
        headers: {
            "Content-Type": "application/json"
        }
    });
}

export function closeUI() {
    if (!isInGame()) {
        console.log('[Dev Mode] closeUI called');
        return;
    }
    sendAction('close');
}

export function compareArticleContentFilePath(path: string) {
    return `./articles/${path.replace(".md", "")}.md`;
}

export async function fetchArticle(path: string) {
    const res = await fetch(compareArticleContentFilePath(path));
    
    const text = await res.text();
    const data = text.split('---');
        
    let media = [];
    if(data[2]) {
        media = JSON.parse(data[2]);
    }
    
    return {
        data: marked(data[1]),
        title: data[0].replace("\n", ""),
        media
    };
}

export function compareMediaFilePath(path: string) {
    return `./media/${path}`;
}