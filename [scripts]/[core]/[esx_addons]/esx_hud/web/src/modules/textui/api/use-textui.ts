import { useNuiData } from "@yankes/fivem-react/hooks";

export const useTextui = () => useNuiData<string | null>("textui", process.env.NODE_ENV === "development" ? "Kliknij ~E~ aby otworzyć bank" : null);