"use client";

import { motion } from "framer-motion";
import { useMemo, memo } from "react";

interface SpaceBackgroundProps {
    isMobile: boolean;
}

const SpaceBackground = ({ isMobile }: SpaceBackgroundProps) => {
    // Generate stable random values for stars
    const stars = useMemo(() => {
        return Array.from({ length: isMobile ? 80 : 250 }).map(() => ({
            width: Math.random() < 0.15 ? '2px' : '1px',
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
        return [
            { id: 1, top: "15%", left: "-10%", angle: "35deg", duration: 3.8, delay: 2, repeatDelay: 15, length: "300px", distance: "150vw" },
            { id: 2, top: "-10%", left: "40%", angle: "45deg", duration: 3.4, delay: 8, repeatDelay: 22, length: "200px", distance: "120vw" },
            { id: 3, top: "40%", left: "-20%", angle: "25deg", duration: 4.8, delay: 14, repeatDelay: 28, length: "400px", distance: "200vw" }
        ];
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
                        className="absolute rounded-full bg-white/50"
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
                            opacity: [0.4, 0.9, 0.4],
                            scale: [1, 1.2, 1],
                            boxShadow: [
                                "0 0 0px 0px rgba(255,255,255,0)",
                                "0 0 12px 2px rgba(255,255,255,0.5)",
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
                    opacity: [0.1, 0.2, 0.1],
                    scale: [1, 1.1, 1]
                }}
                transition={{ duration: 20, repeat: Infinity, ease: "easeInOut" }}
                className="absolute top-[-10%] left-[-10%] w-[80%] h-[80%] bg-white/8 blur-[120px] rounded-full"
            />
            <motion.div
                animate={{
                    opacity: [0.15, 0.25, 0.15],
                    scale: [1.1, 1, 1.1]
                }}
                transition={{ duration: 25, repeat: Infinity, ease: "easeInOut", delay: 5 }}
                className="absolute bottom-[-15%] right-[-10%] w-[90%] h-[90%] bg-white/12 blur-[150px] rounded-full"
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
                            opacity: [0, 0.7, 0],
                            x: [`${p.x}%`, `${p.x + (p.direction * 3)}%`]
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
            {shootingStars.map((ss) => (
                <div
                    key={`shooting-star-wrapper-${ss.id}`}
                    className="absolute pointer-events-none"
                    style={{ top: ss.top, left: ss.left, transform: `rotate(${ss.angle})` }}
                >
                    <motion.div
                        initial={{ x: "-100vw", opacity: 0, scaleX: 0 }}
                        animate={{
                            x: ["0vw", ss.distance],
                            opacity: [0, 1, 0],
                            scaleX: [0.5, 1, 0.5],
                        }}
                        transition={{
                            duration: ss.duration,
                            repeat: Infinity,
                            repeatDelay: ss.repeatDelay,
                            ease: "linear",
                            delay: ss.delay
                        }}
                        className="h-[1.5px] bg-gradient-to-r from-transparent via-white/80 to-white rounded-full shadow-[0_0_8px_1px_rgba(255,255,255,0.4)]"
                        style={{ width: ss.length }}
                    />
                </div>
            ))}

            {/* Giant Planetary Horizon */}
            <div className={`absolute -bottom-[40%] pointer-events-none select-none transition-all duration-700 ${isMobile ? "-left-[40%] w-[180%] h-[75%]" : "-left-[10%] w-[120%] h-[75%]"}`}>
                <div className="absolute inset-0 border-t-[2px] border-white/20 rounded-[100%] blur-[0.5px] rotate-[3deg]" />
                <div className="absolute inset-0 border-t-[4px] border-white/10 rounded-[100%] blur-[4px] rotate-[3deg]" />
                <div className="absolute top-0 left-0 w-full h-60 bg-gradient-to-b from-white/15 to-transparent blur-3xl rounded-[100%] opacity-70 rotate-[3deg]" />
            </div>

            {/* Foreground Depth Vignette */}
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,transparent_45%,rgba(0,0,0,0.35)_100%)] pointer-events-none" />
        </div>
    );
};

export default memo(SpaceBackground);
