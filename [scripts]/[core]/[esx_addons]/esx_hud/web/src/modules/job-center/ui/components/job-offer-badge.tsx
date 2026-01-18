import { cn } from "@/lib/utils"

function JobOfferBadge ({
    color = "0 0% 63%",
    className,
    style,
    ...props
}: React.ComponentProps<"span"> & {
    color?: string
}) {
    return (
        <span
            className={cn("text-[10px] font-medium px-1.5 py-[3px] rounded-[4px] shadow-xs inline-flex [&_svg]:size-2.5 [&_svg]:shrink-0 select-none text-center justify-center items-center gap-x-1", className)}
            style={{
                color: `hsl(${color})`,
                backgroundColor: `hsla(${color} / 0.15)`,
                ...style
            }}
            {...props}
        />
    )
}

export { JobOfferBadge }