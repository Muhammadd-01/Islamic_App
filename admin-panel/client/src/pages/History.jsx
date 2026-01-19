import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { Search, Plus, Edit, Trash2, X, Play, FileText, Check } from 'lucide-react';

export default function History() {
    const [history, setHistory] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingHistory, setEditingHistory] = useState(null);
    const [categoryFilter, setCategoryFilter] = useState('all');
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        era: '',
        category: 'islamic',
        contentType: 'video',
        videoUrl: '',
        documentUrl: '',
        imageUrl: ''
    });

    useEffect(() => {
        fetchHistory();
    }, []);

    const fetchHistory = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'history'));
            const data = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setHistory(data);
        } catch (error) {
            console.error('Error fetching history:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editingHistory) {
                await updateDoc(doc(db, 'history', editingHistory.id), {
                    ...formData,
                    updatedAt: new Date().toISOString()
                });
            } else {
                await addDoc(collection(db, 'history'), {
                    ...formData,
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                });
            }
            fetchHistory();
            closeModal();
        } catch (error) {
            console.error('Error saving history:', error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this history item?')) {
            try {
                await deleteDoc(doc(db, 'history', id));
                fetchHistory();
            } catch (error) {
                console.error('Error deleting history:', error);
            }
        }
    };

    const openEditModal = (item) => {
        setEditingHistory(item);
        setFormData({
            title: item.title || '',
            description: item.description || '',
            era: item.era || '',
            category: item.category || 'islamic',
            contentType: item.contentType || 'video',
            videoUrl: item.videoUrl || '',
            documentUrl: item.documentUrl || '',
            imageUrl: item.imageUrl || ''
        });
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingHistory(null);
        setFormData({
            title: '',
            description: '',
            era: '',
            category: 'islamic',
            contentType: 'video',
            videoUrl: '',
            documentUrl: '',
            imageUrl: ''
        });
    };

    const filteredHistory = history.filter(item => {
        const matchesSearch = item.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.description?.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesCategory = categoryFilter === 'all' || item.category === categoryFilter;
        return matchesSearch && matchesCategory;
    });

    const getCategoryBadge = (category) => {
        switch (category) {
            case 'islamic':
                return <span className="px-2 py-1 bg-green-500/20 text-green-400 rounded-full text-xs">Islamic</span>;
            case 'western':
                return <span className="px-2 py-1 bg-blue-500/20 text-blue-400 rounded-full text-xs">Western</span>;
            default:
                return <span className="px-2 py-1 bg-gray-500/20 text-gray-400 rounded-full text-xs">{category}</span>;
        }
    };

    const getTypeBadge = (type) => {
        switch (type) {
            case 'video':
                return <span className="flex items-center gap-1 px-2 py-1 bg-red-500/20 text-red-400 rounded-full text-xs"><Play size={12} /> Video</span>;
            case 'document':
                return <span className="flex items-center gap-1 px-2 py-1 bg-purple-500/20 text-purple-400 rounded-full text-xs"><FileText size={12} /> Document</span>;
            default:
                return null;
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gold-primary"></div>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">History Management</h1>
                    <p className="text-light-muted">Manage Islamic and Western history content</p>
                </div>
                <button
                    onClick={() => setShowModal(true)}
                    className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors"
                >
                    <Plus size={20} />
                    Add History
                </button>
            </div>

            {/* Filters */}
            <div className="flex flex-col sm:flex-row gap-4">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-light-muted" size={20} />
                    <input
                        type="text"
                        placeholder="Search history..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary focus:border-transparent"
                    />
                </div>
                <div className="flex gap-2">
                    <button
                        onClick={() => setCategoryFilter('all')}
                        className={`px-4 py-2 rounded-lg transition-colors ${categoryFilter === 'all' ? 'bg-gold-primary text-dark-main' : 'bg-dark-card text-light-muted hover:bg-dark-icon'}`}
                    >
                        All
                    </button>
                    <button
                        onClick={() => setCategoryFilter('islamic')}
                        className={`px-4 py-2 rounded-lg transition-colors ${categoryFilter === 'islamic' ? 'bg-green-600 text-white' : 'bg-dark-card text-light-muted hover:bg-dark-icon'}`}
                    >
                        Islamic
                    </button>
                    <button
                        onClick={() => setCategoryFilter('western')}
                        className={`px-4 py-2 rounded-lg transition-colors ${categoryFilter === 'western' ? 'bg-blue-600 text-white' : 'bg-dark-card text-light-muted hover:bg-dark-icon'}`}
                    >
                        Western
                    </button>
                </div>
            </div>

            {/* History Table */}
            <div className="bg-dark-card rounded-xl border border-dark-icon overflow-hidden">
                <table className="w-full">
                    <thead className="bg-dark-icon/50">
                        <tr>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Title</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Era</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Category</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Type</th>
                            <th className="px-6 py-4 text-right text-sm font-medium text-light-muted">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-dark-icon">
                        {filteredHistory.length === 0 ? (
                            <tr>
                                <td colSpan="5" className="px-6 py-8 text-center text-light-muted">
                                    No history items found
                                </td>
                            </tr>
                        ) : (
                            filteredHistory.map((item) => (
                                <tr key={item.id} className="hover:bg-dark-icon/30 transition-colors">
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-3">
                                            {item.imageUrl ? (
                                                <img src={item.imageUrl} alt={item.title} className="w-10 h-10 rounded-lg object-cover" />
                                            ) : (
                                                <div className="w-10 h-10 rounded-lg bg-dark-icon flex items-center justify-center">
                                                    <FileText size={20} className="text-light-muted" />
                                                </div>
                                            )}
                                            <div>
                                                <p className="font-medium text-light-primary">{item.title}</p>
                                                <p className="text-sm text-light-muted line-clamp-1">{item.description}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 text-light-primary">{item.era}</td>
                                    <td className="px-6 py-4">{getCategoryBadge(item.category)}</td>
                                    <td className="px-6 py-4">{getTypeBadge(item.contentType)}</td>
                                    <td className="px-6 py-4">
                                        <div className="flex items-center justify-end gap-2">
                                            <button
                                                onClick={() => openEditModal(item)}
                                                className="p-2 text-light-muted hover:text-gold-primary hover:bg-dark-icon rounded-lg transition-colors"
                                            >
                                                <Edit size={18} />
                                            </button>
                                            <button
                                                onClick={() => handleDelete(item.id)}
                                                className="p-2 text-light-muted hover:text-red-400 hover:bg-dark-icon rounded-lg transition-colors"
                                            >
                                                <Trash2 size={18} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card rounded-xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
                        <div className="flex items-center justify-between p-6 border-b border-dark-icon">
                            <h2 className="text-xl font-bold text-light-primary">
                                {editingHistory ? 'Edit History' : 'Add History'}
                            </h2>
                            <button onClick={closeModal} className="p-2 hover:bg-dark-icon rounded-lg">
                                <X size={20} className="text-light-muted" />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Title</label>
                                <input
                                    type="text"
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Description</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    rows="3"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Era</label>
                                <input
                                    type="text"
                                    value={formData.era}
                                    onChange={(e) => setFormData({ ...formData, era: e.target.value })}
                                    placeholder="e.g., 632-661 CE"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Category</label>
                                    <select
                                        value={formData.category}
                                        onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    >
                                        <option value="islamic">Islamic</option>
                                        <option value="western">Western</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Content Type</label>
                                    <select
                                        value={formData.contentType}
                                        onChange={(e) => setFormData({ ...formData, contentType: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    >
                                        <option value="video">Video</option>
                                        <option value="document">Document</option>
                                    </select>
                                </div>
                            </div>
                            {/* Dynamic input based on content type */}
                            {formData.contentType === 'video' ? (
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">YouTube URL</label>
                                    <input
                                        type="url"
                                        value={formData.videoUrl}
                                        onChange={(e) => setFormData({ ...formData, videoUrl: e.target.value })}
                                        placeholder="https://youtube.com/watch?v=..."
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    />
                                    <p className="text-xs text-light-muted mt-1">Enter a YouTube video URL</p>
                                </div>
                            ) : (
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Upload Document</label>
                                    <input
                                        type="file"
                                        accept=".pdf,.doc,.docx"
                                        onChange={(e) => {
                                            const file = e.target.files[0];
                                            if (file) {
                                                // For now, we'll upload to Firebase Storage and get URL
                                                // This is a placeholder - actual upload logic needed
                                                setFormData({ ...formData, documentFile: file, documentUrl: URL.createObjectURL(file) });
                                            }
                                        }}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-gold-primary file:text-dark-main hover:file:bg-gold-dark"
                                    />
                                    <p className="text-xs text-light-muted mt-1">Upload PDF or Word document (max 10MB)</p>
                                    {formData.documentUrl && (
                                        <p className="text-xs text-green-400 mt-1">✓ Document selected</p>
                                    )}
                                </div>
                            )}
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Image URL</label>
                                <input
                                    type="url"
                                    value={formData.imageUrl}
                                    onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                                    placeholder="Thumbnail image URL"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                />
                            </div>
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="flex-1 px-4 py-2 bg-dark-icon text-light-primary rounded-lg hover:bg-dark-icon/80 transition-colors"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors flex items-center justify-center gap-2"
                                >
                                    <Check size={18} />
                                    {editingHistory ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
