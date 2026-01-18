import { useEffect, useState } from "react";
import { BACKGROUND_IMAGES } from "@/constants";

const INTERVAL_DURATION = 15000;
const ANIMATION_DURATION = 400;

export const Background = () => {
    const [index, setIndex] = useState(() => Math.floor(Math.random() * BACKGROUND_IMAGES.length));
    const [animating, setAnimating] = useState(false);

    useEffect(() => {
        const interval = setInterval(() => {
            setAnimating(true);
            setTimeout(() => {
                setIndex((prev) => (prev + 1) % BACKGROUND_IMAGES.length);
                setAnimating(false);
            }, ANIMATION_DURATION);
        }, INTERVAL_DURATION);

        return () => clearInterval(interval);
    }, []);

    const currentImage = BACKGROUND_IMAGES[index];
    const nextImage = BACKGROUND_IMAGES[(index + 1) % BACKGROUND_IMAGES.length];

    return (
        <>
            <div
                className="w-screen h-screen fixed z-0 top-0 left-0 bg-cover bg-center transition-opacity duration-300"
                style={{
                    backgroundImage: `
                        linear-gradient(hsla(0 0% 0% / 0.5), hsla(0 0% 0% / 0.5)),
                        linear-gradient(to bottom, hsla(var(--primary-hsl) / 0.35), transparent),
                        url(${currentImage})
                    `
                }}
            />
            
            {animating && (
                <div
                    className="w-screen h-screen fixed z-[1] top-0 left-0 bg-cover bg-center animate-next-image"
                    style={{
                        backgroundImage: `
                            linear-gradient(hsla(0 0% 0% / 0.4), hsla(0 0% 0% / 0.4)),
                            linear-gradient(to bottom, hsla(var(--primary-hsl) / 0.2), transparent),
                            url(${nextImage})
                        `,
                        animationDuration: `${ANIMATION_DURATION}ms`
                    }}
                />
            )}

            <div
                className="w-screen h-screen fixed z-[2] top-0 left-0 backdrop-blur-[24px]"
                style={{
                    mask: "linear-gradient(to top, hsla(0 0% 0% / 0.8), transparent)"
                }}
            />
        </>
    );
};