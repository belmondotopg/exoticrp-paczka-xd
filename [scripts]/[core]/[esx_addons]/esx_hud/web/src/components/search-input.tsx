import { SearchIcon } from "lucide-react";

import { cn } from "@/lib/utils";
import { Input } from "./ui/input";

function SearchInput ({ className, ...props }: React.ComponentProps<typeof Input>) {
    return (
        <div className="relative h-10">
            <Input
                placeholder="Wyszukaj..."
                className={cn("ps-8 w-[350px] h-full", className)}
                {...props}
            />
            <SearchIcon className="text-muted-foreground size-4 shrink-0 absolute left-3 top-1/2 -translate-y-1/2" />
        </div>
    )
}

export { SearchInput }