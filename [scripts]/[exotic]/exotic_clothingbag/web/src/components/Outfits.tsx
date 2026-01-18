import { LockKeyhole, Package, Save } from "lucide-react";
import type OutfitType from "../types/outfit";
import Button from "./Button";
import Outfit from "./Outfit";
import { useEffect, useState } from "react";
import { AnimatePresence, motion } from "motion/react";
import Modal from "./Modal";
import { fetchNui } from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";

export default function Outfits({
    outfits,
    limit,
}: {
    outfits: OutfitType[];
    limit: number;
}) {
    const [newOutfitName, setNewOutfitName] = useState<string>("");
    const [expandedOutfit, setExpandedOutfit] = useState<number | null>(null);

    const [showCreateNewModal, setShowCreateNewModal] =
        useState<boolean>(false);

    const [showDeleteOutfitModal, setShowDeleteOutfitModal] =
        useState<boolean>(false);

    const handleCancelCreateNewOutfit = () => {
        setShowCreateNewModal(false);
        setNewOutfitName("");
    };

    const handleSubmitCreateNewOutfit = async () => {
        const success = isEnvBrowser()
            ? true
            : await fetchNui("createNewOutfit", {
                  name: newOutfitName,
              });

        if (success) {
            setShowCreateNewModal(false);
            setNewOutfitName("");
        }
    };

    const handleCancelDeleteOutfit = () => {
        setShowDeleteOutfitModal(false);
    };

    const handleSubmitDeleteOutfit = async () => {
        if (expandedOutfit === null) return;

        const success = isEnvBrowser()
            ? true
            : await fetchNui("deleteOutfit", {
                  id: expandedOutfit,
              });

        if (success) {
            setShowDeleteOutfitModal(false);
        }
    };

    const handleChangePrivacy = () => {
        fetchNui("switchPrivacy", {});
    };

    useEffect(() => {
        if (expandedOutfit === null) return;

        fetchNui("previewOutfit", { id: expandedOutfit });
    }, [expandedOutfit]);

    return (
        <>
            <AnimatePresence>
                {showCreateNewModal && (
                    <Modal
                        title="Wpisz nazwę nowego stroju"
                        onSubmit={handleSubmitCreateNewOutfit}
                        onCancel={handleCancelCreateNewOutfit}
                    >
                        <input
                            type="text"
                            name="name"
                            id="name"
                            placeholder="Nazwa nowego stroju"
                            value={newOutfitName}
                            onChange={(e) => setNewOutfitName(e.target.value)}
                            className="p-2 w-full bg-gray-500/50 text-white outline-none border-none rounded-md"
                        />
                    </Modal>
                )}
                {showDeleteOutfitModal && (
                    <Modal
                        title="Usuwanie stroju"
                        onSubmit={handleSubmitDeleteOutfit}
                        onCancel={handleCancelDeleteOutfit}
                    >
                        <p className="text-sm text-gray-400">
                            Jesteś pewny że chcesz usunąć ten strój?
                        </p>
                    </Modal>
                )}
            </AnimatePresence>
            <motion.div
                exit={{ opacity: 0 }}
                initial={{
                    opacity: 0,
                }}
                animate={{ opacity: 1 }}
                className="absolute top-1/2 right-[5%] -translate-y-1/2 w-96 h-[40rem] flex flex-col justify-start items-center bg-gradient-to-b from-gray-900 to-black rounded-2xl border border-gray-700 shadow-2xl overflow-hidden"
            >
                <div className="w-full flex justify-between items-center p-4 border-b border-gray-700">
                    <div className="flex justify-center items-center gap-2">
                        <Package className="w-5 h-5 text-orange-400" />
                        <p className="text-orange-400 font-semibold">
                            Torba z ubraniami
                        </p>
                    </div>
                    <p className="text-gray-400 text-sm">
                        {outfits.length}/{limit}
                    </p>
                </div>
                <div className="grow w-full flex flex-col justify-start items-center gap-4 p-4 overflow-y-auto">
                    {outfits.map((outfit: OutfitType) => (
                        <Outfit
                            key={outfit.id}
                            outfit={outfit}
                            setExpanded={setExpandedOutfit}
                            expandedOutfit={expandedOutfit}
                            onDeleteOutfit={() =>
                                setShowDeleteOutfitModal(true)
                            }
                        />
                    ))}
                </div>
                <div className="w-full flex justify-center items-center gap-4 p-4">
                    <Button
                        className="h-full aspect-square flex justify-center items-center p-0"
                        onClick={() => handleChangePrivacy()}
                    >
                        <LockKeyhole className="size-4 text-white" />
                    </Button>
                    <Button
                        className="grow flex justify-center items-center"
                        onClick={() => setShowCreateNewModal(true)}
                    >
                        <Save className="w-4 h-4 mr-2" />
                        Zapisz strój
                    </Button>
                </div>
            </motion.div>
        </>
    );
}
