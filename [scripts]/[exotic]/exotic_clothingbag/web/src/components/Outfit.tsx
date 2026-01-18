import { useEffect, useState } from "react";
import type OutfitType from "../types/outfit";
import Button from "./Button";
import { Footprints, Laugh, PersonStanding, Shirt, Trash } from "lucide-react";
import { AnimatePresence, motion } from "motion/react";
import { fetchNui } from "../utils/fetchNui";

export default function Outfit({
    outfit,
    expandedOutfit,
    setExpanded,
    onDeleteOutfit,
}: {
    outfit: OutfitType;
    expandedOutfit: number | null;
    setExpanded: (id: number | null) => void;
    onDeleteOutfit: (status: boolean) => void;
}) {
    const [isExpanded, setIsExpanded] = useState<boolean>(false);

    useEffect(() => {
        setIsExpanded(expandedOutfit === outfit.id);
    }, [expandedOutfit]);

    const handleDressUpOutfit = (variant: "all" | "top" | "mid" | "low") => {
        fetchNui("dressUp", {
            id: outfit.id,
            variant: variant,
        });
    };

    return (
        <>
            <div className="w-full flex flex-col justify-center items-center">
                <div
                    data-expanded={isExpanded}
                    className="w-full flex items-center gap-2 p-4 bg-gradient-to-r from-gray-800 to-gray-700 rounded-md cursor-pointer transition-all hover:opacity-90 data-[expanded=true]:rounded-b-none"
                    onClick={() =>
                        setExpanded(
                            expandedOutfit === outfit.id ? null : outfit.id
                        )
                    }
                >
                    <div className="w-8 h-8 bg-orange-400 rounded-full flex items-center justify-center text-black font-bold text-sm">
                        {outfit.sex}
                    </div>
                    <span className="text-white font-medium group-hover:text-orange-400 transition-colors">
                        {outfit.label}
                    </span>
                </div>
                <AnimatePresence>
                    {isExpanded && (
                        <motion.div
                            exit={{ translateY: "-1rem", opacity: 0 }}
                            initial={{ translateY: "-1rem", opacity: 0 }}
                            animate={{ translateY: "0rem", opacity: 100 }}
                            transition={{
                                type: "spring",
                                stiffness: 250,
                                damping: 30,
                            }}
                            className="w-full flex justify-between items-center p-4 bg-gradient-to-r from-gray-800 to-gray-700 rounded-b-md"
                        >
                            <div className="flex justify-center items-center gap-4">
                                <Button
                                    className="size-8 flex justify-center items-center p-0"
                                    onClick={() => handleDressUpOutfit("all")}
                                >
                                    <PersonStanding className="size-4 text-white" />
                                </Button>
                                <Button
                                    className="size-8 flex justify-center items-center p-0"
                                    onClick={() => handleDressUpOutfit("top")}
                                >
                                    <Laugh className="size-4 text-white" />
                                </Button>
                                <Button
                                    className="size-8 flex justify-center items-center p-0"
                                    onClick={() => handleDressUpOutfit("mid")}
                                >
                                    <Shirt className="size-4 text-white" />
                                </Button>
                                <Button
                                    className="size-8 flex justify-center items-center p-0"
                                    onClick={() => handleDressUpOutfit("low")}
                                >
                                    <Footprints className="size-4 text-white" />
                                </Button>
                            </div>
                            <Button
                                className="size-8 flex justify-center items-center p-0"
                                onClick={() => onDeleteOutfit(true)}
                            >
                                <Trash className="size-4 text-white" />
                            </Button>
                        </motion.div>
                    )}
                </AnimatePresence>
            </div>
        </>
    );
}
