import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2 } from 'lucide-react';

const API_URL = 'http://localhost:5000/api';

export default function NamesOfAllah() {
    const [names, setNames] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingName, setEditingName] = useState(null);
    const [formData, setFormData] = useState({
        number: '',
        arabic: '',
        transliteration: '',
        meaning: '',
        description: ''
    });

    useEffect(() => {
        fetchNames();
    }, []);

    const fetchNames = async () => {
        try {
            const res = await fetch(`${API_URL}/names`);
            const data = await res.json();
            setNames(data);
        } catch (error) {
            console.error('Error fetching names:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const url = editingName
                ? `${API_URL}/names/${editingName.id}`
                : `${API_URL}/names`;
            const method = editingName ? 'PUT' : 'POST';

            await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });

            fetchNames();
            setShowModal(false);
            resetForm();
        } catch (error) {
            console.error('Error saving name:', error);
        }
    };

    const handleDelete = async (id) => {
        if (!confirm('Are you sure you want to delete this name?')) return;
        try {
            await fetch(`${API_URL}/names/${id}`, { method: 'DELETE' });
            fetchNames();
        } catch (error) {
            console.error('Error deleting name:', error);
        }
    };

    const handleEdit = (name) => {
        setEditingName(name);
        setFormData({
            number: name.number || '',
            arabic: name.arabic || '',
            transliteration: name.transliteration || '',
            meaning: name.meaning || '',
            description: name.description || ''
        });
        setShowModal(true);
    };

    const resetForm = () => {
        setEditingName(null);
        setFormData({ number: '', arabic: '', transliteration: '', meaning: '', description: '' });
    };

    const filteredNames = names.filter(name =>
        name.transliteration?.toLowerCase().includes(search.toLowerCase()) ||
        name.meaning?.toLowerCase().includes(search.toLowerCase()) ||
        name.arabic?.includes(search)
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
                    <h1 className="text-2xl font-bold text-light-primary font-outfit">99 Names of Allah</h1>
                    <p className="text-light-muted">Manage the beautiful names of Allah</p>
                </div>
                <button
                    onClick={() => { resetForm(); setShowModal(true); }}
                    className="flex items-center gap-2 bg-gold-primary text-iconBlack px-4 py-2 rounded-lg hover:bg-gold-highlight transition-colors"
                >
                    <Plus size={20} />
                    Add Name
                </button>
            </div>

            <div className="relative">
                <Search className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                <input
                    type="text"
                    placeholder="Search names..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 bg-dark-card border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none"
                />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {filteredNames.map((name) => (
                    <div key={name.id} className="bg-dark-card border border-dark-icon rounded-xl p-4">
                        <div className="flex justify-between items-start">
                            <div className="flex items-center gap-3">
                                <span className="w-8 h-8 bg-gold-primary/20 text-gold-primary rounded-full flex items-center justify-center text-sm font-bold">
                                    {name.number}
                                </span>
                                <div>
                                    <h3 className="text-xl text-gold-primary font-arabic">{name.arabic}</h3>
                                    <p className="text-light-primary font-medium">{name.transliteration}</p>
                                </div>
                            </div>
                            <div className="flex gap-2">
                                <button onClick={() => handleEdit(name)} className="p-1 text-light-muted hover:text-gold-primary">
                                    <Edit size={16} />
                                </button>
                                <button onClick={() => handleDelete(name.id)} className="p-1 text-light-muted hover:text-error">
                                    <Trash2 size={16} />
                                </button>
                            </div>
                        </div>
                        <p className="mt-2 text-light-muted text-sm">{name.meaning}</p>
                    </div>
                ))}
            </div>

            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                    <div className="bg-dark-card border border-dark-icon rounded-xl p-6 w-full max-w-md">
                        <h2 className="text-xl font-bold text-light-primary mb-4">
                            {editingName ? 'Edit Name' : 'Add New Name'}
                        </h2>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <input
                                type="number"
                                placeholder="Number (1-99)"
                                value={formData.number}
                                onChange={(e) => setFormData({ ...formData, number: parseInt(e.target.value) })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                required
                            />
                            <input
                                type="text"
                                placeholder="Arabic"
                                value={formData.arabic}
                                onChange={(e) => setFormData({ ...formData, arabic: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg text-right"
                                dir="rtl"
                                required
                            />
                            <input
                                type="text"
                                placeholder="Transliteration"
                                value={formData.transliteration}
                                onChange={(e) => setFormData({ ...formData, transliteration: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                required
                            />
                            <input
                                type="text"
                                placeholder="Meaning"
                                value={formData.meaning}
                                onChange={(e) => setFormData({ ...formData, meaning: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                required
                            />
                            <textarea
                                placeholder="Description"
                                value={formData.description}
                                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                rows={3}
                            />
                            <div className="flex gap-3">
                                <button type="button" onClick={() => setShowModal(false)} className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon">
                                    Cancel
                                </button>
                                <button type="submit" className="flex-1 px-4 py-2 bg-gold-primary text-iconBlack rounded-lg hover:bg-gold-highlight">
                                    {editingName ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
