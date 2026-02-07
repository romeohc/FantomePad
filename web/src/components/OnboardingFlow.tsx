
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
        <div className="w-full max-w-4xl mx-auto flex flex-col md:flex-row bg-[#0F0F0F] rounded-2xl overflow-hidden border border-white/5 shadow-2xl relative">
            {/* Background Effects */}
            <div className="absolute top-0 right-0 w-1/2 h-1/2 bg-brand-blue/5 blur-[120px] rounded-full pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-1/2 h-1/2 bg-purple-500/5 blur-[120px] rounded-full pointer-events-none" />

            {/* Left Panel: Visual & Progress */}
            <div className="md:w-1/3 bg-[#121212] p-8 border-r border-white/5 flex flex-col justify-between relative z-10">
                <div>
                    <div className="flex items-center gap-3 mb-8">
                        <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-brand-blue to-purple-600 flex items-center justify-center shadow-lg shadow-brand-blue/20">
                            <span className="font-bold text-white">F</span>
                        </div>
                        <span className="font-bold text-lg tracking-tight text-white">FantomePad</span>
                    </div>

                    <div className="space-y-6">
                        {steps.map((s, idx) => (
                            <div key={s.id} className="flex items-center gap-4 relative">
                                {/* Connector Line */}
                                {idx < steps.length - 1 && (
                                    <div className={`absolute left-[11px] top-8 w-px h-8 transition-colors duration-500 ${idx < currentStepIndex ? "bg-brand-blue" : "bg-white/10"
                                        }`} />
                                )}

                                <div className={`h-6 w-6 rounded-full flex items-center justify-center text-[10px] font-bold border transition-all duration-500 ${idx <= currentStepIndex
                                        ? "bg-brand-blue border-brand-blue text-black scale-110"
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

                <div className="mt-8">
                    <div className="bg-white/5 p-4 rounded-xl border border-white/5 text-xs text-brand-gray">
                        <p className="flex items-center gap-2 mb-2 font-bold text-white">
                            <ShieldCheck className="h-4 w-4 text-green-400" />
                            Security First
                        </p>
                        Votre licence est liée à votre Hardware ID pour une protection maximale.
                    </div>
                </div>
            </div>

            {/* Right Panel: Content Form */}
            <div className="flex-1 p-8 md:p-12 relative z-10 flex flex-col justify-center min-h-[500px]">
                <AnimatePresence mode="wait">
                    {/* Step 1: Platform Selection */}
                    {step === "platform_selection" && (
                        <motion.div
                            key="platform"
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                            className="space-y-8"
                        >
                            <div className="space-y-2">
                                <h2 className="text-3xl font-bold text-white">Choisissez votre plateforme</h2>
                                <p className="text-brand-gray">Sur quelle version de MetaTrader opérez-vous ?</p>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <button
                                    onClick={() => setPlatform("mt4")}
                                    className={`p-6 rounded-2xl border transition-all group relative overflow-hidden ${platform === "mt4"
                                        ? "bg-brand-blue/10 border-brand-blue ring-1 ring-brand-blue shadow-lg shadow-brand-blue/10"
                                        : "bg-[#151515] border-white/5 hover:border-brand-gray/50 hover:bg-[#1A1A1A]"
                                        }`}
                                >
                                    <div className="flex flex-col items-start gap-4 relative z-10">
                                        <div className={`p-3 rounded-xl transition-colors ${platform === "mt4" ? "bg-brand-blue text-black" : "bg-white/5 text-white"}`}>
                                            <Laptop className="h-6 w-6" />
                                        </div>
                                        <div>
                                            <div className="text-xl font-bold text-white">MetaTrader 4</div>
                                            <div className="text-xs text-brand-gray/80 mt-1">Version Standard</div>
                                        </div>
                                    </div>
                                </button>

                                <button
                                    onClick={() => setPlatform("mt5")}
                                    className={`p-6 rounded-2xl border transition-all group relative overflow-hidden ${platform === "mt5"
                                        ? "bg-brand-blue/10 border-brand-blue ring-1 ring-brand-blue shadow-lg shadow-brand-blue/10"
                                        : "bg-[#151515] border-white/5 hover:border-brand-gray/50 hover:bg-[#1A1A1A]"
                                        }`}
                                >
                                    <div className="flex flex-col items-start gap-4 relative z-10">
                                        <div className={`p-3 rounded-xl transition-colors ${platform === "mt5" ? "bg-brand-blue text-black" : "bg-white/5 text-white"}`}>
                                            <Zap className="h-6 w-6" />
                                        </div>
                                        <div>
                                            <div className="text-xl font-bold text-white">MetaTrader 5</div>
                                            <div className="text-xs text-brand-gray/80 mt-1">Performance Max</div>
                                        </div>
                                    </div>
                                </button>
                            </div>

                            <div className="flex justify-end pt-4">
                                <button
                                    disabled={!platform}
                                    onClick={() => setStep("install")}
                                    className="px-8 py-3.5 bg-brand-blue text-black font-bold rounded-xl flex items-center gap-2 hover:bg-brand-blue/90 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg shadow-brand-blue/20"
                                >
                                    Continuer
                                    <ArrowRight className="h-4 w-4" />
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
                            className="space-y-8"
                        >
                            <div className="space-y-2">
                                <button onClick={() => setStep("platform_selection")} className="flex items-center gap-1 text-xs text-brand-gray hover:text-white transition-colors mb-4">
                                    <ChevronLeft className="h-3 w-3" /> Retour
                                </button>
                                <h2 className="text-3xl font-bold text-white">Installation Requise</h2>
                                <p className="text-brand-gray">Assurez-vous d'avoir la plateforme installée avant de continuer.</p>
                            </div>

                            <div className="space-y-4">
                                <a href="#" className="block w-full group p-5 bg-[#151515] border border-white/5 rounded-2xl flex items-center justify-between hover:border-brand-blue/50 hover:bg-[#1A1A1A] transition-all">
                                    <div className="flex items-center gap-5">
                                        <div className="bg-brand-blue/10 p-4 rounded-xl text-brand-blue border border-brand-blue/20">
                                            <Download className="h-6 w-6" />
                                        </div>
                                        <div>
                                            <div className="text-base font-bold text-white">Télécharger {platform === "mt4" ? "MT4" : "MT5"}</div>
                                            <div className="text-xs text-brand-gray mt-1">Installateur Officiel MetaQuotes (Win/Mac)</div>
                                        </div>
                                    </div>
                                    <ArrowRight className="h-5 w-5 text-brand-gray group-hover:text-white transition-colors" />
                                </a>

                                <div className="text-center text-xs text-brand-gray py-2 uppercase tracking-widest font-bold">
                                    — Ou —
                                </div>

                                <button
                                    onClick={() => {
                                        setStep("activation");
                                        activateLicense();
                                    }}
                                    className="w-full bg-white text-black font-bold py-4 rounded-xl hover:bg-neutral-200 transition-all shadow-lg shadow-white/5"
                                >
                                    Je l'ai déjà installé
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
                            className="space-y-8 text-center"
                        >
                            <div className="space-y-2">
                                <div className="mx-auto w-16 h-16 bg-green-500/10 rounded-full flex items-center justify-center mb-6 ring-4 ring-green-500/5">
                                    <Check className="h-8 w-8 text-green-400" />
                                </div>
                                <h2 className="text-3xl font-bold text-white">Licence Active !</h2>
                                <p className="text-brand-gray max-w-sm mx-auto">Votre code unique a été généré. Copiez-le pour débloquer votre accès.</p>
                            </div>

                            {loading ? (
                                <div className="py-12 flex justify-center">
                                    <div className="h-8 w-8 border-4 border-brand-blue border-t-transparent rounded-full animate-spin" />
                                </div>
                            ) : (
                                <div className="space-y-6 max-w-sm mx-auto">
                                    <div className="bg-[#151515] border border-white/5 rounded-2xl p-6 space-y-4 relative overflow-hidden group hover:border-white/10 transition-colors">
                                        <div className="absolute top-0 right-0 p-2 opacity-50">
                                            <Copy className="h-24 w-24 text-white/5 -rotate-12 transform translate-x-4 -translate-y-4" />
                                        </div>

                                        <div className="text-[10px] text-brand-gray uppercase tracking-widest font-bold">Votre Code de Licence</div>
                                        <div className="text-2xl font-mono font-bold text-white tracking-widest py-2 border-y border-white/5 bg-black/20 rounded">
                                            {activationCode}
                                        </div>
                                        <button
                                            onClick={handleCopy}
                                            className="w-full flex items-center justify-center gap-2 text-xs font-bold text-brand-blue hover:text-white py-2 transition-colors bg-brand-blue/5 hover:bg-brand-blue/10 rounded-lg"
                                        >
                                            {copied ? <Check className="h-3 w-3" /> : <Copy className="h-3 w-3" />}
                                            {copied ? "Copié dans le presse-papier" : "Copier le code"}
                                        </button>
                                    </div>

                                    <div className="grid grid-cols-2 gap-3">
                                        <button className="p-3 bg-[#151515] hover:bg-[#1A1A1A] border border-white/5 rounded-xl flex flex-col items-center gap-2 transition-all group">
                                            <Download className="h-5 w-5 text-brand-gray group-hover:text-white transition-colors" />
                                            <span className="text-[10px] font-bold text-brand-gray group-hover:text-white">Télécharger EA</span>
                                        </button>
                                        <button className="p-3 bg-[#151515] hover:bg-[#1A1A1A] border border-white/5 rounded-xl flex flex-col items-center gap-2 transition-all group">
                                            <PlayCircle className="h-5 w-5 text-brand-gray group-hover:text-white transition-colors" />
                                            <span className="text-[10px] font-bold text-brand-gray group-hover:text-white">Tutoriel</span>
                                        </button>
                                    </div>

                                    <button
                                        onClick={onComplete}
                                        className="w-full bg-brand-blue text-black font-bold py-4 rounded-xl hover:bg-brand-blue/90 transition-all shadow-lg shadow-brand-blue/20"
                                    >
                                        Accéder au Dashboard
                                    </button>
                                </div>
                            )}
                        </motion.div>
                    )}
                </AnimatePresence>
            </div>
        </div>
    );
}
