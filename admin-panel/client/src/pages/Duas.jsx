import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2 } from 'lucide-react';

const API_URL = 'http://localhost:5000/api';

export default function Duas() {
    const [duas, setDuas] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingDua, setEditingDua] = useState(null);
    const [formData, setFormData] = useState({
        title: '',
        arabic: '',
        transliteration: '',
        translation: '',
        category: '',
        reference: '',
        benefits: ''
    });

    const categories = ['Morning', 'Evening', 'Prayer', 'Travel', 'Food', 'Sleep', 'Protection', 'Forgiveness', 'General'];

    useEffect(() => {
        fetchDuas();
    }, []);

    const fetchDuas = async () => {
        try {
            const res = await fetch(`${API_URL}/duas`);
            const data = await res.json();
            setDuas(data);
        } catch (error) {
            console.error('Error fetching duas:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const url = editingDua ? `${API_URL}/duas/${editingDua.id}` : `${API_URL}/duas`;
            const method = editingDua ? 'PUT' : 'POST';

            await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });

            fetchDuas();
            setShowModal(false);
            resetForm();
        } catch (error) {
            console.error('Error saving dua:', error);
        }
    };

    const handleDelete = async (id) => {
        if (!confirm('Are you sure you want to delete this dua?')) return;
        try {
            await fetch(`${API_URL}/duas/${id}`, { method: 'DELETE' });
            fetchDuas();
        } catch (error) {
            console.error('Error deleting dua:', error);
        }
    };

    const handleEdit = (dua) => {
        setEditingDua(dua);
        setFormData({
            title: dua.title || '',
            arabic: dua.arabic || '',
            transliteration: dua.transliteration || '',
            translation: dua.translation || '',
            category: dua.category || '',
            reference: dua.reference || '',
            benefits: dua.benefits || ''
        });
        setShowModal(true);
    };

    const resetForm = () => {
        setEditingDua(null);
        setFormData({ title: '', arabic: '', transliteration: '', translation: '', category: '', reference: '', benefits: '' });
    };

    const filteredDuas = duas.filter(dua =>
        dua.title?.toLowerCase().includes(search.toLowerCase()) ||
        dua.category?.toLowerCase().includes(search.toLowerCase()) ||
        dua.arabic?.includes(search)
    );

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary font-outfit">Duas</h1>
                    <p className="text-light-muted">Manage Islamic supplications</p>
                </div>
                <button
                    onClick={() => { resetForm(); setShowModal(true); }}
                    className="flex items-center gap-2 bg-gold-primary text-iconBlack px-4 py-2 rounded-lg hover:bg-gold-highlight transition-colors"
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

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                {filteredDuas.map((dua) => (
                    <div key={dua.id} className="bg-dark-card border border-dark-icon rounded-xl p-4">
                        <div className="flex justify-between items-start">
                            <div>
                                <span className="px-2 py-1 bg-gold-primary/20 text-gold-primary text-xs rounded-full">
                                    {dua.category}
                                </span>
                                <h3 className="text-lg text-light-primary font-medium mt-2">{dua.title}</h3>
                            </div>
                            <div className="flex gap-2">
                                <button onClick={() => handleEdit(dua)} className="p-1 text-light-muted hover:text-gold-primary">
                                    <Edit size={16} />
                                </button>
                                <button onClick={() => handleDelete(dua.id)} className="p-1 text-light-muted hover:text-error">
                                    <Trash2 size={16} />
                                </button>
                            </div>
                        </div>
                        <p className="mt-2 text-gold-primary text-right text-lg" dir="rtl">{dua.arabic}</p>
                        <p className="mt-2 text-light-muted text-sm italic">{dua.transliteration}</p>
                        <p className="mt-1 text-light-primary text-sm">{dua.translation}</p>
                    </div>
                ))}
            </div>

            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl p-6 w-full max-w-lg max-h-[90vh] overflow-y-auto">
                        <h2 className="text-xl font-bold text-light-primary mb-4">
                            {editingDua ? 'Edit Dua' : 'Add New Dua'}
                        </h2>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <input
                                type="text"
                                placeholder="Title"
                                value={formData.title}
                                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                required
                            />
                            <select
                                value={formData.category}
                                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                required
                            >
                                <option value="">Select Category</option>
                                {categories.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                            </select>
                            <textarea
                                placeholder="Arabic"
                                value={formData.arabic}
                                onChange={(e) => setFormData({ ...formData, arabic: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg text-right"
                                dir="rtl"
                                rows={2}
                                required
                            />
                            <textarea
                                placeholder="Transliteration"
                                value={formData.transliteration}
                                onChange={(e) => setFormData({ ...formData, transliteration: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                rows={2}
                            />
                            <textarea
                                placeholder="Translation"
                                value={formData.translation}
                                onChange={(e) => setFormData({ ...formData, translation: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                rows={2}
                                required
                            />
                            <input
                                type="text"
                                placeholder="Reference (e.g., Sahih Bukhari)"
                                value={formData.reference}
                                onChange={(e) => setFormData({ ...formData, reference: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                            />
                            <textarea
                                placeholder="Benefits"
                                value={formData.benefits}
                                onChange={(e) => setFormData({ ...formData, benefits: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                rows={2}
                            />
                            <div className="flex gap-3">
                                <button type="button" onClick={() => setShowModal(false)} className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon">
                                    Cancel
                                </button>
                                <button type="submit" className="flex-1 px-4 py-2 bg-gold-primary text-iconBlack rounded-lg hover:bg-gold-highlight">
                                    {editingDua ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
