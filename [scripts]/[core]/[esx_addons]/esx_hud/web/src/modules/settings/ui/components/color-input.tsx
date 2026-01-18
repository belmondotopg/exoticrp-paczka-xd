import { CheckIcon } from "lucide-react";
import { useEffect, useState } from "react";

function ColorInput ({ value, onValueChange, className, ...props }: React.ComponentProps<"input"> & {
    value: string;
    onValueChange: (value: string) => void;
}) {
    const [currentValue, setCurrentValue] = useState(value);
    useEffect(() => setCurrentValue(value), [value]);

    const onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setCurrentValue(e.target.value);
    }

    const canSubmit = value !== currentValue;

    const onSubmit = () => {
        onValueChange(currentValue);
    }

    return (
        <div className="flex items-center gap-x-2.5">
            <div className="w-8 h-4 rounded-[4px]" style={{ backgroundColor: currentValue }}>
                <input
                    type="color"
                    value={currentValue}
                    onChange={onChange}
                    className="w-full h-full rounded-[4px] cursor-pointer opacity-0"
                    {...props}
                />
            </div>
            {canSubmit && (
                <button className="text-muted-foreground hover:text-foreground transition outline-none focus-visible:text-foreground" onClick={onSubmit}>
                    <CheckIcon className="size-4 shrink-0" />
                </button>
            )}
        </div>
    )
}

export { ColorInput }