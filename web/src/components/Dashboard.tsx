import {
    LogOut, Monitor, HelpCircle,
    Copy, Check, Clock, Bell,
    Zap, Download, Eye, EyeOff,
    LayoutDashboard, Menu, X, PlayCircle, Calendar,
    ExternalLink, FileCode, LucideIcon
} from "lucide-react";
import { useState } from "react";
import { createClient } from "@/utils/supabase";
import { motion, AnimatePresence } from "framer-motion";
import Image from "next/image";

interface DashboardProps {
    email: string;
    activationCode: string;
    status: string;
}

interface NavItemProps {
    id: string;
    icon: LucideIcon;
    label: string;
    alert?: number;
    activeTab: string;
    setActiveTab: (id: string) => void;
    setMobileMenuOpen: (open: boolean) => void;
}

interface StatusIndicatorProps {
    status: string;
}

// Move NavItem OUTSIDE the Dashboard component to avoid re-creation during render
function NavItem({ id, icon: Icon, label, alert, activeTab, setActiveTab, setMobileMenuOpen }: NavItemProps) {
    return (
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
}

// Move StatusIndicator OUTSIDE the Dashboard component to avoid re-creation during render
function StatusIndicator({ status }: StatusIndicatorProps) {
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
}

export default function Dashboard({ email, activationCode, status }: DashboardProps) {
    const supabase = createClient();
    const [activeTab, setActiveTab] = useState("overview");
    const [copied, setCopied] = useState(false);
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

    // Fictional states for non-functional features
    const [isLocked, setIsLocked] = useState(false);
    const notifications = 2;

    const handleLogout = async () => { // Renamed from handleSignOut in snippet
        await supabase.auth.signOut();
        window.location.reload();
    };

    const handleCopy = () => {
        if (activationCode) { // Added check for activationCode
            navigator.clipboard.writeText(activationCode);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        }
    };

    // --- PENDING STATE VIEW ---
    if (status === 'pending') {
        return (
            <div className="min-h-screen bg-black text-white p-6 flex items-center justify-center">
                <div className="max-w-6xl w-full space-y-12">
                    {/* Header */}
                    <div className="flex justify-between items-center">
                        <span className="text-xl font-bold text-white tracking-tight">Tutoriel d&apos;installation</span>
                        <button
                            onClick={handleLogout}
                            className="flex items-center gap-2 text-xs font-bold text-brand-gray hover:text-white transition-colors uppercase tracking-wider"
                        >
                            <LogOut className="h-4 w-4" /> Déconnexion
                        </button>
                    </div>

                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-stretch">
                        {/* Left: Video Tutorial */}
                        <div className="h-full">
                            <div className="relative w-full h-full min-h-[350px] bg-[#151515] border border-white/10 rounded-3xl overflow-hidden group cursor-pointer shadow-2xl">
                                <div className="absolute inset-0 bg-gradient-to-br from-brand-blue/10 to-transparent opacity-50" />
                                <div className="absolute inset-0 flex items-center justify-center">
                                    <div className="h-20 w-20 bg-white/10 backdrop-blur-md rounded-full flex items-center justify-center border border-white/20 group-hover:scale-110 transition-transform shadow-xl">
                                        <PlayCircle className="h-8 w-8 text-white fill-white/20" />
                                    </div>
                                </div>
                                <div className="absolute bottom-6 left-6">
                                    <div className="px-3 py-1 bg-brand-blue text-black text-[10px] font-black uppercase tracking-widest rounded-full mb-2 inline-block">Tutoriel</div>
                                    <h3 className="text-xl font-bold">Installation & Connexion</h3>
                                </div>
                            </div>
                        </div>

                        {/* Right: Actions */}
                        <div className="space-y-8 bg-[#121212] p-10 rounded-3xl border border-white/5 flex flex-col justify-center">
                            <div>
                                <div className="inline-block">
                                    <StatusIndicator status="pending" />
                                </div>
                            </div>

                            {/* License Key Display */}
                            <div className="space-y-3">
                                <div className="flex justify-between items-center">
                                    <span className="text-[10px] uppercase tracking-widest font-bold text-brand-gray">Votre Licence</span>
                                    {copied && <span className="text-[10px] text-green-400 font-bold flex items-center gap-1"><Check className="h-3 w-3" /> Copié</span>}
                                </div>
                                <div
                                    onClick={handleCopy}
                                    className="bg-black/50 border border-white/10 rounded-xl p-6 flex items-center justify-between cursor-pointer hover:border-brand-blue/50 transition-all group"
                                >
                                    <code className="font-mono text-2xl font-bold tracking-widest text-white group-hover:text-brand-blue transition-colors">
                                        {activationCode}
                                    </code>
                                    <Copy className="h-6 w-6 text-brand-gray group-hover:text-white transition-colors" />
                                </div>
                            </div>

                            <div className="h-px bg-white/5" />

                            {/* Download Button */}
                            <a href="#" className="flex items-center gap-4 group">
                                <div className="h-14 w-14 bg-white text-black rounded-xl flex items-center justify-center shrink-0 group-hover:scale-110 transition-transform">
                                    <Download className="h-7 w-7" />
                                </div>
                                <div>
                                    <div className="font-bold text-lg text-white group-hover:text-brand-blue transition-colors">Télécharger mon Logiciel</div>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

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
                        <div className="flex items-center justify-center mb-12 relative h-10">
                            <Image src="/logo_long_noir-removebg-preview.png" alt="FantomePad" width={128} height={32} className="h-8 brightness-0 invert" />
                            <button onClick={() => setMobileMenuOpen(false)} className="absolute right-0 p-2 bg-white/5 rounded-xl hover:bg-white/10 transition-colors">
                                <X className="h-6 w-6 text-white" />
                            </button>
                        </div>
                        <div className="space-y-3 flex-1">
                            <NavItem id="overview" icon={LayoutDashboard} label="Vue d&apos;ensemble" activeTab={activeTab} setActiveTab={setActiveTab} setMobileMenuOpen={setMobileMenuOpen} />
                            <NavItem id="docs" icon={HelpCircle} label="Documentation" activeTab={activeTab} setActiveTab={setActiveTab} setMobileMenuOpen={setMobileMenuOpen} />
                            <NavItem id="updates" icon={Bell} label="Nouveautés" alert={notifications} activeTab={activeTab} setActiveTab={setActiveTab} setMobileMenuOpen={setMobileMenuOpen} />
                        </div>
                        <button
                            onClick={handleLogout}
                            className="mt-8 w-full flex items-center justify-center gap-3 text-sm font-bold text-white hover:text-white/80 py-4 transition-all"
                        >
                            <LogOut className="h-4 w-4" />
                            Se déconnecter
                        </button>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Sidebar (Desktop) */}
            <div className="hidden md:flex w-72 border-r border-white/5 flex-col p-6 space-y-8 bg-[#0F0F0F]">
                <div className="flex items-center justify-center px-2">
                    <Image src="/logo_long_noir-removebg-preview.png" alt="FantomePad" width={144} height={36} className="h-9 w-auto brightness-0 invert" />
                </div>

                <div className="space-y-2 flex-1 pt-6">
                    <NavItem id="overview" icon={LayoutDashboard} label="Vue d&apos;ensemble" activeTab={activeTab} setActiveTab={setActiveTab} setMobileMenuOpen={setMobileMenuOpen} />
                    <NavItem id="docs" icon={HelpCircle} label="Documentation" activeTab={activeTab} setActiveTab={setActiveTab} setMobileMenuOpen={setMobileMenuOpen} />
                    <NavItem id="updates" icon={Bell} label="Nouveautés" alert={notifications} activeTab={activeTab} setActiveTab={setActiveTab} setMobileMenuOpen={setMobileMenuOpen} />
                </div>

                <div className="pt-6">
                    <button
                        onClick={handleLogout}
                        className="w-full flex items-center justify-center gap-3 text-sm font-bold text-white hover:text-white/80 py-4 transition-all group"
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
                                {/* Top Row: Status & Activation Code */}
                                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                                    {/* Status Card */}
                                    <div className="relative group min-h-[220px]">
                                        <div className="absolute inset-0 bg-gradient-to-r from-brand-blue/10 to-purple-500/10 rounded-2xl blur-xl opacity-50 group-hover:opacity-75 transition-opacity"></div>
                                        <div className="relative h-full bg-[#121212] border border-white/5 p-8 rounded-3xl flex flex-col justify-between overflow-hidden">
                                            <div className="flex justify-between items-start">
                                                <div>
                                                    <div className="text-sm font-bold text-brand-gray mb-2 uppercase tracking-wider">Votre Licence</div>
                                                    <h3 className="text-3xl md:text-4xl font-bold text-white mb-2">FantomePad Pro</h3>
                                                    <StatusIndicator status={status} />
                                                </div>
                                            </div>

                                            <div className="mt-4 flex gap-4">
                                                <div className="bg-black/30 px-4 py-2 rounded-xl border border-white/5 flex items-center gap-2">
                                                    <Zap className="h-4 w-4 text-yellow-400" />
                                                    <span className="text-sm font-bold text-white">Version Lifetime</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    {/* License Code Card */}
                                    <div className="bg-[#121212] border border-white/5 p-8 rounded-3xl flex flex-col justify-between min-h-[220px]">
                                        <div className="flex justify-between items-start">
                                            <div>
                                                <h4 className="text-xl font-bold text-white">Clé d&apos;Activation</h4>
                                                <p className="text-sm text-brand-gray mt-1">Utilisez cette clé pour activer votre Expert Advisor.</p>
                                            </div>
                                            <button
                                                onClick={() => setIsLocked(!isLocked)}
                                                className="p-2 text-brand-gray hover:text-white transition-colors"
                                            >
                                                {isLocked ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                                            </button>
                                        </div>

                                        <div className="relative group pt-4">
                                            <div className="bg-black/40 border border-white/5 rounded-2xl p-6 flex items-center justify-between font-mono text-xl md:text-2xl tracking-widest text-center shadow-inner overflow-hidden">
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
                                </div>

                                {/* Bottom Row: Downloads & Support */}
                                <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
                                    {/* Downloads Hub */}
                                    <div className="lg:col-span-3 bg-[#121212] border border-white/5 p-8 rounded-3xl flex flex-col min-h-[300px]">
                                        <div className="flex items-center justify-between mb-8">
                                            <div>
                                                <h4 className="text-xl font-bold text-white">Centre de Téléchargement</h4>
                                                <p className="text-sm text-brand-gray">Plateformes et Logiciel FantomePad</p>
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                            {/* Platforms Selection */}
                                            <div className="space-y-4">
                                                <div className="text-[10px] font-bold text-brand-gray uppercase tracking-widest pl-1">Plateformes</div>
                                                <button className="w-full h-[72px] flex items-center justify-between p-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/5 transition-all group">
                                                    <div className="flex items-center gap-4">
                                                        <Monitor className="h-5 w-5 text-brand-gray group-hover:text-white" />
                                                        <span className="font-bold text-base">MetaTrader 4</span>
                                                    </div>
                                                    <Download className="h-4 w-4 text-brand-gray group-hover:text-white" />
                                                </button>
                                                <button className="w-full h-[72px] flex items-center justify-between p-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/5 transition-all group opacity-60 cursor-not-allowed">
                                                    <div className="flex items-center gap-4">
                                                        <Monitor className="h-5 w-5 text-brand-gray" />
                                                        <span className="font-bold text-base text-brand-gray">MetaTrader 5</span>
                                                    </div>
                                                    <span className="text-[10px] bg-white/10 px-2 py-1 rounded text-brand-gray font-bold">BIENTÔT</span>
                                                </button>
                                            </div>

                                            {/* Software Selection */}
                                            <div className="space-y-4">
                                                <div className="text-[10px] font-bold text-brand-gray uppercase tracking-widest pl-1">Logiciel Expert</div>
                                                <button className="w-full h-[72px] flex items-center justify-between p-4 rounded-2xl bg-brand-blue/5 hover:bg-brand-blue/10 border border-brand-blue/20 transition-all group">
                                                    <div className="flex items-center gap-4">
                                                        <FileCode className="h-5 w-5 text-brand-blue" />
                                                        <div className="text-left">
                                                            <div className="font-bold text-base text-white leading-tight">Expert MT4</div>
                                                            <div className="text-[10px] text-brand-blue font-bold">Version v2.4.1</div>
                                                        </div>
                                                    </div>
                                                    <Download className="h-4 w-4 text-brand-blue group-hover:scale-110 transition-transform" />
                                                </button>
                                                <button className="w-full h-[72px] flex items-center justify-between p-4 rounded-2xl bg-white/5 hover:bg-white/10 border border-white/5 transition-all group opacity-60 cursor-not-allowed">
                                                    <div className="flex items-center gap-4">
                                                        <FileCode className="h-5 w-5 text-brand-gray" />
                                                        <div className="text-left">
                                                            <div className="font-bold text-base text-brand-gray leading-tight">Expert MT5</div>
                                                            <div className="text-[10px] text-brand-gray/50 font-bold uppercase">MetaTrader 5</div>
                                                        </div>
                                                    </div>
                                                    <Download className="h-4 w-4 text-brand-gray" />
                                                </button>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Support Card */}
                                    <div className="lg:col-span-2 bg-gradient-to-br from-[#1A1A1A] to-[#121212] border border-white/5 p-8 rounded-3xl flex flex-col justify-between min-h-[300px] relative overflow-hidden group">
                                        <div className="absolute top-0 right-0 w-32 h-32 bg-brand-blue/5 blur-3xl rounded-full -mr-16 -mt-16 group-hover:bg-brand-blue/10 transition-colors"></div>

                                        <div>
                                            <h4 className="text-2xl font-bold text-white mb-2">Support &amp; Aide</h4>
                                            <p className="text-brand-gray text-sm leading-relaxed mb-6">
                                                Notre équipe est à votre disposition pour vous aider dans l&apos;installation ou la configuration de FantomePad.
                                            </p>
                                        </div>

                                        <div className="space-y-4">
                                            <div className="flex items-center gap-3 p-4 rounded-2xl bg-black/20 border border-white/5">
                                                <div className="text-xs font-bold text-brand-gray uppercase tracking-widest">Email:</div>
                                                <div className="text-white font-mono font-bold">contact@fantomepad.com</div>
                                            </div>

                                            <a
                                                href="mailto:contact@fantomepad.com"
                                                className="w-full flex items-center justify-center gap-2 bg-white text-black font-black py-4 rounded-2xl hover:bg-neutral-200 transition-all active:scale-[0.98]"
                                            >
                                                <span>Contacter le support</span>
                                                <ExternalLink className="h-4 w-4" />
                                            </a>
                                        </div>
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
        </div >
    );
}
