import { motion } from "motion/react";
import Button from "./Button";

export default function Modal({
    title,
    children,
    onSubmit,
    onCancel,
}: {
    title: string;
    children: React.ReactNode | React.ReactNode[];
    onSubmit: () => void;
    onCancel: () => void;
}) {
    return (
        <>
            <motion.div
                exit={{ opacity: 0 }}
                initial={{
                    opacity: 0,
                }}
                animate={{ opacity: 1 }}
                className="h-screen w-screen fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 flex justify-center items-center bg-black/60 z-10"
            >
                <div className="w-[31rem] flex flex-col justify-center items-start gap-4 p-4 bg-gradient-to-b from-gray-900 to-black border border-gray-700 rounded-xl">
                    <p className="text-orange-400 font-semibold">{title}</p>
                    {children}
                    <div className="w-full flex justify-end items-center gap-3">
                        <Button
                            className="py-2 px-6 bg-gray-500/50 border-none rounded-md"
                            onClick={onCancel}
                        >
                            Anuluj
                        </Button>
                        <Button
                            className="py-2 px-6 border-none rounded-md bg-orange-400"
                            onClick={onSubmit}
                        >
                            Potwierdź
                        </Button>
                    </div>
                </div>
            </motion.div>
        </>
    );
}
