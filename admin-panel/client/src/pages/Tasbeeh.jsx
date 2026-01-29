import { useEffect, useState } from 'react';
import { Loader2, Search, RefreshCw, Activity, Award, Calendar } from 'lucide-react';
import { tasbeehApi } from '../services/api';

function TasbeehPage() {
    const [stats, setStats] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [search, setSearch] = useState('');

    useEffect(() => {
        fetchStats();
    }, []);

    const fetchStats = async () => {
        try {
            setLoading(true);
            const { data } = await tasbeehApi.getAll();
            setStats(data.stats);
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to load tasbeeh stats');
        } finally {
            setLoading(false);
        }
    };

    const filteredStats = stats.filter(s =>
        s.userName?.toLowerCase().includes(search.toLowerCase()) ||
        s.userEmail?.toLowerCase().includes(search.toLowerCase())
    );

    const totalGlobalCounts = stats.reduce((acc, curr) => acc + (curr.totalCount || 0), 0);
    const avgDailyCounts = stats.length > 0
        ? Math.round(stats.reduce((acc, curr) => acc + (curr.dailyCount || 0), 0) / stats.length)
        : 0;

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Tasbeeh Analytics</h1>
                    <p className="text-light-muted">Monitor user engagement and dhikr activity</p>
                </div>
                <button
                    onClick={fetchStats}
                    className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-all font-medium"
                >
                    <RefreshCw className={loading ? 'animate-spin' : ''} size={18} />
                    Refresh
                </button>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-dark-card border border-dark-icon p-6 rounded-xl hover:border-gold-primary/30 transition-all group overflow-hidden relative">
                    <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:scale-125 transition-transform duration-500">
                        <Activity size={80} className="text-gold-primary" />
                    </div>
                    <div className="flex items-center gap-4 relative z-10">
                        <div className="p-3 bg-gold-primary/10 text-gold-primary rounded-lg">
                            <Activity size={24} />
                        </div>
                        <div>
                            <p className="text-sm text-light-muted">Global Total</p>
                            <h3 className="text-2xl font-bold text-light-primary">{totalGlobalCounts.toLocaleString()}</h3>
                        </div>
                    </div>
                </div>
                <div className="bg-dark-card border border-dark-icon p-6 rounded-xl hover:border-gold-primary/30 transition-all group overflow-hidden relative">
                    <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:scale-125 transition-transform duration-500">
                        <Calendar size={80} className="text-green-500" />
                    </div>
                    <div className="flex items-center gap-4 relative z-10">
                        <div className="p-3 bg-green-500/10 text-green-500 rounded-lg">
                            <Calendar size={24} />
                        </div>
                        <div>
                            <p className="text-sm text-light-muted">Avg Daily/User</p>
                            <h3 className="text-2xl font-bold text-light-primary">{avgDailyCounts}</h3>
                        </div>
                    </div>
                </div>
                <div className="bg-dark-card border border-dark-icon p-6 rounded-xl hover:border-gold-primary/30 transition-all group overflow-hidden relative">
                    <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:scale-125 transition-transform duration-500">
                        <Award size={80} className="text-amber-500" />
                    </div>
                    <div className="flex items-center gap-4 relative z-10">
                        <div className="p-3 bg-amber-500/10 text-amber-500 rounded-lg">
                            <Award size={24} />
                        </div>
                        <div>
                            <p className="text-sm text-light-muted">Active Users</p>
                            <h3 className="text-2xl font-bold text-light-primary">{stats.length}</h3>
                        </div>
                    </div>
                </div>
            </div>

            {/* Search */}
            <div className="relative group">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-light-muted group-focus-within:text-gold-primary transition-colors" />
                <input
                    type="text"
                    placeholder="Search by user name or email..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 bg-dark-card border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none hover:border-gold-primary/30 transition-all"
                />
            </div>

            {/* Error */}
            {error && (
                <div className="bg-red-500/10 text-red-400 p-4 rounded-lg border border-red-500/20">
                    {error}
                </div>
            )}

            {/* Loading */}
            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
                </div>
            ) : (
                <div className="bg-dark-card rounded-xl shadow-sm overflow-hidden border border-dark-icon transition-all hover:shadow-gold-primary/5">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-dark-main/50 border-b border-dark-icon">
                                <tr>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-light-muted uppercase tracking-wider">User</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-light-muted uppercase tracking-wider">Total Counts</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-light-muted uppercase tracking-wider">Streak</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-light-muted uppercase tracking-wider">Today's Progress</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-light-muted uppercase tracking-wider">Last Activity</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-dark-icon">
                                {filteredStats.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" className="px-6 py-12 text-center text-light-muted">
                                            <div className="flex flex-col items-center gap-2">
                                                <Activity size={40} className="text-dark-icon" />
                                                <p>No tasbeeh activity found</p>
                                            </div>
                                        </td>
                                    </tr>
                                ) : (
                                    filteredStats.map((stat) => (
                                        <tr key={stat.id} className="hover:bg-dark-main/30 transition-colors group">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-dark-main border border-dark-icon rounded-full flex items-center justify-center overflow-hidden transition-transform group-hover:scale-110">
                                                        {stat.userImage ? (
                                                            <img src={stat.userImage} alt={stat.userName} className="w-full h-full object-cover" />
                                                        ) : (
                                                            <span className="text-sm font-bold text-gold-primary">
                                                                {stat.userName?.charAt(0).toUpperCase() || 'U'}
                                                            </span>
                                                        )}
                                                    </div>
                                                    <div>
                                                        <p className="font-semibold text-light-primary group-hover:text-gold-primary transition-colors">{stat.userName || 'Anonymous User'}</p>
                                                        <p className="text-xs text-light-muted">{stat.userEmail}</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4">
                                                <span className="font-bold text-gold-primary text-lg">{stat.totalCount?.toLocaleString() || 0}</span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-2 text-amber-500 font-bold bg-amber-500/10 px-3 py-1 rounded-full w-fit">
                                                    <Award size={16} />
                                                    <span>{stat.streakCount || 0} Day{stat.streakCount !== 1 ? 's' : ''}</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="flex flex-col gap-2 min-w-[150px]">
                                                    <div className="flex justify-between text-xs">
                                                        <span className="text-light-muted">Progress</span>
                                                        <span className="text-gold-primary font-bold">{stat.dailyCount || 0}</span>
                                                    </div>
                                                    <div className="h-1.5 bg-dark-main border border-dark-icon rounded-full overflow-hidden">
                                                        <div
                                                            className="h-full bg-gold-primary shadow-[0_0_10px_rgba(251,191,36,0.3)] transition-all duration-1000"
                                                            style={{ width: `${Math.min(100, ((stat.dailyCount || 0) / 100) * 100)}%` }}
                                                        />
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-light-muted text-sm italic">
                                                {stat.lastUpdated ? new Date(stat.lastUpdated).toLocaleString() : 'Never'}
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}
        </div>
    );
}

export default TasbeehPage;
