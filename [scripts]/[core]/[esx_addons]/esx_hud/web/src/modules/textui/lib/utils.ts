import type { FormattedText } from "@/modules/textui/types/formatted-text";

export function formatText(input: string, regex = /~([^~]+)~/g): FormattedText[] {
    const result: FormattedText[] = [];
    let lastIndex = 0;
    let match;
  
    while ((match = regex.exec(input)) !== null) {
      if (match.index > lastIndex) {
        result.push({ type: "text", value: input.slice(lastIndex, match.index) });
      }
  
      result.push({ type: "badge", value: match[1] });
  
      lastIndex = regex.lastIndex;
    }
  
    if (lastIndex < input.length) {
      result.push({ type: "text", value: input.slice(lastIndex) });
    }
  
    return result;
}