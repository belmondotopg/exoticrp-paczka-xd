import { useEffect, useState, useTransition } from "react";
import { CheckIcon, KeyboardIcon, Loader2Icon } from "lucide-react";
import YouTube, { type YouTubeEvent } from "react-youtube";

import { cn, openUrl } from "@/lib/utils";
import { getVideoData, extractVideoIdFromYouTubeUrl } from "@/lib/youtube";
import { Background } from "@/components/background";
import { Button } from "@/components/ui/button";
import { Box } from "@/components/ui/box";
import { Slider } from "@/components/ui/slider";

import { Input } from "./components/ui/input";
import { useLoadingFraction } from "./hooks/use-loading-fraction";
import { DEFAULT_SONG_URLS, KEYBOARD_DATA } from "./constants";
import toast, { Toaster } from "react-hot-toast";
import { SongTitleTicker } from "./components/song-title-ticker";
import { Keyboard } from "./components/keyboard";

function getVolume () {
    const volume = localStorage.getItem("volume") ?? "75";
    try {
        return parseInt(volume);
    } catch {
        return 75;
    }
}

type CurrentSong = {
    id: string;
    url: string;
    title: string;
}

export const App = () => {
    const [isKeyboardOpen, setIsKeyboardOpen] = useState(false);

    const [volume, setVolume] = useState(getVolume());
    const loadingFraction = useLoadingFraction();

    const [url, setUrl] = useState("");
    const [currentSong, setCurrentSong] = useState<CurrentSong | null>(null);
    const [isPending, startTransition] = useTransition();
    const [player, setPlayer] = useState<YT.Player | null>(null);
    
    const playSong = (url: string) => {
        const id = extractVideoIdFromYouTubeUrl(url);
        if (!id) {
            toast.error("Podany link jest nieprawidłowy");
            return;
        }

        startTransition(async () => {
            const { data, error } = await getVideoData(id);

            if (error || !data) {
                toast.error(error ?? "Coś poszło nie tak");
                return;
            }

            if (!data.embeddable || data.privacyStatus !== "public") {
                toast.error("Wideo jest prywatne lub nie jest dostepne");
            }

            setCurrentSong({ id, title: data.title, url });
            toast.success("Wideo zostało odnalezione, za parę chwil pisoneka się odtworzy!");
        });
    }

    const handleVolumeChange = (value: number[]) => {
        setVolume(value[0]);
        localStorage.setItem("volume", value[0].toString());
    };

    const onSubmit = () => {
        if (!url) return;

        playSong(url);
        setUrl("");

        localStorage.setItem("lastUrl", url);
    }

    const onPlayerReady = (event: YouTubeEvent<YT.Player>) => {
        const player = event.target;
        setPlayer(player);
        player.setVolume(volume);
        player.pauseVideo();
    };

    const onPlayerStateChange = (event: YouTubeEvent) => {
        const player = event.target;
        player.playVideo();
    }

    const backToDefaultPlaylist = () => {
        const url = DEFAULT_SONG_URLS[Math.floor(Math.random() * DEFAULT_SONG_URLS.length)];;
        playSong(url);

        localStorage.removeItem("lastUrl");
    }

    useEffect(() => {
        const url = localStorage.getItem("lastUrl") ?? DEFAULT_SONG_URLS[Math.floor(Math.random() * DEFAULT_SONG_URLS.length)];
        
        if (process.env.NODE_ENV === "development") {
            const onKeyDown = (e: KeyboardEvent) => {
                if (e.key === "Enter") {
                    playSong(url);
                }
            }

            window.addEventListener("keydown", onKeyDown);

            return () => window.removeEventListener("keydown", onKeyDown);
        }

        playSong(url);
    }, []);

    useEffect(() => {
        if (player && typeof player.setVolume === "function") {
            try {
                player.setVolume(volume);
            } catch {}
        }
    }, [volume, player, currentSong]);

    return (
        <>
            <Toaster
                position="top-center"
                reverseOrder={false}
            />
            <Background />
            <Keyboard data={KEYBOARD_DATA} isOpen={isKeyboardOpen} onOpenChange={setIsKeyboardOpen} />
            <img
                src="logo.webp"
                alt=""
                className="fixed top-1/2 left-1/2 -translate-1/2 w-[200px] z-10 anim-pulse"
                style={{ imageRendering: '-webkit-optimize-contrast' as any }}
            />
            <Button className="fixed top-15 left-15 z-10 w-[324px] justify-start" onClick={() => setIsKeyboardOpen(true)}>
                <KeyboardIcon />
                Klawiszologia
            </Button>
            <div className="fixed bottom-15 left-15 flex gap-x-3 z-10">
                <Button className="size-11 p-0" onClick={() => openUrl("https://indrop.eu/s/exoticrp")}>
                    <img
                        src="indrop.svg"
                        alt=""
                        className="size-4"
                    />
                </Button>
                <Button className="size-11 p-0" onClick={() => openUrl("https://discord.gg/exoticrp")}>
                    <img
                        src="discord.svg"
                        alt=""
                        className="size-4"
                    />
                </Button>
            </div>
            <Box className="fixed bottom-15 right-15 z-10 font-bold">
                <Loader2Icon className="animate-spin" />
                {loadingFraction.toFixed(0)}%
            </Box>
            <div className={cn("w-[300px] flex flex-col gap-y-2 z-10 fixed bottom-15 left-1/2 -translate-x-1/2 transition", (!currentSong && !isPending) && "opacity-0 pointer-events-none")}>
                <Box className="font-semibold">
                    <div className="flex items-center gap-x-0.5">
                        <div className="playing-animation-bar" />
                        <div className="playing-animation-bar" />
                        <div className="playing-animation-bar" />
                    </div>
                    {isPending && <Loader2Icon className="size-4 shrink-0 animate-spin" />}
                    
                    <SongTitleTicker title={currentSong?.title ?? ""} />
                </Box>
                <Box>
                    <Slider
                        defaultValue={[volume]}
                        onValueChange={handleVolumeChange}
                        min={0}
                        max={100}
                        disabled={isPending}
                    />
                </Box>
            </div>
            <div className="w-[324px] flex flex-col gap-y-2.5 fixed top-15 right-15 z-10">
                <div className="w-full relative">
                    <img
                        src="youtube.svg"
                        alt=""
                        className="size-5 absolute top-1/2 left-4.5 -translate-y-1/2 z-10"
                    />
                    <Input
                        placeholder="Podaj link do piosenki z YouTube..."
                        disabled={isPending}
                        className="w-full ps-12 pe-10 disabled:opacity-50 disabled:pointer-events-none"
                        value={url}
                        onChange={(e) => setUrl(e.target.value)}
                    />
                    {url && (
                        <button
                            onClick={onSubmit}
                            type="button"
                            className="absolute top-1/2 right-4 -translate-y-1/2 text-muted-foreground hover:text-foreground cursor-pointer transition disabled:opacity-50 disabled:pointer-events-none"
                            disabled={isPending}
                        >
                            <CheckIcon className="size-4 shrink-0" />
                        </button>
                    )}
                </div>
                {currentSong && !DEFAULT_SONG_URLS.includes(currentSong.url) && (
                    <Button className="w-full" onClick={backToDefaultPlaylist}>
                        Wróć Do Domyślnej Playlisty
                    </Button>
                )}
            </div>

            {currentSong && (
                <YouTube
                    videoId={currentSong.id}
                    opts={{
                        height: "0",
                        width: "0",
                        playerVars: {
                            autoplay: 1,
                            loop: 1,
                            playlist: currentSong.id
                        }
                    }}
                    onReady={onPlayerReady}
                    onStateChange={onPlayerStateChange}
                    className="fixed z-10"
                />
            )}
        </>
    )
}