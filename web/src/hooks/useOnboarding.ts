import { useState, useEffect } from "react";
import { createClient } from "@/utils/supabase";

export type OnboardingStep = "platform_selection" | "install" | "activation";
export type Platform = "mt4" | "mt5" | null;

export const useOnboarding = (email: string) => {
    const [step, setStep] = useState<OnboardingStep>("platform_selection");
    const [platform, setPlatform] = useState<Platform>(null);
    const [activationCode, setActivationCode] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const supabase = createClient();

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

        const newCode = generateCode();

        try {
            const { error: updateError } = await supabase
                .from("licences")
                .update({ activation_code: newCode })
                .eq("email", email);

            if (updateError) throw updateError;

            setActivationCode(newCode);
        } catch (err: any) {
            setError("Erreur lors de l'activation. Veuillez réessayer.");
            console.error(err);
        } finally {
            setLoading(false);
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
    };
};
