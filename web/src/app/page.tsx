"use client";

import { motion, AnimatePresence } from "framer-motion";
import { useState, useEffect, useCallback, useMemo } from "react";
import { ArrowRight, Mail, KeyRound, AlertCircle, CheckCircle2, Monitor } from "lucide-react";
import { createClient } from "@/utils/supabase";
import OnboardingFlow from "@/components/OnboardingFlow";
import Dashboard from "@/components/Dashboard";
import SpaceBackground from "@/components/SpaceBackground";
import LoginForm from "@/components/LoginForm";
import type { Session } from "@supabase/supabase-js";

interface LicenseData {
  id?: string;
  email: string;
  activation_code?: string;
  status?: string;
}

export default function Home() {
  const [session, setSession] = useState<Session | null>(null);
  const [license, setLicense] = useState<LicenseData | null>(null);
  const [email, setEmail] = useState("");
  const [code, setCode] = useState("");
  const [loading, setLoading] = useState(true);
  const [step, setStep] = useState<"email" | "otp">("email");
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768);
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  // Memoize the supabase client to prevent recreation on every render
  const supabase = useMemo(() => createClient(), []);

  const fetchLicense = useCallback(async (userEmail: string) => {
    const { data, error: fetchError } = await supabase
      .from("licences")
      .select("*")
      .eq("email", userEmail)
      .single();

    if (fetchError && fetchError.code === 'PGRST116') { // No rows found
      setLicense(null);
      setError("Cet email n'est associé à aucune commande FantomePad.");
    } else if (fetchError) {
      setError(fetchError.message || "Une erreur est survenue lors de la récupération de la licence.");
    } else {
      setLicense(data);
    }
    setLoading(false);
  }, [supabase]);

  useEffect(() => {
    // Check current session
    const initSession = async () => {
      const { data: { session: currentSession } } = await supabase.auth.getSession();
      setSession(currentSession);
      if (currentSession?.user?.email) {
        fetchLicense(currentSession.user.email);
      } else {
        setLoading(false);
      }
    };

    initSession();

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, newSession) => {
      setSession(newSession);
      if (newSession?.user?.email) {
        fetchLicense(newSession.user.email);
      } else {
        setLicense(null); // Clear license if session ends
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, [supabase.auth, fetchLicense]);



  const handleSendOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setMessage(null);

    try {
      // Check if license exists using Secure RPC (prevents public RLS exposure)
      const { data: exists, error: rpcError } = await supabase
        .rpc('check_license_exists', { email_input: email.toLowerCase() });

      if (rpcError) {
        throw rpcError;
      }

      if (!exists) {
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
      setMessage("Code de vérification envoyé.");
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Une erreur est survenue.");
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
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Code invalide ou expiré.");
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

  // Dashboard View (Full Screen) - Only if active or blocked
  if (session && license?.activation_code && (license?.status === 'active' || license?.status === 'blocked')) {
    return (
      <Dashboard
        email={session.user.email || ""}
        activationCode={license.activation_code}
        status={license.status}
      />
    );
  }

  // Auth & Onboarding View (Centered Card)
  // Auth & Onboarding View (Centered Card)
  return (
    <main className="flex min-h-screen items-center justify-center p-4 bg-[#050505] select-none relative overflow-hidden">
      {!session && <SpaceBackground isMobile={isMobile} />}

      {session && (
        <div className="absolute inset-0 z-0 overflow-hidden pointer-events-none">
          <div className="absolute -top-1/4 -right-1/4 w-1/2 h-1/2 bg-brand-blue/5 blur-[120px] rounded-full" />
          <div className="absolute -bottom-1/4 -left-1/4 w-1/2 h-1/2 bg-brand-blue/5 blur-[120px] rounded-full" />
        </div>
      )}

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, ease: "easeOut" }}
        className={`relative z-10 w-full ${session ? "max-w-6xl" : "max-w-md"} transition-all duration-500`}
      >
        {session ? (
          // Onboarding State (Within Card)
          <OnboardingFlow
            email={session.user.email || ""}
            initialData={license}
            onComplete={() => fetchLicense(session.user.email || "")}
          />
        ) : (
          <LoginForm
            step={step}
            email={email}
            code={code}
            setEmail={setEmail}
            setCode={setCode}
            loading={loading}
            error={error}
            message={message}
            handleSendOTP={handleSendOTP}
            handleVerifyOTP={handleVerifyOTP}
            setStep={setStep}
          />
        )}
      </motion.div>
    </main>
  );
}
