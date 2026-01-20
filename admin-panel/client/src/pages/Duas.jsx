import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Image as ImageIcon, X } from 'lucide-react';
import { duasApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

export default function Duas() {
    const { notify } = useNotification();
    const [duas, setDuas] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingDua, setEditingDua] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [imageFile, setImageFile] = useState(null);

    const [formData, setFormData] = useState({
        title: '',
        arabic: '',
        transliteration: '',
        translation: '',
        category: '',
        reference: '',
        benefits: '',
        imageUrl: '' // New field
    });

    const categories = ['Morning', 'Evening', 'Prayer', 'Travel', 'Food', 'Sleep', 'Protection', 'Forgiveness', 'General'];

    useEffect(() => {
        fetchDuas();
    }, []);

    const fetchDuas = async () => {
        try {
            setLoading(true);
            const { data } = await duasApi.getAll();
            setDuas(data);
        } catch (error) {
            console.error('Error fetching duas:', error);
            notify.error('Failed to fetch duas');
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
            data.append('arabic', formData.arabic);
            data.append('transliteration', formData.transliteration);
            data.append('translation', formData.translation);
            data.append('category', formData.category);
            data.append('reference', formData.reference);
            data.append('benefits', formData.benefits);
            if (formData.imageUrl) data.append('imageUrl', formData.imageUrl);

            if (imageFile) {
                data.append('image', imageFile);
            }

            if (editingDua) {
                await duasApi.update(editingDua.id, data);
                notify.success('Dua updated successfully');
            } else {
                await duasApi.create(data);
                notify.success('Dua created successfully');
            }

            fetchDuas();
            closeModal();
        } catch (error) {
            console.error('Error saving dua:', error);
            notify.error('Failed to save dua: ' + (error.response?.data?.error || error.message));
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this dua?')) return;
        setDeletingId(id);
        try {
            await duasApi.delete(id);
            setDuas(duas.filter(d => d.id !== id));
            notify.success('Dua deleted successfully');
        } catch (error) {
            console.error('Error deleting dua:', error);
            notify.error('Failed to delete dua');
        } finally {
            setDeletingId(null);
        }
    };

    const openModal = (dua = null) => {
        if (dua) {
            setEditingDua(dua);
            setFormData({
                title: dua.title || '',
                arabic: dua.arabic || '',
                transliteration: dua.transliteration || '',
                translation: dua.translation || '',
                category: dua.category || '',
                reference: dua.reference || '',
                benefits: dua.benefits || '',
                imageUrl: dua.imageUrl || ''
            });
        } else {
            setEditingDua(null);
            setFormData({
                title: '',
                arabic: '',
                transliteration: '',
                translation: '',
                category: '',
                reference: '',
                benefits: '',
                imageUrl: ''
            });
        }
        setImageFile(null);
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingDua(null);
        setImageFile(null);
    };

    const filteredDuas = duas.filter(dua =>
        dua.title?.toLowerCase().includes(search.toLowerCase()) ||
        dua.category?.toLowerCase().includes(search.toLowerCase()) ||
        dua.arabic?.includes(search)
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary font-outfit">Duas</h1>
                    <p className="text-light-muted">Manage Islamic supplications</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg hover:bg-gold-dark transition-colors"
                >
                    <Plus size={20} />
                    Add Dua
                </button>
            </div>

            <div className="relative">
                <Search className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                <input
                    type="text"
                    placeholder="Search duas..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none"
                />
            </div>

            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
                </div>
            ) : (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                    {filteredDuas.map((dua) => (
                        <div key={dua.id} className="bg-dark-card border border-dark-icon rounded-xl p-4 hover:border-gold-primary/30 transition-colors">
                            <div className="flex justify-between items-start">
                                <div className="flex-1">
                                    <div className="flex items-center gap-2 mb-2">
                                        <span className="px-2 py-1 bg-gold-primary/20 text-gold-primary text-xs rounded-full">
                                            {dua.category}
                                        </span>
                                        {dua.imageUrl && <ImageIcon size={14} className="text-light-muted" />}
                                    </div>
                                    <h3 className="text-lg text-light-primary font-medium">{dua.title}</h3>
                                </div>
                                <div className="flex gap-2">
                                    <button onClick={() => openModal(dua)} className="p-1 text-light-muted hover:text-gold-primary">
                                        <Edit size={16} />
                                    </button>
                                    <button
                                        onClick={() => handleDelete(dua.id)}
                                        className="p-1 text-light-muted hover:text-red-400"
                                        disabled={deletingId === dua.id}
                                    >
                                        {deletingId === dua.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 size={16} />}
                                    </button>
                                </div>
                            </div>
                            <p className="mt-2 text-gold-primary text-right text-lg font-amiri" dir="rtl">{dua.arabic}</p>
                            <p className="mt-2 text-light-muted text-sm italic">{dua.transliteration}</p>
                            <p className="mt-1 text-light-primary text-sm">{dua.translation}</p>
                        </div>
                    ))}
                </div>
            )}

            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-lg max-h-[90vh] overflow-y-auto custom-scrollbar">
                        <div className="flex items-center justify-between p-6 border-b border-dark-icon sticky top-0 bg-dark-card z-10">
                            <h2 className="text-xl font-bold text-light-primary">
                                {editingDua ? 'Edit Dua' : 'Add New Dua'}
                            </h2>
                            <button onClick={closeModal} className="text-light-muted hover:text-light-primary">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Title</label>
                                <input
                                    type="text"
                                    placeholder="Title"
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Category</label>
                                <select
                                    value={formData.category}
                                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                >
                                    <option value="">Select Category</option>
                                    {categories.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                                </select>
                            </div>

                            <ImageUpload
                                label="Background/Category Image (Optional)"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="dua-images"
                            />

                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Arabic Text</label>
                                <textarea
                                    placeholder="Arabic"
                                    value={formData.arabic}
                                    onChange={(e) => setFormData({ ...formData, arabic: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg text-right font-amiri"
                                    dir="rtl"
                                    rows={3}
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Transliteration</label>
                                <textarea
                                    placeholder="Transliteration"
                                    value={formData.transliteration}
                                    onChange={(e) => setFormData({ ...formData, transliteration: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                    rows={2}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Translation</label>
                                <textarea
                                    placeholder="Translation"
                                    value={formData.translation}
                                    onChange={(e) => setFormData({ ...formData, translation: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                    rows={2}
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Reference</label>
                                <input
                                    type="text"
                                    placeholder="Reference (e.g., Sahih Bukhari)"
                                    value={formData.reference}
                                    onChange={(e) => setFormData({ ...formData, reference: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Benefits</label>
                                <textarea
                                    placeholder="Benefits"
                                    value={formData.benefits}
                                    onChange={(e) => setFormData({ ...formData, benefits: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                    rows={2}
                                />
                            </div>
                            <div className="flex gap-3 pt-2">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon">
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting}
                                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark disabled:opacity-50"
                                >
                                    {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : (editingDua ? 'Update' : 'Create')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
