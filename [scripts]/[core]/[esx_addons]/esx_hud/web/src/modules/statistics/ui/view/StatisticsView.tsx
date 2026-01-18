import { XIcon } from "lucide-react";
import { useStatistics } from "../../api/useStatistics";
import StatisticBox from "../components/StatisticBox";
import { motion, AnimatePresence } from "framer-motion";

const StatisticsView = () => {
    const { visible, statistics, closeStatisticsMenu } = useStatistics();

    return (
        <AnimatePresence>
            {visible && (
                <motion.div 
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.95 }}
                    transition={{ duration: 0.3, ease: "easeOut" }}
                    className="statistics font-montserrat absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 px-[2.2vw] py-[3.2vh] pb-[5vh] rounded-[1vw] border-[0.15vw] border-[#1f1f1f]"
                >
                    <motion.header
                        className="flex justify-between items-start"
                        initial={{ opacity: 0, y: -10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.4, delay: 0.1 }}
                    >
                        <div >
                            <p className="margin-0 padding-0 font-extrabold text-[1.5vw]">
                                TWOJE STATYSTYKI
                            </p>
                            <p className="text-[#CECDCD] text-[0.68vw] font-medium w-[70%] leading-[2.2vh] mt-[0.5vh]">
                                Tu znajdziesz aktualne statystyki swojej postaci. Pracuj nad sobą i obserwuj realny progres.
                            </p>
                        </div>
                        <button 
                            className="w-[2vw] h-[2vw] flex items-center justify-center bg-neutral-800 rounded-[0.3vw] hover:bg-neutral-700 transition-colors duration-300 hover:cursor-pointer"
                            onClick={closeStatisticsMenu}
                        >
                            <XIcon className="w-[1vw]" />
                        </button>
                    </motion.header>
                    <div 
                        className="grid grid-cols-2 mt-[6vh]"
                        style={{
                            gap: "4vh 2vw"
                        }}
                    >
                        {statistics.map((item, idx) => (
                            <motion.div
                                key={idx}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ 
                                    duration: 0.5, 
                                    ease: "easeOut",
                                    delay: 0.2 + (idx * 0.1)
                                }}
                            >
                                <StatisticBox
                                    {...item}
                                />
                            </motion.div>
                        ))}
                    </div>
                </motion.div>
            )}
        </AnimatePresence>
    )
}

export default StatisticsView;