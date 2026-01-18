import { fetchNui } from "@yankes/fivem-react/utils";
import { MapPinIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";

import { JobOfferBadge } from "./job-offer-badge";
import type { JobOffer } from "../../types/job-offer";

export const JobOfferCard = ({
    id,
    title,
    description,
    category,
    image,
    address,
    salary,
    isAvailable
}: JobOffer) => {
    const onApply = () => {
        fetchNui("/job-offers:apply", { id });
    }

    const onSetWaypoint = () => {
        fetchNui("/job-offers:set-waypoint", { id });
    }

    return (
        <div
            className="flex flex-col justify-between rounded-2xl bg-[#1B1B1B] border border-[hsla(0_0%_25%_/_0.65)] shadow-md overflow-hidden w-[calc(25%_-_16px)]"
        >
            <div
                className={cn("min-h-[190px] flex-1 bg-cover relative bg-center after:absolute after:top-[1px] after:w-full after:h-full after:bg-linear-to-t after:from-[#1B1B1B]", !isAvailable && "saturate-0")}
                style={{
                    backgroundImage: `url(${image})`
                }}
            />
            <div className="p-5 flex flex-col gap-y-4.5">
                <div className="flex gap-1.5 flex-wrap">
                    <JobOfferBadge>
                        <MapPinIcon />
                        {address}
                    </JobOfferBadge>
                    <JobOfferBadge color="144 100% 39%">
                        {salary}
                    </JobOfferBadge>
                    <JobOfferBadge color="212 100% 66%">
                        {category.label}
                    </JobOfferBadge>
                    {!isAvailable && (
                        <JobOfferBadge color="359 100% 70%">
                            Niedostępne
                        </JobOfferBadge>
                    )}
                </div>
                <div className="flex flex-col gap-y-3.5">
                    <div className="flex flex-col gap-y-2">
                        <span className="text-base font-bold line-clamp-1">
                            {title}
                        </span>
                        <span className="text-xs font-medium text-muted-foreground line-clamp-2">
                            {description}
                        </span>
                    </div>
                    <div className="flex gap-x-1.5">
                        <Button className="text-xs" variant="secondary" size="sm" disabled={!isAvailable} onClick={onApply}>
                            Aplikuj
                        </Button>
                        <Button className="text-xs" variant="secondary" size="sm" onClick={onSetWaypoint}>
                            Ustaw Waypoint
                        </Button>
                    </div>
                </div>
            </div>
        </div>
    )
}