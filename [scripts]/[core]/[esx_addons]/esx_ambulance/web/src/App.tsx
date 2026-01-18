import { useEffect, useState } from "react";
import "./App.css";
import { fetchNui } from "@yankes/fivem-react/utils";

const App = () => {
    const [display, setDisplay] = useState(false);
    const [timer, setTimer] = useState(300);
    const [canCrawl, setCanCrawl] = useState(false);
    const [minutes, setMinutes] = useState<number[]>([0, 0]);
    const [seconds, setSeconds] = useState<number[]>([0, 0]);

    const handleMessageEvent = (e: MessageEvent) => {
        const data = e.data;
        switch (data.action) {
            case "setTimer":
                setTimer(data.value);
                break;
            case "setVisibleCrawling":
                setCanCrawl(data.crawling);
                break;
            case "close":
                setDisplay(false);
                break;
            case "open":
                setDisplay(true);
                break;
        }
    };

    useEffect(() => {
        window.addEventListener("message", handleMessageEvent);
        return () => window.removeEventListener("message", handleMessageEvent);
    }, []);

    useEffect(() => {
        const mins = Math.floor(timer / 60);
        const secs = timer % 60;
        setMinutes([Math.floor(mins / 10), mins % 10]);
        setSeconds([Math.floor(secs / 10), secs % 10]);
    }, [timer]);

    useEffect(() => {
        if (!display || timer !== 0) return;

        fetchNui("respawnPlayer", {})
    }, [display, timer]);

    return (
        <>
            {display && (
                <main>
                    <div className="wrapper">
                        <div className="heading">
                            <p>Jesteś w stanie</p>
                            <p>{canCrawl ? "POWALENIA" : "NIEPRZYTOMNOŚCI"}</p>
                        </div>
                        <div className="action-keys">
                            <div className="action-key-group">
                                <div>G</div>
                                <p>aby wezwać EMS</p>
                            </div>
                            {canCrawl && (
                                <div className="action-key-group">
                                    <div>J</div>
                                    <p>aby się czołgać</p>
                                </div>
                            )}
                            {timer === 0 && (
                                <div className="action-key-group">
                                    <div>E</div>
                                    <p>aby odrodzić się w szpitalu</p>
                                </div>
                            )}
                        </div>
                        {timer !== 0 && (
                            <div className="counter-group">
                                <p>Odrodzenie możliwe za</p>
                                <div className="counter">
                                    <span>
                                        {minutes.map((digit, idx) => (
                                            <p key={idx}>{digit}</p>
                                        ))}
                                    </span>
                                    <p>:</p>
                                    <span>
                                        {seconds.map((digit, idx) => (
                                            <p key={idx}>{digit}</p>
                                        ))}
                                    </span>
                                </div>
                            </div>
                        )}
                    </div>
                </main>
            )}
        </>
    );
};

export default App;