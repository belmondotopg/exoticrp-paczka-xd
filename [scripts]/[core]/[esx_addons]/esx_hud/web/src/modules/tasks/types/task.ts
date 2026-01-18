export type Task = {
    id: string;
    name: string;
    progress: number[];
    formatProgress?: (progress: number) => string;
    ts: number;
}