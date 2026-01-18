export interface Statistic {
    label: string;
    level: number;

    current: number;
    required: number;

    unit?: string;
    colorKey?: string;
}
