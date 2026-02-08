
import { motion, AnimatePresence } from "framer-motion";
import { ArrowRight, Copy, Check, ChevronLeft, ChevronRight, Download, PlayCircle, Loader2, Monitor, LogOut } from "lucide-react";
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
            title: `1. Ouvrir ${platform === 'mt5' ? 'MT5' : 'MT4'}`,
            description: "Lancez votre terminal de trading.",
        },
        {
            title: "2. Dossier de données",
            description: "Fichier > Ouvrir dossier des données.",
        },
        {
            title: "3. Copier le fichier",
            description: "Collez le dans le dossier 'Experts'.",
        },
        {
            title: "4. Installation",
            description: "Glissez FantomePad sur un graphique.",
        },
        {
            title: "5. Auto-trading",
            description: "Activez l'option Auto-trading.",
        },
        {
            title: "6. Activation",
            description: "Collez votre licence à droite.",
        }
    ];

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
                                    <a href="#" className="block w-full group p-6 bg-[#151515] border-2 border-white/5 rounded-3xl flex items-center justify-between hover:border-brand-blue/30 hover:bg-[#1A1A1A] transition-all">
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
                                                <div className="text-xs text-brand-gray mt-1 font-medium italic opacity-60 text-left">Version 2.4.1 • {platform?.toUpperCase()}</div>
                                            </div>
                                        </div>
                                    </a>

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
                                    {/* Header: Back Button & Title */}
                                    <div className="space-y-4 text-center md:text-left">
                                        <button onClick={() => setStep("download")} className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-brand-gray hover:text-white transition-colors mb-2 group mx-auto md:mx-0">
                                            <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-1" /> Retour
                                        </button>
                                        <h2 className="text-2xl md:text-3xl font-bold text-white tracking-tight">Activer votre Logiciel</h2>
                                    </div>

                                    <div className="grid grid-cols-1 xl:grid-cols-2 gap-8 items-stretch">
                                        {/* Left: Video */}
                                        {/* Left: Interactive Tutorial Carousel */}
                                        <div className="relative w-full bg-[#151515] border border-white/10 rounded-2xl overflow-hidden shadow-2xl flex flex-col h-full min-h-[300px]">
                                            <div className="flex-1 relative group">
                                                <div className="absolute inset-0 bg-gradient-to-br from-brand-blue/5 to-transparent opacity-50" />

                                                {/* Placeholder Content Center */}
                                                <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                                                    <div className="text-white/5 font-bold text-8xl select-none">
                                                        {tutorialStep + 1}
                                                    </div>
                                                </div>

                                                {/* Bottom Controls & Text */}
                                                <div className="absolute bottom-6 left-6 right-6 flex items-end justify-between">
                                                    <div className="flex-1 pr-4 min-w-0">
                                                        <h3 className="text-xl font-bold text-white mb-1 transition-all whitespace-nowrap truncate">
                                                            {tutorialSteps[tutorialStep].title}
                                                        </h3>
                                                        <p className="text-xs text-brand-gray font-medium leading-relaxed whitespace-nowrap truncate">
                                                            {tutorialSteps[tutorialStep].description}
                                                        </p>
                                                    </div>

                                                    <div className="flex items-center gap-2 shrink-0">
                                                        <button
                                                            onClick={prevTutorialStep}
                                                            disabled={tutorialStep === 0}
                                                            className="h-8 w-8 rounded-full bg-white/10 hover:bg-white/20 disabled:opacity-20 disabled:cursor-not-allowed flex items-center justify-center transition-all border border-white/10"
                                                        >
                                                            <ChevronLeft className="h-4 w-4 text-white" />
                                                        </button>
                                                        <button
                                                            onClick={nextTutorialStep}
                                                            disabled={tutorialStep === tutorialSteps.length - 1}
                                                            className="h-8 w-8 rounded-full bg-brand-blue text-black hover:bg-brand-blue/90 disabled:bg-white/10 disabled:text-white disabled:opacity-20 disabled:cursor-not-allowed flex items-center justify-center transition-all shadow-lg shadow-brand-blue/20"
                                                        >
                                                            <ChevronRight className="h-4 w-4" />
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        {/* Right: Actions */}
                                        <div className="flex flex-col justify-center h-full gap-6">
                                            {loading ? (
                                                <div className="py-8 flex flex-col items-center gap-4 border border-white/5 rounded-2xl bg-white/5 h-full justify-center min-h-[300px]">
                                                    <Loader2 className="h-8 w-8 text-brand-blue animate-spin" />
                                                    <p className="text-[10px] font-bold text-brand-gray uppercase tracking-widest">Génération de la clé...</p>
                                                </div>
                                            ) : (
                                                <>
                                                    {/* Status Block (Yellow) */}
                                                    <div className="bg-yellow-500/10 border border-yellow-500/20 rounded-3xl p-6 flex items-center justify-center gap-3 animate-pulse w-full">
                                                        <div className="h-3 w-3 bg-yellow-500 rounded-full shrink-0 shadow-[0_0_10px_rgba(234,179,8,0.5)]" />
                                                        <span className="text-sm font-black text-yellow-500 tracking-widest uppercase">NON ACTIVÉ</span>
                                                    </div>

                                                    {/* License Block */}
                                                    <div className="bg-[#121212] border border-white/5 rounded-3xl p-6 space-y-4 w-full h-full flex flex-col justify-center">
                                                        <div className="flex justify-between items-center">
                                                            <span className="text-[10px] uppercase tracking-widest font-bold text-brand-gray">Votre Licence</span>
                                                            {copied && <span className="text-[10px] text-green-400 font-bold flex items-center gap-1"><Check className="h-3 w-3" /> Copié</span>}
                                                        </div>
                                                        <button
                                                            onClick={handleCopy}
                                                            className="w-full bg-[#151515] border border-white/10 rounded-xl p-4 flex items-center justify-between hover:border-brand-blue/50 transition-all group"
                                                        >
                                                            <code className="font-mono text-xl font-bold tracking-widest text-white group-hover:text-brand-blue transition-colors">
                                                                {activationCode || "FP-XXXX-XXXX"}
                                                            </code>
                                                            <Copy className="h-5 w-5 text-brand-gray group-hover:text-white transition-colors" />
                                                        </button>
                                                    </div>
                                                </>
                                            )}
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
