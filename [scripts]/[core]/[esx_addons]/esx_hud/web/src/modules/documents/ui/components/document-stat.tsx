interface Props {
    label: string;
    children: React.ReactNode;
}

export const DocumentStat = ({ label, children }: Props) => {
    return (
        <div className="w-full flex flex-col gap-y-1.5">
            <span className="font-semibold text-xs">{label}</span>
            <span className="font-bold text-xs text-primary">
                {children}
            </span>
        </div>
    )
}