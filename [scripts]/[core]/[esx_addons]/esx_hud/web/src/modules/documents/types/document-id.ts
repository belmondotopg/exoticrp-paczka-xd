import type { BasicDocumentData } from "./basic-document-data";

export type DocumentId = BasicDocumentData & {
    birthDate: number;
    gender: "m" | "f";
    nationality: string;
    gunLicense: boolean;
    height: number;
    drivingLicense: {
        a: boolean;
        b: boolean;
        c: boolean;
    }
}