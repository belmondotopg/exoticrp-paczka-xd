import type { BasicDocumentData } from "./basic-document-data";

export type BusinessCard = BasicDocumentData & {
    phoneNumber: string;
    job: string;
}