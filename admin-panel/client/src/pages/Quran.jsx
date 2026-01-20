import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Image as ImageIcon, X } from 'lucide-react';
import { quranApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

export default function Quran() {
    const { notify } = useNotification();
    const [quran, setQuran] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingQuran, setEditingQuran] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [imageFile, setImageFile] = useState(null);

    const [formData, setFormData] = useState({
        surahName: '',
        surahNumber: '',
        ayahs: '',
        revelationType: 'Meccan',
        description: '',
        imageUrl: '',
        audioUrl: ''
    });

    useEffect(() => {
        fetchQuran();
    }, []);

    const fetchQuran = async () => {
        try {
            setLoading(true);
            const { data } = await quranApi.getAll();
            setQuran(data);
        } catch (error) {
            console.error('Error fetching quran data:', error);
            notify.error('Failed to fetch Quran data');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            const data = new FormData();
            data.append('surahName', formData.surahName);
            data.append('surahNumber', formData.surahNumber);
            data.append('ayahs', formData.ayahs);
            data.append('revelationType', formData.revelationType);
            data.append('description', formData.description);
            data.append('audioUrl', formData.audioUrl);
            if (formData.imageUrl) data.append('imageUrl', formData.imageUrl);

            if (imageFile) {
                data.append('image', imageFile);
            }

            if (editingQuran) {
                await quranApi.update(editingQuran.id, data);
                notify.success('Entry updated successfully');
            } else {
                await quranApi.create(data);
                notify.success('Entry created successfully');
            }

            fetchQuran();
            closeModal();
        } catch (error) {
            console.error('Error saving quran entry:', error);
            notify.error('Failed to save entry: ' + (error.response?.data?.error || error.message));
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this entry?')) return;
        setDeletingId(id);
        try {
            await quranApi.delete(id);
            setQuran(quran.filter(i => i.id !== id));
            notify.success('Entry deleted successfully');
        } catch (error) {
            console.error('Error deleting entry:', error);
            notify.error('Failed to delete entry');
        } finally {
            setDeletingId(null);
        }
    };

    const openModal = (item = null) => {
        if (item) {
            setEditingQuran(item);
            setFormData({
                surahName: item.surahName || '',
                surahNumber: item.surahNumber || '',
                ayahs: item.ayahs || '',
                revelationType: item.revelationType || 'Meccan',
                description: item.description || '',
                imageUrl: item.imageUrl || '',
                audioUrl: item.audioUrl || ''
            });
        } else {
            setEditingQuran(null);
            setFormData({
                surahName: '',
                surahNumber: '',
                ayahs: '',
                revelationType: 'Meccan',
                description: '',
                imageUrl: '',
                audioUrl: ''
            });
        }
        setImageFile(null);
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingQuran(null);
        setImageFile(null);
    };

    const filteredQuran = quran.filter(item =>
        item.surahName?.toLowerCase().includes(search.toLowerCase()) ||
        String(item.surahNumber)?.includes(search)
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Quran Management</h1>
                    <p className="text-light-muted">Manage Surahs, Ayahs, and Interpretations</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark transition"
                >
                    <Plus size={20} />
                    Add Entry
                </button>
            </div>

            <div className="relative">
                <Search className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                <input
                    type="text"
                    placeholder="Search Surah Name or Number..."
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
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filteredQuran.map((item) => (
                        <div key={item.id} className="bg-dark-card border border-dark-icon rounded-xl overflow-hidden hover:border-gold-primary/50 transition-colors">
                            <div className="p-5 border-b border-dark-icon flex justify-between items-center bg-dark-main/30">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-full bg-gold-primary/20 text-gold-primary flex items-center justify-center font-bold">
                                        {item.surahNumber}
                                    </div>
                                    <div>
                                        <h3 className="text-lg font-semibold text-light-primary">{item.surahName}</h3>
                                        <span className="text-xs text-light-muted">{item.revelationType} • {item.ayahs} Ayahs</span>
                                    </div>
                                </div>
                                {item.imageUrl && (
                                    <img src={item.imageUrl} alt={item.surahName} className="w-10 h-10 rounded object-cover" />
                                )}
                            </div>
                            <div className="p-4">
                                <p className="text-light-muted text-sm mb-4 line-clamp-3">{item.description}</p>
                                <div className="flex gap-2">
                                    <button
                                        onClick={() => openModal(item)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-dark-icon text-gold-primary py-2 rounded-lg hover:bg-dark-icon/80"
                                    >
                                        <Edit size={16} />
                                        Edit
                                    </button>
                                    <button
                                        onClick={() => handleDelete(item.id)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-red-500/10 text-red-400 py-2 rounded-lg hover:bg-red-500/20"
                                        disabled={deletingId === item.id}
                                    >
                                        {deletingId === item.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 size={16} />}
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-lg max-h-[90vh] overflow-y-auto custom-scrollbar">
                        <div className="flex items-center justify-between p-6 border-b border-dark-icon sticky top-0 bg-dark-card z-10">
                            <h2 className="text-xl font-bold text-light-primary">
                                {editingQuran ? 'Edit Entry' : 'Add Entry'}
                            </h2>
                            <button onClick={closeModal} className="text-light-muted hover:text-light-primary">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Surah Number</label>
                                    <input
                                        type="number"
                                        value={formData.surahNumber}
                                        onChange={(e) => setFormData({ ...formData, surahNumber: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Surah Name</label>
                                    <input
                                        type="text"
                                        value={formData.surahName}
                                        onChange={(e) => setFormData({ ...formData, surahName: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                        required
                                    />
                                </div>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Number of Ayahs</label>
                                    <input
                                        type="number"
                                        value={formData.ayahs}
                                        onChange={(e) => setFormData({ ...formData, ayahs: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                        required
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Revelation Type</label>
                                    <select
                                        value={formData.revelationType}
                                        onChange={(e) => setFormData({ ...formData, revelationType: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    >
                                        <option value="Meccan">Meccan</option>
                                        <option value="Medinan">Medinan</option>
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Description/Overview</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary h-24 resize-none"
                                />
                            </div>

                            <ImageUpload
                                label="Cover/Calligraphy"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="quran-images"
                            />

                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Audio URL (Recitation)</label>
                                <input
                                    type="text"
                                    value={formData.audioUrl}
                                    onChange={(e) => setFormData({ ...formData, audioUrl: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    placeholder="https://..."
                                />
                            </div>

                            <div className="flex gap-3 pt-4">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon">
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting}
                                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark disabled:opacity-50"
                                >
                                    {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : (editingQuran ? 'Update' : 'Create')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
