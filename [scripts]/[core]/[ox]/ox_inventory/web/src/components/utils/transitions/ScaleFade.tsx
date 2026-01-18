import React from "react";
import { motion, AnimatePresence } from "framer-motion";

interface Props {
  in?: boolean;
  children: React.ReactNode;
}

const ScaleFade: React.FC<Props> = ({ in: isVisible, children }) => {
  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          className="inventory-motion-wrapper"
          initial={{ opacity: 0, scale: 0.85 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.85 }}
          transition={{
            duration: 0.3,
            type: "spring",
            stiffness: 220,
            damping: 28,
          }}
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default ScaleFade;