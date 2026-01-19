import { useEffect, useState } from 'react';
import {
    Users, ShoppingCart, DollarSign, TrendingUp, Loader2, BookOpen,
    Heart, Star, MessageCircle, Newspaper, GraduationCap, Lightbulb,
    FlaskConical, History, Landmark
} from 'lucide-react';
import { db } from '../config/firebase';
import { collection, getDocs } from 'firebase/firestore';

function Dashboard() {
    const [stats, setStats] = useState({});
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchAllStats();
    }, []);

    const fetchAllStats = async () => {
        try {
            setLoading(true);

            // Fetch counts from all collections
            const collections = [
                'users', 'orders', 'books', 'questions', 'inventions',
                'scientists', 'names_of_allah', 'duas', 'daily_inspiration',
                'news', 'politics', 'scholars', 'courses', 'history',
                'beliefs', 'hadiths', 'surahs'
            ];

            const counts = {};
            for (const col of collections) {
                try {
                    const snapshot = await getDocs(collection(db, col));
                    counts[col] = snapshot.size;
                } catch {
                    counts[col] = 0;
                }
            }

            // Calculate some derived stats
            const pendingOrders = await getPendingOrdersCount();

            setStats({
                ...counts,
                pendingOrders,
                totalRevenue: 0 // Would come from actual orders
            });
        } catch (error) {
            console.error('Error fetching stats:', error);
        } finally {
            setLoading(false);
        }
    };

    const getPendingOrdersCount = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'orders'));
            return snapshot.docs.filter(doc => doc.data().status === 'pending').length;
        } catch {
            return 0;
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
            </div>
        );
    }

    const mainCards = [
        { title: 'Total Users', value: stats.users || 0, icon: Users, color: 'bg-blue-500' },
        { title: 'Total Orders', value: stats.orders || 0, icon: ShoppingCart, color: 'bg-green-500' },
        { title: 'Pending Orders', value: stats.pendingOrders || 0, icon: TrendingUp, color: 'bg-yellow-500' },
        { title: 'Total Books', value: stats.books || 0, icon: BookOpen, color: 'bg-purple-500' },
    ];

    const contentCards = [
        { title: 'Quran Surahs', value: stats.surahs || 0, icon: BookOpen, color: 'text-emerald-400', bg: 'bg-emerald-500/20' },
        { title: 'Hadiths', value: stats.hadiths || 0, icon: BookOpen, color: 'text-green-400', bg: 'bg-green-500/20' },
        { title: 'Duas', value: stats.duas || 0, icon: Heart, color: 'text-pink-400', bg: 'bg-pink-500/20' },
        { title: '99 Names', value: stats.names_of_allah || 0, icon: Star, color: 'text-amber-400', bg: 'bg-amber-500/20' },
        { title: 'Scientists', value: stats.scientists || 0, icon: GraduationCap, color: 'text-blue-400', bg: 'bg-blue-500/20' },
        { title: 'Inventions', value: stats.inventions || 0, icon: FlaskConical, color: 'text-purple-400', bg: 'bg-purple-500/20' },
        { title: 'News Articles', value: stats.news || 0, icon: Newspaper, color: 'text-cyan-400', bg: 'bg-cyan-500/20' },
        { title: 'Q&A', value: stats.questions || 0, icon: MessageCircle, color: 'text-orange-400', bg: 'bg-orange-500/20' },
        { title: 'Scholars', value: stats.scholars || 0, icon: Users, color: 'text-indigo-400', bg: 'bg-indigo-500/20' },
        { title: 'Courses', value: stats.courses || 0, icon: GraduationCap, color: 'text-teal-400', bg: 'bg-teal-500/20' },
        { title: 'History', value: stats.history || 0, icon: History, color: 'text-rose-400', bg: 'bg-rose-500/20' },
        { title: 'Politics', value: stats.politics || 0, icon: Landmark, color: 'text-slate-400', bg: 'bg-slate-500/20' },
        { title: 'Beliefs', value: stats.beliefs || 0, icon: MessageCircle, color: 'text-violet-400', bg: 'bg-violet-500/20' },
        { title: 'Daily Inspiration', value: stats.daily_inspiration || 0, icon: Lightbulb, color: 'text-yellow-400', bg: 'bg-yellow-500/20' },
    ];

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-2xl font-bold text-light-primary font-outfit">Dashboard</h1>
                <p className="text-light-muted">Welcome to DeenSphere Admin Panel - Overview of all content</p>
            </div>

            {/* Main Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {mainCards.map(({ title, value, icon: Icon, color }) => (
                    <div key={title} className="bg-dark-card border border-dark-icon rounded-xl shadow-sm p-6">
                        <div className="flex items-center justify-between mb-4">
                            <div className={`p-3 rounded-lg ${color}`}>
                                <Icon className="w-6 h-6 text-white" />
                            </div>
                        </div>
                        <h3 className="text-3xl font-bold text-light-primary">{value}</h3>
                        <p className="text-light-muted text-sm">{title}</p>
                    </div>
                ))}
            </div>

            {/* Content Stats Section */}
            <div className="bg-dark-card border border-dark-icon rounded-xl shadow-sm p-6">
                <h2 className="text-lg font-semibold text-light-primary mb-4">Content Statistics</h2>
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-7 gap-4">
                    {contentCards.map(({ title, value, icon: Icon, color, bg }) => (
                        <div key={title} className="bg-dark-main/50 rounded-lg p-4 text-center hover:bg-dark-icon/50 transition-colors">
                            <div className={`w-10 h-10 ${bg} rounded-lg flex items-center justify-center mx-auto mb-2`}>
                                <Icon className={`w-5 h-5 ${color}`} />
                            </div>
                            <p className="text-2xl font-bold text-light-primary">{value}</p>
                            <p className="text-xs text-light-muted">{title}</p>
                        </div>
                    ))}
                </div>
            </div>

            {/* Quick Actions */}
            <div className="bg-dark-card border border-dark-icon rounded-xl shadow-sm p-6">
                <h2 className="text-lg font-semibold text-light-primary mb-4">Quick Actions</h2>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <a href="/quran" className="flex items-center space-x-3 p-4 bg-dark-main/50 rounded-lg hover:bg-dark-icon transition-colors text-light-primary">
                        <BookOpen className="w-5 h-5 text-emerald-400" />
                        <span>Manage Quran</span>
                    </a>
                    <a href="/hadith" className="flex items-center space-x-3 p-4 bg-dark-main/50 rounded-lg hover:bg-dark-icon transition-colors text-light-primary">
                        <BookOpen className="w-5 h-5 text-green-400" />
                        <span>Manage Hadith</span>
                    </a>
                    <a href="/users" className="flex items-center space-x-3 p-4 bg-dark-main/50 rounded-lg hover:bg-dark-icon transition-colors text-light-primary">
                        <Users className="w-5 h-5 text-gold-primary" />
                        <span>Manage Users</span>
                    </a>
                    <a href="/orders" className="flex items-center space-x-3 p-4 bg-dark-main/50 rounded-lg hover:bg-dark-icon transition-colors text-light-primary">
                        <ShoppingCart className="w-5 h-5 text-gold-primary" />
                        <span>View Orders</span>
                    </a>
                </div>
            </div>

            {/* Last Updated */}
            <p className="text-xs text-light-muted/60 text-right">
                Last updated: {new Date().toLocaleString()}
            </p>
        </div>
    );
}

export default Dashboard;
