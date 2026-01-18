import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "inline-flex text-center items-center justify-center gap-x-1 whitespace-nowrap overflow-hidden transition font-semibold [&_svg]:size-4 [&_svg]:shrink-0 transition",
  {
    variants: {
      variant: {
        default: "bg-[hsla(var(--primary-hsl)_/_0.35)] shadow-xs",
        muted: "bg-neutral-600 text-neutral-200 shadow-xs"
      },
      size: {
        default: "text-xs px-2.5 py-1.5 rounded-[8px]",
        sm: "text-[8px] px-1.5 py-1 rounded-[4px]",
      }
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

function Badge({
  className,
  variant,
  size,
  asChild = false,
  ...props
}: React.ComponentProps<"span"> &
  VariantProps<typeof badgeVariants> & { asChild?: boolean }) {
  const Comp = asChild ? Slot : "span"

  return (
    <Comp
      data-slot="badge"
      className={cn(badgeVariants({ variant, size }), className)}
      {...props}
    />
  )
}

export { Badge, badgeVariants }
