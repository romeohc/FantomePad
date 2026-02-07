
import { useState, useEffect, useCallback, useMemo } from "react";
import { createClient } from "@/utils/supabase";

/**
 * Onboarding steps:
 * 1. platform_selection: User chooses MT4 or MT5
 * 2. install: User confirms installation or downloads platform
 * 3. activation: User generates/views their license code
 */
export type OnboardingStep = "platform_selection" | "install" | "activation";
export type Platform = "mt4" | "mt5" | null;

export const useOnboarding = (email: string) => {
    // Initialize state
    const [step, setStep] = useState<OnboardingStep>("platform_selection");
    const [platform, setPlatform] = useState<Platform>(null);
    const [activationCode, setActivationCode] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    // Memoize the supabase client to prevent recreation on every render
    const supabase = useMemo(() => createClient(), []);

    const checkExistingLicense = useCallback(async () => {
        if (!email) return;

        try {
            const { data } = await supabase
                .from("licences")
                .select("activation_code")
                .ilike("email", email) // Case-insensitive match
                .single();

            if (data?.activation_code) {
                setActivationCode(data.activation_code);
                setStep("activation"); // Jump to end if code exists
                // Clear local storage for step since we are done, or keep it as "activation"
                localStorage.setItem("onboarding_step", "activation");
            }
        } catch (err) {
            console.error("Error checking license:", err);
        }
    }, [email, supabase]);

    // Load state from localStorage on mount (Client-side only)
    useEffect(() => {
        if (typeof window !== "undefined") {
            const savedStep = localStorage.getItem("onboarding_step") as OnboardingStep;
            const savedPlatform = localStorage.getItem("onboarding_platform") as Platform;

            if (savedStep) setStep(savedStep);
            if (savedPlatform) setPlatform(savedPlatform);
        }

        // Always check the specific license status from DB effectively acting as the "source of truth"
        checkExistingLicense();
    }, [email, checkExistingLicense]); // Re-run if email changes (e.g. login)

    // Persist state changes to localStorage
    useEffect(() => {
        if (typeof window !== "undefined") {
            if (step) localStorage.setItem("onboarding_step", step);
            if (platform) localStorage.setItem("onboarding_platform", platform);
        }
    }, [step, platform]);



    // Generate a random activation code (Format: FP-XXXX-XXXX)
    const generateCode = () => {
        const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        const segment = () => Array.from({ length: 4 }, () => chars[Math.floor(Math.random() * chars.length)]).join("");
        return `FP-${segment()}-${segment()}`;
    };


    const activateLicense = async () => {
        if (!email) return;

        setLoading(true);
        setError(null);

        try {
            // 1. Check if code already exists (double check)
            const { data: existing } = await supabase
                .from("licences")
                .select("activation_code")
                .ilike("email", email)
                .single();

            if (existing?.activation_code) {
                setActivationCode(existing.activation_code);
                setStep("activation");
                setLoading(false);
                return;
            }

            // 2. Generate and Update
            const newCode = generateCode();

            const { data: updated, error: updateError } = await supabase
                .from("licences")
                .update({ activation_code: newCode })
                .ilike("email", email)
                .select("activation_code")
                .single();

            if (updateError) throw updateError;

            if (updated?.activation_code) {
                setActivationCode(updated.activation_code);
                setStep("activation");
            } else {
                throw new Error("Activation failed - no data returned");
            }

        } catch (err: unknown) {
            console.error("Activation error:", err);
            setError("Erreur d'activation. Veuillez réessayer.");
        } finally {
            setLoading(false);
        }
    };

    const getProgress = () => {
        switch (step) {
            case "platform_selection": return 33;
            case "install": return 66;
            case "activation": return 100;
            default: return 0;
        }
    };

    return {
        step,
        setStep,
        platform,
        setPlatform,
        activationCode,
        activateLicense,
        loading,
        error,
        progress: getProgress(),
    };
};
