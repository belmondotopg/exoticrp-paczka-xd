import { useCallback, useEffect, useState } from "react"
import articles from "./constants/articles"
import { closeUI, cn, compareMediaFilePath, fetchArticle, isInGame } from "./lib/utils";
import { PageContent } from "./types/PageContent";
import { FaXmark } from "react-icons/fa6";
import Button from "./components/button";
import Tooltip from "./components/tooltip";

export default function App() {
    const [display, setDisplay] = useState(!isInGame());
    const [page, setPage] = useState(0);
    const [pageContent, setPageContent] = useState<PageContent | null>(null);
    const [titles, setTitles] = useState<string[]>([]);
    const [isTransitioning, setIsTransitioning] = useState(false);
    const [selectedImage, setSelectedImage] = useState<string | null>(null);

    useEffect(() => {
        if (!isInGame()) {
            return;
        }

        interface MessageData {
            eventName: "nui:switch";
            open: boolean;
        }

        const onMessage = ({ data }: MessageEvent<MessageData>) => {
            if (data.eventName !== "nui:switch") return;
            setDisplay(data.open);
        };

        window.addEventListener("message", onMessage);
        return () => window.removeEventListener("message", onMessage);
    }, []);

    useEffect(() => {
        if (display) {
            setPage(0);
        }
    }, [display]);

    useEffect(() => {
        const fetchTitles = async () => {
            const titlePromises = articles.map(article => 
                fetchArticle(article).then(({ title }) => title)
            );
            const fetchedTitles = await Promise.all(titlePromises);
            setTitles(fetchedTitles);
        };

        if (articles.length > 0) {
            fetchTitles();
        }
    }, []);

    useEffect(() => {
        if (!display) return;

        const article = articles[page];
        if (!article) {
            if (articles[0]) {
                setPage(0);
            }
            return;
        }

        setIsTransitioning(true);
        let cancelled = false;
        
        const timer = setTimeout(() => {
            fetchArticle(article).then((data) => {
                if (!cancelled) {
                    setPageContent(data);
                    setIsTransitioning(false);
                }
            });
        }, 150);

        return () => {
            cancelled = true;
            clearTimeout(timer);
        };
    }, [page, display]);

    const goPreviousPage = useCallback(() => {
        if (page > 0) {
            setPage(prev => prev - 1);
        }
    }, [page]);

    const goNextPage = useCallback(() => {
        if (page < articles.length - 1) {
            setPage(prev => prev + 1);
        }
    }, [page]);

    const handlePageChange = useCallback((newPage: number) => {
        setPage(newPage);
    }, []);

    const handleClose = useCallback(() => {
        closeUI();
    }, []);

    const handleFinish = useCallback(() => {
        closeUI();
    }, []);

    const handleImageClick = useCallback((src: string) => {
        setSelectedImage(src);
    }, []);

    const handleCloseImage = useCallback(() => {
        setSelectedImage(null);
    }, []);

    useEffect(() => {
        if (!selectedImage) return;

        const handleEscape = (e: KeyboardEvent) => {
            if (e.key === 'Escape') {
                handleCloseImage();
            }
        };

        window.addEventListener('keydown', handleEscape);
        return () => window.removeEventListener('keydown', handleEscape);
    }, [selectedImage, handleCloseImage]);

    if (!display || !pageContent) {
        return null;
    }

    const isLastPage = page === articles.length - 1;

    return (
        <div className="fixed inset-0 flex items-center justify-center p-4">
            <div className="w-full max-w-[900px] py-8 px-10 rounded-2xl bg-[#141414] text-white shadow-2xl border border-white/10 ui-fade-in">
                <header className="w-full flex justify-between items-center mb-6 animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
                    <div className="w-[100px]" />
                    <h1 
                        key={page}
                        className="font-sora text-3xl font-bold text-center text-white animate-fade-in-up"
                        style={{ animationDelay: '0.15s' }}
                    >
                        {pageContent.title}
                    </h1>
                    <div className="flex justify-end w-[100px]">
                        <button
                            onClick={handleClose}
                            className="h-10 aspect-square rounded-xl text-sm flex items-center justify-center bg-[#0E0E0E] hover:bg-[#141414] transition-all duration-200 ease-out border border-white/20 hover:border-white/30 hover:scale-110 active:scale-95"
                            aria-label="Zamknij"
                        >
                            <FaXmark className="transition-transform duration-200 ease-out" />
                        </button>
                    </div>
                </header>
                <div 
                    key={page}
                    className={cn(
                        "bg-[#0E0E0E]/50 rounded-xl p-6 border border-white/5 transition-opacity duration-200",
                        isTransitioning && "opacity-50"
                    )}
                >
                    <p
                        dangerouslySetInnerHTML={{ __html: pageContent.data }}
                        className="text-center text-sm text-white/90 leading-6 animate-fade-in-up"
                        style={{ animationDelay: '0.2s' }}
                    />
                </div>
                {pageContent.media && pageContent.media.length > 0 && (
                    <div 
                        className={cn(
                            "grid gap-4 mt-6",
                            pageContent.media.length === 1 && "grid-cols-1",
                            pageContent.media.length === 2 && "grid-cols-2",
                            pageContent.media.length >= 3 && "grid-cols-3"
                        )}
                    >
                        {pageContent.media.map((src, key) => (
                            <div
                                key={key}
                                onClick={() => handleImageClick(src)}
                                className="aspect-video bg-[#0E0E0E] rounded-xl overflow-hidden bg-cover bg-center bg-no-repeat transition-all duration-300 ease-out hover:scale-[1.02] hover:shadow-xl border border-white/10 shadow-lg hover:border-white/20 animate-fade-in-up cursor-pointer"
                                style={{ 
                                    backgroundImage: `url(${compareMediaFilePath(src)})`,
                                    animationDelay: `${0.25 + key * 0.08}s`
                                }}
                            />
                        ))}
                    </div>
                )}
                <div 
                    className="mt-10 w-full flex gap-6 justify-between items-center animate-fade-in-up"
                    style={{ animationDelay: '0.3s' }}
                >
                    <div className="w-44 flex">
                        <Button
                            onClick={goPreviousPage}
                            disabled={page === 0}
                        >
                            Wstecz
                        </Button>
                    </div>
                    <div className="flex gap-2">
                        {titles.map((title, key) => (
                            <Tooltip key={key} text={title}>
                                <button
                                    onClick={() => handlePageChange(key)}
                                    className={cn(
                                        "size-3 rounded-full transition-all duration-300 ease-out border hover:scale-125 active:scale-95",
                                        page === key 
                                            ? "bg-orange-500 border-orange-500 shadow-lg shadow-orange-500/50 scale-125" 
                                            : "border-white/30 hover:border-white/50 hover:bg-white/10"
                                    )}
                                    aria-label={title}
                                />
                            </Tooltip>
                        ))}
                    </div>
                    <div className="flex items-center gap-3 w-44 justify-end">
                        <Button onClick={handleClose}>
                            Pomiń
                        </Button>
                        <Button
                            variant="primary"
                            onClick={isLastPage ? handleFinish : goNextPage}
                        >
                            {isLastPage ? "Zakończ" : "Następne"}
                        </Button>
                    </div>
                </div>
            </div>
            {selectedImage && (
                <div 
                    className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 animate-fade-in"
                    onClick={handleCloseImage}
                >
                    <div 
                        className="w-[80vw] h-[80vh] rounded-lg animate-fade-in-scale flex items-center justify-center"
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className="relative inline-block max-w-full max-h-full">
                            <button
                                onClick={handleCloseImage}
                                className="absolute top-2 right-2 h-12 w-12 rounded-full bg-orange-500 hover:bg-orange-600 flex items-center justify-center text-white shadow-lg shadow-orange-500/50 transition-all duration-200 ease-out hover:scale-110 active:scale-95 z-10"
                                aria-label="Zamknij"
                            >
                                <FaXmark className="text-lg" />
                            </button>
                            <img
                                src={compareMediaFilePath(selectedImage)}
                                alt="Powiększone zdjęcie"
                                className="max-w-full max-h-full object-contain rounded-lg shadow-2xl"
                            />
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}