import { useMemo } from "react";
import type { Country } from "@/modules/identity/types/country";

// Statyczna lista najpopularniejszych krajów - rozwiązanie problemu z CORS w FiveM
const COUNTRIES: Country[] = [
    { cca2: "PL", flags: { svg: "🇵🇱" }, translations: { pol: { common: "Polska" } } },
    { cca2: "US", flags: { svg: "🇺🇸" }, translations: { pol: { common: "Stany Zjednoczone" } } },
    { cca2: "GB", flags: { svg: "🇬🇧" }, translations: { pol: { common: "Wielka Brytania" } } },
    { cca2: "DE", flags: { svg: "🇩🇪" }, translations: { pol: { common: "Niemcy" } } },
    { cca2: "FR", flags: { svg: "🇫🇷" }, translations: { pol: { common: "Francja" } } },
    { cca2: "IT", flags: { svg: "🇮🇹" }, translations: { pol: { common: "Włochy" } } },
    { cca2: "ES", flags: { svg: "🇪🇸" }, translations: { pol: { common: "Hiszpania" } } },
    { cca2: "RU", flags: { svg: "🇷🇺" }, translations: { pol: { common: "Rosja" } } },
    { cca2: "UA", flags: { svg: "🇺🇦" }, translations: { pol: { common: "Ukraina" } } },
    { cca2: "CZ", flags: { svg: "🇨🇿" }, translations: { pol: { common: "Czechy" } } },
    { cca2: "SK", flags: { svg: "🇸🇰" }, translations: { pol: { common: "Słowacja" } } },
    { cca2: "AT", flags: { svg: "🇦🇹" }, translations: { pol: { common: "Austria" } } },
    { cca2: "NL", flags: { svg: "🇳🇱" }, translations: { pol: { common: "Holandia" } } },
    { cca2: "BE", flags: { svg: "🇧🇪" }, translations: { pol: { common: "Belgia" } } },
    { cca2: "SE", flags: { svg: "🇸🇪" }, translations: { pol: { common: "Szwecja" } } },
    { cca2: "NO", flags: { svg: "🇳🇴" }, translations: { pol: { common: "Norwegia" } } },
    { cca2: "DK", flags: { svg: "🇩🇰" }, translations: { pol: { common: "Dania" } } },
    { cca2: "FI", flags: { svg: "🇫🇮" }, translations: { pol: { common: "Finlandia" } } },
    { cca2: "CH", flags: { svg: "🇨🇭" }, translations: { pol: { common: "Szwajcaria" } } },
    { cca2: "PT", flags: { svg: "🇵🇹" }, translations: { pol: { common: "Portugalia" } } },
    { cca2: "GR", flags: { svg: "🇬🇷" }, translations: { pol: { common: "Grecja" } } },
    { cca2: "TR", flags: { svg: "🇹🇷" }, translations: { pol: { common: "Turcja" } } },
    { cca2: "RO", flags: { svg: "🇷🇴" }, translations: { pol: { common: "Rumunia" } } },
    { cca2: "BG", flags: { svg: "🇧🇬" }, translations: { pol: { common: "Bułgaria" } } },
    { cca2: "HU", flags: { svg: "🇭🇺" }, translations: { pol: { common: "Węgry" } } },
    { cca2: "HR", flags: { svg: "🇭🇷" }, translations: { pol: { common: "Chorwacja" } } },
    { cca2: "RS", flags: { svg: "🇷🇸" }, translations: { pol: { common: "Serbia" } } },
    { cca2: "LT", flags: { svg: "🇱🇹" }, translations: { pol: { common: "Litwa" } } },
    { cca2: "LV", flags: { svg: "🇱🇻" }, translations: { pol: { common: "Łotwa" } } },
    { cca2: "EE", flags: { svg: "🇪🇪" }, translations: { pol: { common: "Estonia" } } },
    { cca2: "BY", flags: { svg: "🇧🇾" }, translations: { pol: { common: "Białoruś" } } },
    { cca2: "CA", flags: { svg: "🇨🇦" }, translations: { pol: { common: "Kanada" } } },
    { cca2: "MX", flags: { svg: "🇲🇽" }, translations: { pol: { common: "Meksyk" } } },
    { cca2: "BR", flags: { svg: "🇧🇷" }, translations: { pol: { common: "Brazylia" } } },
    { cca2: "AR", flags: { svg: "🇦🇷" }, translations: { pol: { common: "Argentyna" } } },
    { cca2: "AU", flags: { svg: "🇦🇺" }, translations: { pol: { common: "Australia" } } },
    { cca2: "NZ", flags: { svg: "🇳🇿" }, translations: { pol: { common: "Nowa Zelandia" } } },
    { cca2: "JP", flags: { svg: "🇯🇵" }, translations: { pol: { common: "Japonia" } } },
    { cca2: "CN", flags: { svg: "🇨🇳" }, translations: { pol: { common: "Chiny" } } },
    { cca2: "KR", flags: { svg: "🇰🇷" }, translations: { pol: { common: "Korea Południowa" } } },
    { cca2: "IN", flags: { svg: "🇮🇳" }, translations: { pol: { common: "Indie" } } },
    { cca2: "ZA", flags: { svg: "🇿🇦" }, translations: { pol: { common: "Republika Południowej Afryki" } } },
    { cca2: "EG", flags: { svg: "🇪🇬" }, translations: { pol: { common: "Egipt" } } },
    { cca2: "IL", flags: { svg: "🇮🇱" }, translations: { pol: { common: "Izrael" } } },
    { cca2: "SA", flags: { svg: "🇸🇦" }, translations: { pol: { common: "Arabia Saudyjska" } } },
    { cca2: "AE", flags: { svg: "🇦🇪" }, translations: { pol: { common: "Zjednoczone Emiraty Arabskie" } } },
];

export const useCountries = () => {
    const data = useMemo(() => 
        COUNTRIES.sort((a, b) => a.translations.pol.common.localeCompare(b.translations.pol.common)),
        []
    );

    return { 
        data, 
        isLoading: false, 
        isError: false 
    };
}