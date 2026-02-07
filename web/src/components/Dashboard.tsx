
import {
    LogOut, Activity, Monitor, Shield, Settings, HelpCircle,
    Copy, Check, MoreVertical, CreditCard, Clock, Bell,
    ChevronRight, Zap, RefreshCw, Smartphone, Download,
    LayoutDashboard, Key, Menu, X
} from "lucide-react";
import { useState } from "react";
import { createClient } from "@/utils/supabase";
import { motion, AnimatePresence } from "framer-motion";

interface DashboardProps {
    email: string;
    activationCode: string;
    hardwareId?: string;
    status: string;
}

export default function Dashboard({ email, activationCode, hardwareId, status }: DashboardProps) {
    const supabase = createClient();
    const [activeTab, setActiveTab] = useState("overview");
    const [copied, setCopied] = useState(false);
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

    // Fictional states for non-functional features
    const [isLocked, setIsLocked] = useState(false);
    const [notifications, setNotifications] = useState(2);

    const handleLogout = async () => {
        await supabase.auth.signOut();
        window.location.reload();
    };

    const handleCopy = () => {
        if (activationCode) {
            navigator.clipboard.writeText(activationCode);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        }
    };

    const StatusIndicator = ({ status }: { status: string }) => {
        const getStyles = () => {
            switch (status?.toLowerCase()) {
                case "active":
                    return { bg: "bg-green-500/10", text: "text-green-400", dot: "bg-green-500", label: "Actif" };
                case "blocked":
                    return { bg: "bg-red-500/10", text: "text-red-400", dot: "bg-red-500", label: "Bloqué" };
                case "pending":
                default:
                    return { bg: "bg-yellow-500/10", text: "text-yellow-400", dot: "bg-yellow-500", label: "En attente" };
            }
        };
        const style = getStyles();
        return (
            <div className={`px-3 py-1.5 rounded-full ${style.bg} border border-white/5 ${style.text} text-[10px] font-bold uppercase tracking-wide flex items-center gap-2`}>
                <span className="relative flex h-2 w-2">
                    {status?.toLowerCase() === "active" && (
                        <span className={`animate-ping absolute inline-flex h-full w-full rounded-full ${style.dot} opacity-75`}></span>
                    )}
                    <span className={`relative inline-flex rounded-full h-2 w-2 ${style.dot}`}></span>
                </span>
                {style.label}
            </div>
        );
    };

    const NavItem = ({ id, icon: Icon, label, alert }: any) => (
        <button
            onClick={() => {
                setActiveTab(id);
                setMobileMenuOpen(false);
            }}
            className={`w-full flex items-center justify-between p-3 rounded-xl transition-all ${activeTab === id
                    ? "bg-brand-blue/10 text-brand-blue border border-brand-blue/20"
                    : "text-brand-gray hover:bg-white/5 hover:text-white"
                }`}
        >
            <div className="flex items-center gap-3">
                <Icon className="h-5 w-5" />
                <span className="text-sm font-medium">{label}</span>
            </div>
            {alert && (
                <span className="bg-brand-blue text-black text-[10px] font-bold px-1.5 rounded-full">{alert}</span>
            )}
        </button>
    );

    return (
        <div className="flex h-screen w-full bg-[#0A0A0A] overflow-hidden text-white select-none relative">
            {/* Mobile Menu Overlay */}
            <AnimatePresence>
                {mobileMenuOpen && (
                    <motion.div
                        initial={{ opacity: 0, x: "-100%" }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: "-100%" }}
                        transition={{ type: "tween" }}
                        className="absolute inset-0 z-50 bg-[#0F0F0F] p-6 flex flex-col md:hidden"
                    >
                        <div className="flex items-center justify-between mb-8">
                            <div className="flex items-center gap-3">
                                <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-brand-blue to-purple-600 flex items-center justify-center shadow-lg shadow-brand-blue/20">
                                    <span className="font-bold text-white">F</span>
                                </div>
                                <span className="font-bold text-lg tracking-tight">FantomePad</span>
                            </div>
                            <button onClick={() => setMobileMenuOpen(false)} className="p-2 bg-white/5 rounded-lg">
                                <X className="h-6 w-6 text-white" />
                            </button>
                        </div>
                        <div className="space-y-2 flex-1">
                            <NavItem id="overview" icon={LayoutDashboard} label="Vue d'ensemble" />
                            <NavItem id="license" icon={Key} label="Ma Licence" />
                            <NavItem id="settings" icon={Settings} label="Paramètres" />
                            <div className="h-px bg-white/5 my-4" />
                            <NavItem id="docs" icon={HelpCircle} label="Documentation" />
                            <NavItem id="updates" icon={Bell} label="Nouveautés" alert={notifications} />
                        </div>
                        <button
                            onClick={handleLogout}
                            className="mt-8 w-full flex items-center justify-center gap-2 text-xs text-brand-gray/50 hover:text-red-400 transition-colors py-4 border-t border-white/5"
                        >
                            <LogOut className="h-4 w-4" />
                            Se déconnecter
                        </button>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Sidebar (Desktop) */}
            <div className="hidden md:flex w-64 border-r border-white/5 flex-col p-6 space-y-8 bg-[#0F0F0F]">
                <div className="flex items-center gap-3 px-2">
                    <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-brand-blue to-purple-600 flex items-center justify-center shadow-lg shadow-brand-blue/20">
                        <span className="font-bold text-white">F</span>
                    </div>
                    <span className="font-bold text-lg tracking-tight">FantomePad</span>
                </div>

                <div className="space-y-2 flex-1">
                    <div className="text-[10px] font-bold text-brand-gray/50 uppercase tracking-widest px-3 mb-2">Menu Principal</div>
                    <NavItem id="overview" icon={LayoutDashboard} label="Vue d'ensemble" />
                    <NavItem id="license" icon={Key} label="Ma Licence" />
                    <NavItem id="settings" icon={Settings} label="Paramètres" />
                    <div className="pt-4">
                        <div className="text-[10px] font-bold text-brand-gray/50 uppercase tracking-widest px-3 mb-2">Support</div>
                        <NavItem id="docs" icon={HelpCircle} label="Documentation" />
                        <NavItem id="updates" icon={Bell} label="Nouveautés" alert={notifications} />
                    </div>
                </div>

                <div className="border-t border-white/5 pt-6 space-y-4">
                    <div className="bg-[#151515] p-3 rounded-xl border border-white/5 flex items-center gap-3">
                        <div className="h-8 w-8 rounded-full bg-gradient-to-tr from-gray-700 to-gray-600 flex items-center justify-center text-xs font-bold ring-2 ring-black">
                            {email.substring(0, 2).toUpperCase()}
                        </div>
                        <div className="overflow-hidden">
                            <div className="text-xs font-bold text-white truncate max-w-[120px]">{email}</div>
                            <div className="text-[10px] text-brand-gray truncate">Utilisateur Pro</div>
                        </div>
                    </div>
                    <button
                        onClick={handleLogout}
                        className="w-full flex items-center justify-center gap-2 text-xs text-brand-gray/50 hover:text-red-400 transition-colors"
                    >
                        <LogOut className="h-3 w-3" />
                        Se déconnecter
                    </button>
                </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 flex flex-col h-full overflow-hidden relative bg-[#0A0A0A]">
                {/* Top Bar */}
                <header className="h-16 border-b border-white/5 flex items-center justify-between px-4 md:px-8 bg-[#0A0A0A]/80 backdrop-blur-xl z-20 sticky top-0">
                    <div className="flex items-center gap-4">
                        <button
                            onClick={() => setMobileMenuOpen(true)}
                            className="md:hidden p-2 -ml-2 text-brand-gray hover:text-white"
                        >
                            <Menu className="h-6 w-6" />
                        </button>
                        <h2 className="text-lg font-bold truncate">Vue d'ensemble</h2>
                    </div>

                    <div className="flex items-center gap-3">
                        <div className="hidden md:flex items-center gap-1 text-xs text-brand-gray mr-4">
                            <Clock className="h-3 w-3" />
                            <span className="hidden lg:inline">Dernière synchro:</span> À l'instant
                        </div>
                        <div className="h-8 w-8 rounded-full bg-gradient-to-tr from-gray-700 to-gray-600 flex md:hidden items-center justify-center text-xs font-bold ring-2 ring-black">
                            {email.substring(0, 2).toUpperCase()}
                        </div>
                        <div className="hidden md:block px-3 py-1.5 rounded-full bg-white/5 border border-white/5 text-[10px] font-mono text-brand-gray">
                            v2.4.1
                        </div>
                    </div>
                </header>

                {/* Dashboard Grid */}
                <main className="flex-1 overflow-y-auto p-4 md:p-8 scrollbar-hide">
                    <div className="max-w-6xl mx-auto space-y-6 md:space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700 pb-20 md:pb-0">

                        {/* Status Hero Section */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6">
                            <div className="md:col-span-2 relative group">
                                <div className="absolute inset-0 bg-gradient-to-r from-brand-blue/10 to-purple-500/10 rounded-2xl blur-xl opacity-50 group-hover:opacity-75 transition-opacity"></div>
                                <div className="relative h-full bg-[#121212] border border-white/5 p-5 md:p-6 rounded-2xl flex flex-col justify-between overflow-hidden">
                                    <div className="flex justify-between items-start mb-6 md:mb-0">
                                        <div>
                                            <div className="text-sm text-brand-gray mb-1">Statut de la Licence</div>
                                            <div className="flex flex-wrap items-center gap-3">
                                                <h3 className="text-2xl md:text-3xl font-bold text-white">FantomePad Pro</h3>
                                                <StatusIndicator status={status} />
                                            </div>
                                        </div>
                                        <div className="bg-white/5 p-2 rounded-lg shrink-0">
                                            <Shield className="h-5 w-5 md:h-6 md:w-6 text-brand-blue" />
                                        </div>
                                    </div>

                                    <div className="mt-4 md:mt-8 grid grid-cols-2 md:grid-cols-3 gap-3">
                                        <div className="bg-black/20 p-3 rounded-lg border border-white/5">
                                            <div className="text-[10px] text-brand-gray uppercase mb-1">Renouvellement</div>
                                            <div className="text-xs md:text-sm font-bold text-white">Lifetime Access</div>
                                        </div>
                                        <div className="bg-black/20 p-3 rounded-lg border border-white/5">
                                            <div className="text-[10px] text-brand-gray uppercase mb-1">Serveur</div>
                                            <div className="text-xs md:text-sm font-bold text-green-400 flex items-center gap-1">
                                                <Zap className="h-3 w-3" />
                                                Connecté
                                            </div>
                                        </div>
                                        <div className="hidden md:block bg-black/20 p-3 rounded-lg border border-white/5">
                                            <div className="text-[10px] text-brand-gray uppercase mb-1">Sécurité</div>
                                            <div className="text-xs md:text-sm font-bold text-white">Maximal</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            {/* HWID Card */}
                            <div className="bg-[#121212] border border-white/5 p-5 md:p-6 rounded-2xl flex flex-col justify-between hover:border-brand-gray/20 transition-colors gap-4">
                                <div className="flex justify-between items-start">
                                    <div className="overflow-hidden">
                                        <div className="text-sm text-brand-gray mb-1">Hardware ID (HWID)</div>
                                        <div className="text-base md:text-lg font-mono font-bold text-white truncate w-full">
                                            {hardwareId || "Non lié"}
                                        </div>
                                    </div>
                                    <Monitor className="h-5 w-5 text-purple-400 shrink-0" />
                                </div>
                                <div className="mt-auto">
                                    <div className="flex items-center justify-between text-xs text-brand-gray mb-2">
                                        <span>Dernière connexion</span>
                                        <span>2 min</span>
                                    </div>
                                    <div className="h-1 w-full bg-white/5 rounded-full overflow-hidden">
                                        <div className="h-full bg-purple-500 w-3/4 rounded-full"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Middle Section: Activation Code & Actions */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6">
                            {/* License Code */}
                            <div className="md:col-span-2 bg-[#121212] border border-white/5 p-5 md:p-6 rounded-2xl">
                                <div className="flex flex-col md:flex-row items-start md:items-center justify-between mb-6 gap-4">
                                    <div className="flex items-center gap-3">
                                        <div className="p-2 bg-brand-blue/10 rounded-lg text-brand-blue">
                                            <Key className="h-5 w-5" />
                                        </div>
                                        <div>
                                            <h4 className="text-base font-bold text-white">Clé d'Activation</h4>
                                            <p className="text-xs text-brand-gray">Clé unique pour votre EA</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2 self-end md:self-auto">
                                        <span className="text-[10px] font-bold text-brand-gray uppercase tracking-wider hidden md:inline">Protection</span>
                                        <button
                                            onClick={() => setIsLocked(!isLocked)}
                                            className={`w-10 h-6 rounded-full p-1 transition-colors ${isLocked ? 'bg-brand-blue' : 'bg-white/10'}`}
                                        >
                                            <div className={`h-4 w-4 bg-white rounded-full transition-transform ${isLocked ? 'translate-x-4' : 'translate-x-0'}`}></div>
                                        </button>
                                    </div>
                                </div>

                                <div className="relative group">
                                    <div className="bg-black/40 border border-white/5 rounded-xl p-3 md:p-4 flex items-center justify-between font-mono text-base md:text-xl tracking-widest text-center shadow-inner overflow-hidden">
                                        <span className="truncate mr-2">
                                            {isLocked ? "•••• - •••• - ••••" : activationCode}
                                        </span>
                                        <button
                                            onClick={handleCopy}
                                            className="p-2 hover:bg-white/10 rounded-lg transition-colors text-brand-gray hover:text-white shrink-0"
                                        >
                                            {copied ? <Check className="h-5 w-5 text-green-400" /> : <Copy className="h-5 w-5" />}
                                        </button>
                                    </div>
                                </div>
                            </div>

                            {/* Platform Actions */}
                            <div className="bg-[#121212] border border-white/5 p-5 md:p-6 rounded-2xl flex flex-col space-y-4">
                                <h4 className="text-sm font-bold text-white flex items-center gap-2">
                                    <Smartphone className="h-4 w-4 text-brand-gray" />
                                    Plateformes
                                </h4>

                                <button className="flex items-center justify-between p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 transition-all group">
                                    <div className="flex items-center gap-3">
                                        <div className="h-2 w-2 rounded-full bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.5)]"></div>
                                        <span className="font-bold text-sm">MetaTrader 4</span>
                                    </div>
                                    <Download className="h-4 w-4 text-brand-gray group-hover:text-white" />
                                </button>
                                <button className="flex items-center justify-between p-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/5 transition-all group opacity-50">
                                    <div className="flex items-center gap-3">
                                        <div className="h-2 w-2 rounded-full bg-brand-gray"></div>
                                        <span className="font-bold text-sm text-brand-gray">MetaTrader 5</span>
                                    </div>
                                    <span className="text-[10px] bg-white/10 px-2 py-0.5 rounded text-brand-gray">Bientôt</span>
                                </button>
                            </div>
                        </div>

                        {/* Graph Section (Fictional) - Hidden on very small screens if needed, but we'll try to keep it responsive */}
                        <div className="bg-[#121212] border border-white/5 p-5 md:p-6 rounded-2xl hidden md:block">
                            <div className="flex items-center justify-between mb-6">
                                <div>
                                    <h4 className="text-base font-bold text-white">Activité du Trading</h4>
                                    <p className="text-xs text-brand-gray">Performance de l'EA sur les 30 derniers jours</p>
                                </div>
                                <div className="flex gap-2">
                                    {['1H', '24H', '7J', '30J'].map((t) => (
                                        <button key={t} className={`px-3 py-1 rounded-lg text-xs font-bold ${t === '30J' ? 'bg-brand-blue text-black' : 'bg-white/5 text-brand-gray hover:bg-white/10'}`}>
                                            {t}
                                        </button>
                                    ))}
                                </div>
                            </div>

                            {/* Fake Graph Visual */}
                            <div className="h-48 w-full flex items-end gap-2 px-2">
                                {Array.from({ length: 40 }).map((_, i) => {
                                    const height = Math.random() * 80 + 20 + "%";
                                    return (
                                        <div
                                            key={i}
                                            className="flex-1 bg-brand-blue/20 hover:bg-brand-blue/50 transition-colors rounded-t-sm relative group"
                                            style={{ height }}
                                        >
                                            {/* Tooltip on hover */}
                                            <div className="absolute -top-8 left-1/2 -translate-x-1/2 bg-black border border-white/10 px-2 py-1 rounded text-[10px] text-white opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-10">
                                                Trade #{i + 1}
                                            </div>
                                        </div>
                                    )
                                })}
                            </div>
                        </div>

                    </div>
                </main>
            </div>
        </div>
    );
}
