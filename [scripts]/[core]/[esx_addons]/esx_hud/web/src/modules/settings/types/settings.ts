import type { JSX } from "react";
import type z from "zod";

import type { CATEGORIES } from "../constants";

export type SettingValue = string | number | boolean;

export type Setting = {
    name: string;
    category: keyof typeof CATEGORIES;
    label: string;
    defaultValue: SettingValue;
    schema: z.ZodTypeAny;
    component: ({ value, setValue }: {
        value: SettingValue
        setValue: (value: SettingValue) => void
    }) => JSX.Element;
    onValueChange?: (value: SettingValue) => void;
}