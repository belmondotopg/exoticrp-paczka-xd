import type { BasicDocumentData } from "./basic-document-data";

export type Badge = BasicDocumentData & {
    badge: string;
    grade: string;
    fraction: string;
}