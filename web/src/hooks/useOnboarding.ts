
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
            // 1. Check existing license
            const { data: current, error: checkError } = await supabase
                .from("licences")
                .select("activation_code")
                .ilike("email", email)
                .single();

            if (checkError && checkError.code !== 'PGRST116') { // PGRST116 means "no rows found"
                throw checkError;
            }

            // If code exists and is not empty, we are done
            if (current?.activation_code) {
                setActivationCode(current.activation_code);
                setStep("activation");
                setLoading(false);
                return;
            }

            // 2. Generate and Update
            // The row should exist (created at purchase), so we just update the code
            const newCode = generateCode();
            console.log("Generating code for:", email);

            const { data: updated, error: updateError } = await supabase
                .from("licences")
                .update({
                    activation_code: newCode,
                    status: 'pending', // Set to pending so user sees the setup dashboard
                    last_check: new Date().toISOString()
                })
                .ilike("email", email)
                .select("activation_code")
                .single();

            if (updateError) {
                console.error("Supabase Update Error:", updateError);
                throw updateError;
            }

            if (updated?.activation_code) {
                setActivationCode(updated.activation_code);
                setStep("activation");
            } else {
                throw new Error("Update succeeded but returned no data");
            }

        } catch (err: unknown) {
            console.error("Full Activation Error:", JSON.stringify(err, null, 2));
            const msg = (err as Error)?.message || "Erreur inconnue";
            setError(`Erreur: ${msg}`);
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
