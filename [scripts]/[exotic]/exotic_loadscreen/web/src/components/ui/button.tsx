import { cn } from "@/lib/utils";

function Button ({ className, ...props }: React.ComponentProps<"button">) {
    return (
        <button
            className={cn("px-6 py-3.5 rounded-[10px] flex items-center justify-center gap-x-2.5 bg-[hsla(0_0%_0%_/_0.4)] hover:bg-[hsla(0_0%_0%_/_0.6)] backdrop-blur-2xl transition [&_svg]:shrink-0 [&_svg]:size-4 disabled:opacity-50 disabled:pointer-events-none text-sm cursor-pointer shadow-md outline-none", className)}
            {...props}
        />
    )
}

export { Button }