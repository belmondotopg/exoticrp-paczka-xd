import { useMemo } from "react";

import { formatText } from "@/modules/textui/lib/utils";
import type { FormattedText } from "@/modules/textui/types/formatted-text";

export const useFormattedText = (text: string | null) => useMemo<FormattedText[] | null>(() => text ? formatText(text) : null, [text]);