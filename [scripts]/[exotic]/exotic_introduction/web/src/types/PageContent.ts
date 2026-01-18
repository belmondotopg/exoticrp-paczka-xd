export type PageContent = {
    title: string;
    data: string | Promise<string>;
    media?: string[];
}