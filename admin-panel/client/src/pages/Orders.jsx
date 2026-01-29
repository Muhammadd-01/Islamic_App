import { useEffect, useState } from 'react';
import { Trash2, Loader2, Package, RefreshCw, Eye } from 'lucide-react';
import { ordersApi } from '../services/api';

function OrdersPage() {
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [statusFilter, setStatusFilter] = useState('');
    const [selectedOrder, setSelectedOrder] = useState(null);

    useEffect(() => {
        fetchOrders();
    }, [statusFilter]);

    const fetchOrders = async () => {
        try {
            setLoading(true);
            const { data } = await ordersApi.getAll({ status: statusFilter });
            setOrders(data.orders);
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to load orders');
        } finally {
            setLoading(false);
        }
    };

    const handleStatusChange = async (orderId, newStatus) => {
        try {
            await ordersApi.updateStatus(orderId, newStatus);
            setOrders(orders.map(o => o.id === orderId ? { ...o, status: newStatus } : o));
        } catch (err) {
            alert('Failed to update status: ' + (err.response?.data?.message || err.message));
        }
    };

    const handleDelete = async (orderId) => {
        if (!confirm('Are you sure you want to delete this order?')) {
            return;
        }

        try {
            await ordersApi.delete(orderId);
            setOrders(orders.filter(o => o.id !== orderId));
        } catch (err) {
            alert('Failed to delete order: ' + (err.response?.data?.message || err.message));
        }
    };

    const getStatusColor = (status) => {
        switch (status) {
            case 'completed': return 'bg-green-500/20 text-green-400';
            case 'proceed': return 'bg-blue-500/20 text-blue-400';
            case 'pending': return 'bg-gold-primary/20 text-gold-primary';
            case 'cancelled': return 'bg-red-500/20 text-red-400';
            default: return 'bg-dark-icon text-light-muted';
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Orders</h1>
                    <p className="text-light-muted">Manage customer orders</p>
                </div>
                <div className="flex gap-3">
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="px-4 py-2 bg-dark-card border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none transition-all hover:border-gold-primary/30"
                    >
                        <option value="" className="bg-dark-card">All Orders</option>
                        <option value="pending" className="bg-dark-card">Pending</option>
                        <option value="proceed" className="bg-dark-card">Proceed</option>
                        <option value="completed" className="bg-dark-card">Completed</option>
                        <option value="cancelled" className="bg-dark-card">Cancelled</option>
                    </select>
                    <button
                        onClick={fetchOrders}
                        className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main font-medium rounded-lg hover:bg-gold-dark transition-all shadow-[0_0_15px_rgba(251,191,36,0.2)]"
                    >
                        <RefreshCw size={18} />
                        Refresh
                    </button>
                </div>
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
                /* Orders Table */
                <div className="bg-dark-card border border-dark-icon rounded-xl shadow-lg overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-dark-main border-b border-dark-icon">
                                <tr>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Order ID</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Customer</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Items</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Total</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Status</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Date</th>
                                    <th className="px-6 py-4 text-right text-sm font-semibold text-light-muted uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-dark-icon">
                                {orders.length === 0 ? (
                                    <tr>
                                        <td colSpan="7" className="px-6 py-8 text-center text-light-muted">
                                            No orders found
                                        </td>
                                    </tr>
                                ) : (
                                    orders.map((order) => (
                                        <tr key={order.id} className="hover:bg-gold-primary/[0.02] transition-colors group">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-gold-primary/10 border border-gold-primary/20 rounded-lg flex items-center justify-center">
                                                        <Package className="w-5 h-5 text-gold-primary" />
                                                    </div>
                                                    <span className="font-mono text-sm text-light-primary">{order.id.slice(0, 8).toUpperCase()}</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-light-primary/80">{order.userName || 'Unknown'}</td>
                                            <td className="px-6 py-4 text-light-muted">{order.items?.length || 0} items</td>
                                            <td className="px-6 py-4 font-medium text-light-primary">
                                                ${(order.total || 0).toFixed(2)}
                                            </td>
                                            <td className="px-6 py-4">
                                                <select
                                                    value={order.status}
                                                    onChange={(e) => handleStatusChange(order.id, e.target.value)}
                                                    className={`px-3 py-1 rounded-full text-xs font-semibold border-none cursor-pointer outline-none transition-all ${getStatusColor(order.status)}`}
                                                >
                                                    <option value="pending" className="bg-dark-card">Pending</option>
                                                    <option value="proceed" className="bg-dark-card">Proceed</option>
                                                    <option value="completed" className="bg-dark-card">Completed</option>
                                                    <option value="cancelled" className="bg-dark-card">Cancelled</option>
                                                </select>
                                            </td>
                                            <td className="px-6 py-4 text-light-muted text-sm">
                                                {order.createdAt
                                                    ? new Date(order.createdAt).toLocaleDateString()
                                                    : 'N/A'}
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    <button
                                                        onClick={() => setSelectedOrder(order)}
                                                        className="p-2 text-gold-primary hover:bg-gold-primary/10 rounded-lg transition-all"
                                                        title="View Details"
                                                    >
                                                        <Eye className="w-5 h-5" />
                                                    </button>
                                                    <button
                                                        onClick={() => handleDelete(order.id)}
                                                        className="p-2 text-light-muted hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-all opacity-0 group-hover:opacity-100"
                                                        title="Delete Order"
                                                    >
                                                        <Trash2 className="w-5 h-5" />
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {/* Order Details Modal */}
            {selectedOrder && (
                <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl max-w-lg w-full max-h-[80vh] overflow-y-auto shadow-2xl animate-in fade-in zoom-in duration-200">
                        <div className="p-6 border-b border-dark-icon">
                            <div className="flex items-center justify-between">
                                <h2 className="text-xl font-bold text-light-primary">Order Details</h2>
                                <button
                                    onClick={() => setSelectedOrder(null)}
                                    className="p-2 hover:bg-dark-icon rounded-lg text-light-muted transition-colors"
                                >
                                    ✕
                                </button>
                            </div>
                        </div>
                        <div className="p-6 space-y-4">
                            <div>
                                <p className="text-sm font-medium text-light-muted uppercase tracking-wider mb-1">Order ID</p>
                                <p className="font-mono text-gold-primary">{selectedOrder.id}</p>
                            </div>
                            <div>
                                <p className="text-sm font-medium text-light-muted uppercase tracking-wider mb-1">Customer</p>
                                <p className="text-light-primary text-lg">{selectedOrder.userName || 'Unknown'}</p>
                            </div>
                            <div>
                                <p className="text-sm font-medium text-light-muted uppercase tracking-wider mb-2">Items</p>
                                <div className="space-y-2">
                                    {selectedOrder.items?.map((item, idx) => (
                                        <div key={idx} className="flex justify-between bg-dark-main border border-dark-icon p-4 rounded-xl transition-all hover:border-gold-primary/30">
                                            <div>
                                                <p className="font-semibold text-light-primary">{item.title}</p>
                                                <p className="text-sm text-light-muted">Quantity: {item.quantity}</p>
                                            </div>
                                            <p className="font-bold text-light-primary">${(item.price * item.quantity).toFixed(2)}</p>
                                        </div>
                                    ))}
                                </div>
                            </div>
                            <div className="flex justify-between items-center pt-6 border-t border-dark-icon">
                                <p className="text-lg font-semibold text-light-primary">Grand Total</p>
                                <p className="text-2xl font-bold text-gold-primary">${(selectedOrder.total || 0).toFixed(2)}</p>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Stats */}
            <div className="flex items-center justify-between text-sm text-light-muted">
                <span>Showing {orders.length} orders</span>
            </div>
        </div>
    );
}

export default OrdersPage;
