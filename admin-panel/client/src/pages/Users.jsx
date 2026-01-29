import { useEffect, useState } from 'react';
import { Trash2, Shield, User, Loader2, Search, RefreshCw } from 'lucide-react';
import { usersApi } from '../services/api';

function UsersPage() {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [search, setSearch] = useState('');
    const [deleting, setDeleting] = useState(null);

    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            const { data } = await usersApi.getAll({ search });
            setUsers(data.users);
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to load users');
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (userId, userName) => {
        if (!confirm(`Are you sure you want to delete user "${userName}"? This action cannot be undone.`)) {
            return;
        }

        try {
            setDeleting(userId);
            await usersApi.delete(userId);
            setUsers(users.filter(u => u.id !== userId));
        } catch (err) {
            alert('Failed to delete user: ' + (err.response?.data?.message || err.message));
        } finally {
            setDeleting(null);
        }
    };

    const handleRoleChange = async (userId, newRole) => {
        try {
            await usersApi.updateRole(userId, newRole);
            setUsers(users.map(u => u.id === userId ? { ...u, role: newRole } : u));
        } catch (err) {
            alert('Failed to update role: ' + (err.response?.data?.message || err.message));
        }
    };

    const filteredUsers = users.filter(u =>
        u.name?.toLowerCase().includes(search.toLowerCase()) ||
        u.email?.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Users</h1>
                    <p className="text-light-muted">Manage all registered users</p>
                </div>
                <button
                    onClick={fetchUsers}
                    className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main font-medium rounded-lg hover:bg-gold-dark transition-all shadow-[0_0_15px_rgba(251,191,36,0.2)]"
                >
                    <RefreshCw size={18} />
                    Refresh
                </button>
            </div>

            {/* Search */}
            <div className="relative group">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-light-muted group-focus-within:text-gold-primary transition-colors" />
                <input
                    type="text"
                    placeholder="Search users by name or email..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 bg-dark-card border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary focus:border-transparent outline-none transition-all hover:border-gold-primary/30"
                />
            </div>

            {/* Error */}
            {error && (
                <div className="bg-red-500/10 border border-red-500/20 text-red-500 p-4 rounded-lg">
                    {error}
                </div>
            )}

            {/* Loading */}
            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
                </div>
            ) : (
                /* Users Table */
                <div className="bg-dark-card border border-dark-icon rounded-xl shadow-lg overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-dark-main border-b border-dark-icon">
                                <tr>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">User</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Email</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Role</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Joined</th>
                                    <th className="px-6 py-4 text-right text-sm font-semibold text-light-muted uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-dark-icon">
                                {filteredUsers.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" className="px-6 py-8 text-center text-light-muted">
                                            No users found
                                        </td>
                                    </tr>
                                ) : (
                                    filteredUsers.map((user) => (
                                        <tr key={user.id} className="hover:bg-gold-primary/[0.02] transition-colors group">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-gold-primary/10 border border-gold-primary/20 rounded-full flex items-center justify-center overflow-hidden">
                                                        {user.imageUrl ? (
                                                            <img
                                                                src={user.imageUrl}
                                                                alt={user.name}
                                                                className="w-10 h-10 rounded-full object-cover"
                                                            />
                                                        ) : (
                                                            <User className="w-5 h-5 text-gold-primary" />
                                                        )}
                                                    </div>
                                                    <div>
                                                        <p className="font-medium text-light-primary">{user.name || 'No name'}</p>
                                                        <p className="text-xs text-light-muted">{user.id.slice(0, 8)}...</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-light-primary/80">{user.email}</td>
                                            <td className="px-6 py-4">
                                                <select
                                                    value={user.role || 'user'}
                                                    onChange={(e) => handleRoleChange(user.id, e.target.value)}
                                                    className={`px-3 py-1 rounded-full text-xs font-semibold border-none cursor-pointer outline-none transition-all ${user.role === 'admin'
                                                        ? 'bg-purple-500/20 text-purple-400'
                                                        : 'bg-dark-main text-light-muted hover:bg-dark-icon'
                                                        }`}
                                                >
                                                    <option value="user" className="bg-dark-card">User</option>
                                                    <option value="admin" className="bg-dark-card">Admin</option>
                                                </select>
                                            </td>
                                            <td className="px-6 py-4 text-light-muted text-sm">
                                                {user.createdAt
                                                    ? new Date(user.createdAt).toLocaleDateString()
                                                    : 'N/A'}
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <button
                                                    onClick={() => handleDelete(user.id, user.name || user.email)}
                                                    disabled={deleting === user.id}
                                                    className="p-2 text-light-muted hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-all opacity-0 group-hover:opacity-100 disabled:opacity-50"
                                                >
                                                    {deleting === user.id ? (
                                                        <Loader2 className="w-5 h-5 animate-spin" />
                                                    ) : (
                                                        <Trash2 className="w-5 h-5" />
                                                    )}
                                                </button>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {/* Stats */}
            <div className="flex items-center justify-between text-sm text-light-muted">
                <span>Showing {filteredUsers.length} users</span>
            </div>
        </div>
    );
}

export default UsersPage;
