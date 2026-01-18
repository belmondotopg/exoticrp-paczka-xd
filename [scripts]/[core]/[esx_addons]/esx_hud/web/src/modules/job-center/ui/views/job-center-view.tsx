import { useEffect, useMemo, useState } from "react";
import { useDebounce } from "use-debounce";
import { useVisible } from "@yankes/fivem-react/hooks";
import { SearchIcon, XIcon } from "lucide-react";

import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

import { useJobOffers } from "../../api/use-job-offers";
import { JobOfferCard } from "../components/job-offer-card";

export const JobCenterView = () => {
    const { visible, close: onClose } = useVisible("job-center", false);

    const jobOffers = useJobOffers();
  
    const [searchValue, setSearchValue] = useState("");
    const [debouncedSearch] = useDebounce(searchValue, 500);

    const [category, setCategory] = useState("all");

    const searchedData = useMemo(() => {
        if (!jobOffers) return [];

        const filteredData = jobOffers.filter((item) => {
            const searchValue = debouncedSearch.toLowerCase();
            const title = item.title.toLowerCase();

            const isTitleCompare = title.includes(searchValue) || searchValue.includes(title);
            
            if (category !== "all") return isTitleCompare && item.category.name === category;

            return isTitleCompare;
        });

        return filteredData;
    }, [jobOffers, debouncedSearch, category]);

    const allCategories = useMemo(() => {
        if (!jobOffers) return [];

        const allCategories = jobOffers.map((item) => item.category);

        const categoriesNames = Array.from(new Set(allCategories.map((item) => item.name)));
        const uniqueCategories = categoriesNames.map((name) => {
            const category = allCategories.find((item) => item.name === name);

            if (!category) return null;

            return {
                name: category.name,
                label: category.label
            }

        }).filter((item) => item !== null) as { name: string; label: string }[];
        
        return uniqueCategories;
    }, [jobOffers]);

    useEffect(() => {
        const onKeyDown = (e: KeyboardEvent) => {
            if (e.key === "Escape") onClose();
        }

        window.addEventListener("keydown", onKeyDown);

        return () => window.removeEventListener("keydown", onKeyDown);
    }, []);

    return visible && (
        <>
            <div
                className="fixed w-screen h-screen top-0 left-0 z-50 bg-[hsla(0_0%_0%_/_0.6)]"
                onClick={onClose}
            />
            <div className="fixed w-[1350px] h-[809px] top-1/2 left-1/2 -translate-1/2 p-10 rounded-4xl border border-neutral-700 shadow-xl z-[51] flex flex-col gap-y-8 bg-neutral-900 overflow-y-auto">
                <button className="text-muted-foreground hover:text-foreground transition absolute top-10 right-10 cursor-pointer" onClick={onClose}>
                    <XIcon className="shrink-0 size-4" />
                </button>
                <div className="w-full flex items-center gap-x-3.5">
                    <img
                        src="logo.webp"
                        alt="Exotic RolePlay"
                        className="h-16"
                    />
                    <div className="flex-1 flex flex-col gap-y-2">
                        <span className="text-xl font-bold">Urząd Pracy</span>
                        <span className="text-sm font-medium text-muted-foreground">Znajdz Twoją pracę marzeń!</span>
                    </div>
                </div>
                <div className="flex gap-x-3">
                    <div className="relative">
                        <SearchIcon className="size-4 absolute top-1/2 left-3 -translate-y-1/2 text-muted-foreground" />
                        <Input
                            value={searchValue}
                            onChange={(e) => setSearchValue(e.currentTarget.value)}
                            placeholder="Wyszukaj..."
                            className="w-[350px] ps-8"
                        />
                    </div>
                    <Select
                        value={category}
                        onValueChange={setCategory}
                    >
                        <SelectTrigger className="w-52 bg-neutral-800">
                            <SelectValue placeholder="Kategoria..." />
                        </SelectTrigger>
                        <SelectContent className="w-52">
                            <SelectItem value="all">
                                Wszystkie
                            </SelectItem>
                            {allCategories.map((category) => (
                                <SelectItem
                                    key={category.name}
                                    value={category.name}
                                >
                                    {category.label}
                                </SelectItem>
                            ))}
                        </SelectContent>
                    </Select>
                </div>
                <div className="w-full flex flex-wrap gap-4 overflow-y-auto">
                    {searchedData.map((item) => (
                        <JobOfferCard
                            key={item.id}
                            {...item}
                        />
                    ))}
                </div>
            </div>
        </>
    )
}