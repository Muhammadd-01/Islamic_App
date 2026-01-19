import { BrowserRouter, Routes, Route, NavLink } from 'react-router-dom';
import { LayoutDashboard, Users, ShoppingCart, BookOpen, MessageCircle, Menu, X, LogOut } from 'lucide-react';
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
import Login from './pages/Login';

function AuthGuard({ children }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
            setUser(currentUser);
            setLoading(false);
        });
        return unsubscribe;
    }, []);

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-dark-main">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gold-primary"></div>
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

    const handleLogout = () => {
        signOut(auth);
    };

    const navLinks = [
        { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
        { to: '/users', icon: Users, label: 'Users' },
        { to: '/orders', icon: ShoppingCart, label: 'Orders' },
        { to: '/books', icon: BookOpen, label: 'Books' },
        { to: '/questions', icon: MessageCircle, label: 'Questions' },
        { to: '/inventions', icon: BookOpen, label: 'Inventions' },
        { to: '/scientists', icon: Users, label: 'Scientists' },
        { to: '/names', icon: BookOpen, label: '99 Names' },
        { to: '/duas', icon: BookOpen, label: 'Duas' },
        { to: '/inspiration', icon: BookOpen, label: 'Inspiration' },
        { to: '/news', icon: BookOpen, label: 'News' },
        { to: '/politics', icon: BookOpen, label: 'Politics' },
        { to: '/scholars', icon: Users, label: 'Scholars' },
        { to: '/courses', icon: BookOpen, label: 'Courses' },
        { to: '/history', icon: BookOpen, label: 'History' },
    ];

    return (
        <BrowserRouter>
            <AuthGuard>
                <div className="min-h-screen bg-dark-main flex">
                    {/* Sidebar */}
                    <aside
                        className={`fixed inset-y-0 left-0 z-50 w-64 bg-dark-card shadow-lg border-r border-dark-icon transform transition-transform duration-300 lg:translate-x-0 lg:static ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'
                            }`}
                    >
                        <div className="flex items-center justify-between h-16 px-6 border-b border-dark-icon">
                            <div className="flex items-center space-x-3">
                                <img src="/deensphere_logo.png" alt="DeenSphere" className="w-8 h-8" />
                                <span className="font-bold text-light-primary font-outfit">DeenSphere</span>
                            </div>
                            <button
                                className="lg:hidden p-1 hover:bg-dark-icon text-light-muted rounded"
                                onClick={() => setSidebarOpen(false)}
                            >
                                <X size={20} />
                            </button>
                        </div>

                        <nav className="p-4 space-y-2 flex flex-col h-[calc(100%-4rem)]">
                            <div className="flex-1 space-y-2">
                                {navLinks.map(({ to, icon: Icon, label }) => (
                                    <NavLink
                                        key={to}
                                        to={to}
                                        className={({ isActive }) =>
                                            `flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${isActive
                                                ? 'bg-gold-primary/10 text-gold-primary'
                                                : 'text-light-muted hover:bg-dark-icon'
                                            }`
                                        }
                                        onClick={() => setSidebarOpen(false)}
                                    >
                                        <Icon size={20} />
                                        <span className="font-medium">{label}</span>
                                    </NavLink>
                                ))}
                            </div>

                            <button
                                onClick={handleLogout}
                                className="flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors text-error hover:bg-error/10 w-full"
                            >
                                <LogOut size={20} />
                                <span className="font-medium">Sign Out</span>
                            </button>
                        </nav>
                    </aside>

                    {/* Overlay */}
                    {sidebarOpen && (
                        <div
                            className="fixed inset-0 bg-black/50 z-40 lg:hidden"
                            onClick={() => setSidebarOpen(false)}
                        />
                    )}

                    {/* Main Content */}
                    <main className="flex-1 min-h-screen">
                        {/* Top Bar */}
                        <header className="h-16 bg-dark-card border-b border-dark-icon shadow-sm flex items-center justify-between px-6">
                            <button
                                className="lg:hidden p-2 hover:bg-dark-icon text-light-muted rounded"
                                onClick={() => setSidebarOpen(true)}
                            >
                                <Menu size={20} />
                            </button>
                            <div className="flex-1" />
                            <div className="flex items-center space-x-4">
                                <div className="w-8 h-8 bg-gold-primary rounded-full flex items-center justify-center">
                                    <span className="text-iconBlack text-sm font-medium">A</span>
                                </div>
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
                            </Routes>
                        </div>
                    </main>
                </div>
            </AuthGuard>
        </BrowserRouter>
    );
}

export default App;
