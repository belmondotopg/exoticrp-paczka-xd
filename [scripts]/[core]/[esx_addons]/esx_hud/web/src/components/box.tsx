import { cn } from "@/lib/utils"

function Box ({
    className,
    style,
    ...props
}: React.ComponentProps<"div">) {
    return (
        <div
            className={cn("bg-[hsla(0_0%_9%_/_0.9)] border-2 border-neutral-600 rounded-xl shadow", className)}
            style={{
                backgroundImage: "linear-gradient(to top, hsla(var(--primary-hsl) / 0.075), transparent)",
                ...style
            }}
            {...props}
        />
    )
}

export { Box }