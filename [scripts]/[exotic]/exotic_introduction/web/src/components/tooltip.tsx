import { memo } from 'react';
import { cn } from '../lib/utils';

interface TooltipProps {
  children: React.ReactNode;
  text: string;
}

const Tooltip = memo<TooltipProps>(({
    children,
    text
}) => {
  return (
    <div className="relative group">
        {children}
        <div
            className={cn(
                "text-xs bg-[#0E0E0E] border border-white/20 p-2 rounded-lg absolute left-1/2 -translate-x-1/2 bottom-full mb-2 text-center w-32",
                "transition-all duration-200 ease-out opacity-0 scale-95 translate-y-2",
                "group-hover:opacity-100 group-hover:scale-100 group-hover:translate-y-0",
                "pointer-events-none shadow-lg z-50"
            )}
        >
            {text}
        </div>
    </div>
  );
});

Tooltip.displayName = 'Tooltip';

export default Tooltip;