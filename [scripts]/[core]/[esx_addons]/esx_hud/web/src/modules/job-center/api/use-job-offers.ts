import { useNuiData } from "@yankes/fivem-react/hooks";
import type { JobOffer } from "../types/job-offer";

const MOCK_DATA: JobOffer[] = [
    {
        id: "burger-shot",
        title: "Burger Shot",
        category: {
            name: "gastronomy",
            label: "Gastronomia"
        },
        description: "Krótki opis.",
        image: "https://img.gta5-mods.com/q85-w800/images/burger-shot-clothing-for-mp-male-female/280bd6-1.png",
        address: "3561 Whispymound Drive",
        salary: "$50/kurs",
        isAvailable: true
    },
    {
        id: "uwu-cafe",
        title: "UwU Cafe",
        description: "Krótki opis. Krótki opis. Krótki opis. Krótki opis.",
        category: {
            name: "gastronomy",
            label: "Gastronomia"
        },
        image: "https://8e216c4e759fe0cb2d2a.cdn6.editmysite.com/uploads/b/8e216c4e759fe0cb2d2aff7b494f5bea1273731906e6d30881536897743d5c09/2022-05-25_11-06-54_1653502028.png?width=2400&optimize=medium&height=480&fit=cover&dpr=2.625",
        address: "3561 Whispymound Drive",
        salary: "$60/kurs",
        isAvailable: true
    },
    {
        id: "fisher",
        title: "Rybak",
        description: "Krótki opis.",
        category: {
            name: "physical",
            label: "Praca Fizyczna"
        },
        image: "https://preview.redd.it/4ujrtt4yr0f41.png?width=960&format=png&auto=webp&s=a5ba2d1b33bf153c25b9a2fc978e81093fac2352",
        address: "3561 Whispymound Drive",
        salary: "$90/kurs",
        isAvailable: false
    },
]

export const useJobOffers = () => {
    return useNuiData<JobOffer[] | null>("job-offers", process.env.NODE_ENV === "development" ? MOCK_DATA : null);
}