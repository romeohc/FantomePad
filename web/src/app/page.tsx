"use client";

import { motion } from "framer-motion";
import { useState } from "react";
import { ArrowRight, Mail } from "lucide-react";

export default function Home() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    // Logic will be added in Phase 3
    setTimeout(() => setLoading(false), 1500);
  };

  return (
    <main className="flex min-h-screen items-center justify-center p-4 bg-brand-bg select-none">
      {/* Background Subtle Accent */}
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
            {/* Header */}
            <header className="text-center mb-10">
              <motion.span 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.2 }}
                className="text-xs font-bold tracking-[0.2em] text-brand-gray uppercase mb-3 block"
              >
                Welcome to FantomePad
              </motion.span>
              <motion.h1 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.3 }}
                className="text-2xl md:text-3xl font-bold text-white tracking-tight"
              >
                The new standard <br /> 
                <span className="text-brand-gray">is here.</span>
              </motion.h1>
            </header>

            {/* Login Form */}
            <form onSubmit={handleLogin} className="space-y-6">
              <div className="space-y-2">
                <label className="text-[10px] font-bold text-brand-gray tracking-widest uppercase ml-1">
                  Email d'achat Shopify
                </label>
                <div className="relative group">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <Mail className="h-4 w-4 text-brand-gray group-focus-within:text-white transition-colors" />
                  </div>
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="nom@exemple.com"
                    className="w-full bg-[#1A1A1A] border border-brand-border rounded-xl py-3 pl-11 pr-4 text-white placeholder:text-brand-gray/50 focus:outline-none focus:ring-1 focus:ring-brand-blue focus:border-transparent transition-all"
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
                    Continuer
                    <ArrowRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
                  </>
                )}
              </button>
            </form>

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
