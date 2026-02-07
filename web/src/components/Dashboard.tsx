import { LogOut, Activity, Monitor, RefreshCw } from "lucide-react";
import { useState } from "react";
import { createClient } from "@/utils/supabase";

interface DashboardProps {
    email: string;
    activationCode: string;
}

export default function Dashboard({ email, activationCode }: DashboardProps) {
    const [resetting, setResetting] = useState(false);
    const supabase = createClient();

    const handleLogout = async () => {
        await supabase.auth.signOut();
        window.location.reload();
    };

    const handleReset = async () => {
        setResetting(true);
        // Simulation du reset
        setTimeout(() => setResetting(false), 2000);
    };

    return (
        <div className="w-full max-w-lg space-y-6 animate-in fade-in duration-700">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-white">Dashboard</h1>
                    <p className="text-brand-gray text-xs truncate max-w-[200px]">{email}</p>
                </div>
                <div className="px-3 py-1 rounded-full bg-green-500/10 border border-green-500/20 text-green-400 text-[10px] font-bold uppercase tracking-wide flex items-center gap-2">
                    <span className="relative flex h-2 w-2">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                    </span>
                    Actif
                </div>
            </div>

            {/* Main Stats Card */}
            <div className="bg-[#1A1A1A] border border-brand-border rounded-xl p-6 space-y-6">
                <div className="flex items-start justify-between">
                    <div className="space-y-1">
                        <div className="text-xs text-brand-gray uppercase tracking-widest">Code Licence</div>
                        <div className="text-xl font-mono font-bold text-white tracking-wider">{activationCode}</div>
                    </div>
                    <Activity className="h-5 w-5 text-brand-blue" />
                </div>

                <div className="h-px w-full bg-brand-border/50" />

                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="bg-brand-bg p-2 rounded-lg border border-brand-border">
                            <Monitor className="h-5 w-5 text-white" />
                        </div>
                        <div>
                            <div className="text-xs text-brand-gray">Machine ID</div>
                            <div className="text-sm text-white font-mono">HW-7823-99X1</div>
                        </div>
                    </div>

                    <button
                        onClick={handleReset}
                        disabled={resetting}
                        className="text-xs text-brand-gray hover:text-white underline decoration-brand-gray/50 hover:decoration-white transition-all disabled:opacity-50"
                    >
                        {resetting ? "Reset..." : "Reset HWID"}
                    </button>
                </div>
            </div>

            {/* Actions */}
            <div className="grid grid-cols-2 gap-4">
                <div className="p-4 bg-[#1A1A1A] border border-brand-border rounded-xl space-y-2">
                    <div className="text-2xl font-bold text-white">MT4</div>
                    <div className="text-xs text-brand-gray">Plateforme active</div>
                </div>
                <div className="p-4 bg-[#1A1A1A] border border-brand-border rounded-xl space-y-2 opacity-50">
                    <div className="text-2xl font-bold text-white">MT5</div>
                    <div className="text-xs text-brand-gray">Non configuré</div>
                </div>
            </div>

            <button
                onClick={handleLogout}
                className="w-full flex items-center justify-center gap-2 text-xs text-brand-gray hover:text-white py-4 transition-colors"
            >
                <LogOut className="h-3 w-3" />
                Se déconnecter
            </button>
        </div>
    );
}
