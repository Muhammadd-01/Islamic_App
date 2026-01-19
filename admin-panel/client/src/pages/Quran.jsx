import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { Search, Plus, Edit, Trash2, X, Check, BookOpen } from 'lucide-react';

export default function Quran() {
    const [surahs, setSurahs] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingSurah, setEditingSurah] = useState(null);
    const [formData, setFormData] = useState({
        number: '',
        name_ar: '',
        name_en: '',
        name_transliteration: '',
        totalAyahs: '',
        revelationType: 'meccan',
        description: ''
    });

    useEffect(() => {
        fetchSurahs();
    }, []);

    const fetchSurahs = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'surahs'));
            const data = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setSurahs(data.sort((a, b) => (a.number || 0) - (b.number || 0)));
        } catch (error) {
            console.error('Error fetching surahs:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const surahData = {
                ...formData,
                number: parseInt(formData.number) || 0,
                totalAyahs: parseInt(formData.totalAyahs) || 0,
                updatedAt: new Date().toISOString()
            };

            if (editingSurah) {
                await updateDoc(doc(db, 'surahs', editingSurah.id), surahData);
            } else {
                await addDoc(collection(db, 'surahs'), {
                    ...surahData,
                    createdAt: new Date().toISOString()
                });
            }
            fetchSurahs();
            closeModal();
        } catch (error) {
            console.error('Error saving surah:', error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this surah?')) {
            try {
                await deleteDoc(doc(db, 'surahs', id));
                fetchSurahs();
            } catch (error) {
                console.error('Error deleting surah:', error);
            }
        }
    };

    const openEditModal = (item) => {
        setEditingSurah(item);
        setFormData({
            number: item.number?.toString() || '',
            name_ar: item.name_ar || '',
            name_en: item.name_en || '',
            name_transliteration: item.name_transliteration || '',
            totalAyahs: item.totalAyahs?.toString() || '',
            revelationType: item.revelationType || 'meccan',
            description: item.description || ''
        });
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingSurah(null);
        setFormData({
            number: '',
            name_ar: '',
            name_en: '',
            name_transliteration: '',
            totalAyahs: '',
            revelationType: 'meccan',
            description: ''
        });
    };

    const filteredSurahs = surahs.filter(item => {
        return item.name_en?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.name_transliteration?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.number?.toString().includes(searchTerm);
    });

    const getRevelationBadge = (type) => {
        if (type === 'meccan') {
            return <span className="px-2 py-1 bg-amber-500/20 text-amber-400 rounded-full text-xs">Meccan</span>;
        }
        return <span className="px-2 py-1 bg-emerald-500/20 text-emerald-400 rounded-full text-xs">Medinan</span>;
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
                    <h1 className="text-2xl font-bold text-light-primary">Quran Management</h1>
                    <p className="text-light-muted">Manage Surah information and metadata</p>
                </div>
                <button
                    onClick={() => setShowModal(true)}
                    className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors"
                >
                    <Plus size={20} />
                    Add Surah
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-light-muted" size={20} />
                <input
                    type="text"
                    placeholder="Search surahs by name or number..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary focus:border-transparent text-light-primary"
                />
            </div>

            {/* Surahs Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {filteredSurahs.length === 0 ? (
                    <p className="col-span-full text-center text-light-muted py-8">No surahs found</p>
                ) : (
                    filteredSurahs.map((surah) => (
                        <div key={surah.id} className="bg-dark-card rounded-xl border border-dark-icon p-4 hover:border-gold-primary/50 transition-colors">
                            <div className="flex items-start justify-between mb-3">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-lg bg-gold-primary/20 flex items-center justify-center">
                                        <span className="text-gold-primary font-bold">{surah.number}</span>
                                    </div>
                                    <div>
                                        <h3 className="font-medium text-light-primary">{surah.name_transliteration || surah.name_en}</h3>
                                        <p className="text-xl text-light-muted font-arabic">{surah.name_ar}</p>
                                    </div>
                                </div>
                                <div className="flex gap-1">
                                    <button
                                        onClick={() => openEditModal(surah)}
                                        className="p-1.5 text-light-muted hover:text-gold-primary hover:bg-dark-icon rounded transition-colors"
                                    >
                                        <Edit size={16} />
                                    </button>
                                    <button
                                        onClick={() => handleDelete(surah.id)}
                                        className="p-1.5 text-light-muted hover:text-red-400 hover:bg-dark-icon rounded transition-colors"
                                    >
                                        <Trash2 size={16} />
                                    </button>
                                </div>
                            </div>
                            <div className="flex items-center justify-between text-sm">
                                <span className="text-light-muted">{surah.totalAyahs} Ayahs</span>
                                {getRevelationBadge(surah.revelationType)}
                            </div>
                            {surah.description && (
                                <p className="mt-2 text-sm text-light-muted line-clamp-2">{surah.description}</p>
                            )}
                        </div>
                    ))
                )}
            </div>

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card rounded-xl w-full max-w-lg max-h-[90vh] overflow-y-auto border border-dark-icon">
                        <div className="flex items-center justify-between p-6 border-b border-dark-icon">
                            <h2 className="text-xl font-bold text-light-primary">
                                {editingSurah ? 'Edit Surah' : 'Add Surah'}
                            </h2>
                            <button onClick={closeModal} className="p-2 hover:bg-dark-icon rounded-lg">
                                <X size={20} className="text-light-muted" />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Surah Number *</label>
                                    <input
                                        type="number"
                                        value={formData.number}
                                        onChange={(e) => setFormData({ ...formData, number: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                        required
                                        min="1"
                                        max="114"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Total Ayahs *</label>
                                    <input
                                        type="number"
                                        value={formData.totalAyahs}
                                        onChange={(e) => setFormData({ ...formData, totalAyahs: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                        required
                                    />
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Arabic Name</label>
                                <input
                                    type="text"
                                    value={formData.name_ar}
                                    onChange={(e) => setFormData({ ...formData, name_ar: e.target.value })}
                                    dir="rtl"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary text-right"
                                    placeholder="سورة الفاتحة"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">English Name *</label>
                                <input
                                    type="text"
                                    value={formData.name_en}
                                    onChange={(e) => setFormData({ ...formData, name_en: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    required
                                    placeholder="The Opening"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Transliteration *</label>
                                <input
                                    type="text"
                                    value={formData.name_transliteration}
                                    onChange={(e) => setFormData({ ...formData, name_transliteration: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    required
                                    placeholder="Al-Fatihah"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Revelation Type</label>
                                <select
                                    value={formData.revelationType}
                                    onChange={(e) => setFormData({ ...formData, revelationType: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                >
                                    <option value="meccan">Meccan</option>
                                    <option value="medinan">Medinan</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Description</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    rows="3"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    placeholder="Brief description of the surah..."
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
                                    {editingSurah ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
