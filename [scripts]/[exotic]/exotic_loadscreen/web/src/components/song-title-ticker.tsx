import { useEffect, useRef, useState } from "react";

export function SongTitleTicker ({ title }: { title: string }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const textRef = useRef<HTMLSpanElement>(null);
  const [isOverflowing, setIsOverflowing] = useState(false);

  useEffect(() => {
    if (containerRef.current && textRef.current) {
      const containerWidth = containerRef.current.offsetWidth;
      const textWidth = textRef.current.scrollWidth;

      setIsOverflowing(textWidth > containerWidth);
    }
  }, [title]);

  return (
    <div
      ref={containerRef}
      className="ticker-container flex-1 overflow-hidden whitespace-nowrap relative"
    >
      <span
        ref={textRef}
        className={`inline-block ${isOverflowing ? "animate-ticker-scroll pl-full" : ""}`}
      >
        {title}
      </span>
    </div>
  );
}