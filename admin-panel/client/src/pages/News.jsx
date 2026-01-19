import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, ExternalLink, Youtube, Newspaper, RefreshCw } from 'lucide-react';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

export default function NewsPage() {
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editItem, setEditItem] = useState(null);
    const [form, setForm] = useState({
        title: '',
        description: '',
        source: '',
        url: '',
        imageUrl: '',
        category: 'world',
    });

    useEffect(() => {
        fetchItems();
    }, []);

    const fetchItems = async () => {
        try {
            const res = await fetch(`${API_URL}/news`);
            const data = await res.json();
            setItems(data);
        } catch (error) {
            console.error('Error fetching news:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const method = editItem ? 'PUT' : 'POST';
            const url = editItem ? `${API_URL}/news/${editItem.id}` : `${API_URL}/news`;

            await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(form),
            });

            fetchItems();
            resetForm();
        } catch (error) {
            console.error('Error saving:', error);
        }
    };

    const handleDelete = async (id) => {
        if (!confirm('Are you sure?')) return;
        try {
            await fetch(`${API_URL}/news/${id}`, { method: 'DELETE' });
            fetchItems();
        } catch (error) {
            console.error('Error deleting:', error);
        }
    };

    const resetForm = () => {
        setForm({
            title: '',
            description: '',
            source: '',
            url: '',
            imageUrl: '',
            category: 'world',
        });
        setEditItem(null);
        setShowModal(false);
    };

    const openEdit = (item) => {
        setForm(item);
        setEditItem(item);
        setShowModal(true);
    };

    const categories = ['world', 'technology', 'science', 'health', 'business', 'islamic'];

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gold-primary"></div>
            </div>
        );
    }

    return (
        <div className="p-6">
            <div className="flex justify-between items-center mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">News Management</h1>
                    <p className="text-light-muted">Manage news articles and YouTube videos</p>
                </div>
                <div className="flex gap-3">
                    <button
                        onClick={fetchItems}
                        className="flex items-center gap-2 bg-dark-card border border-dark-icon hover:border-gold-primary text-light-primary px-4 py-2 rounded-lg transition-colors"
                    >
                        <RefreshCw size={18} />
                        Refresh
                    </button>
                    <button
                        onClick={() => setShowModal(true)}
                        className="flex items-center gap-2 bg-gold-primary hover:bg-gold-highlight text-black px-4 py-2 rounded-lg font-medium transition-colors"
                    >
                        <Plus size={20} />
                        Add News
                    </button>
                </div>
            </div>

            {/* News Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {items.map(item => (
                    <div key={item.id} className="bg-dark-card rounded-xl overflow-hidden border border-dark-icon">
                        {item.imageUrl && (
                            <img
                                src={item.imageUrl}
                                alt={item.title}
                                className="w-full h-40 object-cover"
                                onError={(e) => { e.target.style.display = 'none'; }}
                            />
                        )}
                        <div className="p-4">
                            <div className="flex items-center gap-2 mb-2">
                                <span className="px-2 py-0.5 bg-gold-primary/20 text-gold-primary text-xs rounded-full">
                                    {item.category}
                                </span>
                                <span className="text-xs text-light-muted">{item.source}</span>
                            </div>
                            <h3 className="font-semibold text-light-primary line-clamp-2 mb-2">{item.title}</h3>
                            <p className="text-sm text-light-muted line-clamp-2">{item.description}</p>

                            <div className="flex justify-between items-center mt-4">
                                <a
                                    href={item.url}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="flex items-center gap-1 text-gold-primary hover:text-gold-highlight text-sm"
                                >
                                    <ExternalLink size={14} />
                                    Open Link
                                </a>
                                <div className="flex gap-2">
                                    <button
                                        onClick={() => openEdit(item)}
                                        className="p-2 bg-dark-icon rounded-lg hover:bg-dark-secondary transition-colors"
                                    >
                                        <Edit size={16} className="text-gold-primary" />
                                    </button>
                                    <button
                                        onClick={() => handleDelete(item.id)}
                                        className="p-2 bg-dark-icon rounded-lg hover:bg-red-500/20 transition-colors"
                                    >
                                        <Trash2 size={16} className="text-red-400" />
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            {items.length === 0 && (
                <div className="text-center py-12">
                    <Newspaper size={48} className="mx-auto text-light-muted mb-4" />
                    <p className="text-light-muted">No news articles yet. Add some!</p>
                </div>
            )}

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                    <div className="bg-dark-card rounded-xl p-6 w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
                        <h2 className="text-xl font-bold text-light-primary mb-4">
                            {editItem ? 'Edit News' : 'Add News'}
                        </h2>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div>
                                <label className="block text-sm text-light-muted mb-1">Title</label>
                                <input
                                    type="text"
                                    value={form.title}
                                    onChange={(e) => setForm({ ...form, title: e.target.value })}
                                    className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm text-light-muted mb-1">Description</label>
                                <textarea
                                    value={form.description}
                                    onChange={(e) => setForm({ ...form, description: e.target.value })}
                                    className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                    rows={3}
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm text-light-muted mb-1">Source</label>
                                    <input
                                        type="text"
                                        value={form.source}
                                        onChange={(e) => setForm({ ...form, source: e.target.value })}
                                        className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                        placeholder="BBC, CNN, etc."
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm text-light-muted mb-1">Category</label>
                                    <select
                                        value={form.category}
                                        onChange={(e) => setForm({ ...form, category: e.target.value })}
                                        className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                    >
                                        {categories.map(cat => (
                                            <option key={cat} value={cat}>{cat.charAt(0).toUpperCase() + cat.slice(1)}</option>
                                        ))}
                                    </select>
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm text-light-muted mb-1">URL</label>
                                <input
                                    type="url"
                                    value={form.url}
                                    onChange={(e) => setForm({ ...form, url: e.target.value })}
                                    className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                    placeholder="https://"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm text-light-muted mb-1">Image URL (optional)</label>
                                <input
                                    type="url"
                                    value={form.imageUrl}
                                    onChange={(e) => setForm({ ...form, imageUrl: e.target.value })}
                                    className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                    placeholder="https://..."
                                />
                            </div>
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={resetForm}
                                    className="flex-1 px-4 py-2 bg-dark-icon text-light-muted rounded-lg hover:bg-dark-secondary transition-colors"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 px-4 py-2 bg-gold-primary text-black rounded-lg hover:bg-gold-highlight font-medium transition-colors"
                                >
                                    {editItem ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
