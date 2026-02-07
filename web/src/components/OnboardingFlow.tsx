
import { motion, AnimatePresence } from "framer-motion";
import { ArrowRight, Download, PlayCircle, Copy, Check, ChevronLeft, Laptop, ShieldCheck, Zap } from "lucide-react";
import { useState } from "react";
import { useOnboarding } from "@/hooks/useOnboarding";

interface OnboardingFlowProps {
    email: string;
    onComplete: () => void;
}

export default function OnboardingFlow({ email, onComplete }: OnboardingFlowProps) {
    const {
        step,
        setStep,
        platform,
        setPlatform,
        activationCode,
        activateLicense,
        loading,
        progress
    } = useOnboarding(email);

    const [copied, setCopied] = useState(false);

    const handleCopy = () => {
        if (activationCode) {
            navigator.clipboard.writeText(activationCode);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        }
    };

    const steps = [
        { id: "platform_selection", label: "Plateforme" },
        { id: "install", label: "Installation" },
        { id: "activation", label: "Activation" },
    ];

    const currentStepIndex = steps.findIndex(s => s.id === step);

    return (
        <div className="w-full max-w-5xl mx-auto flex flex-col gap-6 md:gap-0 relative">
            {/* Background Effects (Moved to outer to cover everything) */}
            <div className="absolute top-0 right-0 w-1/2 h-1/2 bg-brand-blue/5 blur-[120px] rounded-full pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-1/2 h-1/2 bg-purple-500/5 blur-[120px] rounded-full pointer-events-none" />

            {/* Progress Bar Container - Detached on Mobile */}
            <div className="md:hidden flex justify-center py-4">
                <div className="flex items-center gap-12 relative px-4">
                    {steps.map((s, idx) => (
                        <div key={s.id} className="flex flex-col items-center gap-3 relative">
                            {/* Connector Line (Large Mobile) */}
                            {idx < steps.length - 1 && (
                                <div className={`absolute left-10 top-5 w-12 h-px transition-colors duration-500 ${idx < currentStepIndex ? "bg-brand-blue" : "bg-white/10"
                                    }`} />
                            )}

                            <div className={`h-10 w-10 rounded-full flex items-center justify-center text-xs font-bold border-2 transition-all duration-500 z-10 ${idx <= currentStepIndex
                                ? "bg-brand-blue border-brand-blue text-black shadow-[0_0_15px_rgba(59,130,246,0.3)]"
                                : "bg-black border-white/20 text-brand-gray"
                                }`}>
                                {idx < currentStepIndex ? <Check className="h-5 w-5" /> : idx + 1}
                            </div>
                            <span className={`text-[10px] font-bold uppercase tracking-widest transition-colors duration-500 ${idx <= currentStepIndex ? "text-white" : "text-brand-gray/50"
                                }`}>
                                {s.label}
                            </span>
                        </div>
                    ))}
                </div>
            </div>

            {/* Main Content Box */}
            <div className="flex flex-col md:flex-row bg-[#0F0F0F] rounded-3xl overflow-hidden border border-white/5 shadow-2xl relative min-h-[500px]">

                {/* Left Panel: Desktop Progress & Security */}
                <div className="hidden md:flex md:w-1/4 bg-[#121212] p-8 border-r border-white/5 flex-col justify-between relative z-10">
                    <div className="space-y-8 mt-4">
                        {steps.map((s, idx) => (
                            <div key={s.id} className="flex items-center gap-4 relative">
                                {/* Connector Line (Desktop) */}
                                {idx < steps.length - 1 && (
                                    <div className={`absolute left-[11px] top-8 w-px h-10 transition-colors duration-500 ${idx < currentStepIndex ? "bg-brand-blue" : "bg-white/10"
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
                </div>

                {/* Right Panel: Content Form */}
                <div className="flex-1 p-8 md:p-16 relative z-10 flex flex-col justify-center">
                    <AnimatePresence mode="wait">
                        {/* Step 1: Platform Selection */}
                        {step === "platform_selection" && (
                            <motion.div
                                key="platform"
                                initial={{ opacity: 0, scale: 0.98 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.98 }}
                                className="space-y-8"
                            >
                                <div className="space-y-3 text-center md:text-left">
                                    <h2 className="text-3xl md:text-4xl font-bold text-white tracking-tight">Version de MetaTrader</h2>
                                    <p className="text-brand-gray text-base md:text-lg">Sélectionnez la plateforme de trading que vous utilisez.</p>
                                </div>

                                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <button
                                        onClick={() => setPlatform("mt4")}
                                        className={`p-8 rounded-3xl border-2 transition-all group relative overflow-hidden ${platform === "mt4"
                                            ? "bg-brand-blue/10 border-brand-blue shadow-[0_0_30px_rgba(59,130,246,0.15)]"
                                            : "bg-[#151515] border-white/5 hover:border-white/10"
                                            }`}
                                    >
                                        <div className="flex flex-col items-center md:items-start gap-5 relative z-10">
                                            <div className={`p-4 rounded-2xl transition-colors ${platform === "mt4" ? "bg-brand-blue text-black" : "bg-white/5 text-white"}`}>
                                                <Laptop className="h-8 w-8" />
                                            </div>
                                            <div className="text-center md:text-left">
                                                <div className="text-xl md:text-2xl font-bold text-white">MT4</div>
                                            </div>
                                        </div>
                                    </button>

                                    <button
                                        onClick={() => setPlatform("mt5")}
                                        className={`p-8 rounded-3xl border-2 transition-all group relative overflow-hidden ${platform === "mt5"
                                            ? "bg-brand-blue/10 border-brand-blue shadow-[0_0_30px_rgba(59,130,246,0.15)]"
                                            : "bg-[#151515] border-white/5 hover:border-white/10"
                                            }`}
                                    >
                                        <div className="flex flex-col items-center md:items-start gap-5 relative z-10">
                                            <div className={`p-4 rounded-2xl transition-colors ${platform === "mt5" ? "bg-brand-blue text-black" : "bg-white/5 text-white"}`}>
                                                <Zap className="h-8 w-8" />
                                            </div>
                                            <div className="text-center md:text-left">
                                                <div className="text-xl md:text-2xl font-bold text-white">MT5</div>
                                            </div>
                                        </div>
                                    </button>
                                </div>

                                <div className="flex justify-center md:justify-end pt-6">
                                    <button
                                        disabled={!platform}
                                        onClick={() => setStep("install")}
                                        className="w-full md:w-auto px-16 py-5 bg-brand-blue text-white font-black text-xs uppercase tracking-widest rounded-2xl flex items-center justify-center gap-3 hover:bg-brand-blue/90 disabled:opacity-30 disabled:cursor-not-allowed transition-all shadow-xl shadow-brand-blue/10 group active:scale-[0.98]"
                                    >
                                        Étape Suivante
                                        <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                                    </button>
                                </div>
                            </motion.div>
                        )}

                        {/* Step 2: Install */}
                        {step === "install" && (
                            <motion.div
                                key="install"
                                initial={{ opacity: 0, x: 20 }}
                                animate={{ opacity: 1, x: 0 }}
                                exit={{ opacity: 0, x: -20 }}
                                className="space-y-10"
                            >
                                <div className="space-y-4 text-center md:text-left">
                                    <button onClick={() => setStep("platform_selection")} className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-brand-gray hover:text-white transition-colors mb-6 mx-auto md:mx-0 group">
                                        <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-1" /> Retour
                                    </button>
                                    <h2 className="text-3xl md:text-4xl font-bold text-white tracking-tight">Installation</h2>
                                    <p className="text-brand-gray text-base md:text-lg">Téléchargez ou vérifiez votre plateforme {platform?.toUpperCase()}.</p>
                                </div>

                                <div className="space-y-6">
                                    <a href="#" className="block w-full group p-6 bg-[#151515] border-2 border-white/5 rounded-3xl flex items-center justify-between hover:border-brand-blue/30 hover:bg-[#1A1A1A] transition-all">
                                        <div className="flex items-center gap-6">
                                            <div className="bg-brand-blue/10 p-5 rounded-2xl text-brand-blue border border-brand-blue/20 group-hover:bg-brand-blue group-hover:text-black transition-all">
                                                <Download className="h-7 w-7" />
                                            </div>
                                            <div>
                                                <div className="text-lg font-bold text-white">Installer {platform?.toUpperCase()}</div>
                                                <div className="text-xs text-brand-gray mt-1 font-medium italic opacity-60 text-left">Version officielle MetaQuotes</div>
                                            </div>
                                        </div>
                                        <ArrowRight className="h-6 w-6 text-brand-gray group-hover:text-white transition-all transform group-hover:translate-x-1" />
                                    </a>

                                    <div className="relative py-4">
                                        <div className="absolute inset-0 flex items-center" aria-hidden="true">
                                            <div className="w-full border-t border-white/5"></div>
                                        </div>
                                        <div className="relative flex justify-center">
                                            <span className="bg-[#0F0F0F] px-4 text-[10px] font-black uppercase tracking-[0.4em] text-white/20">OU</span>
                                        </div>
                                    </div>

                                    <button
                                        onClick={() => {
                                            setStep("activation");
                                            activateLicense();
                                        }}
                                        className="w-full bg-white text-black font-black text-xs uppercase tracking-widest py-5 rounded-2xl hover:bg-neutral-200 transition-all shadow-xl shadow-white/5 active:scale-[0.98]"
                                    >
                                        Plateforme déjà prête
                                    </button>
                                </div>
                            </motion.div>
                        )}

                        {/* Step 3: Activation */}
                        {step === "activation" && (
                            <motion.div
                                key="activation"
                                initial={{ opacity: 0, scale: 0.95 }}
                                animate={{ opacity: 1, scale: 1 }}
                                className="space-y-10 text-center"
                            >
                                <div className="space-y-4">
                                    <div className="mx-auto w-20 h-20 bg-green-500/10 rounded-full flex items-center justify-center mb-8 ring-8 ring-green-500/5 animate-pulse">
                                        <Check className="h-10 w-10 text-green-400" />
                                    </div>
                                    <h2 className="text-3xl md:text-5xl font-bold text-white tracking-tighter">Votre Clé est Prête</h2>
                                    <p className="text-brand-gray text-base md:text-lg max-w-sm mx-auto">Code unique généré pour votre compte.</p>
                                </div>

                                {loading ? (
                                    <div className="py-12 flex flex-col items-center gap-4">
                                        <div className="h-10 w-10 border-4 border-brand-blue border-t-transparent rounded-full animate-spin" />
                                        <p className="text-[10px] font-bold text-brand-blue uppercase tracking-widest">Génération...</p>
                                    </div>
                                ) : (
                                    <div className="space-y-8 max-w-md mx-auto">
                                        {/* License Key Card */}
                                        <div className="bg-[#121212] border-2 border-white/5 rounded-3xl p-6 space-y-4 relative overflow-hidden group">
                                            <div className="text-[10px] text-brand-gray/50 uppercase tracking-[0.3em] font-black">License Key</div>
                                            <div className="text-xl md:text-2xl font-mono font-bold text-white tracking-[0.2em] py-3 bg-black/40 rounded-xl border border-white/5 shadow-inner">
                                                {activationCode}
                                            </div>
                                            <button
                                                onClick={handleCopy}
                                                className="w-full flex items-center justify-center gap-3 text-xs font-black uppercase tracking-widest text-brand-blue hover:text-white py-3 transition-all bg-brand-blue/5 hover:bg-brand-blue/20 rounded-xl border border-brand-blue/20 hover:border-brand-blue/50"
                                            >
                                                {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                                                {copied ? "Copié" : "Copier la clé"}
                                            </button>
                                        </div>

                                        {/* Fake Video Tutorial */}
                                        <div className="relative aspect-video bg-[#151515] border border-white/5 rounded-3xl overflow-hidden group cursor-pointer hover:border-brand-blue/30 transition-all">
                                            <div className="absolute inset-0 bg-black/20 group-hover:bg-black/10 transition-colors flex items-center justify-center">
                                                <div className="h-16 w-16 bg-white/10 backdrop-blur-md rounded-full flex items-center justify-center border border-white/20 group-hover:scale-110 transition-transform">
                                                    <PlayCircle className="h-8 w-8 text-white fill-white/20" />
                                                </div>
                                            </div>
                                            <div className="absolute bottom-4 left-4 right-4">
                                                <div className="text-sm font-bold text-white">Tutoriel d'installation</div>
                                                <div className="text-[10px] text-brand-gray uppercase tracking-wider font-bold">Guide Rapide • 2:30</div>
                                            </div>
                                        </div>

                                        {/* Download EA Button */}
                                        <a
                                            href="#"
                                            className="w-full flex items-center justify-center gap-3 p-5 bg-[#151515] border border-white/10 rounded-2xl hover:bg-[#1A1A1A] hover:border-brand-blue/50 transition-all group"
                                        >
                                            <div className="h-10 w-10 bg-brand-blue/10 rounded-lg flex items-center justify-center text-brand-blue group-hover:bg-brand-blue group-hover:text-black transition-colors">
                                                <Download className="h-5 w-5" />
                                            </div>
                                            <div className="text-left">
                                                <div className="text-xs font-black text-white uppercase tracking-wider">Télécharger l'Expert Advisor</div>
                                                <div className="text-[10px] text-brand-gray font-bold">Version v2.4.1 pour {platform?.toUpperCase()}</div>
                                            </div>
                                        </a>

                                        {/* Final Button */}
                                        <button
                                            onClick={onComplete}
                                            className="w-full bg-brand-blue text-white font-black text-xs uppercase tracking-widest py-6 rounded-2xl hover:bg-brand-blue/90 transition-all shadow-2xl shadow-brand-blue/20 active:scale-[0.98] mt-8"
                                        >
                                            Ouvrir FantomePad
                                        </button>
                                    </div>
                                )}
                            </motion.div>
                        )}
                    </AnimatePresence>
                </div>
            </div>
        </div>
    );
}
