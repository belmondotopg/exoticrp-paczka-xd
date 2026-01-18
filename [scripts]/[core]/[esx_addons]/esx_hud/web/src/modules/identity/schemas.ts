import { z } from "zod";

const dateRegex = /^(0?[1-9]|[12][0-9]|3[01])\/(0?[1-9]|1[0-2])\/\d{4}$/;

const parseDate = (dateStr: string): Date | null => {
  const [day, month, year] = dateStr.split("/").map(Number);
  const date = new Date(year, month - 1, day);

  if (
    date.getFullYear() === year &&
    date.getMonth() === month - 1 &&
    date.getDate() === day
  ) {
    return date;
  }

  return null;
};

const stringDateSchema = z
  .string()
  .regex(
    dateRegex,
    "Data musi być w formacie D/MM/YYYY lub DD/MM/YYYY i być poprawną datą."
  )
  .refine((val) => {
    const date = parseDate(val);
    if (!date) return false;

    const now = new Date();
    const age = now.getFullYear() - date.getFullYear();

    const hasHadBirthdayThisYear =
      now.getMonth() > date.getMonth() ||
      (now.getMonth() === date.getMonth() && now.getDate() >= date.getDate());

    const realAge = hasHadBirthdayThisYear ? age : age - 1;

    return realAge >= 16 && realAge <= 100;
  }, "Wiek musi zawierać się między 16 a 100 lat");

export const createCharacterSchema = z.object({
    firstName: z.string().min(1, "Wymagane").max(32, "Maksymalnie 32 znaki"),
    lastName: z.string().min(1, "Wymagane").max(32, "Maksymalnie 32 znaki"),
    birthDate: stringDateSchema,
    height: z.number()
        .min(140, "Postać musi mieć minimalnie 140 cm wzrostu")
        .max(210, "Postać może mieć maksymalnie 210 cm wzrostu"),
    gender: z.enum(["mele", "famele"], "Musisz wybrać płeć"),
    countryCode: z.string().min(1, "Wymagane")
});

export type CreateCharacterInput = z.infer<typeof createCharacterSchema>;