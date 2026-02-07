import { motion } from "framer-motion";
import { ArrowRight, Download, PlayCircle, Copy, Check } from "lucide-react";
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

    return (
        <div className="w-full space-y-8 min-h-[400px] flex flex-col justify-center">
            {/* Progress Bar - Visible during onboarding */}
            {!activationCode && (
                <div className="absolute top-0 left-0 w-full px-8 md:px-12 pt-8">
                    <div className="h-1 w-full bg-[#1A1A1A] rounded-full overflow-hidden">
                        <motion.div
                            initial={{ width: 0 }}
                            animate={{ width: `${progress}%` }}
                            transition={{ duration: 0.5, ease: "circOut" }}
                            className="h-full bg-brand-blue shadow-[0_0_10px_rgba(0,186,255,0.5)]"
                        />
                    </div>
                    <div className="flex justify-between mt-2">
                        <span className={`text-[10px] font-bold tracking-widest uppercase transition-colors ${step === "platform_selection" ? "text-brand-blue" : "text-brand-gray"}`}>Plateforme</span>
                        <span className={`text-[10px] font-bold tracking-widest uppercase transition-colors ${step === "install" ? "text-brand-blue" : "text-brand-gray"}`}>Installation</span>
                        <span className={`text-[10px] font-bold tracking-widest uppercase transition-colors ${step === "activation" ? "text-brand-blue" : "text-brand-gray"}`}>Activation</span>
                    </div>
                </div>
            )}

            {/* Step Content */}
            {step === "platform_selection" && (
                <div className="space-y-8 animate-in fade-in zoom-in duration-500">
                    <div className="text-center space-y-2">
                        <h2 className="text-2xl font-bold text-white">Choisissez votre plateforme</h2>
                        <p className="text-brand-gray text-sm">FantomePad est disponible pour MetaTrader 4 et 5.</p>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <button
                            onClick={() => setPlatform("mt4")}
                            className={`p-6 rounded-xl border transition-all ${platform === "mt4"
                                ? "bg-brand-blue/10 border-brand-blue ring-1 ring-brand-blue"
                                : "bg-[#1A1A1A] border-brand-border hover:border-brand-gray"
                                }`}
                        >
                            <div className="text-3xl font-bold text-white mb-2">MT4</div>
                            <div className="text-xs text-brand-gray uppercase tracking-widest">MetaTrader 4</div>
                        </button>

                        <button
                            onClick={() => setPlatform("mt5")}
                            className={`p-6 rounded-xl border transition-all ${platform === "mt5"
                                ? "bg-brand-blue/10 border-brand-blue ring-1 ring-brand-blue"
                                : "bg-[#1A1A1A] border-brand-border hover:border-brand-gray"
                                }`}
                        >
                            <div className="text-3xl font-bold text-white mb-2">MT5</div>
                            <div className="text-xs text-brand-gray uppercase tracking-widest">MetaTrader 5</div>
                        </button>
                    </div>

                    <button
                        disabled={!platform}
                        onClick={() => setStep("install")}
                        className="w-full bg-white text-black font-bold py-3.5 rounded-xl flex items-center justify-center gap-2 hover:bg-neutral-200 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                    >
                        Continuer
                        <ArrowRight className="h-4 w-4" />
                    </button>
                </div>
            )}

            {step === "install" && (
                <div className="space-y-8 animate-in fade-in slide-in-from-right-10 duration-500">
                    <div className="text-center space-y-2">
                        <h2 className="text-2xl font-bold text-white">Installation</h2>
                        <p className="text-brand-gray text-sm">Avez-vous déjà installé {platform === "mt4" ? "MetaTrader 4" : "MetaTrader 5"} ?</p>
                    </div>

                    <div className="space-y-4">
                        <button className="w-full group p-4 bg-[#1A1A1A] border border-brand-border rounded-xl flex items-center justify-between hover:border-brand-blue transition-all">
                            <div className="flex items-center gap-4">
                                <div className="bg-brand-blue/10 p-3 rounded-lg text-brand-blue">
                                    <Download className="h-6 w-6" />
                                </div>
                                <div className="text-left">
                                    <div className="font-bold text-white">Télécharger {platform === "mt4" ? "MT4" : "MT5"}</div>
                                    <div className="text-xs text-brand-gray">Version officielle MetaQuotes</div>
                                </div>
                            </div>
                            <ArrowRight className="h-5 w-5 text-brand-gray group-hover:text-white transition-colors" />
                        </button>

                        <div className="relative">
                            <div className="absolute inset-0 flex items-center">
                                <span className="w-full border-t border-brand-border"></span>
                            </div>
                            <div className="relative flex justify-center text-xs uppercase">
                                <span className="bg-brand-bg px-2 text-brand-gray">Ou</span>
                            </div>
                        </div>

                        <button
                            onClick={() => {
                                setStep("activation");
                                activateLicense();
                            }}
                            className="w-full bg-white text-black font-bold py-3.5 rounded-xl hover:bg-neutral-200 transition-all"
                        >
                            Je l'ai déjà installé
                        </button>
                    </div>
                </div>
            )}

            {step === "activation" && (
                <div className="space-y-8 animate-in fade-in zoom-in duration-500">
                    <div className="text-center space-y-2">
                        <h2 className="text-2xl font-bold text-white">Activation</h2>
                        <p className="text-brand-gray text-sm">Votre licence est prête. Configurez votre FantomePad.</p>
                    </div>

                    {loading ? (
                        <div className="py-12 flex justify-center">
                            <div className="h-8 w-8 border-4 border-brand-blue border-t-transparent rounded-full animate-spin" />
                        </div>
                    ) : (
                        <div className="space-y-6">
                            <div className="bg-[#1A1A1A] border border-brand-border rounded-xl p-6 text-center space-y-4">
                                <div className="text-xs text-brand-gray uppercase tracking-widest">Votre Code d'Activation</div>
                                <div className="text-3xl font-mono font-bold text-white tracking-wider text-glow">
                                    {activationCode}
                                </div>
                                <button
                                    onClick={handleCopy}
                                    className="mx-auto flex items-center gap-2 text-xs text-brand-blue hover:text-white transition-colors"
                                >
                                    {copied ? <Check className="h-3 w-3" /> : <Copy className="h-3 w-3" />}
                                    {copied ? "Copié !" : "Copier le code"}
                                </button>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <button className="p-4 bg-[#1A1A1A] border border-brand-border rounded-xl flex flex-col items-center gap-3 hover:border-brand-gray transition-all group">
                                    <Download className="h-6 w-6 text-white group-hover:text-brand-blue transition-colors" />
                                    <span className="text-xs font-bold text-white">Télécharger l'EA</span>
                                </button>
                                <button className="p-4 bg-[#1A1A1A] border border-brand-border rounded-xl flex flex-col items-center gap-3 hover:border-brand-gray transition-all group">
                                    <PlayCircle className="h-6 w-6 text-white group-hover:text-brand-blue transition-colors" />
                                    <span className="text-xs font-bold text-white">Tutoriel Vidéo</span>
                                </button>
                            </div>

                            <button
                                onClick={onComplete}
                                className="w-full bg-brand-blue text-white font-bold py-3.5 rounded-xl hover:bg-blue-600 transition-all"
                            >
                                Accéder au Dashboard
                            </button>
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}
