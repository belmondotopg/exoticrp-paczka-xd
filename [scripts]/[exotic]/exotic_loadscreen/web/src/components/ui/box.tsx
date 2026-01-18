import { cn } from "@/lib/utils";

function Box ({ className, ...props }: React.ComponentProps<"div">) {
    return (
        <div
            className={cn("px-4 py-3 rounded-[10px] flex items-center justify-center gap-x-2.5 bg-[hsla(0_0%_0%_/_0.4)] backdrop-blur-2xl [&_svg]:shrink-0 [&_svg]:size-4 text-sm shadow-md", className)}
            {...props}
        />
    )
}

export { Box }