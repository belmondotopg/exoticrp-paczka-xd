import type { LucideIcon } from "lucide-react";

import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

function IdentityInput ({
    className,
    icon: Icon,
    ...props
}: React.ComponentProps<typeof Input> & {
    icon: LucideIcon
}) {
    return (
        <div className="relative w-full">
            <Icon className="size-4 absolute left-4 top-1/2 left4 -translate-y-1/2 text-primary" />
            <input
                className={cn(
                    "border border-[hsla(0_0%_25%_/_0.5)] px-3 h-11 ps-9.5 rounded-lg !bg-[hsla(0_0%_0%_/_0.9)] w-full outline-none focus:border-2 focus:border-neutral-600 transition text-xs",
                    className
                )}
                {...props}
            />
        </div>
    )
}

export { IdentityInput };