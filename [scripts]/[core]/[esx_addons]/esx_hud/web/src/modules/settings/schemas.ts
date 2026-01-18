import { z } from "zod";
import { isValidHsl } from "./lib/utils";

export const booleanStringSchema = z
    .string()
    .nullish()
    .transform((val) => val === "true");

export const numberStringSchema = z
    .string()
    .nullish()
    .refine((val) => val && !isNaN(+val))
    .transform((val) => val ? +val : 0);

export const hslStringSchema = z
    .string()
    .refine(isValidHsl)
    .nullish()