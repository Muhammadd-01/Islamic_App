import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Music, X, Globe, User } from 'lucide-react';
import { reciterApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

export default function Reciters() {
    const { notify } = useNotification();
    const [reciters, setReciters] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingReciter, setEditingReciter] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);

    const [formData, setFormData] = useState({
        name: '',
        language: 'Arabic',
        imageUrl: '',
        description: ''
    });

    useEffect(() => {
        fetchReciters();
    }, []);

    const fetchReciters = async () => {
        try {
            setLoading(true);
            const { data } = await reciterApi.getAll();
            setReciters(data);
        } catch (error) {
            console.error('Error fetching reciters:', error);
            notify.error('Failed to fetch reciters');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            if (editingReciter) {
                await reciterApi.update(editingReciter.id, formData);
                notify.success('Reciter updated successfully');
            } else {
                await reciterApi.create(formData);
                notify.success('Reciter created successfully');
            }
            fetchReciters();
            closeModal();
        } catch (error) {
            notify.error('Failed to save reciter');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure?')) return;
        setDeletingId(id);
        try {
            await reciterApi.delete(id);
            setReciters(reciters.filter(r => r.id !== id));
            notify.success('Reciter deleted');
        } catch (error) {
            notify.error('Failed to delete');
        } finally {
            setDeletingId(null);
        }
    };

    const openModal = (item = null) => {
        if (item) {
            setEditingReciter(item);
            setFormData({
                name: item.name || '',
                language: item.language || 'Arabic',
                imageUrl: item.imageUrl || '',
                description: item.description || ''
            });
        } else {
            setEditingReciter(null);
            setFormData({ name: '', language: 'Arabic', imageUrl: '', description: '' });
        }
        setShowModal(true);
    };

    const closeModal = () => setShowModal(false);

    const filtered = reciters.filter(r =>
        r.name?.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Reciters Management</h1>
                    <p className="text-light-muted">Manage Quran reciters and their profiles</p>
                </div>
                <button onClick={() => openModal()} className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark">
                    <Plus size={20} /> Add Reciter
                </button>
            </div>

            <div className="relative">
                <Search className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                <input
                    type="text"
                    placeholder="Search reciters..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon text-light-primary rounded-lg outline-none focus:ring-2 focus:ring-gold-primary"
                />
            </div>

            {loading ? (
                <div className="flex justify-center py-12"><Loader2 className="animate-spin text-gold-primary" /></div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {filtered.map(reciter => (
                        <div key={reciter.id} className="bg-dark-card border border-dark-icon rounded-xl overflow-hidden p-4">
                            <div className="flex items-center gap-4 mb-4">
                                {reciter.imageUrl ? (
                                    <img src={reciter.imageUrl} className="w-16 h-16 rounded-full object-cover border-2 border-gold-primary/30" />
                                ) : (
                                    <div className="w-16 h-16 rounded-full bg-gold-primary/10 flex items-center justify-center text-gold-primary"><User size={32} /></div>
                                )}
                                <div>
                                    <h3 className="font-bold text-light-primary">{reciter.name}</h3>
                                    <p className="text-xs text-light-muted flex items-center gap-1"><Globe size={12} /> {reciter.language}</p>
                                </div>
                            </div>
                            <div className="flex gap-2">
                                <button onClick={() => openModal(reciter)} className="flex-1 py-2 bg-dark-icon text-gold-primary rounded-lg hover:bg-dark-icon/80 flex items-center justify-center gap-1"><Edit size={16} /> Edit</button>
                                <button onClick={() => handleDelete(reciter.id)} className="flex-1 py-2 bg-red-500/10 text-red-400 rounded-lg hover:bg-red-500/20 flex items-center justify-center" disabled={deletingId === reciter.id}>
                                    {deletingId === reciter.id ? <Loader2 className="animate-spin w-4 h-4" /> : <Trash2 size={16} />}
                                </button>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-md">
                        <div className="flex items-center justify-between p-6 border-b border-dark-icon">
                            <h2 className="font-bold text-light-primary">{editingReciter ? 'Edit' : 'Add'} Reciter</h2>
                            <button onClick={closeModal}><X size={20} className="text-light-muted" /></button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm text-light-muted mb-1">Name</label>
                                <input type="text" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary" required />
                            </div>
                            <div>
                                <label className="block text-sm text-light-muted mb-1">Language</label>
                                <input type="text" value={formData.language} onChange={e => setFormData({ ...formData, language: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary" required />
                            </div>
                            <ImageUpload label="Profile Picture" value={formData.imageUrl} onChange={url => setFormData({ ...formData, imageUrl: url })} bucket="reciters" />
                            <div className="flex gap-3 pt-4">
                                <button type="button" onClick={closeModal} className="flex-1 py-2 border border-dark-icon rounded-lg text-light-muted">Cancel</button>
                                <button type="submit" disabled={submitting} className="flex-1 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark disabled:opacity-50">
                                    {submitting ? <Loader2 className="animate-spin w-5 h-5 mx-auto" /> : (editingReciter ? 'Update' : 'Create')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
