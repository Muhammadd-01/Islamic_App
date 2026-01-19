import { BrowserRouter, Routes, Route, NavLink } from 'react-router-dom';
import {
    LayoutDashboard, Users, ShoppingCart, BookOpen, MessageCircle,
    Menu, X, LogOut, Lightbulb, Newspaper, Landmark, GraduationCap,
    History, FlaskConical, Star, Heart, ChevronLeft, ChevronRight
} from 'lucide-react';
import { useState, useEffect } from 'react';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { auth } from './config/firebase';
import Dashboard from './pages/Dashboard';
import UsersPage from './pages/Users';
import OrdersPage from './pages/Orders';
import BooksPage from './pages/Books';
import QuestionsPage from './pages/Questions';
import InventionsPage from './pages/Inventions';
import ScientistsPage from './pages/Scientists';
import NamesOfAllahPage from './pages/NamesOfAllah';
import DuasPage from './pages/Duas';
import DailyInspirationPage from './pages/DailyInspiration';
import NewsPage from './pages/News';
import PoliticsPage from './pages/Politics';
import ScholarsPage from './pages/Scholars';
import CoursesPage from './pages/Courses';
import HistoryPage from './pages/History';
import BeliefsPage from './pages/Beliefs';
import Login from './pages/Login';

function AuthGuard({ children }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
            setUser(currentUser);
            setLoading(false);
        });
        return () => unsubscribe();
    }, []);

    if (loading) {
        return (
            <div className="min-h-screen bg-dark-main flex items-center justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-gold-primary"></div>
            </div>
        );
    }

    if (!user) {
        return <Login />;
    }

    return children;
}

function App() {
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

    const handleLogout = () => {
        signOut(auth);
    };

    const navLinks = [
        { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
        { to: '/users', icon: Users, label: 'Users' },
        { to: '/orders', icon: ShoppingCart, label: 'Orders' },
        { to: '/books', icon: BookOpen, label: 'Books' },
        { to: '/questions', icon: MessageCircle, label: 'Questions' },
        { to: '/inventions', icon: FlaskConical, label: 'Inventions' },
        { to: '/scientists', icon: GraduationCap, label: 'Scientists' },
        { to: '/names', icon: Star, label: '99 Names' },
        { to: '/duas', icon: Heart, label: 'Duas' },
        { to: '/inspiration', icon: Lightbulb, label: 'Inspiration' },
        { to: '/news', icon: Newspaper, label: 'News' },
        { to: '/politics', icon: Landmark, label: 'Politics' },
        { to: '/scholars', icon: Users, label: 'Scholars' },
        { to: '/courses', icon: GraduationCap, label: 'Courses' },
        { to: '/history', icon: History, label: 'History' },
        { to: '/beliefs', icon: MessageCircle, label: 'Beliefs' },
    ];

    return (
        <BrowserRouter>
            <AuthGuard>
                <div className="min-h-screen bg-dark-main flex">
                    {/* Sidebar */}
                    <aside
                        className={`fixed inset-y-0 left-0 z-50 ${sidebarCollapsed ? 'w-20' : 'w-64'} bg-dark-card shadow-lg border-r border-dark-icon transform transition-all duration-300 lg:translate-x-0 lg:static ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'
                            }`}
                    >
                        <div className="flex flex-col h-full">
                            {/* Logo */}
                            <div className={`p-6 border-b border-dark-icon flex items-center ${sidebarCollapsed ? 'justify-center' : 'justify-between'}`}>
                                {!sidebarCollapsed && (
                                    <h1 className="text-xl font-bold bg-gradient-to-r from-gold-primary to-gold-dark bg-clip-text text-transparent">
                                        DeenSphere
                                    </h1>
                                )}
                                {sidebarCollapsed && (
                                    <span className="text-2xl font-bold text-gold-primary">D</span>
                                )}
                                <button
                                    onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
                                    className="hidden lg:flex p-1 hover:bg-dark-icon rounded-lg text-light-muted"
                                >
                                    {sidebarCollapsed ? <ChevronRight size={20} /> : <ChevronLeft size={20} />}
                                </button>
                                <button
                                    onClick={() => setSidebarOpen(false)}
                                    className="lg:hidden text-light-muted hover:text-light-primary"
                                >
                                    <X size={24} />
                                </button>
                            </div>

                            {/* Navigation */}
                            <nav className="flex-1 p-4 overflow-y-auto">
                                <ul className="space-y-2">
                                    {navLinks.map((link) => (
                                        <li key={link.to}>
                                            <NavLink
                                                to={link.to}
                                                className={({ isActive }) =>
                                                    `flex items-center ${sidebarCollapsed ? 'justify-center' : 'gap-3'} px-4 py-3 rounded-lg transition-colors ${isActive
                                                        ? 'bg-gold-primary/20 text-gold-primary'
                                                        : 'text-light-muted hover:bg-dark-icon hover:text-light-primary'
                                                    }`
                                                }
                                                title={sidebarCollapsed ? link.label : ''}
                                            >
                                                <link.icon size={20} />
                                                {!sidebarCollapsed && <span>{link.label}</span>}
                                            </NavLink>
                                        </li>
                                    ))}
                                </ul>
                            </nav>

                            {/* Logout Button */}
                            <div className="p-4 border-t border-dark-icon">
                                <button
                                    onClick={handleLogout}
                                    className={`flex items-center ${sidebarCollapsed ? 'justify-center' : 'gap-3'} w-full px-4 py-3 rounded-lg text-red-400 hover:bg-red-500/10 transition-colors`}
                                    title={sidebarCollapsed ? 'Logout' : ''}
                                >
                                    <LogOut size={20} />
                                    {!sidebarCollapsed && <span>Logout</span>}
                                </button>
                            </div>
                        </div>
                    </aside>

                    {/* Mobile Overlay */}
                    {sidebarOpen && (
                        <div
                            className="fixed inset-0 bg-black/50 z-40 lg:hidden"
                            onClick={() => setSidebarOpen(false)}
                        />
                    )}

                    {/* Main Content */}
                    <main className="flex-1 min-h-screen">
                        {/* Top Header */}
                        <header className="bg-dark-card border-b border-dark-icon py-4 px-6 flex items-center justify-between lg:justify-end">
                            <button
                                onClick={() => setSidebarOpen(true)}
                                className="lg:hidden text-light-muted hover:text-light-primary"
                            >
                                <Menu size={24} />
                            </button>
                            <div className="flex items-center gap-4">
                                <span className="text-sm text-light-muted">Admin Panel</span>
                            </div>
                        </header>

                        {/* Page Content */}
                        <div className="p-6">
                            <Routes>
                                <Route path="/" element={<Dashboard />} />
                                <Route path="/users" element={<UsersPage />} />
                                <Route path="/orders" element={<OrdersPage />} />
                                <Route path="/books" element={<BooksPage />} />
                                <Route path="/questions" element={<QuestionsPage />} />
                                <Route path="/inventions" element={<InventionsPage />} />
                                <Route path="/scientists" element={<ScientistsPage />} />
                                <Route path="/names" element={<NamesOfAllahPage />} />
                                <Route path="/duas" element={<DuasPage />} />
                                <Route path="/inspiration" element={<DailyInspirationPage />} />
                                <Route path="/news" element={<NewsPage />} />
                                <Route path="/politics" element={<PoliticsPage />} />
                                <Route path="/scholars" element={<ScholarsPage />} />
                                <Route path="/courses" element={<CoursesPage />} />
                                <Route path="/history" element={<HistoryPage />} />
                                <Route path="/beliefs" element={<BeliefsPage />} />
                            </Routes>
                        </div>
                    </main>
                </div>
            </AuthGuard>
        </BrowserRouter>
    );
}

export default App;
