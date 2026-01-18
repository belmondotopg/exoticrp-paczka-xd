import * as React from "react"

import { cn } from "@/lib/utils"

function Textarea({ className, ...props }: React.ComponentProps<"textarea">) {
  return (
    <textarea
      data-slot="textarea"
      className={cn(
        "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-[hsla(0_0%_45%_/_0.5)] aria-invalid:ring-[hsla(357_100%_45%_/_0.2)] dark:aria-invalid:ring-[hsla(357_100%_45%_/_0.4)] aria-invalid:border-destructive dark:bg-30 flex field-sizing-content min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 md:text-sm dark:bg-neutral-800",
        className
      )}
      {...props}
    />
  )
}

export { Textarea }
