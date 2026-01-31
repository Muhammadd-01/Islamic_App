import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { Search, Plus, Edit, Trash2, X, Play, FileText, Check } from 'lucide-react';
import { useNotification } from '../components/NotificationSystem';

export default function Beliefs() {
    const { notify } = useNotification();
    const [beliefs, setBeliefs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingBelief, setEditingBelief] = useState(null);
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        category: 'atheism',
        contentType: 'video',
        videoUrl: '',
        documentUrl: '',
        imageUrl: ''
    });

    const categories = [
        { value: 'atheism', label: 'Atheism' },
        { value: 'agnosticism', label: 'Agnosticism' },
        { value: 'deism', label: 'Deism' },
        { value: 'humanism', label: 'Secular Humanism' },
        { value: 'nihilism', label: 'Nihilism' },
        { value: 'other', label: 'Other' }
    ];

    useEffect(() => {
        fetchBeliefs();
    }, []);

    const fetchBeliefs = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'beliefs'));
            const data = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setBeliefs(data);
        } catch (error) {
            console.error('Error fetching beliefs:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editingBelief) {
                await updateDoc(doc(db, 'beliefs', editingBelief.id), {
                    ...formData,
                    updatedAt: new Date().toISOString()
                });
            } else {
                await addDoc(collection(db, 'beliefs'), {
                    ...formData,
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                });
            }
            fetchBeliefs();
            closeModal();
        } catch (error) {
            console.error('Error saving belief:', error);
            notify.error('Failed to save content');
        }
    };

    const handleDelete = async (id) => {
        const confirmed = await notify.confirm({
            title: 'Delete Content',
            message: 'Are you sure you want to delete this item? This action cannot be undone.',
            confirmText: 'Delete',
            cancelText: 'Cancel'
        });
        if (!confirmed) return;

        try {
            await deleteDoc(doc(db, 'beliefs', id));
            notify.success('Content deleted successfully');
            fetchBeliefs();
        } catch (error) {
            console.error('Error deleting belief:', error);
            notify.error('Failed to delete content');
        }
    };


    const openEditModal = (item) => {
        setEditingBelief(item);
        setFormData({
            name: item.name || '',
            description: item.description || '',
            category: item.category || 'atheism',
            contentType: item.contentType || 'video',
            videoUrl: item.videoUrl || '',
            documentUrl: item.documentUrl || '',
            imageUrl: item.imageUrl || ''
        });
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingBelief(null);
        setFormData({
            name: '',
            description: '',
            category: 'atheism',
            contentType: 'video',
            videoUrl: '',
            documentUrl: '',
            imageUrl: ''
        });
    };

    const filteredBeliefs = beliefs.filter(item =>
        item.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.description?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const getCategoryBadge = (category) => {
        const colors = {
            atheism: 'bg-red-500/20 text-red-400',
            agnosticism: 'bg-yellow-500/20 text-yellow-400',
            deism: 'bg-blue-500/20 text-blue-400',
            humanism: 'bg-green-500/20 text-green-400',
            nihilism: 'bg-purple-500/20 text-purple-400',
            other: 'bg-gray-500/20 text-gray-400'
        };
        const label = categories.find(c => c.value === category)?.label || category;
        return <span className={`px-2 py-1 ${colors[category] || colors.other} rounded-full text-xs`}>{label}</span>;
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
                    <h1 className="text-2xl font-bold text-light-primary">Beliefs & Worldviews</h1>
                    <p className="text-light-muted">Manage content for Atheism, Agnosticism, and other worldviews</p>
                </div>
                <button
                    onClick={() => setShowModal(true)}
                    className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors"
                >
                    <Plus size={20} />
                    Add Content
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-light-muted" size={20} />
                <input
                    type="text"
                    placeholder="Search beliefs..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                />
            </div>

            {/* Table */}
            <div className="bg-dark-card rounded-xl border border-dark-icon overflow-hidden">
                <table className="w-full">
                    <thead className="bg-dark-icon/50">
                        <tr>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Name</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Category</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Type</th>
                            <th className="px-6 py-4 text-right text-sm font-medium text-light-muted">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-dark-icon">
                        {filteredBeliefs.length === 0 ? (
                            <tr>
                                <td colSpan="4" className="px-6 py-8 text-center text-light-muted">
                                    No beliefs content found
                                </td>
                            </tr>
                        ) : (
                            filteredBeliefs.map((item) => (
                                <tr key={item.id} className="hover:bg-dark-icon/30 transition-colors">
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-3">
                                            {item.imageUrl ? (
                                                <img src={item.imageUrl} alt={item.name} className="w-10 h-10 rounded-lg object-cover" />
                                            ) : (
                                                <div className="w-10 h-10 rounded-lg bg-dark-icon flex items-center justify-center">
                                                    <FileText size={20} className="text-light-muted" />
                                                </div>
                                            )}
                                            <div>
                                                <p className="font-medium text-light-primary">{item.name}</p>
                                                <p className="text-sm text-light-muted line-clamp-1">{item.description}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4">{getCategoryBadge(item.category)}</td>
                                    <td className="px-6 py-4">
                                        <span className="flex items-center gap-1 px-2 py-1 bg-blue-500/20 text-blue-400 rounded-full text-xs">
                                            {item.contentType === 'video' ? <Play size={12} /> : <FileText size={12} />}
                                            {item.contentType}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="flex items-center justify-end gap-2">
                                            <button
                                                onClick={() => openEditModal(item)}
                                                className="p-2 text-light-muted hover:text-gold-primary hover:bg-dark-icon rounded-lg"
                                            >
                                                <Edit size={18} />
                                            </button>
                                            <button
                                                onClick={() => handleDelete(item.id)}
                                                className="p-2 text-light-muted hover:text-red-400 hover:bg-dark-icon rounded-lg"
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
                                {editingBelief ? 'Edit Content' : 'Add Content'}
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
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Category</label>
                                    <select
                                        value={formData.category}
                                        onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    >
                                        {categories.map(cat => (
                                            <option key={cat.value} value={cat.value}>{cat.label}</option>
                                        ))}
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
                                    className="flex-1 px-4 py-2 bg-dark-icon text-light-primary rounded-lg hover:bg-dark-icon/80"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark flex items-center justify-center gap-2"
                                >
                                    <Check size={18} />
                                    {editingBelief ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
