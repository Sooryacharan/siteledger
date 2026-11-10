import { forwardRef, type LabelHTMLAttributes } from "react";

import { cn } from "@/lib/cn";

const Label = forwardRef<HTMLLabelElement, LabelHTMLAttributes<HTMLLabelElement>>(
  ({ className, ...props }, ref) => (
    <label
      ref={ref}
      className={cn("text-sm font-medium text-[#1c1915]", className)}
      {...props}
    />
  ),
);
Label.displayName = "Label";

export { Label };
