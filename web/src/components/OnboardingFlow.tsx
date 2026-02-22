
import { motion, AnimatePresence } from "framer-motion";
import { ArrowRight, Copy, Check, ChevronLeft, ChevronRight, Download, PlayCircle, Loader2, Monitor, LogOut, KeyRound } from "lucide-react";
import { useState, useEffect, useRef } from "react";

import { createClient } from "@/utils/supabase";
import { useOnboarding } from "@/hooks/useOnboarding";
import Image from "next/image";
import SpaceBackground from "./SpaceBackground";


interface LicenseData {
    activation_code?: string;
    status?: string;
}

interface OnboardingFlowProps {
    email: string;
    initialData?: LicenseData | null;
    onComplete: () => void;
}

export default function OnboardingFlow({ email, initialData, onComplete }: OnboardingFlowProps) {
    const {
        step,
        setStep,
        platform,
        setPlatform,
        os,
        setOs,
        activationCode,
        activateLicense,
        loading
    } = useOnboarding(email, initialData);


    const [copied, setCopied] = useState(false);
    const [isMobile, setIsMobile] = useState(false);
    const [isPlaying, setIsPlaying] = useState(false);
    const videoTimeRef = useRef(0);


    // Reset video state only if platform or OS changes
    useEffect(() => {
        setIsPlaying(false);
        videoTimeRef.current = 0;
    }, [platform, os]);


    useEffect(() => {
        const checkMobile = () => setIsMobile(window.innerWidth < 768);
        checkMobile();
        window.addEventListener('resize', checkMobile);
        return () => window.removeEventListener('resize', checkMobile);
    }, []);

    const [urlCopied, setUrlCopied] = useState(false);

    // Poll for status update when in activation step
    useEffect(() => {
        if (step === "activation") {
            // Initial trigger to ensure everything is up to date
            if (!activationCode) {
                activateLicense();
            }

            const interval = setInterval(() => {
                onComplete(); // Refetch license in parent to check for 'active' status
            }, 3000);

            return () => clearInterval(interval);
        }
    }, [step, onComplete, activateLicense, activationCode]);

    const handleCopy = () => {
        if (activationCode) {
            navigator.clipboard.writeText(activationCode);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        }
    };

    const handleLogout = async () => {
        const supabase = createClient();
        await supabase.auth.signOut();
        window.location.reload();
    };

    const steps = [
        { id: "platform_selection", label: "Configuration" },
        { id: "install", label: "MetaTrader" },
        { id: "download", label: "Fantomepad" },
        { id: "activation", label: "Activation" },
    ];




    const currentStepIndex = steps.findIndex(s => s.id === step);

    return (
        <div className="w-full max-w-6xl mx-auto flex flex-col gap-6 md:gap-0 relative">
            {/* Background Effects */}
            <div className="absolute top-0 right-0 w-1/2 h-1/2 bg-brand-blue/5 blur-[120px] rounded-full pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-1/2 h-1/2 bg-purple-500/5 blur-[120px] rounded-full pointer-events-none" />

            {/* Desktop Recommendation Alert - Floating above main box */}


            {/* Mobile Desktop Recommendation Alert */}
            {step === "platform_selection" && (
                <div className="md:hidden flex justify-center">
                    <div className="flex items-center gap-3 px-5 py-2.5 bg-blue-500/10 border border-blue-500/20 rounded-xl animate-fade-in-down">
                        <Monitor className="h-4.5 w-4.5 text-blue-400" />
                        <span className="text-[13px] font-bold text-blue-200">Installation recommandée sur Ordinateur</span>
                    </div>
                </div>
            )}

            {/* Progress Bar Container - Detached on Mobile */}
            <div className="md:hidden flex justify-center pb-4 pt-2">
                <div className="flex items-center gap-6 relative px-4">
                    {steps.map((s, idx) => (
                        <div key={s.id} className="flex flex-col items-center gap-2 relative">
                            {/* Connector Line */}
                            {idx < steps.length - 1 && (
                                <div className={`absolute left-8 top-4 w-8 h-px transition-colors duration-500 ${idx < currentStepIndex ? "bg-brand-blue" : "bg-white/10"
                                    }`} />
                            )}

                            <div className={`h-8 w-8 rounded-full flex items-center justify-center text-xs font-bold border-2 transition-all duration-500 z-10 ${idx <= currentStepIndex
                                ? "bg-brand-blue border-brand-blue text-black shadow-[0_0_15px_rgba(59,130,246,0.3)]"
                                : "bg-black border-white/20 text-brand-gray"
                                }`}>
                                {idx < currentStepIndex ? <Check className="h-4 w-4" /> : idx + 1}
                            </div>
                            <span className={`text-[9px] font-bold uppercase tracking-widest transition-colors duration-500 ${idx <= currentStepIndex ? "text-white" : "text-brand-gray/50"
                                }`}>
                                {s.label}
                            </span>
                        </div>
                    ))}
                </div>
            </div>




            {/* Main Content Box */}
            <div className="flex flex-col md:flex-row bg-[#0F0F0F] rounded-3xl overflow-hidden border border-white/5 shadow-2xl relative min-h-[600px]">

                {/* Left Panel: Desktop Progress */}
                <div className="hidden md:flex md:w-1/4 bg-[#121212] p-8 border-r border-white/5 flex-col justify-between relative z-10">
                    <div className="space-y-10 mt-8">
                        {steps.map((s, idx) => (
                            <div key={s.id} className="flex items-center gap-4 relative">
                                {/* Connector Line */}
                                {idx < steps.length - 1 && (
                                    <div className={`absolute left-[11px] top-8 w-px h-12 transition-colors duration-500 ${idx < currentStepIndex ? "bg-brand-blue" : "bg-white/10"
                                        }`} />
                                )}

                                <div className={`h-6 w-6 rounded-full flex items-center justify-center text-[10px] font-bold border transition-all duration-500 ${idx <= currentStepIndex
                                    ? "bg-brand-blue border-brand-blue text-black"
                                    : "bg-transparent border-white/20 text-brand-gray"
                                    }`}>
                                    {idx < currentStepIndex ? <Check className="h-3 w-3" /> : idx + 1}
                                </div>
                                <span className={`text-sm font-medium transition-colors duration-500 ${idx <= currentStepIndex ? "text-white" : "text-brand-gray"
                                    }`}>
                                    {s.label}
                                </span>
                            </div>
                        ))}

                    </div>

                    {/* Desktop Logout Button - Bottom of Sidebar */}
                    <button
                        onClick={handleLogout}
                        className="w-full flex items-center justify-center gap-2 text-xs font-bold text-brand-gray hover:text-white transition-all group mt-auto pt-8 opacity-60 hover:opacity-100"
                    >
                        <LogOut className="h-3.5 w-3.5 group-hover:-translate-x-0.5 transition-transform" />
                        Se Déconnecter
                    </button>
                </div>

                {/* Right Panel: Content Form */}
                <div className="flex-1 p-8 md:p-12 relative z-10 flex flex-col justify-center">
                    <AnimatePresence mode="wait">
                        {/* Step 1: Platform Selection */}
                        {step === "platform_selection" && (
                            <motion.div
                                key="platform"
                                initial={{ opacity: 0, scale: 0.98 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.98 }}
                                className="space-y-6 max-w-2xl mx-auto w-full"
                            >
                                <div className="space-y-3 text-center md:text-left">
                                    <h2 className="text-3xl md:text-4xl font-bold text-white tracking-tight">Configuration</h2>
                                    <p className="text-brand-gray text-base md:text-lg">Sélectionnez votre plateforme et votre système d'exploitation.</p>
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <button
                                        onClick={() => setPlatform("mt4")}
                                        className={`p-4 rounded-2xl border-2 transition-all group relative overflow-hidden ${platform === "mt4"
                                            ? "bg-brand-blue/10 border-brand-blue shadow-[0_0_20px_rgba(59,130,246,0.15)]"
                                            : "bg-[#151515] border-white/5 hover:border-white/10"
                                            }`}
                                    >
                                        <div className="flex flex-col items-center gap-3 relative z-10">
                                            <Image src="/Icone/logo mt4.png" alt="MT4" width={40} height={40} className="h-10 w-10 object-contain rounded-lg" />
                                            <span className="text-lg font-bold text-white">MT4</span>
                                        </div>
                                    </button>

                                    <button
                                        onClick={() => setPlatform("mt5")}
                                        className={`p-4 rounded-2xl border-2 transition-all group relative overflow-hidden ${platform === "mt5"
                                            ? "bg-brand-blue/10 border-brand-blue shadow-[0_0_20px_rgba(59,130,246,0.15)]"
                                            : "bg-[#151515] border-white/5 hover:border-white/10"
                                            }`}
                                    >
                                        <div className="flex flex-col items-center gap-3 relative z-10">
                                            <Image src="/Icone/logo mt5.png" alt="MT5" width={40} height={40} className="h-10 w-10 object-contain rounded-lg" />
                                            <span className="text-lg font-bold text-white">MT5</span>
                                        </div>
                                    </button>
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <button
                                        onClick={() => setOs("windows")}
                                        className={`p-4 rounded-2xl border-2 transition-all group relative overflow-hidden ${os === "windows"
                                            ? "bg-brand-blue/10 border-brand-blue shadow-[0_0_20px_rgba(59,130,246,0.15)]"
                                            : "bg-[#151515] border-white/5 hover:border-white/10"
                                            }`}
                                    >
                                        <div className="flex flex-col items-center gap-3 relative z-10">
                                            <Image src="/Icone/logo windows.png" alt="Windows" width={40} height={40} className="h-10 w-10 object-contain" />
                                            <span className="text-lg font-bold text-white">Windows</span>
                                        </div>
                                    </button>

                                    <button
                                        onClick={() => setOs("mac")}
                                        className={`p-4 rounded-2xl border-2 transition-all group relative overflow-hidden ${os === "mac"
                                            ? "bg-brand-blue/10 border-brand-blue shadow-[0_0_20px_rgba(59,130,246,0.15)]"
                                            : "bg-[#151515] border-white/5 hover:border-white/10"
                                            }`}
                                    >
                                        <div className="flex flex-col items-center gap-3 relative z-10">
                                            <Image src="/Icone/logo apple.png" alt="Mac" width={40} height={40} className="h-10 w-10 object-contain" />
                                            <span className="text-lg font-bold text-white">Mac</span>
                                        </div>
                                    </button>
                                </div>

                                <div className="flex flex-col items-center gap-6 pt-4">
                                    <button
                                        disabled={!platform || !os}
                                        onClick={() => setStep("install")}
                                        className="w-full bg-white text-black font-black text-xs uppercase tracking-widest py-4 rounded-2xl flex items-center justify-center gap-3 hover:bg-neutral-200 disabled:opacity-30 disabled:cursor-not-allowed transition-all shadow-xl shadow-white/5 group active:scale-[0.98]"
                                    >
                                        Étape Suivante
                                        <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                                    </button>
                                </div>
                            </motion.div>
                        )}

                        {/* Step 2: Install Platform */}
                        {step === "install" && (
                            <motion.div
                                key="install"
                                initial={{ opacity: 0, x: 20 }}
                                animate={{ opacity: 1, x: 0 }}
                                exit={{ opacity: 0, x: -20 }}
                                className="space-y-10 max-w-2xl mx-auto w-full"
                            >
                                <div className="space-y-4 text-center md:text-left">
                                    <button onClick={() => setStep("platform_selection")} className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-brand-gray hover:text-white transition-colors mb-6 mx-auto md:mx-0 group">
                                        <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-1" /> Retour
                                    </button>
                                    <h2 className="text-3xl md:text-4xl font-bold text-white tracking-tight">Télécharger {platform?.toUpperCase()}</h2>
                                    <p className="text-brand-gray text-base md:text-lg">Assurez-vous d'avoir installé la plateforme {platform?.toUpperCase()}.</p>
                                </div>

                                <div className="space-y-6">
                                    <div className="block w-full group p-6 bg-[#151515] border-2 border-white/5 rounded-3xl flex items-center justify-between hover:border-brand-blue/30 hover:bg-[#1A1A1A] transition-all cursor-default">
                                        <div className="flex items-center gap-6">
                                            <div className="p-1 rounded-2xl flex items-center justify-center">
                                                <Image
                                                    src={platform === "mt4" ? "/Icone/logo mt4.png" : "/Icone/logo mt5.png"}
                                                    alt={platform?.toUpperCase() || "Platform"}
                                                    width={40}
                                                    height={40}
                                                    className="h-10 w-10 object-contain rounded-lg"
                                                />
                                            </div>
                                            <div>
                                                <div className="text-lg font-bold text-white">Télécharger {platform?.toUpperCase()}</div>
                                                <div className="text-xs text-brand-gray mt-1 font-medium italic opacity-60 text-left">
                                                    {platform === "mt4" && os === "windows" ? "Version officielle Pepperstone" : "Version officielle MetaQuotes"}
                                                </div>
                                            </div>
                                        </div>

                                        {/* MT4 Download Action (Right Aligned Logo) */}
                                        {(platform === "mt4" || platform === "mt5") && (
                                            <a
                                                href={platform === "mt4"
                                                    ? (os === "mac"
                                                        ? "https://download.terminal.free/cdn/web/metaquotes.software.corp/mt4/MetaTrader4.pkg.zip?utm_source=www.metatrader4.com&utm_campaign=download.mt4.macos"
                                                        : "https://download.terminal.free/cdn/web/pepperstone.group.limited/mt4/pepperstone4setup.exe")
                                                    : (os === "mac"
                                                        ? "https://download.terminal.free/cdn/web/metaquotes.ltd/mt5/MetaTrader5.pkg.zip?utm_source=www.metatrader4.com&utm_campaign=download.mt5.macos"
                                                        : "https://download.terminal.free/cdn/web/metaquotes.ltd/mt5/mt5setup.exe?utm_source=www.metatrader4.com&utm_campaign=download")
                                                }
                                                className="h-11 w-11 bg-white text-black rounded-xl flex items-center justify-center shrink-0 hover:scale-105 transition-all shadow-lg hover:shadow-white/10 group/dl"
                                                title={`Télécharger ${platform?.toUpperCase()} pour ${os === "mac" ? "Mac" : "Windows"}`}
                                                onClick={(e) => e.stopPropagation()}
                                            >
                                                <Download className="h-5 w-5 transition-transform group-hover/dl:scale-110" />
                                            </a>
                                        )}

                                    </div>

                                    <button
                                        onClick={() => setStep("download")}
                                        className="w-full bg-white text-black font-black text-xs uppercase tracking-widest py-4 rounded-2xl flex items-center justify-center gap-3 hover:bg-neutral-200 transition-all shadow-xl shadow-white/5 group active:scale-[0.98]"
                                    >
                                        J'AI TÉLÉCHARGÉ {platform?.toUpperCase()}
                                        <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                                    </button>
                                </div>
                            </motion.div>
                        )}

                        {/* Step 3: Download Software */}
                        {step === "download" && (
                            <motion.div
                                key="download"
                                initial={{ opacity: 0, x: 20 }}
                                animate={{ opacity: 1, x: 0 }}
                                exit={{ opacity: 0, x: -20 }}
                                className="space-y-10 max-w-2xl mx-auto w-full"
                            >
                                <div className="space-y-4 text-center md:text-left">
                                    <button onClick={() => setStep("install")} className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-brand-gray hover:text-white transition-colors mb-6 mx-auto md:mx-0 group">
                                        <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-1" /> Retour
                                    </button>
                                    <h2 className="text-3xl md:text-4xl font-bold text-white tracking-tight">Télécharger FantomePad</h2>
                                    <p className="text-brand-gray text-base md:text-lg">Obtenez la dernière version de FantomePad.</p>
                                </div>

                                <div className="space-y-6">
                                    <div className="block w-full group p-6 bg-[#151515] border-2 border-white/5 rounded-3xl flex items-center justify-between hover:border-brand-blue/30 hover:bg-[#1A1A1A] transition-all cursor-default">
                                        <div className="flex items-center gap-6">
                                            <div className="p-1 rounded-2xl flex items-center justify-center">
                                                <Image
                                                    src="/Logo/logo-blanc.svg"
                                                    alt="FantomePad"
                                                    width={40}
                                                    height={40}
                                                    className="h-10 w-10 object-contain rounded-lg bg-white"
                                                />
                                            </div>
                                            <div>
                                                <div className="text-lg font-bold text-white">Télécharger FantomePad</div>
                                                <div className="text-xs text-brand-gray mt-1 font-medium italic opacity-60 text-left">Version 1.0.0 • {platform?.toUpperCase()}</div>
                                            </div>
                                        </div>

                                        {/* FantomePad Download Action (Right Aligned Logo) */}
                                        {(platform === "mt4" || platform === "mt5") && (
                                            <a
                                                href={platform === "mt4" ? "/EA/fantomepad.ex4" : "/EA/fantomepad.ex5"}
                                                download={platform === "mt4" ? "fantomepad.ex4" : "fantomepad.ex5"}
                                                className="h-11 w-11 bg-white text-black rounded-xl flex items-center justify-center shrink-0 hover:scale-105 transition-all shadow-lg hover:shadow-white/10 group/dl"
                                                title={`Télécharger fantomepad.${platform === "mt4" ? "ex4" : "ex5"}`}
                                                onClick={(e) => e.stopPropagation()}
                                            >
                                                <Download className="h-5 w-5 transition-transform group-hover/dl:scale-110" />
                                            </a>
                                        )}
                                    </div>

                                    <button
                                        onClick={() => {
                                            setStep("activation");
                                            if (!activationCode) activateLicense();
                                        }}
                                        className="w-full bg-white text-black font-black text-xs uppercase tracking-widest py-4 rounded-2xl flex items-center justify-center gap-3 hover:bg-neutral-200 transition-all shadow-xl shadow-white/5 group active:scale-[0.98]"
                                    >
                                        J'AI TÉLÉCHARGÉ FANTOMEPAD
                                        <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                                    </button>
                                </div>
                            </motion.div>
                        )}

                        {/* Step 4: Tutorial & Activation */}
                        {step === "activation" && (
                            <motion.div
                                key="activation"
                                initial={{ opacity: 0, scale: 0.95 }}
                                animate={{ opacity: 1, scale: 1 }}
                                className="w-full"
                            >
                                <div className="space-y-6">
                                    {/* Header: Back Button & Title & Status */}
                                    <div className="flex flex-col md:flex-row items-center md:items-end justify-between gap-6 md:gap-4">
                                        <div className="space-y-4 text-center md:text-left w-full md:w-auto">
                                            <button onClick={() => setStep("download")} className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-brand-gray hover:text-white transition-colors mb-2 group mx-auto md:mx-0">
                                                <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-1" /> Retour
                                            </button>
                                            <h2 className="text-2xl md:text-3xl font-bold text-white tracking-tight">Activer votre Logiciel</h2>
                                        </div>

                                        {/* Status Badge - Right Aligned & Larger */}
                                        <div className="mb-1 w-auto flex justify-center">
                                            {loading ? (
                                                <div className="bg-white/5 border border-white/10 rounded-full px-4 py-2 flex items-center gap-3">
                                                    <Loader2 className="h-4 w-4 text-brand-blue animate-spin" />
                                                    <span className="text-xs font-bold text-brand-gray uppercase tracking-widest">Connexion...</span>
                                                </div>
                                            ) : (
                                                <div className="bg-yellow-500/10 border border-yellow-500/20 rounded-full px-4 py-2 flex items-center gap-3">
                                                    <div className="h-2 w-2 bg-yellow-500 rounded-full shadow-[0_0_8px_rgba(234,179,8,0.5)] animate-pulse" />
                                                    <span className="text-xs font-black text-yellow-500 tracking-widest uppercase">En attente</span>
                                                </div>
                                            )}
                                        </div>
                                    </div>

                                    <div className="flex flex-col h-full relative pt-4 pb-1">

                                        {/* Main Content Area */}
                                        <div className="flex-1 flex flex-col items-center justify-start w-full max-w-4xl mx-auto space-y-10">


                                            {/* Video Container */}
                                            <div className="w-full aspect-video bg-black border border-white/5 shadow-2xl rounded-2xl overflow-hidden relative flex items-center justify-center group/video">
                                                {!isPlaying ? (
                                                    <div className="absolute inset-0 z-0 cursor-pointer group/preview flex flex-col items-center justify-center" onClick={() => setIsPlaying(true)}>
                                                        <SpaceBackground isMobile={isMobile} />
                                                        <div className="relative z-10 flex flex-col items-center">
                                                            <div className="relative h-20 w-20 md:h-24 md:w-24 bg-white/10 backdrop-blur-md border border-white/20 rounded-full flex items-center justify-center shadow-2xl group-hover/preview:border-brand-blue/50 group-hover/preview:bg-white/15 transition-all">
                                                                <PlayCircle className="w-10 h-10 md:w-12 md:h-12 text-white fill-white/10 group-hover/preview:text-brand-blue group-hover/preview:fill-brand-blue/10 transition-all ml-1" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                ) : (
                                                    <video
                                                        key={`${os}-${platform}`}
                                                        className="w-full h-full object-contain relative z-10"
                                                        controls
                                                        autoPlay
                                                        preload="auto"
                                                        onTimeUpdate={(e) => {
                                                            videoTimeRef.current = e.currentTarget.currentTime;
                                                        }}
                                                        onLoadedMetadata={(e) => {
                                                            if (videoTimeRef.current > 0) {
                                                                e.currentTarget.currentTime = videoTimeRef.current;
                                                            }
                                                        }}
                                                    >
                                                        <source src={`/video/onboarding/${os}-${platform}.mp4`} type="video/mp4" />
                                                        Votre navigateur ne supporte pas la lecture de vidéos.
                                                    </video>
                                                )}
                                            </div>

                                            {/* Unified Data section */}
                                            <div className="w-full grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
                                                {/* API URL Container */}
                                                <div className="p-3 md:p-4 bg-[#0A0A0A] border border-white/5 rounded-2xl md:rounded-3xl flex flex-col justify-center space-y-2 relative overflow-hidden shadow-lg">
                                                    <div className="absolute inset-0 bg-brand-blue/5 opacity-0 pointer-events-none" />

                                                    <div className="flex items-center gap-3 relative z-10">
                                                        <div className="w-2 h-2 rounded-full bg-brand-blue shadow-[0_0_10px_rgba(59,130,246,0.5)]" />
                                                        <span className="text-brand-gray text-[10px] md:text-xs font-bold uppercase tracking-widest">
                                                            URL API
                                                        </span>
                                                    </div>

                                                    <button
                                                        onClick={() => {
                                                            navigator.clipboard.writeText("https://api.fantomepad.com");
                                                            setUrlCopied(true);
                                                            setTimeout(() => setUrlCopied(false), 2000);
                                                        }}
                                                        className="w-full bg-[#111] border border-white/10 hover:border-brand-blue/50 rounded-xl p-2 md:p-3 flex items-center justify-between transition-all duration-300 relative z-10 group/btn"
                                                    >
                                                        <code className="font-mono text-xs md:text-sm font-bold tracking-widest text-white group-hover/btn:text-brand-blue transition-colors truncate mr-2">
                                                            https://api.fantomepad.com
                                                        </code>
                                                        <div className={`h-8 w-8 md:h-10 md:w-10 rounded-lg flex items-center justify-center transition-all duration-300 shrink-0 ${urlCopied ? "bg-green-500/20 text-green-500 scale-110" : "bg-white/5 group-hover/btn:bg-brand-blue group-hover/btn:text-black group-hover/btn:scale-105"}`}>
                                                            {urlCopied ? <Check className="h-4 w-4 md:h-5 md:w-5" /> : <Copy className="h-4 w-4 md:h-5 md:w-5" />}
                                                        </div>
                                                    </button>
                                                </div>

                                                {/* Activation Key Container */}
                                                <div className="p-3 md:p-4 bg-[#0A0A0A] border border-white/5 rounded-2xl md:rounded-3xl flex flex-col justify-center space-y-2 relative overflow-hidden shadow-lg">
                                                    <div className="absolute inset-0 bg-brand-blue/5 opacity-0 pointer-events-none" />

                                                    <div className="flex items-center gap-3 relative z-10">
                                                        <div className="w-2 h-2 rounded-full bg-brand-blue shadow-[0_0_10px_rgba(59,130,246,0.5)]" />
                                                        <span className="text-brand-gray text-[10px] md:text-xs font-bold uppercase tracking-widest">
                                                            Code d'activation
                                                        </span>
                                                    </div>

                                                    <button
                                                        onClick={handleCopy}
                                                        className="w-full bg-[#111] border border-white/10 hover:border-brand-blue/50 rounded-xl p-2 md:p-3 flex items-center justify-between transition-all duration-300 relative z-10 group/btn"
                                                    >
                                                        <code className="font-mono text-xs md:text-sm font-bold tracking-widest text-white group-hover/btn:text-brand-blue transition-colors truncate mr-2">
                                                            {activationCode || "FP-XXXX-XXXX"}
                                                        </code>
                                                        <div className={`h-8 w-8 md:h-10 md:w-10 rounded-lg flex items-center justify-center transition-all duration-300 shrink-0 ${copied ? "bg-green-500/20 text-green-500 scale-110" : "bg-white/5 group-hover/btn:bg-brand-blue group-hover/btn:text-black group-hover/btn:scale-105"}`}>
                                                            {copied ? <Check className="h-4 w-4 md:h-5 md:w-5" /> : <Copy className="h-4 w-4 md:h-5 md:w-5" />}
                                                        </div>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </motion.div>
                        )}
                    </AnimatePresence>
                </div>
            </div>


            {/* Logout Button - Mobile only, centered below the main box */}
            <div className="md:hidden flex justify-center mt-6 pb-8">
                <button
                    onClick={handleLogout}
                    className="flex items-center gap-2 text-xs font-bold text-brand-gray hover:text-white py-2 transition-all group opacity-60 hover:opacity-100"
                >
                    <LogOut className="h-3.5 w-3.5 group-hover:-translate-x-0.5 transition-transform" />
                    Se Déconnecter
                </button>
            </div>
        </div >
    );
}
