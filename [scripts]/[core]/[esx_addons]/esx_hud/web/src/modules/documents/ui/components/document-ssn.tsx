import { cn } from "@/lib/utils";

interface Props {
    ssn: number;
    className?: string;
}

export const DocumentSsn = ({ ssn, className }: Props) => {
    return (
        <div className={cn("inline-flex text-center justify-center items-center px-2.5 py-0.5 bg-primary text-white font-bold text-[9px] rounded-[4px]", className)}>
            {ssn}
        </div>
    )
}