
import { useState, useEffect } from "react";
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

    const supabase = createClient();

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
    }, [email]); // Re-run if email changes (e.g. login)

    // Persist state changes to localStorage
    useEffect(() => {
        if (typeof window !== "undefined") {
            if (step) localStorage.setItem("onboarding_step", step);
            if (platform) localStorage.setItem("onboarding_platform", platform);
        }
    }, [step, platform]);

    const checkExistingLicense = async () => {
        if (!email) return;

        try {
            const { data, error } = await supabase
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
    };

    // Generate a random activation code (Format: FP-XXXX-XXXX)
    const generateCode = () => {
        const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        const segment = () => Array.from({ length: 4 }, () => chars[Math.floor(Math.random() * chars.length)]).join("");
        return `FP-${segment()}-${segment()}`;
    };


    const activateLicense = async () => {
        if (!email) return;

        // Safety check: Don't generate if already exists in state
        if (activationCode) return;

        setLoading(true);
        setError(null);

        // Double check DB before writing (in case state is stale)
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

        try {
            const newCode = generateCode();

            // Only update if activation_code is currently NULL
            const { error: updateError } = await supabase
                .from("licences")
                .update({ activation_code: newCode })
                .ilike("email", email) // Case-insensitive match for safety
                .is("activation_code", null);

            if (updateError) throw updateError;

            // Verification: Read it back to be sure
            await checkExistingLicense();

        } catch (err: any) {
            setError("Erreur lors de l'activation. Veuillez réessayer.");
            console.error(err);
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
