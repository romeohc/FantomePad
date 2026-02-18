
import { motion, AnimatePresence } from "framer-motion";
import { ArrowRight, Copy, Check, ChevronLeft, ChevronRight, Download, PlayCircle, Loader2, Monitor, LogOut, KeyRound, Maximize } from "lucide-react";
import { useState, useEffect } from "react";
import { createClient } from "@/utils/supabase";
import { useOnboarding } from "@/hooks/useOnboarding";
import Image from "next/image";

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
    const [tutorialStep, setTutorialStep] = useState(0);

    // Reset tutorial step when leaving/entering
    useEffect(() => {
        if (step !== "activation") {
            setTutorialStep(0);
        }
    }, [step]);

    const tutorialSteps = [
        {
            title: "1. Intégration",
            description: platform === "mt5"
                ? "File > Open Data Folder > MQL5 > Experts + Collez fichier fantomepad.ex5"
                : "File > Open Data Folder > MQL4 > Experts + Collez fichier fantomepad.ex4",
        },
        {
            title: "2. Autorisation",
            description: "Réglages 'Auto Trading' + Collez URL dans 'Allow WebRequest'",
        },
        {
            title: "3. Actualisation",
            description: platform === "mt5"
                ? "Ouvrir Navigator + Clic droit sur 'Expert Advisors' + Refresh"
                : "Ouvrir Navigator + Clic droit sur 'Expert Advisors' + Refresh", // This one is actually the same
        },
        {
            title: "4. Lancement",
            description: "Nettoyez fenêtres + Glissez déposez FantomePad + Activez AutoTrading",
        },
        {
            title: "5. Activation",
            description: "Copiez votre code d'activation pour commencer à trader ;)",
        }
    ];

    const videoPaths = [
        "/video/step1.mp4",
        "/video/step2.mp4",
        "/video/step3.mp4",
        "/video/step4.mp4"
    ];

    const [urlCopied, setUrlCopied] = useState(false);
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;

    const handleCopyUrl = () => {
        if (supabaseUrl) {
            const functionsUrl = supabaseUrl.replace('.supabase.co', '.functions.supabase.co');
            navigator.clipboard.writeText(functionsUrl);
            setUrlCopied(true);
            setTimeout(() => setUrlCopied(false), 2000);
        }
    };

    const nextTutorialStep = () => {
        if (tutorialStep < tutorialSteps.length - 1) {
            setTutorialStep(tutorialStep + 1);
        }
    };

    const prevTutorialStep = () => {
        if (tutorialStep > 0) {
            setTutorialStep(tutorialStep - 1);
        }
    };

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
        { id: "platform_selection", label: "Plateforme" },
        { id: "install", label: "Installation" },
        { id: "download", label: "Logiciel" },
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
            {
                step === "platform_selection" && (
                    <div className="md:hidden flex justify-center mb-2">
                        <div className="flex items-center gap-2 px-3 py-1.5 bg-blue-500/10 border border-blue-500/20 rounded-lg animate-fade-in-down">
                            <Monitor className="h-3.5 w-3.5 text-blue-400" />
                            <span className="text-[11px] font-bold text-blue-200">Installation recommandée sur Ordinateur</span>
                        </div>
                    </div>
                )
            }

            {/* Progress Bar Container - Detached on Mobile */}
            <div className="md:hidden flex justify-center py-4">
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
                                            <Image src="/logo mt4.png" alt="MT4" width={40} height={40} className="h-10 w-10 object-contain rounded-lg" />
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
                                            <Image src="/logo mt5.png" alt="MT5" width={40} height={40} className="h-10 w-10 object-contain rounded-lg" />
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
                                            <Image src="/logo windows.png" alt="Windows" width={40} height={40} className="h-10 w-10 object-contain" />
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
                                            <Image src="/logo apple.png" alt="Mac" width={40} height={40} className="h-10 w-10 object-contain" />
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
                                                    src={platform === "mt4" ? "/logo mt4.png" : "/logo mt5.png"}
                                                    alt={platform?.toUpperCase() || "Platform"}
                                                    width={40}
                                                    height={40}
                                                    className="h-10 w-10 object-contain rounded-lg"
                                                />
                                            </div>
                                            <div>
                                                <div className="text-lg font-bold text-white">Télécharger {platform?.toUpperCase()}</div>
                                                <div className="text-xs text-brand-gray mt-1 font-medium italic opacity-60 text-left">Version officielle MetaQuotes</div>
                                            </div>
                                        </div>

                                        {/* MT4 Download Action (Right Aligned Logo) */}
                                        {(platform === "mt4" || platform === "mt5") && (
                                            <a
                                                href={platform === "mt4"
                                                    ? (os === "mac"
                                                        ? "https://download.terminal.free/cdn/web/metaquotes.software.corp/mt4/MetaTrader4.pkg.zip?utm_source=www.metatrader4.com&utm_campaign=download.mt4.macos"
                                                        : "https://download.terminal.free/cdn/web/metaquotes.software.corp/mt4/mt4setup.exe?utm_source=www.metatrader4.com&utm_campaign=download")
                                                    : (os === "mac"
                                                        ? "https://download.terminal.free/cdn/web/metaquotes.ltd/mt5/MetaTrader5.pkg.zip?utm_source=www.metatrader4.com&utm_campaign=download.mt5.macos"
                                                        : "https://download.terminal.free/cdn/web/metaquotes.ltd/mt5/mt5setup.exe?utm_source=www.metatrader4.com&utm_campaign=download")
                                                }
                                                target="_blank"
                                                rel="noopener noreferrer"
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
                                                    src="/logo-blanc.svg"
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
                                                href={platform === "mt4" ? "/fantomepad.ex4" : "/fantomepad.ex5"}
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

                                    <div className="flex flex-col h-full relative pt-4">

                                        {/* Main Content Area - Reduced Width */}
                                        <div className="flex-1 flex flex-col items-center justify-center w-full max-w-3xl mx-auto">

                                            {/* Video Container - 16:9 Aspect Ratio */}
                                            <div className="w-full aspect-video bg-[#0A0A0A] border border-white/10 rounded-xl overflow-hidden shadow-2xl relative mb-8 group">
                                                {/* Video Player */}
                                                {tutorialStep < 4 ? (
                                                    <div className="absolute inset-0 w-full h-full bg-black">
                                                        {platform === "mt4" ? (
                                                            <>
                                                                <video
                                                                    key={tutorialStep}
                                                                    src={videoPaths[tutorialStep]}
                                                                    className="w-full h-full object-contain"
                                                                    autoPlay
                                                                    muted
                                                                    loop
                                                                    playsInline
                                                                    id={`video-step-${tutorialStep}`}
                                                                    onError={(e) => console.error(`Error loading video for step ${tutorialStep + 1}:`, e)}
                                                                />

                                                                {/* Maximize Button - Always visible, bottom right */}
                                                                <button
                                                                    onClick={() => {
                                                                        const video = document.getElementById(`video-step-${tutorialStep}`) as HTMLVideoElement;
                                                                        if (video) {
                                                                            if (video.requestFullscreen) {
                                                                                video.requestFullscreen();
                                                                            } else if ((video as any).webkitRequestFullscreen) {
                                                                                (video as any).webkitRequestFullscreen();
                                                                            } else if ((video as any).msRequestFullscreen) {
                                                                                (video as any).msRequestFullscreen();
                                                                            }
                                                                        }
                                                                    }}
                                                                    className="absolute bottom-4 right-4 p-2.5 rounded-lg bg-black/60 hover:bg-brand-blue text-white/90 hover:text-black backdrop-blur-md transition-all z-30 pointer-events-auto border border-white/10 hover:border-brand-blue shadow-lg"
                                                                    title="Mode Plein Écran"
                                                                >
                                                                    <Maximize className="h-5 w-5" />
                                                                </button>
                                                            </>
                                                        ) : (
                                                            /* Placeholder for MT5 (No Video) */
                                                            <div className="absolute inset-0 flex items-center justify-center bg-gradient-to-br from-white/5 to-transparent">
                                                                <div className="text-white/5 font-bold text-8xl select-none">
                                                                    {tutorialStep + 1}
                                                                </div>
                                                            </div>
                                                        )}
                                                    </div>
                                                ) : (
                                                    /* Background for License Step */
                                                    <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-transparent opacity-50" />
                                                )}

                                                {/* Step 5 Special Overlay: License Key - Professional Redesign */}
                                                {tutorialStep === 4 && !loading && (
                                                    <div className="absolute inset-0 bg-[#050505] flex flex-col items-center justify-center p-4 md:p-8 text-center animate-fade-in z-20">
                                                        <div className="bg-brand-blue/10 p-3 md:p-4 rounded-full mb-4 md:mb-6">
                                                            <KeyRound className="h-6 w-6 md:h-8 md:w-8 text-brand-blue" />
                                                        </div>

                                                        <h3 className="text-lg md:text-xl font-bold text-white mb-4 md:mb-8">Votre code d'activation</h3>

                                                        <div className="w-full max-w-[280px] md:max-w-sm">
                                                            <button
                                                                onClick={handleCopy}
                                                                className="w-full bg-[#111] border border-white/10 hover:border-brand-blue/50 rounded-lg p-1.5 pl-3 md:pl-4 flex items-center justify-between transition-all group/btn"
                                                            >
                                                                <code className="font-mono text-sm md:text-lg font-bold tracking-wider text-white group-hover/btn:text-brand-blue transition-colors truncate mr-2">
                                                                    {activationCode || "FP-XXXX-XXXX"}
                                                                </code>
                                                                <div className={`h-8 w-8 md:h-10 md:w-10 rounded-md flex items-center justify-center transition-all shrink-0 ${copied ? "bg-green-500/20 text-green-500" : "bg-white/5 group-hover/btn:bg-brand-blue group-hover/btn:text-black"}`}>
                                                                    {copied ? <Check className="h-4 w-4 md:h-5 md:w-5" /> : <Copy className="h-4 w-4 md:h-5 md:w-5" />}
                                                                </div>
                                                            </button>
                                                        </div>
                                                    </div>
                                                )}
                                            </div>

                                            {/* Unified Controls & Text Bar */}
                                            <div className="w-full flex items-center gap-2 md:gap-8 justify-between px-2 md:px-4">
                                                {/* Left: Navigation */}
                                                <button
                                                    onClick={prevTutorialStep}
                                                    disabled={tutorialStep === 0}
                                                    className="h-10 w-10 md:h-12 md:w-12 rounded-full border border-white/10 flex items-center justify-center text-white hover:bg-white/10 disabled:opacity-20 disabled:cursor-not-allowed transition-all shrink-0"
                                                >
                                                    <ChevronLeft className="h-5 w-5" />
                                                </button>

                                                {/* Center: Text Content */}
                                                <div className="flex-1 text-center space-y-2 min-w-0">
                                                    <h3 className="text-xl md:text-2xl font-bold text-white tracking-tight break-words">
                                                        {tutorialSteps[tutorialStep].title}
                                                    </h3>
                                                    <p className="text-brand-gray text-sm md:text-base leading-relaxed max-w-xl mx-auto break-words">
                                                        {tutorialSteps[tutorialStep].description}
                                                    </p>

                                                    {/* Step 2 URL Action */}
                                                    {tutorialStep === 1 && (
                                                        <button
                                                            onClick={handleCopyUrl}
                                                            className="mt-2 inline-flex items-center justify-center gap-2 px-4 py-2 rounded-xl bg-brand-blue/10 border border-brand-blue/20 text-brand-blue text-[10px] md:text-xs font-bold uppercase tracking-widest hover:bg-brand-blue/20 transition-all max-w-full h-auto whitespace-normal break-all text-center leading-tight"
                                                        >
                                                            {urlCopied ? (
                                                                <Check className="h-3.5 w-3.5 shrink-0" />
                                                            ) : (
                                                                <Copy className="h-3.5 w-3.5 shrink-0" />
                                                            )}
                                                            <span>{urlCopied ? "URL Copiée" : "https://zxgkjytxqqxkizqcrdwf.functions.supabase.co"}</span>
                                                        </button>
                                                    )}
                                                </div>

                                                {/* Right: Navigation */}
                                                <button
                                                    onClick={nextTutorialStep}
                                                    disabled={tutorialStep === tutorialSteps.length - 1}
                                                    className="h-10 w-10 md:h-12 md:w-12 rounded-full bg-brand-blue text-black flex items-center justify-center hover:bg-brand-blue/90 disabled:bg-white/10 disabled:text-white disabled:opacity-20 disabled:cursor-not-allowed transition-all shadow-lg shadow-brand-blue/20 shrink-0"
                                                >
                                                    <ChevronRight className="h-5 w-5" />
                                                </button>
                                            </div>

                                            {/* Progress Dots */}
                                            <div className="flex justify-center gap-2 mt-8">
                                                {tutorialSteps.map((_, idx) => (
                                                    <div
                                                        key={idx}
                                                        className={`h-1.5 rounded-full transition-all duration-300 ${idx === tutorialStep ? "w-8 bg-brand-blue" : "w-1.5 bg-white/10"
                                                            }`}
                                                    />
                                                ))}
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
