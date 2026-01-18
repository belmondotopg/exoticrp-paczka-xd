import { cn } from "@/lib/utils";

function Input ({ className, ...props }: React.ComponentProps<"input">) {
    return (
        <input
            className={cn("px-6 py-3.5 rounded-[10px] bg-[hsla(0_0%_0%_/_0.4)] backdrop-blur-2xl outline-none text-sm placeholder:text-muted-foreground focus-visible:ring-4 focus-visible:ring-neutral-600/50 transition", className)}
            {...props}
        />
    )
}

export { Input }