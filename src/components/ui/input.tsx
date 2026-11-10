import { forwardRef, type InputHTMLAttributes } from "react";

import { cn } from "@/lib/cn";

const Input = forwardRef<HTMLInputElement, InputHTMLAttributes<HTMLInputElement>>(
  ({ className, type = "text", ...props }, ref) => (
    <input
      type={type}
      className={cn(
        "flex min-h-11 w-full rounded-xl border border-[#e2d8c6] bg-white px-3 py-2 text-base text-[#1c1915] outline-none ring-[#8a5a2a] placeholder:text-[#8a8176] focus:ring-2",
        className,
      )}
      ref={ref}
      {...props}
    />
  ),
);
Input.displayName = "Input";

export { Input };
