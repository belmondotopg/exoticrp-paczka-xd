import { cn } from "@/lib/utils";

const SIZE = 60;

interface CrosshairProps {
  length: number;
  thickness: number;
  gap: number;
  opacity: number;
  color: string;
  dotOnCenter: boolean;
  className?: string;
}

const Crosshair = ({ length, thickness, gap, opacity, color, dotOnCenter, className }: CrosshairProps) => {
  const center = SIZE / 2;

  return (
    <svg width={SIZE} height={SIZE} className={cn("block", className)}>
      <rect
        x={center - thickness / 2}
        y={center - gap - length}
        width={thickness}
        height={length}
        fill={color}
        opacity={opacity}
        className="shadow-xs"
      />

      <rect
        x={center - thickness / 2}
        y={center + gap}
        width={thickness}
        height={length}
        fill={color}
        opacity={opacity}
        className="shadow-xs"
      />

      <rect
        x={center - gap - length}
        y={center - thickness / 2}
        width={length}
        height={thickness}
        fill={color}
        opacity={opacity}
        className="shadow-xs"
      />

      <rect
        x={center + gap}
        y={center - thickness / 2}
        width={length}
        height={thickness}
        fill={color}
        opacity={opacity}
        className="shadow-xs"
      />

      {dotOnCenter && (
        <circle
          cx={center}
          cy={center}
          r={thickness * 0.65}
          fill={color}
          opacity={opacity}
          className="shadow-xs"
        />
      )}
    </svg>
  );
};

export default Crosshair;