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
                    <h1 className="text-2xl font-bold text-gray-800">Users</h1>
                    <p className="text-gray-500">Manage all registered users</p>
                </div>
                <button
                    onClick={fetchUsers}
                    className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors"
                >
                    <RefreshCw size={18} />
                    Refresh
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                    type="text"
                    placeholder="Search users by name or email..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 bg-white border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                />
            </div>

            {/* Error */}
            {error && (
                <div className="bg-red-50 text-red-600 p-4 rounded-lg">
                    {error}
                </div>
            )}

            {/* Loading */}
            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-primary-500" />
                </div>
            ) : (
                /* Users Table */
                <div className="bg-white rounded-xl shadow-sm overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-gray-50 border-b">
                                <tr>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">User</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Email</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Role</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Joined</th>
                                    <th className="px-6 py-4 text-right text-sm font-medium text-gray-500">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y">
                                {filteredUsers.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" className="px-6 py-8 text-center text-gray-500">
                                            No users found
                                        </td>
                                    </tr>
                                ) : (
                                    filteredUsers.map((user) => (
                                        <tr key={user.id} className="hover:bg-gray-50">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                                                        {user.imageUrl ? (
                                                            <img
                                                                src={user.imageUrl}
                                                                alt={user.name}
                                                                className="w-10 h-10 rounded-full object-cover"
                                                            />
                                                        ) : (
                                                            <User className="w-5 h-5 text-primary-600" />
                                                        )}
                                                    </div>
                                                    <div>
                                                        <p className="font-medium text-gray-800">{user.name || 'No name'}</p>
                                                        <p className="text-xs text-gray-400">{user.id.slice(0, 8)}...</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-gray-600">{user.email}</td>
                                            <td className="px-6 py-4">
                                                <select
                                                    value={user.role || 'user'}
                                                    onChange={(e) => handleRoleChange(user.id, e.target.value)}
                                                    className={`px-3 py-1 rounded-full text-sm font-medium ${user.role === 'admin'
                                                            ? 'bg-purple-100 text-purple-700'
                                                            : 'bg-gray-100 text-gray-700'
                                                        }`}
                                                >
                                                    <option value="user">User</option>
                                                    <option value="admin">Admin</option>
                                                </select>
                                            </td>
                                            <td className="px-6 py-4 text-gray-500 text-sm">
                                                {user.createdAt
                                                    ? new Date(user.createdAt).toLocaleDateString()
                                                    : 'N/A'}
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <button
                                                    onClick={() => handleDelete(user.id, user.name || user.email)}
                                                    disabled={deleting === user.id}
                                                    className="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
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
            <div className="flex items-center justify-between text-sm text-gray-500">
                <span>Showing {filteredUsers.length} users</span>
            </div>
        </div>
    );
}

export default UsersPage;
