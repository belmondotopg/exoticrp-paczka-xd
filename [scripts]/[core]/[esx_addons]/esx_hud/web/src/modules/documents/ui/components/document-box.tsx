import { Box } from "@/components/box";
import { cn } from "@/lib/utils";

type Props = React.ComponentProps<typeof Box> & {
    visible: boolean;
}

function DocumentBox ({ className, visible, ...props }: Props) {
    return (
        <Box
            className={cn(
                "fixed top-1/2 -translate-y-1/2 left-10 px-5 pt-4.5 pb-3 rounded-[10px] w-[380px] transition-opacity duration-300",
                !visible && "scale-0 opacity-0 pointer-events-none",
                className
            )}
            {...props}
        />
    )
}

export { DocumentBox }