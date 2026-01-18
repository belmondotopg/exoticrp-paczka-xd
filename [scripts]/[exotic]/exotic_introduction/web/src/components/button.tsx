import { forwardRef, memo } from "react";
import { cn } from "../lib/utils";

interface Props extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: "primary" | "secondary";
}

const Button = memo(forwardRef<HTMLButtonElement, Props>(({
    children,
    className,
    variant,
    ...props
}, ref) => (
    <button
        ref={ref}
        className={cn(
            "px-6 py-3 rounded-lg text-sm font-medium transition-all duration-200 ease-out cursor-pointer disabled:pointer-events-none disabled:opacity-50 active:scale-95",
            variant === "primary" 
                ? "bg-orange-500 hover:bg-orange-600 text-white shadow-lg shadow-orange-500/20 hover:shadow-orange-500/40 hover:scale-105 hover:-translate-y-0.5" 
                : "bg-[#0E0E0E] hover:bg-[#141414] text-white border border-white/10 hover:border-white/20 hover:scale-105",
            className
        )}
        {...props}
    >
        {children}
    </button>
)));

Button.displayName = 'Button';

export default Button;