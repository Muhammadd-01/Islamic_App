import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
// import { Search, Plus, Edit, Trash2, X, Play, FileText, Check, Globe, Brain, Loader2 } from 'lucide-react';
import { Search, Plus, Edit, Trash2, X, Play, FileText, Check, Globe, Brain, Loader2 } from 'lucide-react';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

export default function ReligionsBeliefs() {
    const { notify } = useNotification();
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingItem, setEditingItem] = useState(null);
    const [typeFilter, setTypeFilter] = useState('all');
    const [imageFile, setImageFile] = useState(null);
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        imageUrl: '',
        type: 'religion', // 'religion' or 'belief'
        contentType: 'video',
        videoUrl: '',
        documentUrl: ''
    });

    useEffect(() => {
        fetchItems();
    }, []);

    const fetchItems = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'religions'));
            const data = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setItems(data);
        } catch (error) {
            notify.error('Failed to fetch items', 'Error');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            if (editingItem) {
                await updateDoc(doc(db, 'religions', editingItem.id), {
                    ...formData,
                    updatedAt: new Date().toISOString()
                });
                notify.success(`${formData.name} updated successfully!`);
            } else {
                await addDoc(collection(db, 'religions'), {
                    ...formData,
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                });
                notify.success(`${formData.name} added successfully!`);
            }
            fetchItems();
            closeModal();
        } catch (error) {
            notify.error('Failed to save item', 'Error');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id, name) => {
        setDeletingId(id);
        try {
            await deleteDoc(doc(db, 'religions', id));
            notify.success(`${name} deleted successfully!`);
            fetchItems();
        } catch (error) {
            notify.error('Failed to delete item', 'Error');
        } finally {
            setDeletingId(null);
        }
    };

    const openEditModal = (item) => {
        setEditingItem(item);
        setFormData({
            name: item.name || '',
            description: item.description || '',
            imageUrl: item.imageUrl || '',
            type: item.type || 'religion',
            contentType: item.contentType || 'video',
            videoUrl: item.videoUrl || '',
            documentUrl: item.documentUrl || ''
        });
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingItem(null);
        setFormData({
            name: '',
            description: '',
            imageUrl: '',
            type: 'religion',
            contentType: 'video',
            videoUrl: '',
            documentUrl: ''
        });
    };

    const filteredItems = items.filter(item => {
        const matchesSearch = item.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.description?.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesType = typeFilter === 'all' || item.type === typeFilter;
        return matchesSearch && matchesType;
    });

    const getTypeBadge = (type) => {
        switch (type) {
            case 'religion':
                return <span className="flex items-center gap-1 px-2 py-1 bg-blue-500/20 text-blue-400 rounded-full text-xs"><Globe size={12} /> Religion</span>;
            case 'belief':
                return <span className="flex items-center gap-1 px-2 py-1 bg-purple-500/20 text-purple-400 rounded-full text-xs"><Brain size={12} /> Belief</span>;
            default:
                return <span className="px-2 py-1 bg-gray-500/20 text-gray-400 rounded-full text-xs">{type}</span>;
        }
    };

    const getContentBadge = (contentType) => {
        switch (contentType) {
            case 'video':
                return <span className="flex items-center gap-1 px-2 py-1 bg-red-500/20 text-red-400 rounded-full text-xs"><Play size={12} /> Video</span>;
            case 'document':
                return <span className="flex items-center gap-1 px-2 py-1 bg-green-500/20 text-green-400 rounded-full text-xs"><FileText size={12} /> Document</span>;
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
                    <h1 className="text-2xl font-bold text-light-primary">Religions & Beliefs</h1>
                    <p className="text-light-muted">Manage world religions and philosophical beliefs</p>
                </div>
                <button
                    onClick={() => setShowModal(true)}
                    className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors"
                >
                    <Plus size={20} />
                    Add Item
                </button>
            </div>

            {/* Filters */}
            <div className="flex flex-col sm:flex-row gap-4">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-light-muted" size={20} />
                    <input
                        type="text"
                        placeholder="Search religions & beliefs..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary focus:border-transparent"
                    />
                </div>
                <div className="flex gap-2">
                    <button
                        onClick={() => setTypeFilter('all')}
                        className={`px-4 py-2 rounded-lg transition-colors ${typeFilter === 'all' ? 'bg-gold-primary text-dark-main' : 'bg-dark-card text-light-muted hover:bg-dark-icon'}`}
                    >
                        All
                    </button>
                    <button
                        onClick={() => setTypeFilter('religion')}
                        className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-colors ${typeFilter === 'religion' ? 'bg-blue-600 text-white' : 'bg-dark-card text-light-muted hover:bg-dark-icon'}`}
                    >
                        <Globe size={16} /> Religions
                    </button>
                    <button
                        onClick={() => setTypeFilter('belief')}
                        className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-colors ${typeFilter === 'belief' ? 'bg-purple-600 text-white' : 'bg-dark-card text-light-muted hover:bg-dark-icon'}`}
                    >
                        <Brain size={16} /> Beliefs
                    </button>
                </div>
            </div>

            {/* Items Table */}
            <div className="bg-dark-card rounded-xl border border-dark-icon overflow-hidden">
                <table className="w-full">
                    <thead className="bg-dark-icon/50">
                        <tr>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Name</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Type</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Content</th>
                            <th className="px-6 py-4 text-right text-sm font-medium text-light-muted">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-dark-icon">
                        {filteredItems.length === 0 ? (
                            <tr>
                                <td colSpan="4" className="px-6 py-8 text-center text-light-muted">
                                    No items found
                                </td>
                            </tr>
                        ) : (
                            filteredItems.map((item) => (
                                <tr key={item.id} className="hover:bg-dark-icon/30 transition-colors">
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-3">
                                            {item.imageUrl ? (
                                                <img src={item.imageUrl} alt={item.name} className="w-10 h-10 rounded-lg object-cover" />
                                            ) : (
                                                <div className="w-10 h-10 rounded-lg bg-dark-icon flex items-center justify-center">
                                                    {item.type === 'religion' ? <Globe size={20} className="text-blue-400" /> : <Brain size={20} className="text-purple-400" />}
                                                </div>
                                            )}
                                            <div>
                                                <p className="font-medium text-light-primary">{item.name}</p>
                                                <p className="text-sm text-light-muted line-clamp-1">{item.description}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4">{getTypeBadge(item.type)}</td>
                                    <td className="px-6 py-4">{getContentBadge(item.contentType)}</td>
                                    <td className="px-6 py-4">
                                        <div className="flex items-center justify-end gap-2">
                                            <button
                                                onClick={() => openEditModal(item)}
                                                className="p-2 text-light-muted hover:text-gold-primary hover:bg-dark-icon rounded-lg transition-colors"
                                                disabled={deletingId === item.id}
                                            >
                                                <Edit size={18} />
                                            </button>
                                            <button
                                                onClick={() => handleDelete(item.id, item.name)}
                                                className="p-2 text-light-muted hover:text-red-400 hover:bg-dark-icon rounded-lg transition-colors"
                                                disabled={deletingId === item.id}
                                            >
                                                {deletingId === item.id ? (
                                                    <Loader2 size={18} className="animate-spin" />
                                                ) : (
                                                    <Trash2 size={18} />
                                                )}
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
                                {editingItem ? 'Edit Item' : 'Add Religion or Belief'}
                            </h2>
                            <button onClick={closeModal} className="p-2 hover:bg-dark-icon rounded-lg">
                                <X size={20} className="text-light-muted" />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Name</label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    placeholder="e.g., Christianity, Atheism"
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
                                    placeholder="Brief description"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            {/* Type Selection */}
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Type</label>
                                <div className="grid grid-cols-2 gap-3">
                                    <button
                                        type="button"
                                        onClick={() => setFormData({ ...formData, type: 'religion' })}
                                        className={`px-4 py-3 rounded-lg border transition-colors flex items-center justify-center gap-2 ${formData.type === 'religion'
                                            ? 'bg-blue-500/20 border-blue-500 text-blue-400'
                                            : 'bg-dark-main border-dark-icon text-light-muted hover:border-light-muted'
                                            }`}
                                    >
                                        <Globe size={18} />
                                        <span className="font-medium">Religion</span>
                                    </button>
                                    <button
                                        type="button"
                                        onClick={() => setFormData({ ...formData, type: 'belief' })}
                                        className={`px-4 py-3 rounded-lg border transition-colors flex items-center justify-center gap-2 ${formData.type === 'belief'
                                            ? 'bg-purple-500/20 border-purple-500 text-purple-400'
                                            : 'bg-dark-main border-dark-icon text-light-muted hover:border-light-muted'
                                            }`}
                                    >
                                        <Brain size={18} />
                                        <span className="font-medium">Belief</span>
                                    </button>
                                </div>
                            </div>
                            <ImageUpload
                                label="Cover/Symbol Image"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="religion-images"
                            />
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
                            {/* Dynamic URL input based on content type */}
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
                                </div>
                            ) : (
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Document URL</label>
                                    <input
                                        type="url"
                                        value={formData.documentUrl}
                                        onChange={(e) => setFormData({ ...formData, documentUrl: e.target.value })}
                                        placeholder="https://example.com/document.pdf"
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    />
                                </div>
                            )}
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="flex-1 px-4 py-2 bg-dark-icon text-light-primary rounded-lg hover:bg-dark-icon/80 transition-colors"
                                    disabled={submitting}
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                                    disabled={submitting}
                                >
                                    {submitting ? (
                                        <Loader2 size={18} className="animate-spin" />
                                    ) : (
                                        <Check size={18} />
                                    )}
                                    {submitting ? 'Saving...' : (editingItem ? 'Update' : 'Create')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
