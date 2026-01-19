import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { Search, Plus, Edit, Trash2, X, Check, BookOpen } from 'lucide-react';

export default function Hadith() {
    const [hadiths, setHadiths] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingHadith, setEditingHadith] = useState(null);
    const [bookFilter, setBookFilter] = useState('all');
    const [formData, setFormData] = useState({
        text_ar: '',
        text_en: '',
        narrator: '',
        book: 'bukhari',
        chapter: '',
        hadithNumber: '',
        grade: 'sahih',
        reference: ''
    });

    useEffect(() => {
        fetchHadiths();
    }, []);

    const fetchHadiths = async () => {
        try {
            const snapshot = await getDocs(collection(db, 'hadiths'));
            const data = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setHadiths(data);
        } catch (error) {
            console.error('Error fetching hadiths:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editingHadith) {
                await updateDoc(doc(db, 'hadiths', editingHadith.id), {
                    ...formData,
                    updatedAt: new Date().toISOString()
                });
            } else {
                await addDoc(collection(db, 'hadiths'), {
                    ...formData,
                    createdAt: new Date().toISOString(),
                    updatedAt: new Date().toISOString()
                });
            }
            fetchHadiths();
            closeModal();
        } catch (error) {
            console.error('Error saving hadith:', error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this hadith?')) {
            try {
                await deleteDoc(doc(db, 'hadiths', id));
                fetchHadiths();
            } catch (error) {
                console.error('Error deleting hadith:', error);
            }
        }
    };

    const openEditModal = (item) => {
        setEditingHadith(item);
        setFormData({
            text_ar: item.text_ar || '',
            text_en: item.text_en || '',
            narrator: item.narrator || '',
            book: item.book || 'bukhari',
            chapter: item.chapter || '',
            hadithNumber: item.hadithNumber || '',
            grade: item.grade || 'sahih',
            reference: item.reference || ''
        });
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingHadith(null);
        setFormData({
            text_ar: '',
            text_en: '',
            narrator: '',
            book: 'bukhari',
            chapter: '',
            hadithNumber: '',
            grade: 'sahih',
            reference: ''
        });
    };

    const filteredHadiths = hadiths.filter(item => {
        const matchesSearch = item.text_en?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            item.narrator?.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesBook = bookFilter === 'all' || item.book === bookFilter;
        return matchesSearch && matchesBook;
    });

    const getGradeBadge = (grade) => {
        switch (grade) {
            case 'sahih':
                return <span className="px-2 py-1 bg-green-500/20 text-green-400 rounded-full text-xs">Sahih</span>;
            case 'hasan':
                return <span className="px-2 py-1 bg-yellow-500/20 text-yellow-400 rounded-full text-xs">Hasan</span>;
            case 'daif':
                return <span className="px-2 py-1 bg-red-500/20 text-red-400 rounded-full text-xs">Da'if</span>;
            default:
                return <span className="px-2 py-1 bg-gray-500/20 text-gray-400 rounded-full text-xs">{grade}</span>;
        }
    };

    const books = [
        { value: 'bukhari', label: 'Sahih Bukhari' },
        { value: 'muslim', label: 'Sahih Muslim' },
        { value: 'tirmidhi', label: 'Jami at-Tirmidhi' },
        { value: 'nasai', label: "Sunan an-Nasa'i" },
        { value: 'abudawud', label: 'Sunan Abu Dawud' },
        { value: 'ibnmajah', label: 'Sunan Ibn Majah' },
        { value: 'malik', label: 'Muwatta Malik' },
        { value: 'ahmad', label: 'Musnad Ahmad' },
    ];

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
                    <h1 className="text-2xl font-bold text-light-primary">Hadith Management</h1>
                    <p className="text-light-muted">Manage hadith collection from various books</p>
                </div>
                <button
                    onClick={() => setShowModal(true)}
                    className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors"
                >
                    <Plus size={20} />
                    Add Hadith
                </button>
            </div>

            {/* Filters */}
            <div className="flex flex-col sm:flex-row gap-4">
                <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-light-muted" size={20} />
                    <input
                        type="text"
                        placeholder="Search hadiths..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary focus:border-transparent text-light-primary"
                    />
                </div>
                <select
                    value={bookFilter}
                    onChange={(e) => setBookFilter(e.target.value)}
                    className="px-4 py-2 bg-dark-card border border-dark-icon rounded-lg text-light-primary focus:ring-2 focus:ring-gold-primary"
                >
                    <option value="all">All Books</option>
                    {books.map(book => (
                        <option key={book.value} value={book.value}>{book.label}</option>
                    ))}
                </select>
            </div>

            {/* Hadiths Table */}
            <div className="bg-dark-card rounded-xl border border-dark-icon overflow-hidden">
                <table className="w-full">
                    <thead className="bg-dark-icon/50">
                        <tr>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Hadith</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Book</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Narrator</th>
                            <th className="px-6 py-4 text-left text-sm font-medium text-light-muted">Grade</th>
                            <th className="px-6 py-4 text-right text-sm font-medium text-light-muted">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-dark-icon">
                        {filteredHadiths.length === 0 ? (
                            <tr>
                                <td colSpan="5" className="px-6 py-8 text-center text-light-muted">
                                    No hadiths found
                                </td>
                            </tr>
                        ) : (
                            filteredHadiths.map((item) => (
                                <tr key={item.id} className="hover:bg-dark-icon/30 transition-colors">
                                    <td className="px-6 py-4">
                                        <div className="flex items-start gap-3">
                                            <div className="w-10 h-10 rounded-lg bg-green-500/20 flex items-center justify-center flex-shrink-0">
                                                <BookOpen size={20} className="text-green-400" />
                                            </div>
                                            <div>
                                                <p className="font-medium text-light-primary line-clamp-2">{item.text_en}</p>
                                                <p className="text-sm text-light-muted">#{item.hadithNumber || 'N/A'}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 text-light-primary capitalize">{item.book}</td>
                                    <td className="px-6 py-4 text-light-primary">{item.narrator}</td>
                                    <td className="px-6 py-4">{getGradeBadge(item.grade)}</td>
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
                <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card rounded-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto border border-dark-icon">
                        <div className="flex items-center justify-between p-6 border-b border-dark-icon">
                            <h2 className="text-xl font-bold text-light-primary">
                                {editingHadith ? 'Edit Hadith' : 'Add Hadith'}
                            </h2>
                            <button onClick={closeModal} className="p-2 hover:bg-dark-icon rounded-lg">
                                <X size={20} className="text-light-muted" />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">Arabic Text</label>
                                <textarea
                                    value={formData.text_ar}
                                    onChange={(e) => setFormData({ ...formData, text_ar: e.target.value })}
                                    rows="3"
                                    dir="rtl"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary text-right"
                                    placeholder="النص العربي"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-2">English Translation *</label>
                                <textarea
                                    value={formData.text_en}
                                    onChange={(e) => setFormData({ ...formData, text_en: e.target.value })}
                                    rows="3"
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    required
                                    placeholder="English translation of the hadith"
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Narrator</label>
                                    <input
                                        type="text"
                                        value={formData.narrator}
                                        onChange={(e) => setFormData({ ...formData, narrator: e.target.value })}
                                        placeholder="e.g., Abu Hurairah (RA)"
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Hadith Number</label>
                                    <input
                                        type="text"
                                        value={formData.hadithNumber}
                                        onChange={(e) => setFormData({ ...formData, hadithNumber: e.target.value })}
                                        placeholder="e.g., 1"
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    />
                                </div>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Book</label>
                                    <select
                                        value={formData.book}
                                        onChange={(e) => setFormData({ ...formData, book: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    >
                                        {books.map(book => (
                                            <option key={book.value} value={book.value}>{book.label}</option>
                                        ))}
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Grade</label>
                                    <select
                                        value={formData.grade}
                                        onChange={(e) => setFormData({ ...formData, grade: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    >
                                        <option value="sahih">Sahih (Authentic)</option>
                                        <option value="hasan">Hasan (Good)</option>
                                        <option value="daif">Da'if (Weak)</option>
                                    </select>
                                </div>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Chapter</label>
                                    <input
                                        type="text"
                                        value={formData.chapter}
                                        onChange={(e) => setFormData({ ...formData, chapter: e.target.value })}
                                        placeholder="Book of Faith"
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-2">Reference</label>
                                    <input
                                        type="text"
                                        value={formData.reference}
                                        onChange={(e) => setFormData({ ...formData, reference: e.target.value })}
                                        placeholder="Bukhari 1"
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg focus:ring-2 focus:ring-gold-primary text-light-primary"
                                    />
                                </div>
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
                                    {editingHadith ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
