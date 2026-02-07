import { LogOut, Activity, Monitor } from "lucide-react";
import { createClient } from "@/utils/supabase";

interface DashboardProps {
    email: string;
    activationCode: string;
    hardwareId?: string;
    status: string;
}

export default function Dashboard({ email, activationCode, hardwareId, status }: DashboardProps) {
    const supabase = createClient();

    const handleLogout = async () => {
        await supabase.auth.signOut();
        window.location.reload();
    };

    const getStatusStyles = () => {
        switch (status?.toLowerCase()) {
            case "active":
                return {
                    bg: "bg-green-500/10",
                    border: "border-green-500/20",
                    text: "text-green-400",
                    label: "Actif",
                    dot: "bg-green-500"
                };
            case "blocked":
                return {
                    bg: "bg-red-500/10",
                    border: "border-red-500/20",
                    text: "text-red-400",
                    label: "Bloqué",
                    dot: "bg-red-500"
                };
            case "pending":
            default:
                return {
                    bg: "bg-yellow-500/10",
                    border: "border-yellow-500/20",
                    text: "text-yellow-400",
                    label: "En attente",
                    dot: "bg-yellow-500"
                };
        }
    };

    const statusStyle = getStatusStyles();

    return (
        <div className="w-full max-w-lg space-y-6 animate-in fade-in duration-700">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-white">Dashboard</h1>
                    <p className="text-brand-gray text-xs truncate max-w-[200px]">{email}</p>
                </div>
                <div className={`px-3 py-1 rounded-full ${statusStyle.bg} border ${statusStyle.border} ${statusStyle.text} text-[10px] font-bold uppercase tracking-wide flex items-center gap-2`}>
                    <span className="relative flex h-2 w-2">
                        {status?.toLowerCase() === "active" && (
                            <span className={`animate-ping absolute inline-flex h-full w-full rounded-full ${statusStyle.dot} opacity-75`}></span>
                        )}
                        <span className={`relative inline-flex rounded-full h-2 w-2 ${statusStyle.dot}`}></span>
                    </span>
                    {statusStyle.label}
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
                            <div className="text-xs text-brand-gray">Hardware ID</div>
                            <div className="text-sm text-white font-mono">
                                {hardwareId || "Non lié"}
                            </div>
                        </div>
                    </div>
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
