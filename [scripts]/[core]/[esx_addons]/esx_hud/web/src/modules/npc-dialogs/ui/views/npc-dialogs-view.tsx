import { useCallback, useEffect, useMemo, useState } from "react";
import { UserIcon, XIcon } from "lucide-react";

import { Button } from "@/components/ui/button";
import { useNPCDialogs } from "@/modules/npc-dialogs/api/use-npc-dialogs";
import { useVisible } from "@yankes/fivem-react/hooks";

export const NPCDialogsView = () => {
    const { visible } = useVisible("npc-dialogs", false)

    const {
        data,
        answers,
        setAnswerValue,
        closeDialpg,
        submitDialog
    } = useNPCDialogs();

    const [pageIndex, setPageIndex] = useState(0);
    const [selectedValue, setSelectedValue] = useState<string | null>(null);

    const currentPage = useMemo(() => {
        return data?.pages?.[pageIndex];
    }, [data?.pages, pageIndex]);

    // Ustaw wartość wybranej odpowiedzi gdy zmienia się strona
    useEffect(() => {
        if (currentPage) {
            setSelectedValue(answers?.[currentPage.name] ?? null);
        }
    }, [currentPage, answers]);

    useEffect(() => {
        setPageIndex(0);
    }, [data?.pages]);

    const hasPreviousPage = useMemo(() => pageIndex > 0, [pageIndex]);
    const hasNextPage = useMemo(() => pageIndex < (data?.pages?.length ?? 0) - 1, [pageIndex, data?.pages?.length]);

    const goPreviousPage = useCallback(() => {
        if (!hasPreviousPage) return;

        setPageIndex(prev => prev - 1);
    }, [hasPreviousPage]);

    const goNextPage = useCallback(() => {
        if (!hasNextPage || !selectedValue || !currentPage) return;
        setAnswerValue(currentPage.name, selectedValue);

        setPageIndex(prev => prev + 1);
    }, [hasNextPage, selectedValue, currentPage, setAnswerValue]);

    useEffect(() => {
        const closeOnEscape = (e: KeyboardEvent) => {
            if (e.key === "Escape") {
                closeDialpg();
            }
        };

        document.addEventListener("keydown", closeOnEscape);

        return () => {
            document.removeEventListener("keydown", closeOnEscape);
        };
    }, [closeDialpg]);

    if (!visible || !data) return null;

    return (
        <div
            className="w-screen h-screen fixed z-50 top-0 left-0 p-20 flex flex-col justify-between items-end gap-y-4"
            style={{
                backgroundImage: "radial-gradient(transparent, hsla(0 0% 0% / .7)), linear-gradient(to top, hsla(var(--primary-hsl) / .125), transparent)"
            }}
        >
            <Button
                variant="secondary-two"
                size="icon"
                onClick={closeDialpg}
            >
                <XIcon />
            </Button>
            <div className="w-full flex flex-col gap-y-8">
                <div className="w-full px-8 py-7 flex items-center gap-x-1 rounded-xl bg-[hsla(0_0%_9%_/_0.9)] shadow text-lg font-semibold">
                    <span className="inline-flex items-center gap-x-2 text-primary font-bold">
                        <UserIcon className="size-6" />
                        {currentPage?.question.userName + ":"}
                    </span>
                    <span>{currentPage?.question.text}</span>
                </div>
                <div className="w-full grid grid-cols-2 gap-3.5">
                    {currentPage?.buttons.map((button) => (
                        <Button
                            key={`${currentPage.name}-${button.value}`}
                            variant={selectedValue === button.value ? "default" : "secondary-two"}
                            className="px-7 py-9 rounded-lg font-semibold text-base text-start justify-start whitespace-normal break-words"
                            onClick={() => {
                                setAnswerValue(currentPage.name, button.value);
                                setSelectedValue(button.value);
                            }}
                        >
                            {button.label}
                        </Button>
                    ))}
                </div>
                <div className="w-full flex items-center justify-between gap-x-3.5">
                    <Button variant="secondary" disabled={!hasPreviousPage} onClick={goPreviousPage}>
                        Poprzednia Strona
                    </Button>
                    {hasNextPage ? (
                        <Button variant="default" disabled={!selectedValue} onClick={goNextPage}>
                            Następna Strona
                        </Button>
                    ) : (
                        <Button disabled={!selectedValue} onClick={submitDialog}>
                            Zakończ
                        </Button>
                    )}
                </div>
                {data.showProgress && (
                    <div className="h-2 rounded-full bg-[hsla(0_0%_9%_/_0.5)] overflow-hidden">
                        <div
                            className="h-full rounded-full bg-primary transition duration-300 w-full origin-left"
                            style={{
                                transform: `scaleX(${((pageIndex) / data.pages!.length) * 100}%)`
                            }}
                        />
                    </div>
                )}
            </div>
        </div>
    )
}