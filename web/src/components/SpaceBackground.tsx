"use client";

import { motion } from "framer-motion";
import { useMemo, memo } from "react";

interface SpaceBackgroundProps {
    isMobile: boolean;
}

const SpaceBackground = ({ isMobile }: SpaceBackgroundProps) => {
    // Generate stable random values for stars
    const stars = useMemo(() => {
        return Array.from({ length: isMobile ? 60 : 150 }).map(() => ({
            width: Math.random() < 0.1 ? '1.5px' : '1px',
            top: Math.random() * 100,
            left: Math.random() * 100,
        }));
    }, [isMobile]);

    // Generate stable random values for twinkling stars
    const twinklers = useMemo(() => {
        return Array.from({ length: isMobile ? 15 : 40 }).map(() => ({
            top: Math.random() * 100,
            left: Math.random() * 100,
            duration: Math.random() * 3 + 2,
            delay: Math.random() * 5,
        }));
    }, [isMobile]);

    // Generate stable random values for space dust/particles
    const dust = useMemo(() => {
        return Array.from({ length: isMobile ? 10 : 25 }).map((_, i) => ({
            x: Math.random() * 100,
            duration: Math.random() * 15 + 15,
            delay: Math.random() * 10,
            direction: i % 2 === 0 ? 1 : -1
        }));
    }, [isMobile]);

    // Generate stable random values for shooting stars
    const shootingStars = useMemo(() => {
        return Array.from({ length: 2 }).map((_, i) => ({
            delay: i * 8 + 3,
            repeatDelay: Math.random() * 15 + 10
        }));
    }, []);

    return (
        <div className="absolute inset-0 z-0 overflow-hidden bg-[#050505]">
            {/* Deep Space Base */}
            <div className="absolute inset-0 bg-[#050505]" />

            {/* Static Background Stars */}
            <div className="absolute inset-0 pointer-events-none">
                {stars.map((star, i) => (
                    <div
                        key={`star-static-${i}`}
                        className="absolute rounded-full bg-white/20"
                        style={{
                            width: star.width,
                            height: star.width,
                            top: `${star.top}%`,
                            left: `${star.left}%`,
                        }}
                    />
                ))}
            </div>

            {/* Twinkling & Pulsing Stars */}
            <div className="absolute inset-0 pointer-events-none">
                {twinklers.map((star, i) => (
                    <motion.div
                        key={`star-twinkle-${i}`}
                        initial={{ opacity: 0.3, scale: 0.8 }}
                        animate={{
                            opacity: [0.2, 0.8, 0.2],
                            scale: [1, 1.2, 1],
                            boxShadow: [
                                "0 0 0px 0px rgba(255,255,255,0)",
                                "0 0 8px 1px rgba(255,255,255,0.3)",
                                "0 0 0px 0px rgba(255,255,255,0)"
                            ]
                        }}
                        transition={{
                            duration: star.duration,
                            repeat: Infinity,
                            ease: "easeInOut",
                            delay: star.delay
                        }}
                        className="absolute w-[1.5px] h-[1.5px] bg-white rounded-full"
                        style={{
                            top: `${star.top}%`,
                            left: `${star.left}%`,
                        }}
                    />
                ))}
            </div>

            {/* Cosmic Nebula Glows */}
            <motion.div
                animate={{
                    opacity: [0.03, 0.07, 0.03],
                    scale: [1, 1.1, 1]
                }}
                transition={{ duration: 20, repeat: Infinity, ease: "easeInOut" }}
                className="absolute top-[-10%] left-[-10%] w-[80%] h-[80%] bg-white/5 blur-[120px] rounded-full"
            />
            <motion.div
                animate={{
                    opacity: [0.03, 0.06, 0.03],
                    scale: [1.1, 1, 1.1]
                }}
                transition={{ duration: 25, repeat: Infinity, ease: "easeInOut", delay: 5 }}
                className="absolute bottom-[-15%] right-[-10%] w-[90%] h-[90%] bg-brand-blue/10 blur-[150px] rounded-full"
            />

            {/* Drifting Space Particles/Dust */}
            <div className="absolute inset-0 pointer-events-none">
                {dust.map((p, i) => (
                    <motion.div
                        key={`particle-${i}`}
                        initial={{
                            x: `${p.x}%`,
                            y: "110%",
                            opacity: 0
                        }}
                        animate={{
                            y: ["110%", "-10%"],
                            opacity: [0, 0.4, 0],
                            x: [`${p.x}%`, `${p.x + (p.direction * 2)}%`]
                        }}
                        transition={{
                            duration: p.duration,
                            repeat: Infinity,
                            ease: "linear",
                            delay: p.delay
                        }}
                        className="absolute w-[1px] h-[1px] bg-white rounded-full blur-[0.3px]"
                    />
                ))}
            </div>

            {/* Cinematic Shooting Stars */}
            {shootingStars.map((ss, i) => (
                <motion.div
                    key={`shooting-star-${i}`}
                    initial={{ x: "-10%", y: "30%", opacity: 0, scale: 0 }}
                    animate={{
                        x: ["0%", "200%"],
                        y: ["30%", "90%"],
                        opacity: [0, 1, 1, 0],
                        scale: [0, 1.2, 1.2, 0],
                    }}
                    transition={{
                        duration: 1.5,
                        repeat: Infinity,
                        repeatDelay: ss.repeatDelay,
                        ease: "circOut",
                        delay: ss.delay
                    }}
                    className="absolute w-[200px] h-[1px] bg-gradient-to-r from-transparent via-white to-transparent origin-left rotate-[30deg]"
                />
            ))}

            {/* Giant Planetary Horizon */}
            <div className="absolute -bottom-[40%] -left-[10%] w-[120%] h-[75%] pointer-events-none select-none">
                <div className="absolute inset-0 border-t-[1.5px] border-white/10 rounded-[100%] blur-[0.5px] rotate-[3deg]" />
                <div className="absolute inset-0 border-t-[3px] border-white/5 rounded-[100%] blur-[3px] rotate-[3deg]" />
                <div className="absolute top-0 left-0 w-full h-40 bg-gradient-to-b from-brand-blue/10 to-transparent blur-2xl rounded-[100%] opacity-40 rotate-[3deg]" />
            </div>

            {/* Foreground Depth Vignette */}
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,transparent_30%,rgba(0,0,0,0.7)_100%)] pointer-events-none" />
        </div>
    );
};

export default memo(SpaceBackground);
