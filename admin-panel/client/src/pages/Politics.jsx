import { useState, useEffect } from 'react';
import { Download, Share2, Plus, Edit, Trash2, Video, FileText, ExternalLink } from 'lucide-react';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

export default function PoliticsPage() {
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editItem, setEditItem] = useState(null);
    const [activeTab, setActiveTab] = useState('islamic');
    const [contentType, setContentType] = useState('all');
    const [form, setForm] = useState({
        title: '',
        description: '',
        category: 'islamic',
        type: 'document', // 'document' or 'video'
        url: '',
        thumbnailUrl: '',
    });

    useEffect(() => {
        fetchItems();
    }, []);

    const fetchItems = async () => {
        try {
            const res = await fetch(`${API_URL}/politics`);
            const data = await res.json();
            setItems(data);
        } catch (error) {
            console.error('Error fetching politics content:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const method = editItem ? 'PUT' : 'POST';
            const url = editItem ? `${API_URL}/politics/${editItem.id}` : `${API_URL}/politics`;

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
            await fetch(`${API_URL}/politics/${id}`, { method: 'DELETE' });
            fetchItems();
        } catch (error) {
            console.error('Error deleting:', error);
        }
    };

    const resetForm = () => {
        setForm({
            title: '',
            description: '',
            category: activeTab,
            type: 'document',
            url: '',
            thumbnailUrl: '',
        });
        setEditItem(null);
        setShowModal(false);
    };

    const openEdit = (item) => {
        setForm(item);
        setEditItem(item);
        setShowModal(true);
    };

    const filteredItems = items.filter(item => {
        const categoryMatch = item.category === activeTab;
        const typeMatch = contentType === 'all' || item.type === contentType;
        return categoryMatch && typeMatch;
    });

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
                    <h1 className="text-2xl font-bold text-light-primary">Politics Content</h1>
                    <p className="text-light-muted">Manage political documents and videos</p>
                </div>
                <button
                    onClick={() => { setForm({ ...form, category: activeTab }); setShowModal(true); }}
                    className="flex items-center gap-2 bg-gold-primary hover:bg-gold-highlight text-black px-4 py-2 rounded-lg font-medium transition-colors"
                >
                    <Plus size={20} />
                    Add Content
                </button>
            </div>

            {/* Tabs */}
            <div className="flex gap-4 mb-6">
                <button
                    onClick={() => setActiveTab('islamic')}
                    className={`px-6 py-2 rounded-lg font-medium transition-colors ${activeTab === 'islamic'
                        ? 'bg-gold-primary text-black'
                        : 'bg-dark-card text-light-muted hover:text-light-primary'
                        }`}
                >
                    Islamic Politics
                </button>
                <button
                    onClick={() => setActiveTab('western')}
                    className={`px-6 py-2 rounded-lg font-medium transition-colors ${activeTab === 'western'
                        ? 'bg-gold-primary text-black'
                        : 'bg-dark-card text-light-muted hover:text-light-primary'
                        }`}
                >
                    Western Politics
                </button>
            </div>

            {/* Content Type Filter */}
            <div className="flex gap-2 mb-6">
                {['all', 'document', 'video'].map(type => (
                    <button
                        key={type}
                        onClick={() => setContentType(type)}
                        className={`px-4 py-1 rounded-full text-sm font-medium transition-colors ${contentType === type
                            ? 'bg-gold-primary text-black'
                            : 'bg-dark-icon text-light-muted hover:text-light-primary'
                            }`}
                    >
                        {type === 'all' ? 'All' : type === 'document' ? 'Documents' : 'Videos'}
                    </button>
                ))}
            </div>

            {/* Content Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {filteredItems.map(item => (
                    <div key={item.id} className="bg-dark-card rounded-xl p-4 border border-dark-icon">
                        <div className="flex items-start gap-3 mb-3">
                            <div className={`p-2 rounded-lg ${item.type === 'video' ? 'bg-red-500/20' : 'bg-blue-500/20'}`}>
                                {item.type === 'video' ? (
                                    <Video size={20} className="text-red-400" />
                                ) : (
                                    <FileText size={20} className="text-blue-400" />
                                )}
                            </div>
                            <div className="flex-1">
                                <h3 className="font-semibold text-light-primary">{item.title}</h3>
                                <p className="text-sm text-light-muted line-clamp-2">{item.description}</p>
                            </div>
                        </div>

                        <div className="flex justify-between items-center mt-4">
                            <div className="flex gap-2">
                                <a
                                    href={item.url}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="p-2 bg-dark-icon rounded-lg hover:bg-dark-secondary transition-colors"
                                    title="Open"
                                >
                                    <ExternalLink size={16} className="text-gold-primary" />
                                </a>
                                {item.type === 'document' && (
                                    <>
                                        <button
                                            className="p-2 bg-dark-icon rounded-lg hover:bg-dark-secondary transition-colors"
                                            title="Download"
                                        >
                                            <Download size={16} className="text-green-400" />
                                        </button>
                                        <button
                                            className="p-2 bg-dark-icon rounded-lg hover:bg-dark-secondary transition-colors"
                                            title="Share"
                                        >
                                            <Share2 size={16} className="text-blue-400" />
                                        </button>
                                    </>
                                )}
                            </div>
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
                ))}
            </div>

            {filteredItems.length === 0 && (
                <div className="text-center py-12 text-light-muted">
                    No content found. Add some!
                </div>
            )}

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                    <div className="bg-dark-card rounded-xl p-6 w-full max-w-md mx-4">
                        <h2 className="text-xl font-bold text-light-primary mb-4">
                            {editItem ? 'Edit Content' : 'Add Content'}
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
                                    <label className="block text-sm text-light-muted mb-1">Category</label>
                                    <select
                                        value={form.category}
                                        onChange={(e) => setForm({ ...form, category: e.target.value })}
                                        className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                    >
                                        <option value="islamic">Islamic</option>
                                        <option value="western">Western</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm text-light-muted mb-1">Type</label>
                                    <select
                                        value={form.type}
                                        onChange={(e) => setForm({ ...form, type: e.target.value })}
                                        className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                    >
                                        <option value="document">Document</option>
                                        <option value="video">Video</option>
                                    </select>
                                </div>
                            </div>
                            {/* Dynamic input based on type */}
                            {form.type === 'video' ? (
                                <div>
                                    <label className="block text-sm text-light-muted mb-1">YouTube URL</label>
                                    <input
                                        type="url"
                                        value={form.url}
                                        onChange={(e) => setForm({ ...form, url: e.target.value })}
                                        className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary"
                                        placeholder="https://youtube.com/watch?v=..."
                                        required
                                    />
                                    <p className="text-xs text-light-muted mt-1">Enter a YouTube video URL</p>
                                </div>
                            ) : (
                                <div>
                                    <label className="block text-sm text-light-muted mb-1">Upload Document</label>
                                    <input
                                        type="file"
                                        accept=".pdf,.doc,.docx"
                                        onChange={(e) => {
                                            const file = e.target.files[0];
                                            if (file) {
                                                setForm({ ...form, documentFile: file, url: URL.createObjectURL(file) });
                                            }
                                        }}
                                        className="w-full bg-dark-secondary border border-dark-icon rounded-lg px-3 py-2 text-light-primary file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-gold-primary file:text-dark-main hover:file:bg-gold-dark"
                                    />
                                    <p className="text-xs text-light-muted mt-1">Upload PDF or Word document (max 10MB)</p>
                                    {form.url && (
                                        <p className="text-xs text-green-400 mt-1">✓ Document selected</p>
                                    )}
                                </div>
                            )}
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
