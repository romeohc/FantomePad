"use client";

import { motion, AnimatePresence } from "framer-motion";
import { Mail, KeyRound, AlertCircle, CheckCircle2, ArrowRight } from "lucide-react";

interface LoginFormProps {
    step: "email" | "otp";
    email: string;
    code: string;
    setEmail: (val: string) => void;
    setCode: (val: string) => void;
    loading: boolean;
    error: string | null;
    message: string | null;
    handleSendOTP: (e: React.FormEvent) => void;
    handleVerifyOTP: (e: React.FormEvent) => void;
    setStep: (step: "email" | "otp") => void;
}

export default function LoginForm({
    step,
    email,
    code,
    setEmail,
    setCode,
    loading,
    error,
    message,
    handleSendOTP,
    handleVerifyOTP,
    setStep,
}: LoginFormProps) {
    return (
        <div className="relative space-y-6">
            <div className="p-[1px] rounded-2xl bg-gradient-to-b from-brand-border to-transparent">
                <div className="bg-brand-bg rounded-2xl p-8 md:p-12 border border-brand-border/50 min-h-[500px] flex flex-col justify-center relative z-10 shadow-2xl">
                    <header className="text-center mb-10">
                        <motion.span
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            transition={{ delay: 0.2 }}
                            className="text-xs font-bold tracking-[0.2em] text-brand-gray uppercase mb-3 block"
                        >
                            {step === "email" ? "Connection / Inscription" : "Vérification"}
                        </motion.span>
                        <motion.h1
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            transition={{ delay: 0.3 }}
                            className="text-2xl md:text-3xl font-bold text-white tracking-tight"
                        >
                            {step === "email" ? (
                                <>The new standard <br /> <span className="text-brand-gray">is here.</span></>
                            ) : (
                                <>Saisissez votre <br /> <span className="text-brand-gray">code de connexion.</span></>
                            )}
                        </motion.h1>
                    </header>

                    <AnimatePresence mode="wait">
                        <motion.div
                            key={step}
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                            transition={{ duration: 0.3 }}
                        >
                            <form onSubmit={step === "email" ? handleSendOTP : handleVerifyOTP} className="space-y-6">
                                {error && (
                                    <div className="flex items-center gap-2 p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-xs animate-shake">
                                        <AlertCircle className="h-4 w-4 shrink-0" />
                                        <span>{error}</span>
                                    </div>
                                )}
                                {message && step === "otp" && (
                                    <div className="flex items-center gap-2.5 p-3.5 rounded-xl bg-white/[0.03] border border-white/10 text-xs transition-all">
                                        <CheckCircle2 className="h-4 w-4 text-green-500 shrink-0" />
                                        <p className="text-green-500/90 font-medium">
                                            {message}
                                            <span className="text-white/60 ml-1.5 font-normal">
                                                Pensez à vérifier vos spams.
                                            </span>
                                        </p>
                                    </div>
                                )}



                                <div className="space-y-4">
                                    <div className="relative group">
                                        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                            {step === "email" ? (
                                                <Mail className="h-4 w-4 text-brand-gray group-focus-within:text-white transition-colors" />
                                            ) : (
                                                <KeyRound className="h-4 w-4 text-brand-gray group-focus-within:text-white transition-colors" />
                                            )}
                                        </div>
                                        <input
                                            type={step === "email" ? "email" : "text"}
                                            required
                                            value={step === "email" ? email : code}
                                            onChange={(e) => step === "email" ? setEmail(e.target.value) : setCode(e.target.value)}
                                            placeholder={step === "email" ? "Votre mail de commande" : "000000"}
                                            maxLength={step === "email" ? undefined : 8}
                                            className="w-full bg-[#1A1A1A] border border-brand-border rounded-xl py-3 pl-11 pr-4 text-white placeholder:text-brand-gray/50 focus:outline-none focus:ring-1 focus:ring-brand-blue focus:border-transparent transition-all tracking-wide"
                                        />
                                    </div>
                                </div>

                                <button
                                    type="submit"
                                    disabled={loading}
                                    className="w-full bg-white text-black font-bold py-3.5 rounded-xl flex items-center justify-center gap-2 hover:bg-neutral-200 active:scale-[0.98] transition-all disabled:opacity-50 disabled:cursor-not-allowed group"
                                >
                                    {loading ? (
                                        <div className="h-5 w-5 border-2 border-black/20 border-t-black rounded-full animate-spin" />
                                    ) : (
                                        <>
                                            {step === "email" ? "Continuer" : "Vérifier"}
                                            <ArrowRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
                                        </>
                                    )}
                                </button>

                                {step === "otp" && (
                                    <button
                                        type="button"
                                        onClick={() => setStep("email")}
                                        className="w-full text-center text-xs text-brand-gray hover:text-white transition-colors"
                                    >
                                        Modifier l&apos;email
                                    </button>
                                )}
                            </form>
                        </motion.div>
                    </AnimatePresence>

                    <footer className="mt-12 pt-8 border-t border-brand-border/50 text-center">
                        <p className="text-xs text-brand-gray tracking-wide">
                            Besoin d&apos;aide ?{" "}
                            <a href="mailto:contact@fantomepad.com" className="text-white hover:underline">
                                contact@fantomepad.com
                            </a>
                        </p>
                    </footer>
                </div>
            </div>
            {/* Shop Button below Auth Card */}
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 1 }}
                className="flex justify-center"
            >
                <a
                    href="https://fantomepad.com"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="group flex items-center gap-2 px-6 py-3 rounded-full bg-white/5 border border-white/10 hover:bg-white/10 hover:border-white/30 transition-all duration-300 backdrop-blur-sm"
                >
                    <span className="text-xs font-bold text-brand-gray group-hover:text-white transition-colors">Visiter la boutique</span>
                    <ArrowRight className="h-3.5 w-3.5 text-brand-gray group-hover:text-white group-hover:translate-x-1 transition-all" />
                </a>
            </motion.div>
        </div >
    );
}
