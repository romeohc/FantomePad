import {
    LogOut, Monitor, Shield, HelpCircle,
    Copy, Check, Clock, Bell,
    Zap, Smartphone, Download,
    LayoutDashboard, Menu, X, PlayCircle, Calendar
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
            <div className={`px-4 py-2 rounded-full ${style.bg} border border-white/5 ${style.text} text-xs font-bold uppercase tracking-wide flex items-center gap-2`}>
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
            className={`w-full flex items-center justify-between p-4 rounded-xl transition-all ${activeTab === id
                ? "bg-brand-blue/10 text-brand-blue border border-brand-blue/20"
                : "text-brand-gray hover:bg-white/5 hover:text-white"
                }`}
        >
            <div className="flex items-center gap-3">
                <Icon className="h-5 w-5" />
                <span className="text-sm font-bold">{label}</span>
            </div>
            {alert && (
                <span className="bg-brand-blue text-black text-[10px] font-bold px-2 py-0.5 rounded-full">{alert}</span>
            )}
        </button>
    );

    return (
        <div className="flex h-screen w-full bg-[#0A0A0A] overflow-hidden text-white select-none relative font-sans">
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
                        <div className="flex items-center justify-between mb-12">
                            <div className="flex items-center gap-3">
                                <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-brand-blue to-purple-600 flex items-center justify-center shadow-lg shadow-brand-blue/20">
                                    <span className="font-bold text-white text-xl">F</span>
                                </div>
                                <span className="font-bold text-2xl tracking-tight">FantomePad</span>
                            </div>
                            <button onClick={() => setMobileMenuOpen(false)} className="p-2 bg-white/5 rounded-xl hover:bg-white/10 transition-colors">
                                <X className="h-6 w-6 text-white" />
                            </button>
                        </div>
                        <div className="space-y-3 flex-1">
                            <NavItem id="overview" icon={LayoutDashboard} label="Vue d'ensemble" />
                            <NavItem id="docs" icon={HelpCircle} label="Documentation" />
                            <NavItem id="updates" icon={Bell} label="Nouveautés" alert={notifications} />
                        </div>
                        <button
                            onClick={handleLogout}
                            className="mt-8 w-full flex items-center justify-center gap-2 text-sm font-bold text-red-400 bg-red-500/10 hover:bg-red-500/20 py-4 rounded-xl transition-all border border-red-500/20"
                        >
                            <LogOut className="h-4 w-4" />
                            Se déconnecter
                        </button>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Sidebar (Desktop) */}
            <div className="hidden md:flex w-72 border-r border-white/5 flex-col p-6 space-y-8 bg-[#0F0F0F]">
                <div className="flex items-center gap-3 px-2">
                    <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-brand-blue to-purple-600 flex items-center justify-center shadow-lg shadow-brand-blue/20">
                        <span className="font-bold text-white text-xl">F</span>
                    </div>
                    <span className="font-bold text-xl tracking-tight">FantomePad</span>
                </div>

                <div className="space-y-2 flex-1 pt-6">
                    <NavItem id="overview" icon={LayoutDashboard} label="Vue d'ensemble" />
                    <NavItem id="docs" icon={HelpCircle} label="Documentation" />
                    <NavItem id="updates" icon={Bell} label="Nouveautés" alert={notifications} />
                </div>

                <div className="pt-6">
                    <button
                        onClick={handleLogout}
                        className="w-full flex items-center justify-center gap-2 text-sm font-bold text-red-400 bg-red-500/10 hover:bg-red-500/20 py-4 rounded-xl transition-all border border-red-500/20 group"
                    >
                        <LogOut className="h-4 w-4 group-hover:-translate-x-1 transition-transform" />
                        Se déconnecter
                    </button>
                </div>
            </div>

            {/* Main Content */}
            <div className="flex-1 flex flex-col h-full overflow-hidden relative bg-[#0A0A0A]">
                {/* Top Bar */}
                <header className="h-20 border-b border-white/5 flex items-center justify-between px-6 md:px-10 bg-[#0A0A0A]/80 backdrop-blur-xl z-20 sticky top-0">
                    <div className="flex items-center gap-4">
                        <button
                            onClick={() => setMobileMenuOpen(true)}
                            className="md:hidden p-2 -ml-2 text-brand-gray hover:text-white"
                        >
                            <Menu className="h-6 w-6" />
                        </button>
                        <h2 className="text-xl font-bold truncate">
                            {activeTab === 'overview' && "Tableau de Bord"}
                            {activeTab === 'docs' && "Centre de Ressources"}
                            {activeTab === 'updates' && "Dernières Annonces"}
                        </h2>
                    </div>

                    <div className="flex items-center gap-3">
                        <div className="hidden md:flex items-center gap-2 text-xs text-brand-gray mr-4 bg-white/5 px-3 py-1.5 rounded-lg border border-white/5">
                            <Clock className="h-3 w-3" />
                            <span>Connecté</span>
                        </div>
                        <div className="h-9 w-9 rounded-full bg-gradient-to-tr from-gray-700 to-gray-600 flex items-center justify-center text-xs font-bold ring-2 ring-black">
                            {email.substring(0, 2).toUpperCase()}
                        </div>
                    </div>
                </header>

                {/* Dashboard Content */}
                <main className="flex-1 overflow-y-auto p-4 md:p-10 scrollbar-hide">
                    <div className="max-w-7xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-700 pb-20 md:pb-0">

                        {activeTab === 'overview' && (
                            <div className="space-y-6">
                                {/* Top Row: Status & HWID - BIGGER cards */}
                                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                                    {/* Status Card */}
                                    <div className="relative group min-h-[220px]">
                                        <div className="absolute inset-0 bg-gradient-to-r from-brand-blue/10 to-purple-500/10 rounded-2xl blur-xl opacity-50 group-hover:opacity-75 transition-opacity"></div>
                                        <div className="relative h-full bg-[#121212] border border-white/5 p-8 rounded-3xl flex flex-col justify-between overflow-hidden">
                                            <div className="flex justify-between items-start">
                                                <div>
                                                    <div className="text-sm font-bold text-brand-gray mb-2 uppercase tracking-wider">Votre Licence</div>
                                                    <h3 className="text-3xl md:text-4xl font-bold text-white mb-2">FantomePad Pro</h3>
                                                    <div className="mt-2">
                                                        <StatusIndicator status={status} />
                                                    </div>
                                                </div>
                                                <div className="bg-white/5 p-3 rounded-2xl shrink-0">
                                                    <Shield className="h-8 w-8 text-brand-blue" />
                                                </div>
                                            </div>

                                            <div className="mt-8 flex gap-4">
                                                <div className="bg-black/30 px-4 py-2 rounded-xl border border-white/5 flex items-center gap-2">
                                                    <Zap className="h-4 w-4 text-yellow-400" />
                                                    <span className="text-sm font-bold text-white">Version Lifetime</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    {/* HWID Card */}
                                    <div className="bg-[#121212] border border-white/5 p-8 rounded-3xl flex flex-col justify-between hover:border-brand-gray/20 transition-colors gap-6 min-h-[220px]">
                                        <div className="flex justify-between items-start">
                                            <div className="overflow-hidden w-full">
                                                <div className="text-sm font-bold text-brand-gray mb-2 uppercase tracking-wider">Hardware ID (HWID)</div>
                                                <div className="text-xl md:text-2xl font-mono font-bold text-white truncate w-full tracking-wider bg-black/20 p-3 rounded-xl border border-white/5">
                                                    {hardwareId || "Non lié"}
                                                </div>
                                            </div>
                                            <Monitor className="h-8 w-8 text-purple-400 shrink-0 ml-4" />
                                        </div>
                                        <div>
                                            <div className="flex items-center justify-between text-xs text-brand-gray mb-2 font-medium">
                                                <span>Sécurité active</span>
                                                <span className="text-green-400">100%</span>
                                            </div>
                                            <div className="h-2 w-full bg-white/5 rounded-full overflow-hidden">
                                                <div className="h-full bg-gradient-to-r from-brand-blue to-purple-500 w-full rounded-full"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                {/* Bottom Row: License Key & Platform - BIGGER cards */}
                                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                                    {/* License Code */}
                                    <div className="lg:col-span-2 bg-[#121212] border border-white/5 p-8 rounded-3xl flex flex-col justify-center min-h-[200px]">
                                        <div className="flex flex-col md:flex-row items-start md:items-center justify-between mb-6 gap-4">
                                            <div>
                                                <h4 className="text-xl font-bold text-white">Clé d'Activation</h4>
                                                <p className="text-sm text-brand-gray mt-1">Utilisez cette clé pour activer votre Expert Advisor.</p>
                                            </div>
                                            <button
                                                onClick={() => setIsLocked(!isLocked)}
                                                className={`flex items-center gap-2 px-4 py-2 rounded-xl transition-colors ${isLocked ? 'bg-brand-blue text-black' : 'bg-white/10 text-white'}`}
                                            >
                                                <span className="text-xs font-bold uppercase">{isLocked ? "Masqué" : "Visible"}</span>
                                            </button>
                                        </div>

                                        <div className="relative group">
                                            <div className="bg-black/40 border border-white/5 rounded-2xl p-6 flex items-center justify-between font-mono text-xl md:text-3xl tracking-widest text-center shadow-inner overflow-hidden">
                                                <span className="truncate mr-4 text-brand-blue/90">
                                                    {isLocked ? "•••• - •••• - •••• - ••••" : activationCode}
                                                </span>
                                                <button
                                                    onClick={handleCopy}
                                                    className="p-3 hover:bg-white/10 rounded-xl transition-colors text-brand-gray hover:text-white shrink-0 active:scale-95"
                                                >
                                                    {copied ? <Check className="h-6 w-6 text-green-400" /> : <Copy className="h-6 w-6" />}
                                                </button>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Platform Actions */}
                                    <div className="bg-[#121212] border border-white/5 p-8 rounded-3xl flex flex-col space-y-4 min-h-[200px]">
                                        <h4 className="text-lg font-bold text-white flex items-center gap-2 mb-2">
                                            <Smartphone className="h-5 w-5 text-brand-gray" />
                                            Téléchargements
                                        </h4>

                                        <button className="flex-1 flex items-center justify-between p-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/5 transition-all group">
                                            <div className="flex items-center gap-4">
                                                <div className="h-3 w-3 rounded-full bg-green-500 shadow-[0_0_10px_rgba(34,197,94,0.6)]"></div>
                                                <span className="font-bold text-base">MetaTrader 4</span>
                                            </div>
                                            <Download className="h-5 w-5 text-brand-gray group-hover:text-white" />
                                        </button>
                                        <button className="flex-1 flex items-center justify-between p-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/5 transition-all group opacity-60">
                                            <div className="flex items-center gap-4">
                                                <div className="h-3 w-3 rounded-full bg-brand-gray"></div>
                                                <span className="font-bold text-base text-brand-gray">MetaTrader 5</span>
                                            </div>
                                            <span className="text-[10px] bg-white/10 px-2 py-1 rounded text-brand-gray font-bold">BIENTÔT</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activeTab === 'docs' && (
                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                                {[
                                    { title: "Installation Complète", duration: "5:20", level: "Débutant" },
                                    { title: "Première Configuration", duration: "12:10", level: "Débutant" },
                                    { title: "Comprendre les Signaux", duration: "8:45", level: "Intermédiaire" },
                                    { title: "Optimisation des Gains", duration: "15:30", level: "Avancé" },
                                    { title: "Gérer le Risque (Risk Management)", duration: "10:00", level: "Essentiel" },
                                    { title: "Dépannage Courant", duration: "6:15", level: "Support" },
                                ].map((video, idx) => (
                                    <div key={idx} className="group cursor-pointer">
                                        <div className="relative aspect-video bg-[#151515] border border-white/5 rounded-2xl overflow-hidden mb-4 group-hover:border-brand-blue/50 transition-all">
                                            <div className="absolute inset-0 flex items-center justify-center bg-black/20 group-hover:bg-black/10 transition-colors">
                                                <div className="h-14 w-14 rounded-full bg-white/10 backdrop-blur-md flex items-center justify-center border border-white/20 group-hover:scale-110 transition-transform">
                                                    <PlayCircle className="h-6 w-6 text-white fill-current" />
                                                </div>
                                            </div>
                                            <div className="absolute bottom-3 right-3 bg-black/80 px-2 py-1 rounded text-[10px] font-bold text-white">
                                                {video.duration}
                                            </div>
                                        </div>
                                        <h3 className="text-lg font-bold text-white group-hover:text-brand-blue transition-colors">{video.title}</h3>
                                        <div className="flex items-center gap-2 mt-2">
                                            <span className="text-xs text-brand-gray font-medium px-2 py-0.5 bg-white/5 rounded border border-white/5">{video.level}</span>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}

                        {activeTab === 'updates' && (
                            <div className="space-y-4 max-w-4xl mx-auto">
                                {[
                                    {
                                        version: "v2.4.1",
                                        date: "7 Fév 2026",
                                        title: "Mise à jour de performance critique",
                                        desc: "Amélioration significative de la vitesse d'exécution des ordres sur les marchés volatils. Correction de bugs mineurs sur l'affichage."
                                    },
                                    {
                                        version: "v2.4.0",
                                        date: "1 Fév 2026",
                                        title: "Nouvelle interface Dashboard",
                                        desc: "Refonte complète de l'expérience utilisateur. Le dashboard est maintenant plus rapide, plus fluide et entièrement responsive mobile."
                                    },
                                    {
                                        version: "v2.3.5",
                                        date: "20 Jan 2026",
                                        title: "Support Multi-Devises",
                                        desc: "Ajout du support pour les paires exotiques. Vous pouvez maintenant trader sur plus de 50 nouveaux instruments avec la même précision."
                                    }
                                ].map((update, idx) => (
                                    <div key={idx} className="bg-[#121212] border border-white/5 p-6 rounded-3xl hover:bg-[#151515] transition-colors group">
                                        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-4">
                                            <div className="flex items-center gap-3">
                                                <span className="px-3 py-1 bg-brand-blue/10 text-brand-blue text-xs font-black rounded-lg border border-brand-blue/20">
                                                    {update.version}
                                                </span>
                                                <h3 className="text-lg font-bold text-white group-hover:text-brand-blue transition-colors">{update.title}</h3>
                                            </div>
                                            <div className="flex items-center gap-2 text-xs text-brand-gray font-bold uppercase tracking-wider">
                                                <Calendar className="h-4 w-4" />
                                                {update.date}
                                            </div>
                                        </div>
                                        <p className="text-brand-gray text-sm leading-relaxed">
                                            {update.desc}
                                        </p>
                                    </div>
                                ))}
                            </div>
                        )}

                    </div>
                </main>
            </div>
        </div>
    );
}
