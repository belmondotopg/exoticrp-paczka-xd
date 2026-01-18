import { cn } from "../utils/cn";

export default function Button({
    onClick,
    children,
    className,
}: {
    onClick?: () => void;
    children: React.ReactNode | React.ReactNode[];
    className?: string;
}) {
    return (
        <>
            <button
                onClick={onClick}
                className={cn(
                    "bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white font-semibold p-3 rounded-full border border-orange-400 cursor-pointer shadow-lg transition-colors duration-200",
                    className
                )}
            >
                {children}
            </button>
        </>
    );
}
