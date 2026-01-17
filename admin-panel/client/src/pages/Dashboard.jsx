import { useEffect, useState } from 'react';
import { Users, ShoppingCart, DollarSign, TrendingUp, Loader2 } from 'lucide-react';
import { statsApi } from '../services/api';

function Dashboard() {
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetchStats();
    }, []);

    const fetchStats = async () => {
        try {
            setLoading(true);
            const { data } = await statsApi.getDashboard();
            setStats(data);
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to load dashboard');
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
            </div>
        );
    }

    if (error) {
        return (
            <div className="bg-error/10 text-error p-4 rounded-lg">
                {error}
                <button
                    onClick={fetchStats}
                    className="ml-4 underline"
                >
                    Retry
                </button>
            </div>
        );
    }

    const cards = [
        {
            title: 'Total Users',
            value: stats?.totalUsers || 0,
            icon: Users,
            color: 'bg-blue-500',
            change: `+${stats?.newUsersThisWeek || 0} this week`,
        },
        {
            title: 'Total Orders',
            value: stats?.totalOrders || 0,
            icon: ShoppingCart,
            color: 'bg-green-500',
            change: `+${stats?.ordersThisWeek || 0} this week`,
        },
        {
            title: 'Revenue',
            value: `$${(stats?.totalRevenue || 0).toFixed(2)}`,
            icon: DollarSign,
            color: 'bg-yellow-500',
            change: 'From completed orders',
        },
        {
            title: 'Pending Orders',
            value: stats?.pendingOrders || 0,
            icon: TrendingUp,
            color: 'bg-purple-500',
            change: 'Awaiting processing',
        },
    ];

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-2xl font-bold text-light-primary font-outfit">Dashboard</h1>
                <p className="text-light-muted">Welcome to DeenSphere Admin Panel</p>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {cards.map(({ title, value, icon: Icon, color, change }) => (
                    <div key={title} className="bg-dark-card border border-dark-icon rounded-xl shadow-sm p-6">
                        <div className="flex items-center justify-between mb-4">
                            <div className={`p-3 rounded-lg ${color}`}>
                                <Icon className="w-6 h-6 text-white" />
                            </div>
                        </div>
                        <h3 className="text-2xl font-bold text-light-primary">{value}</h3>
                        <p className="text-light-muted text-sm">{title}</p>
                        <p className="text-xs text-light-muted/60 mt-2">{change}</p>
                    </div>
                ))}
            </div>

            {/* Quick Actions */}
            <div className="bg-dark-card border border-dark-icon rounded-xl shadow-sm p-6">
                <h2 className="text-lg font-semibold text-light-primary mb-4">Quick Actions</h2>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <a
                        href="/users"
                        className="flex items-center space-x-3 p-4 bg-dark-main/50 rounded-lg hover:bg-dark-icon transition-colors text-light-primary"
                    >
                        <Users className="w-5 h-5 text-gold-primary" />
                        <span>Manage Users</span>
                    </a>
                    <a
                        href="/orders"
                        className="flex items-center space-x-3 p-4 bg-dark-main/50 rounded-lg hover:bg-dark-icon transition-colors text-light-primary"
                    >
                        <ShoppingCart className="w-5 h-5 text-gold-primary" />
                        <span>View Orders</span>
                    </a>
                    <button
                        onClick={fetchStats}
                        className="flex items-center space-x-3 p-4 bg-dark-main/50 rounded-lg hover:bg-dark-icon transition-colors text-light-primary"
                    >
                        <TrendingUp className="w-5 h-5 text-gold-primary" />
                        <span>Refresh Stats</span>
                    </button>
                </div>
            </div>

            {/* Last Updated */}
            <p className="text-xs text-light-muted/60 text-right">
                Last updated: {stats?.lastUpdated ? new Date(stats.lastUpdated).toLocaleString() : 'N/A'}
            </p>
        </div>
    );
}

export default Dashboard;
