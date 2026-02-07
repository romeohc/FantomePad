"use client";

import { motion, AnimatePresence } from "framer-motion";
import { useState, useEffect } from "react";
import { ArrowRight, Mail, KeyRound, AlertCircle, CheckCircle2, LogOut } from "lucide-react";
import { createClient } from "@/utils/supabase";

export default function Home() {
  const [session, setSession] = useState<any>(null);
  const [email, setEmail] = useState("");
  const [code, setCode] = useState("");
  const [loading, setLoading] = useState(true);
  const [step, setStep] = useState<"email" | "otp">("email");
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  const supabase = createClient();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    window.location.reload();
  };

  const handleSendOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setMessage(null);

    try {
      const { data: license, error: licenseError } = await supabase
        .from("licences")
        .select("id")
        .eq("email", email.toLowerCase())
        .single();

      if (licenseError || !license) {
        setError("Cet email n'est associé à aucune commande FantomePad.");
        setLoading(false);
        return;
      }

      const { error: authError } = await supabase.auth.signInWithOtp({
        email: email.toLowerCase(),
        options: {
          shouldCreateUser: true,
        },
      });

      if (authError) throw authError;

      setStep("otp");
      setMessage("Un code de vérification a été envoyé à votre email.");
    } catch (err: any) {
      setError(err.message || "Une erreur est survenue.");
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const { error: verifyError } = await supabase.auth.verifyOtp({
        email: email.toLowerCase(),
        token: code,
        type: "email",
      });

      if (verifyError) throw verifyError;
    } catch (err: any) {
      setError("Code invalide ou expiré.");
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-brand-bg">
        <div className="h-8 w-8 border-4 border-white/20 border-t-white rounded-full animate-spin" />
      </main>
    );
  }

  return (
    <main className="flex min-h-screen items-center justify-center p-4 bg-brand-bg select-none">
      <div className="absolute inset-0 z-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-1/4 -right-1/4 w-1/2 h-1/2 bg-brand-blue/5 blur-[120px] rounded-full" />
        <div className="absolute -bottom-1/4 -left-1/4 w-1/2 h-1/2 bg-brand-blue/5 blur-[120px] rounded-full" />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, ease: "easeOut" }}
        className="relative z-10 w-full max-w-md"
      >
        <div className="p-[1px] rounded-2xl bg-gradient-to-b from-brand-border to-transparent">
          <div className="bg-brand-bg rounded-2xl p-8 md:p-12 border border-brand-border/50">
            {session ? (
              <div className="text-center space-y-8">
                <header className="mb-6">
                  <span className="text-xs font-bold tracking-[0.2em] text-brand-gray uppercase mb-3 block">
                    Session Active
                  </span>
                  <h1 className="text-2xl font-bold text-white tracking-tight">
                    Ravi de vous revoir, <br />
                    <span className="text-brand-gray text-lg truncate block font-normal mt-1">
                      {session.user.email}
                    </span>
                  </h1>
                </header>

                <div className="p-6 bg-[#1A1A1A] border border-brand-border rounded-xl space-y-4">
                  <p className="text-sm text-brand-gray">
                    Votre accès est validé. Prêt à configurer votre FantomePad ?
                  </p>
                  <button
                    className="w-full bg-brand-blue text-white font-bold py-3 rounded-xl hover:bg-blue-600 transition-all active:scale-95"
                  >
                    Démarrer l'Onboarding
                  </button>
                </div>

                <button
                  onClick={handleLogout}
                  className="flex items-center justify-center gap-2 text-xs text-brand-gray hover:text-white mx-auto transition-colors"
                >
                  <LogOut className="h-3 w-3" />
                  Se déconnecter
                </button>
              </div>
            ) : (
              <>
                {/* Header Login */}
                <header className="text-center mb-10">
                  <span className="text-xs font-bold tracking-[0.2em] text-brand-gray uppercase mb-3 block">
                    {step === "email" ? "Accès Propriétaire" : "Vérification"}
                  </span>
                  <h1 className="text-2xl md:text-3xl font-bold text-white tracking-tight">
                    {step === "email" ? (
                      <>The new standard <br /> <span className="text-brand-gray">is here.</span></>
                    ) : (
                      <>Saisissez votre <br /> <span className="text-brand-gray">code OTP.</span></>
                    )}
                  </h1>
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
                        <div className="flex items-center gap-2 p-3 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-xs text-left">
                          <AlertCircle className="h-4 w-4 shrink-0" />
                          <span>{error}</span>
                        </div>
                      )}
                      {message && (
                        <div className="flex items-center gap-2 p-3 rounded-lg bg-green-500/10 border border-green-500/20 text-green-400 text-xs text-left">
                          <CheckCircle2 className="h-4 w-4 shrink-0" />
                          <span>{message}</span>
                        </div>
                      )}

                      <div className="space-y-2">
                        <label className="text-[10px] font-bold text-brand-gray tracking-widest uppercase ml-1 block text-left">
                          {step === "email" ? "Email d'achat Shopify" : "Code de vérification"}
                        </label>
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
                            placeholder={step === "email" ? "nom@exemple.com" : "000000"}
                            maxLength={step === "email" ? undefined : 6}
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
                          Modifier l'email
                        </button>
                      )}
                    </form>
                  </motion.div>
                </AnimatePresence>
              </>
            )}

            {/* Footer */}
            <footer className="mt-12 pt-8 border-t border-brand-border/50 text-center">
              <p className="text-[10px] text-brand-gray tracking-wide">
                Besoin d'aide ?{" "}
                <a href="mailto:contact@fantomepad.com" className="text-white hover:underline">
                  contact@fantomepad.com
                </a>
              </p>
            </footer>
          </div>
        </div>
      </motion.div>
    </main>
  );
}
