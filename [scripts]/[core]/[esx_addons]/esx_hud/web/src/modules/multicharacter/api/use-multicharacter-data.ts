import { useEffect, useMemo } from "react";
import { useNuiData } from "@yankes/fivem-react/hooks";
import type { MulticharacterData } from "../types";

const isValidMulticharacterData = (data: any): data is MulticharacterData => {
  return (
    data !== null &&
    data !== undefined &&
    typeof data === "object" &&
    Array.isArray(data.characters) &&
    typeof data.maxSlots === "number" &&
    data.maxSlots > 0
  );
};

export const useMulticharacterData = () => {
  const rawData = useNuiData<MulticharacterData | null>("multicharacter-data", null);

  const data = useMemo(() => {
    if (!rawData) {
      return null;
    }
    
    if (isValidMulticharacterData(rawData)) {
      return rawData;
    }
    
    return null;
  }, [rawData]);

  useEffect(() => {
    if (data && isValidMulticharacterData(data)) {
      fetch(`https://${GetParentResourceName()}/multicharacter/dataReceived`, {
        method: "POST"
      }).catch(() => {});
    }
  }, [data]);

  return data;
};
