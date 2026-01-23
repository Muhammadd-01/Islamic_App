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
            case 'completed': return 'bg-green-100 text-green-700';
            case 'proceed': return 'bg-blue-100 text-blue-700';
            case 'pending': return 'bg-yellow-100 text-yellow-700';
            case 'cancelled': return 'bg-red-100 text-red-700';
            default: return 'bg-gray-100 text-gray-700';
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Orders</h1>
                    <p className="text-gray-500">Manage customer orders</p>
                </div>
                <div className="flex gap-3">
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="px-4 py-2 bg-white border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500"
                    >
                        <option value="">All Orders</option>
                        <option value="pending">Pending</option>
                        <option value="proceed">Proceed</option>
                        <option value="completed">Completed</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                    <button
                        onClick={fetchOrders}
                        className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors"
                    >
                        <RefreshCw size={18} />
                        Refresh
                    </button>
                </div>
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
                /* Orders Table */
                <div className="bg-white rounded-xl shadow-sm overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-gray-50 border-b">
                                <tr>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Order ID</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Customer</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Items</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Total</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Status</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Date</th>
                                    <th className="px-6 py-4 text-right text-sm font-medium text-gray-500">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y">
                                {orders.length === 0 ? (
                                    <tr>
                                        <td colSpan="7" className="px-6 py-8 text-center text-gray-500">
                                            No orders found
                                        </td>
                                    </tr>
                                ) : (
                                    orders.map((order) => (
                                        <tr key={order.id} className="hover:bg-gray-50">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center">
                                                        <Package className="w-5 h-5 text-primary-600" />
                                                    </div>
                                                    <span className="font-mono text-sm">{order.id.slice(0, 8).toUpperCase()}</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-gray-600">{order.userName || 'Unknown'}</td>
                                            <td className="px-6 py-4 text-gray-600">{order.items?.length || 0} items</td>
                                            <td className="px-6 py-4 font-medium text-gray-800">
                                                ${(order.total || 0).toFixed(2)}
                                            </td>
                                            <td className="px-6 py-4">
                                                <select
                                                    value={order.status}
                                                    onChange={(e) => handleStatusChange(order.id, e.target.value)}
                                                    className={`px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(order.status)}`}
                                                >
                                                    <option value="pending">Pending</option>
                                                    <option value="proceed">Proceed</option>
                                                    <option value="completed">Completed</option>
                                                    <option value="cancelled">Cancelled</option>
                                                </select>
                                            </td>
                                            <td className="px-6 py-4 text-gray-500 text-sm">
                                                {order.createdAt
                                                    ? new Date(order.createdAt).toLocaleDateString()
                                                    : 'N/A'}
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    <button
                                                        onClick={() => setSelectedOrder(order)}
                                                        className="p-2 text-gray-500 hover:bg-gray-100 rounded-lg transition-colors"
                                                        title="View Details"
                                                    >
                                                        <Eye className="w-5 h-5" />
                                                    </button>
                                                    <button
                                                        onClick={() => handleDelete(order.id)}
                                                        className="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors"
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
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-xl max-w-lg w-full max-h-[80vh] overflow-y-auto">
                        <div className="p-6 border-b">
                            <div className="flex items-center justify-between">
                                <h2 className="text-xl font-bold">Order Details</h2>
                                <button
                                    onClick={() => setSelectedOrder(null)}
                                    className="p-2 hover:bg-gray-100 rounded-lg"
                                >
                                    ✕
                                </button>
                            </div>
                        </div>
                        <div className="p-6 space-y-4">
                            <div>
                                <p className="text-sm text-gray-500">Order ID</p>
                                <p className="font-mono">{selectedOrder.id}</p>
                            </div>
                            <div>
                                <p className="text-sm text-gray-500">Customer</p>
                                <p>{selectedOrder.userName || 'Unknown'}</p>
                            </div>
                            <div>
                                <p className="text-sm text-gray-500 mb-2">Items</p>
                                <div className="space-y-2">
                                    {selectedOrder.items?.map((item, idx) => (
                                        <div key={idx} className="flex justify-between bg-gray-50 p-3 rounded-lg">
                                            <div>
                                                <p className="font-medium">{item.title}</p>
                                                <p className="text-sm text-gray-500">Qty: {item.quantity}</p>
                                            </div>
                                            <p className="font-medium">${(item.price * item.quantity).toFixed(2)}</p>
                                        </div>
                                    ))}
                                </div>
                            </div>
                            <div className="flex justify-between pt-4 border-t">
                                <p className="font-bold">Total</p>
                                <p className="font-bold text-primary-600">${(selectedOrder.total || 0).toFixed(2)}</p>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Stats */}
            <div className="flex items-center justify-between text-sm text-gray-500">
                <span>Showing {orders.length} orders</span>
            </div>
        </div>
    );
}

export default OrdersPage;
