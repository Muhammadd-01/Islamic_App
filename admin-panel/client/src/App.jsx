import { BrowserRouter, Routes, Route, NavLink } from 'react-router-dom';
import { LayoutDashboard, Users, ShoppingCart, Settings, Menu, X } from 'lucide-react';
import { useState } from 'react';
import Dashboard from './pages/Dashboard';
import UsersPage from './pages/Users';
import OrdersPage from './pages/Orders';

function App() {
    const [sidebarOpen, setSidebarOpen] = useState(false);

    const navLinks = [
        { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
        { to: '/users', icon: Users, label: 'Users' },
        { to: '/orders', icon: ShoppingCart, label: 'Orders' },
    ];

    return (
        <BrowserRouter>
            <div className="min-h-screen bg-gray-100 flex">
                {/* Sidebar */}
                <aside
                    className={`fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 lg:translate-x-0 lg:static ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'
                        }`}
                >
                    <div className="flex items-center justify-between h-16 px-6 border-b">
                        <div className="flex items-center space-x-3">
                            <div className="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-700 rounded-lg flex items-center justify-center">
                                <span className="text-white font-bold">IA</span>
                            </div>
                            <span className="font-bold text-gray-800">Admin Panel</span>
                        </div>
                        <button
                            className="lg:hidden p-1 hover:bg-gray-100 rounded"
                            onClick={() => setSidebarOpen(false)}
                        >
                            <X size={20} />
                        </button>
                    </div>

                    <nav className="p-4 space-y-2">
                        {navLinks.map(({ to, icon: Icon, label }) => (
                            <NavLink
                                key={to}
                                to={to}
                                className={({ isActive }) =>
                                    `flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${isActive
                                        ? 'bg-primary-50 text-primary-600'
                                        : 'text-gray-600 hover:bg-gray-50'
                                    }`
                                }
                                onClick={() => setSidebarOpen(false)}
                            >
                                <Icon size={20} />
                                <span className="font-medium">{label}</span>
                            </NavLink>
                        ))}
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
                    <header className="h-16 bg-white shadow-sm flex items-center justify-between px-6">
                        <button
                            className="lg:hidden p-2 hover:bg-gray-100 rounded"
                            onClick={() => setSidebarOpen(true)}
                        >
                            <Menu size={20} />
                        </button>
                        <div className="flex-1" />
                        <div className="flex items-center space-x-4">
                            <div className="w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center">
                                <span className="text-white text-sm font-medium">A</span>
                            </div>
                        </div>
                    </header>

                    {/* Page Content */}
                    <div className="p-6">
                        <Routes>
                            <Route path="/" element={<Dashboard />} />
                            <Route path="/users" element={<UsersPage />} />
                            <Route path="/orders" element={<OrdersPage />} />
                        </Routes>
                    </div>
                </main>
            </div>
        </BrowserRouter>
    );
}

export default App;
