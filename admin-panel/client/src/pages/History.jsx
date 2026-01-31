import { useState, useEffect } from 'react';
import { Search, Plus, Edit, Trash2, X, Play, FileText, Check, Loader2, Image as ImageIcon } from 'lucide-react';
import { historyApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

export default function History() {
    const { notify } = useNotification();
    const [history, setHistory] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingHistory, setEditingHistory] = useState(null);
    const [categoryFilter, setCategoryFilter] = useState('all');
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [imageFile, setImageFile] = useState(null);
    const [documentFile, setDocumentFile] = useState(null);

    const [formData, setFormData] = useState({
        title: '',
        description: '',
        era: '',
        category: 'islamic',
        displayMode: 'browse', // 'browse', 'timeline'
        contentType: 'video', // 'video', 'document'
        videoUrl: '',
        documentUrl: '',
        imageUrl: ''
    });

    useEffect(() => {
        fetchHistory();
    }, []);

    const fetchHistory = async () => {
        try {
            setLoading(true);
            const { data } = await historyApi.getAll();
            setHistory(data);
        } catch (error) {
            console.error('Error fetching history:', error);
            notify.error('Failed to fetch history');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            const data = new FormData();
            data.append('title', formData.title);
            data.append('description', formData.description);
            data.append('era', formData.era);
            data.append('category', formData.category);
            data.append('displayMode', formData.displayMode);
            data.append('contentType', formData.contentType);
            if (formData.videoUrl) data.append('videoUrl', formData.videoUrl);
            if (formData.documentUrl) data.append('documentUrl', formData.documentUrl);
            if (formData.imageUrl) data.append('imageUrl', formData.imageUrl);

            // Handle files
            if (imageFile) data.append('image', imageFile);
            if (documentFile) data.append('document', documentFile);

            if (editingHistory) {
                await historyApi.update(editingHistory.id, data);
                notify.success('History updated successfully');
            } else {
                await historyApi.create(data);
                notify.success('History created successfully');
            }
            fetchHistory();
            closeModal();
            resetForm();
        } catch (error) {
            console.error('Error saving history:', error);
            notify.error('Failed to save history: ' + (error.response?.data?.error || error.message));
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        const confirmed = await notify.confirm({
            title: 'Delete History',
            message: 'Are you sure you want to delete this history item? This action cannot be undone.',
            confirmText: 'Delete',
            cancelText: 'Cancel'
        });
        if (!confirmed) return;
        setDeletingId(id);
        try {
            await historyApi.delete(id);
            setHistory(history.filter(h => h.id !== id));
            notify.success('History deleted successfully');
        } catch (error) {
            console.error('Error deleting history:', error);
            notify.error('Failed to delete history');
        } finally {
            setDeletingId(null);
        }
    };

    const openEditModal = (item) => {
        setEditingHistory(item);
        setFormData({
            title: item.title || '',
            description: item.description || '',
            era: item.era || '',
            category: item.category || 'islamic',
            displayMode: item.displayMode || 'browse',
            contentType: item.contentType || 'video',
            videoUrl: item.videoUrl || '',
            documentUrl: item.documentUrl || '',
            imageUrl: item.imageUrl || ''
        });
        setImageFile(null);
        setDocumentFile(null);
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingHistory(null);
        resetForm();
    };

    const resetForm = () => {
        setFormData({
            title: '',
            description: '',
            era: '',
            category: 'islamic',
            displayMode: 'browse',
            contentType: 'video',
            videoUrl: '',
            documentUrl: '',
            imageUrl: ''
        });
        setImageFile(null);
        setDocumentFile(null);
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

    const getDisplayModeBadge = (mode) => {
        switch (mode) {
            case 'browse':
                return <span className="px-2 py-1 bg-cyan-500/20 text-cyan-400 rounded-full text-xs">Browse</span>;
            case 'timeline':
                return <span className="px-2 py-1 bg-orange-500/20 text-orange-400 rounded-full text-xs">Timeline</span>;
            default:
                return <span className="px-2 py-1 bg-gray-500/20 text-gray-400 rounded-full text-xs">Browse</span>;
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">History Management</h1>
                    <p className="text-light-muted">Manage Islamic and Western history content</p>
                </div>
                <button
                    onClick={() => {
                        setEditingHistory(null);
                        resetForm();
                        setShowModal(true);
                    }}
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
                        className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary focus:border-transparent text-light-primary"
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

            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="animate-spin text-gold-primary w-8 h-8" />
                </div>
            ) : (
                <div className="bg-dark-card rounded-xl border border-dark-icon overflow-hidden">
                    <table className="w-full">
                        <thead className="bg-dark-icon/50">
                            <tr>
                                <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Title</th>
                                <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Era</th>
                                <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Category</th>
                                <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Display</th>
                                <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Type</th>
                                <th className="px-6 py-4 text-right text-sm font-medium text-light-muted">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-dark-icon">
                            {filteredHistory.length === 0 ? (
                                <tr>
                                    <td colSpan="6" className="px-6 py-8 text-center text-light-muted">
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
                                                        <ImageIcon size={20} className="text-light-muted" />
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
                                        <td className="px-6 py-4">{getDisplayModeBadge(item.displayMode)}</td>
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
                                                    disabled={deletingId === item.id}
                                                >
                                                    {deletingId === item.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 size={18} />}
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            )}

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card rounded-xl w-full max-w-lg max-h-[90vh] overflow-y-auto border border-dark-icon custom-scrollbar">
                        <div className="flex items-center justify-between p-6 border-b border-dark-icon sticky top-0 bg-dark-card z-10">
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
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Description</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    rows="3"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
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
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    required
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Category</label>
                                    <select
                                        value={formData.category}
                                        onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    >
                                        <option value="islamic">Islamic History</option>
                                        <option value="western">Western History</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Content Type</label>
                                    <select
                                        value={formData.contentType}
                                        onChange={(e) => setFormData({ ...formData, contentType: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    >
                                        <option value="video">Video</option>
                                        <option value="document">Document</option>
                                    </select>
                                </div>
                            </div>
                            {/* Display Mode Selection */}
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Display Mode</label>
                                <div className="grid grid-cols-2 gap-3">
                                    <button
                                        type="button"
                                        onClick={() => setFormData({ ...formData, displayMode: 'browse' })}
                                        className={`px-4 py-3 rounded-lg border transition-colors flex flex-col items-center gap-1 ${formData.displayMode === 'browse'
                                            ? 'bg-cyan-500/20 border-cyan-500 text-cyan-400'
                                            : 'bg-dark-main border-dark-icon text-light-muted hover:border-light-muted'
                                            }`}
                                    >
                                        <span className="font-medium">Browse</span>
                                        <span className="text-xs opacity-70">Videos & Documents</span>
                                    </button>
                                    <button
                                        type="button"
                                        onClick={() => setFormData({ ...formData, displayMode: 'timeline' })}
                                        className={`px-4 py-3 rounded-lg border transition-colors flex flex-col items-center gap-1 ${formData.displayMode === 'timeline'
                                            ? 'bg-orange-500/20 border-orange-500 text-orange-400'
                                            : 'bg-dark-main border-dark-icon text-light-muted hover:border-light-muted'
                                            }`}
                                    >
                                        <span className="font-medium">Timeline</span>
                                        <span className="text-xs opacity-70">Chronological Events</span>
                                    </button>
                                </div>
                            </div>

                            <ImageUpload
                                label="Cover Image"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="history-images"
                            />

                            {/* Dynamic input based on content type */}
                            {formData.contentType === 'video' ? (
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">YouTube URL</label>
                                    <input
                                        type="url"
                                        value={formData.videoUrl}
                                        onChange={(e) => setFormData({ ...formData, videoUrl: e.target.value })}
                                        placeholder="https://youtube.com/watch?v=..."
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    />
                                    <p className="text-xs text-light-muted mt-1">Enter a YouTube video URL</p>
                                </div>
                            ) : (
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Upload Document (PDF)</label>
                                    <input
                                        type="file"
                                        accept=".pdf,.doc,.docx"
                                        onChange={(e) => {
                                            const file = e.target.files[0];
                                            if (file) {
                                                setDocumentFile(file);
                                                setFormData({ ...formData, documentUrl: URL.createObjectURL(file) });
                                            }
                                        }}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-gold-primary file:text-dark-main hover:file:bg-gold-dark text-light-primary"
                                    />
                                    <p className="text-xs text-light-muted mt-1">Upload PDF or Word document (max 10MB)</p>
                                    {formData.documentUrl && (
                                        <p className="text-xs text-green-400 mt-1">✓ Document selected/present</p>
                                    )}
                                </div>
                            )}

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
                                    disabled={submitting}
                                    className="flex-1 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                                >
                                    {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : <Check size={18} />}
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
