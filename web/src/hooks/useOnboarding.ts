
import { useState, useEffect, useCallback, useMemo } from "react";
import { createClient } from "@/utils/supabase";

/**
 * Onboarding steps:
 * 1. platform_selection: User chooses MT4 or MT5
 * 2. install: User confirms platform installation
 * 3. download: User downloads the Expert Advisor software
 * 4. activation: Tutorial video + License Key + Waiting for active status
 */
export type OnboardingStep = "platform_selection" | "install" | "download" | "activation";
export type Platform = "mt4" | "mt5" | null;
export type OperatingSystem = "windows" | "mac" | null;

interface LicenseData {
    activation_code?: string;
    status?: string;
}

export const useOnboarding = (email: string, initialData?: LicenseData | null) => {
    // Initialize state
    const [step, setStep] = useState<OnboardingStep>("platform_selection");
    const [platform, setPlatform] = useState<Platform>(null);
    const [os, setOs] = useState<OperatingSystem>(null);
    const [activationCode, setActivationCode] = useState<string | null>(initialData?.activation_code || null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    // Memoize the supabase client to prevent recreation on every render
    const supabase = useMemo(() => createClient(), []);

    const checkExistingLicense = useCallback(async () => {
        if (!email) return;

        // specific check if we already have initialData from parent
        if (initialData?.activation_code) {
            setActivationCode(initialData.activation_code);
            return;
        }

        try {
            const { data } = await supabase
                .from("licences")
                .select("activation_code")
                .ilike("email", email) // Case-insensitive match
                .single();

            if (data?.activation_code) {
                setActivationCode(data.activation_code);
            }
        } catch (err) {
            console.error("Error checking license:", err);
        }
    }, [email, supabase, initialData]);

    // Load state from localStorage on mount (Client-side only)
    useEffect(() => {
        if (typeof window !== "undefined" && email) {
            const savedStep = localStorage.getItem(`onboarding_step_${email}`) as OnboardingStep;
            const savedPlatform = localStorage.getItem(`onboarding_platform_${email}`) as Platform;
            const savedOs = localStorage.getItem(`onboarding_os_${email}`) as OperatingSystem;

            // Always restore step if we have one in local storage
            if (savedStep) {
                setStep(savedStep);
            }

            if (savedPlatform) setPlatform(savedPlatform);
            if (savedOs) setOs(savedOs);
        }

        // Always check the specific license status from DB effectively acting as the "source of truth"
        checkExistingLicense();
    }, [email, checkExistingLicense]); // Re-run if email changes (e.g. login)

    // Persist state changes to localStorage
    useEffect(() => {
        if (typeof window !== "undefined" && email) {
            if (step) localStorage.setItem(`onboarding_step_${email}`, step);
            if (platform) localStorage.setItem(`onboarding_platform_${email}`, platform);
            if (os) localStorage.setItem(`onboarding_os_${email}`, os);
        }
    }, [step, platform, os, email]);






    const activateLicense = async () => {
        if (!email) return;

        setLoading(true);
        setError(null);

        try {
            // 1. Secure Claim via RPC
            // verification is done server-side
            const { data: updated, error: rpcError } = await supabase.rpc('claim_license');

            console.log("RPC Response - Error:", rpcError);
            console.log("RPC Response - Data:", updated);

            if (rpcError) {
                console.error("Supabase RPC Error:", rpcError);
                throw rpcError;
            }

            if (updated?.activation_code) {
                setActivationCode(updated.activation_code);
                setStep("activation");
            } else {
                throw new Error("Activation claims returned no code. Please contact support.");
            }

        } catch (err: unknown) {
            console.error("Full Activation Error:", err);
            const msg = (err as Error)?.message || "Erreur inconnue";
            setError(`Erreur: ${msg}`);
        } finally {
            setLoading(false);
        }
    };

    const getProgress = () => {
        switch (step) {
            case "platform_selection": return 25;
            case "install": return 50;
            case "download": return 75;
            case "activation": return 100;
            default: return 0;
        }
    };

    return {
        step,
        setStep,
        platform,
        setPlatform,
        os,
        setOs,
        activationCode,
        activateLicense,
        loading,
        error,
        progress: getProgress(),
    };
};
