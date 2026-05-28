"use client";
import { useRef, useState } from "react";
import { motion } from "framer-motion";

interface MagneticButtonProps {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
  variant?: "primary" | "outline" | "text";
}

export default function MagneticButton({ 
  children, 
  className = "", 
  onClick,
  variant = "primary" 
}: MagneticButtonProps) {
  const ref = useRef<HTMLButtonElement>(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleMouse = (e: React.MouseEvent<HTMLButtonElement>) => {
    const { clientX, clientY } = e;
    const { height, width, left, top } = ref.current!.getBoundingClientRect();
    const middleX = clientX - (left + width / 2);
    const middleY = clientY - (top + height / 2);
    setPosition({ x: middleX * 0.2, y: middleY * 0.2 });
  };

  const reset = () => {
    setPosition({ x: 0, y: 0 });
  };

  const baseClasses = "relative inline-flex items-center justify-center text-xs uppercase tracking-widest font-bold transition-colors duration-300 overflow-hidden cursor-pointer group";
  
  const variants = {
    primary: "px-8 py-4 md:px-10 md:py-5 bg-guezs-gold text-guezs-black hover:text-guezs-white",
    outline: "px-8 py-4 md:px-10 md:py-5 border-2 border-guezs-sand text-guezs-sand hover:text-guezs-black",
    text: "text-guezs-gold hover:text-guezs-white px-0 py-2",
  };

  return (
    <motion.button
      ref={ref}
      onMouseMove={handleMouse}
      onMouseLeave={reset}
      onClick={onClick}
      animate={{ x: position.x, y: position.y }}
      transition={{ type: "spring", stiffness: 150, damping: 15, mass: 0.1 }}
      className={`${baseClasses} ${variants[variant]} ${className}`}
    >
      <span className="relative z-10 pointer-events-none">{children}</span>
      
      {/* Fill effect background */}
      {variant === "primary" && (
        <div className="absolute inset-0 bg-guezs-black translate-y-[100%] group-hover:translate-y-0 transition-transform duration-500 ease-out z-0 rounded-t-[50%] group-hover:rounded-none" />
      )}
      {variant === "outline" && (
        <div className="absolute inset-0 bg-guezs-sand translate-y-[100%] group-hover:translate-y-0 transition-transform duration-500 ease-out z-0 rounded-t-[50%] group-hover:rounded-none" />
      )}
    </motion.button>
  );
}
