import { FaLocationArrow } from "react-icons/fa6";
import { useEffect, useRef, useState } from "react";

interface DirectionDisplayProps {
    direction: string;
    roadName: string;
    rotation: number;
    visible: boolean;
}

const ICON_OFFSET = -45;

function shortestAngleDiff(from: number, to: number): number {
    return ((to - from + 540) % 360) - 180;
}

function smoothAngle(current: number, target: number, speed = 0.18): number {
    return current + shortestAngleDiff(current, target) * speed;
}

const DirectionDisplay = ({ direction, roadName, rotation, visible }: DirectionDisplayProps) => {
    const [smoothRotation, setSmoothRotation] = useState(rotation);
    const frame = useRef<number | null>(null);

    useEffect(() => {
        const animate = () => {
            setSmoothRotation(prev =>
                smoothAngle(prev, rotation)
            );
            frame.current = requestAnimationFrame(animate);
        };

        frame.current = requestAnimationFrame(animate);
        return () => {
            if (frame.current) cancelAnimationFrame(frame.current);
        };
    }, [rotation]);

    if (!visible) return null;

    return (
        <div className="absolute bottom-[2.2vh] left-[16.4vw] flex gap-[0.6vw]">
            <div className="w-[0.1vw] self-stretch bg-primary/95 rounded-full" />

            <div className="flex flex-col gap-[0.8vh] justify-between">
                <span className="flex items-center gap-[0.4vw] text-[0.75vw] font-bold text-neutral-200">
                    <FaLocationArrow
                        style={{
                            transform: `rotate(${smoothRotation + ICON_OFFSET}deg)`,
                        }}
                        className="text-primary"
                    />
                    <p>{direction}</p>
                </span>

                <div className="flex items-center bg-[hsla(0_0%_15%_/_0.8)] border border-neutral-700 shadow-sm px-[0.4vw] py-[0.6vh] rounded-[0.2vw] w-fit">
                    <p className="text-bold text-neutral-100 text-[0.8vw]">
                        {roadName}
                    </p>
                </div>
            </div>
        </div>
    );
};

export default DirectionDisplay;
