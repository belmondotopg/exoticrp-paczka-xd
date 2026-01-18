import { motion } from "motion/react";

export default function Preview() {
    return (
        <>
            <motion.div
                exit={{ opacity: 0 }}
                initial={{
                    opacity: 0,
                }}
                animate={{ opacity: 1 }}
                className="absolute top-1/2 left-[5%] -translate-y-1/2 w-96 h-[40rem] flex flex-col justify-start items-center bg-gradient-to-b from-gray-900/60 to-black/60 rounded-2xl border border-gray-700 shadow-2xl overflow-hidden"
            ></motion.div>
        </>
    );
}
