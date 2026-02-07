"use client";

import { motion, AnimatePresence } from "framer-motion";
import { useState, useEffect } from "react";
import { ArrowRight, Mail, KeyRound, AlertCircle, CheckCircle2 } from "lucide-react";
import { createClient } from "@/utils/supabase";
import OnboardingFlow from "@/components/OnboardingFlow";
import Dashboard from "@/components/Dashboard";

export default function Home() {
  const [session, setSession] = useState<any>(null);
  const [license, setLicense] = useState<any>(null);
  const [email, setEmail] = useState("");
  const [code, setCode] = useState("");
  const [loading, setLoading] = useState(true);
  const [step, setStep] = useState<"email" | "otp">("email");
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  const supabase = createClient();

  useEffect(() => {
    // Check current session
    const initSession = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      setSession(session);
      if (session?.user?.email) {
        fetchLicense(session.user.email);
      } else {
        setLoading(false);
      }
    };

    initSession();

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session?.user?.email) {
        fetchLicense(session.user.email);
      } else {
        setLicense(null); // Clear license if session ends
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const fetchLicense = async (email: string) => {
    const { data, error } = await supabase
      .from("licences")
      .select("*")
      .eq("email", email)
      .single();

    if (error && error.code === 'PGRST116') { // No rows found
      setLicense(null);
      setError("Cet email n'est associé à aucune commande FantomePad.");
    } else if (error) {
      setError(error.message || "Une erreur est survenue lors de la récupération de la licence.");
    } else {
      setLicense(data);
    }
    setLoading(false);
  };

  const handleSendOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setMessage(null);

    try {
      // Check if license exists before sending OTP
      const { data: licenseData, error: licenseError } = await supabase
        .from("licences")
        .select("id")
        .eq("email", email.toLowerCase())
        .single();

      if (licenseError || !licenseData) {
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

      window.location.reload();
    } catch (err: any) {
      setError(err.message || "Code invalide ou expiré.");
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

  // Dashboard View (Full Screen)
  if (session && license?.activation_code) {
    return (
      <Dashboard
        email={session.user.email}
        activationCode={license.activation_code}
        status={license.status}
      />
    );
  }

  // Auth & Onboarding View (Centered Card)
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
        className={`relative z-10 w-full ${session ? "max-w-5xl" : "max-w-md"} transition-all duration-500`}
      >
        {session ? (
          // Onboarding State (Within Card)
          <OnboardingFlow
            email={session.user.email}
            onComplete={() => fetchLicense(session.user.email)}
          />
        ) : (
          <div className="p-[1px] rounded-2xl bg-gradient-to-b from-brand-border to-transparent">
            <div className="bg-brand-bg rounded-2xl p-8 md:p-12 border border-brand-border/50 min-h-[500px] flex flex-col justify-center">
              {/* Login Form State */}
              <header className="text-center mb-10">
                <motion.span
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.2 }}
                  className="text-xs font-bold tracking-[0.2em] text-brand-gray uppercase mb-3 block"
                >
                  {step === "email" ? "Accès Propriétaire" : "Vérification"}
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
                    <>Saisissez votre <br /> <span className="text-brand-gray">code OTP.</span></>
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
                    {message && (
                      <div className="flex items-center gap-2 p-3 rounded-lg bg-green-500/10 border border-green-500/20 text-green-400 text-xs">
                        <CheckCircle2 className="h-4 w-4 shrink-0" />
                        <span>{message}</span>
                      </div>
                    )}

                    <div className="space-y-2">
                      <label className="text-[10px] font-bold text-brand-gray tracking-widest uppercase ml-1">
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
                        Modifier l'email
                      </button>
                    )}
                  </form>
                </motion.div>
              </AnimatePresence>

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
        )}
      </motion.div>
    </main>
  );
}
