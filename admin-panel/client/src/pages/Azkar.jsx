import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, X } from 'lucide-react';
import { azkarApi } from '../services/api';
import { useNotification } from '../components/NotificationSystem';

export default function Azkar() {
    const { notify } = useNotification();
    const [azkar, setAzkar] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingAzkar, setEditingAzkar] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        arabic: '',
        meaning: ''
    });

    useEffect(() => {
        fetchAzkar();
    }, []);

    const fetchAzkar = async () => {
        try {
            setLoading(true);
            const { data } = await azkarApi.getAll();
            setAzkar(data);
        } catch (error) {
            console.error('Error fetching azkar:', error);
            notify.error('Failed to fetch azkar');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            if (editingAzkar) {
                await azkarApi.update(editingAzkar.id, formData);
                notify.success('Azkar updated successfully');
            } else {
                await azkarApi.create(formData);
                notify.success('Azkar created successfully');
            }
            fetchAzkar();
            closeModal();
        } catch (error) {
            notify.error(error.response?.data?.error || 'Failed to save azkar');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this azkar?')) return;
        try {
            await azkarApi.delete(id);
            setAzkar(azkar.filter(a => a.id !== id));
            notify.success('Azkar deleted successfully');
        } catch (error) {
            notify.error('Failed to delete azkar');
        }
    };

    const openModal = (item = null) => {
        if (item) {
            setEditingAzkar(item);
            setFormData({
                name: item.name,
                arabic: item.arabic,
                meaning: item.meaning
            });
        } else {
            setEditingAzkar(null);
            setFormData({ name: '', arabic: '', meaning: '' });
        }
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingAzkar(null);
    };

    const filteredAzkar = azkar.filter(a =>
        a.name.toLowerCase().includes(search.toLowerCase()) ||
        a.meaning.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Azkar Management</h1>
                    <p className="text-light-muted">Add or edit azkar for the Tasbeeh screen</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark transition-colors"
                >
                    <Plus size={20} />
                    Add Azkar
                </button>
            </div>

            <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-light-muted" size={20} />
                <input
                    type="text"
                    placeholder="Search azkar..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none transition-all hover:border-gold-primary/30"
                />
            </div>

            {loading ? (
                <div className="flex justify-center py-12">
                    <Loader2 className="animate-spin text-gold-primary" size={40} />
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filteredAzkar.map((item) => (
                        <div key={item.id} className="bg-dark-card p-6 rounded-xl border border-dark-icon hover:border-gold-primary/50 hover:shadow-lg hover:shadow-gold-primary/5 transition-all group">
                            <div className="flex justify-between items-start mb-4">
                                <h3 className="text-2xl font-bold text-gold-primary font-arabic" dir="rtl">{item.arabic}</h3>
                                <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button onClick={() => openModal(item)} className="p-2 text-light-muted hover:text-blue-400 transition-colors">
                                        <Edit size={18} />
                                    </button>
                                    <button onClick={() => handleDelete(item.id)} className="p-2 text-light-muted hover:text-red-400 transition-colors">
                                        <Trash2 size={18} />
                                    </button>
                                </div>
                            </div>
                            <h4 className="font-bold text-light-primary mb-1">{item.name}</h4>
                            <p className="text-light-muted text-sm line-clamp-2">{item.meaning}</p>
                        </div>
                    ))}
                </div>
            )}

            {showModal && (
                <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50 backdrop-blur-sm">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-md overflow-hidden shadow-2xl">
                        <div className="flex justify-between items-center p-6 border-b border-dark-icon bg-dark-main/30">
                            <h2 className="text-xl font-bold text-light-primary">{editingAzkar ? 'Edit Azkar' : 'Add Azkar'}</h2>
                            <button onClick={closeModal} className="text-light-muted hover:text-light-primary transition-colors">
                                <X size={24} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Name (Transliteration)</label>
                                <input
                                    required
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none hover:border-gold-primary/30 transition-all"
                                    placeholder="e.g. SubhanAllah"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Arabic Text</label>
                                <input
                                    required
                                    type="text"
                                    value={formData.arabic}
                                    onChange={(e) => setFormData({ ...formData, arabic: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none text-right font-arabic hover:border-gold-primary/30 transition-all"
                                    placeholder="سُبْحَانَ اللّٰهِ"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Meaning</label>
                                <textarea
                                    required
                                    value={formData.meaning}
                                    onChange={(e) => setFormData({ ...formData, meaning: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none h-24 resize-none hover:border-gold-primary/30 transition-all"
                                    placeholder="The meaning of the azkar..."
                                />
                            </div>
                            <div className="flex gap-4 pt-4">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon transition-all"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting}
                                    className="flex-1 bg-gold-primary text-dark-main font-medium px-4 py-2 rounded-lg hover:bg-gold-dark transition-all disabled:opacity-50 flex justify-center items-center backdrop-blur-sm"
                                >
                                    {submitting ? <Loader2 className="animate-spin" size={20} /> : 'Save Azkar'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
