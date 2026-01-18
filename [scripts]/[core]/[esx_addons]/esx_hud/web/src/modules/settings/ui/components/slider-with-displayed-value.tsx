import { Slider } from "@/components/ui/slider";
import { cn } from "@/lib/utils";

type Props = React.ComponentProps<typeof Slider> & {
    value: number[];
    containerClassName?: string;
    textClassName?: string;
    formatValue?: (value: number) => string;
}

export const SliderWithDisplayedValue = ({
    containerClassName,
    textClassName,
    formatValue,
    ...props
}: Props) => {
    return (
        <div className={cn("flex items-center gap-2.5 w-full", containerClassName)}>
            <Slider {...props} />
            <span className={cn("font-semibold text-[10px]", textClassName)}>
                {formatValue ? formatValue(props.value[0]) : props.value[0]}
            </span>
        </div>
    )
}