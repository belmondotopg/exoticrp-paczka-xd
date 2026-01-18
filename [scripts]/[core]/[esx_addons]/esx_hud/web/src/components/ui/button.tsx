import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-1 whitespace-nowrap rounded-lg text-sm font-semibold transition-colors disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-[hsla(0_0%_45%_/_0.5)] focus-visible:ring-[3px] aria-invalid:ring-[hsla(357_100%_45%_/_0.2)] dark:aria-invalid:ring-[hsla(357_100%_45%_/_0.4)] aria-invalid:border-destructive cursor-pointer",
  {
    variants: {
      variant: {
        default: "bg-primary text-white hover:bg-[hsla(var(--primary-hsl)_/_0.9)] border-primary-darker border-b-[4px] active:border-b-0",
        secondary: "bg-neutral-500 text-white hover:bg-[hsla(0_0%_45%_/_0.9)] border-neutral-700 border-b-[4px] active:border-b-0",
        "secondary-two": "bg-[hsla(0_0%_15%_/_0.8)] text-white hover:bg-[hsla(0_0%_15%_/_0.9)] border-neutral-600 border-b-[4px] active:border-b-0",
        danger: "bg-rose-500 text-white hover:bg-[hsla(348_100%_56%_/_0.9)] border-rose-900 border-b-[4px] active:border-b-0",
        green: "bg-emerald-500 text-white hover:bg-[hsla(160_100%_37%_/_0.9)] border-emerald-900 border-b-[4px] active:border-b-0",
        ghost: "hover:bg-neutral-800 text-neutral-300 hover:text-foreground"
      },
      size: {
        default: "h-11 px-4 py-2 has-[>svg]:px-3",
        sm: "h-8 gap-1.5 px-3 has-[>svg]:px-2.5",
        lg: "h-12 px-6 has-[>svg]:px-4",
        icon: "size-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export type ButtonProps = React.ComponentProps<"button"> &
  VariantProps<typeof buttonVariants> & {
    asChild?: boolean
  }

function Button({
  className,
  variant,
  size,
  asChild = false,
  ...props
}: ButtonProps) {
  const Comp = asChild ? Slot : "button"

  return (
    <Comp
      data-slot="button"
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  )
}

export { Button, buttonVariants }