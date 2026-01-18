interface Props {
    label: string;
    children: React.ReactNode;
}

export const SettingField = ({ label, children }: Props) => {
    return (
        <div className="flex items-center justify-between gap-x-4">
            <span className="text-base font-medium shrink-0" dangerouslySetInnerHTML={{ __html: label }} />
            {children}
        </div>
    )
}