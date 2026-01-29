import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Quote, BookOpen, Star, Check } from 'lucide-react';
import { useNotification } from '../components/NotificationSystem';

const API_URL = 'http://localhost:5000/api';

export default function DailyInspiration() {
    const { notify } = useNotification();
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [activeTab, setActiveTab] = useState('all');
    const [showModal, setShowModal] = useState(false);
    const [todayInspiration, setTodayInspiration] = useState(null);
    const [todayLoading, setTodayLoading] = useState(false);
    const [editingItem, setEditingItem] = useState(null);
    const [formData, setFormData] = useState({
        type: 'quote',
        arabic: '',
        translation: '',
        source: '',
        author: ''
    });

    const tabs = [
        { id: 'all', label: 'All', icon: Star },
        { id: 'quote', label: 'Quotes', icon: Quote },
        { id: 'hadith', label: 'Hadiths', icon: BookOpen },
        { id: 'ayat', label: 'Ayats', icon: BookOpen }
    ];

    useEffect(() => {
        fetchItems();
        fetchTodayInspiration();
    }, [activeTab]);

    const fetchTodayInspiration = async () => {
        setTodayLoading(true);
        try {
            const res = await fetch(`${API_URL}/daily-inspirations/today`);
            const data = await res.json();
            if (data.quote || data.hadith || data.ayah) {
                setTodayInspiration(data);
            } else {
                setTodayInspiration(null);
            }
        } catch (error) {
            console.error('Error fetching today inspiration:', error);
        } finally {
            setTodayLoading(false);
        }
    };

    const fetchItems = async () => {
        setLoading(true);
        try {
            const url = activeTab === 'all'
                ? `${API_URL}/inspiration`
                : `${API_URL}/inspiration?type=${activeTab}`;
            const res = await fetch(url);
            const data = await res.json();
            // Ensure items is always an array
            setItems(Array.isArray(data) ? data : (data.items || data.inspirations || []));
        } catch (error) {
            console.error('Error fetching inspirations:', error);
            setItems([]); // Set to empty array on error
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            const url = editingItem ? `${API_URL}/inspiration/${editingItem.id}` : `${API_URL}/inspiration`;
            const method = editingItem ? 'PUT' : 'POST';

            await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });

            notify.success(editingItem ? 'Inspiration updated!' : 'Inspiration added!');
            fetchItems();
            setShowModal(false);
            resetForm();
        } catch (error) {
            notify.error('Error saving inspiration');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        setDeletingId(id);
        try {
            await fetch(`${API_URL}/inspiration/${id}`, { method: 'DELETE' });
            notify.success('Inspiration deleted!');
            fetchItems();
        } catch (error) {
            notify.error('Error deleting');
        } finally {
            setDeletingId(null);
        }
    };

    const handleEdit = (item) => {
        setEditingItem(item);
        setFormData({
            type: item.type || 'quote',
            arabic: item.arabic || '',
            translation: item.translation || '',
            source: item.source || '',
            author: item.author || ''
        });
        setShowModal(true);
    };

    const resetForm = () => {
        setEditingItem(null);
        setFormData({ type: 'quote', arabic: '', translation: '', source: '', author: '' });
    };

    const handleEditToday = (type, data) => {
        setEditingItem({ id: 'today', isToday: true });
        setFormData({
            type,
            arabic: '',
            translation: data.text,
            source: data.source || '',
            author: data.author || ''
        });
        setShowModal(true);
    };

    const handleUpdateToday = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            const res = await fetch(`${API_URL}/daily-inspirations/update`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    type: formData.type,
                    text: formData.translation,
                    source: formData.source,
                    author: formData.author
                })
            });

            if (res.ok) {
                notify.success('Daily inspiration updated!');
                fetchTodayInspiration();
                setShowModal(false);
                resetForm();
            } else {
                throw new Error('Failed to update');
            }
        } catch (error) {
            notify.error('Error updating today\'s inspiration');
        } finally {
            setSubmitting(false);
        }
    };

    const getTypeColor = (type) => {
        switch (type) {
            case 'quote': return 'bg-blue-500/20 text-blue-400';
            case 'hadith': return 'bg-green-500/20 text-green-400';
            case 'ayat': return 'bg-purple-500/20 text-purple-400';
            default: return 'bg-gold-primary/20 text-gold-primary';
        }
    };

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
                    <h1 className="text-2xl font-bold text-light-primary font-outfit">Daily Inspiration</h1>
                    <p className="text-light-muted">Manage quotes, hadiths, and ayats for daily rotation</p>
                </div>
                <button
                    onClick={() => { resetForm(); setShowModal(true); }}
                    className="flex items-center gap-2 bg-gold-primary text-iconBlack px-4 py-2 rounded-lg hover:bg-gold-highlight transition-colors"
                >
                    <Plus size={20} />
                    Add Inspiration
                </button>
            </div>

            {/* Today's Unified Inspiration Section */}
            <div className="bg-dark-card border-2 border-gold-primary/30 rounded-2xl overflow-hidden shadow-2xl">
                <div className="bg-gradient-to-r from-gold-primary/20 to-transparent p-4 border-b border-dark-icon flex justify-between items-center">
                    <div className="flex items-center gap-3">
                        <div className="bg-gold-primary p-2 rounded-lg">
                            <Star className="text-iconBlack" size={20} />
                        </div>
                        <div>
                            <h2 className="text-lg font-bold text-light-primary">Today's Unified Inspiration</h2>
                            <p className="text-xs text-light-muted">Added parts will show up on user homescreens</p>
                        </div>
                    </div>
                    {todayInspiration?.notified && (
                        <div className="flex items-center gap-2 bg-green-500/20 text-green-400 px-3 py-1 rounded-full text-xs font-bold ring-1 ring-green-500/50">
                            <Check size={14} /> PUSH SENT
                        </div>
                    )}
                </div>

                <div className="p-6 grid grid-cols-1 md:grid-cols-3 gap-6">
                    {['quote', 'hadith', 'ayah'].map((type) => {
                        const data = todayInspiration?.[type];
                        return (
                            <div key={type} className={`relative group p-5 rounded-xl border transition-all duration-300 ${data ? 'bg-dark-icon/50 border-gold-primary/50' : 'bg-dark-main/30 border-dark-icon border-dashed'}`}>
                                <div className="flex justify-between items-center mb-4">
                                    <h3 className="capitalize font-bold text-sm flex items-center gap-2">
                                        {type === 'quote' && <Quote size={14} className="text-blue-400" />}
                                        {type === 'hadith' && <BookOpen size={14} className="text-green-400" />}
                                        {type === 'ayah' && <Star size={14} className="text-purple-400" />}
                                        {type}
                                    </h3>
                                    {data ? (
                                        <button onClick={() => handleEditToday(type, data)} className="text-gold-primary hover:text-gold-highlight text-xs font-medium">Edit</button>
                                    ) : (
                                        <button onClick={() => { resetForm(); setFormData({ ...formData, type }); setShowModal(true); }} className="text-light-muted hover:text-gold-primary text-xs font-medium">+ Add</button>
                                    )}
                                </div>

                                {data ? (
                                    <div className="space-y-2">
                                        <p className="text-sm text-light-primary line-clamp-3 italic">"{data.text}"</p>
                                        <p className="text-[10px] text-light-muted font-medium">— {data.author || data.source}</p>
                                    </div>
                                ) : (
                                    <div className="py-4 text-center">
                                        <p className="text-xs text-light-muted italic">Missing part...</p>
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>

                <div className="bg-dark-icon/20 px-6 py-3 border-t border-dark-icon flex items-center justify-between">
                    <div className="flex gap-1">
                        {[1, 2, 3].map((i) => (
                            <div key={i} className={`h-1.5 w-8 rounded-full ${[todayInspiration?.quote, todayInspiration?.hadith, todayInspiration?.ayah].filter(Boolean).length >= i ? 'bg-gold-primary' : 'bg-dark-icon'}`} />
                        ))}
                    </div>
                    <p className="text-xs text-light-muted font-medium">
                        {[todayInspiration?.quote, todayInspiration?.hadith, todayInspiration?.ayah].filter(Boolean).length}/3 Parts added
                    </p>
                </div>
            </div>

            <div className="flex gap-2 border-b border-dark-icon pb-2">
                {tabs.map(tab => (
                    <button
                        key={tab.id}
                        onClick={() => setActiveTab(tab.id)}
                        className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-colors ${activeTab === tab.id
                            ? 'bg-gold-primary text-iconBlack'
                            : 'text-light-muted hover:bg-dark-icon'
                            }`}
                    >
                        <tab.icon size={16} />
                        {tab.label}
                    </button>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                {items.map((item) => (
                    <div key={item.id} className="bg-dark-card border border-dark-icon rounded-xl p-4">
                        <div className="flex justify-between items-start">
                            <span className={`px-2 py-1 text-xs rounded-full capitalize ${getTypeColor(item.type)}`}>
                                {item.type}
                            </span>
                            <div className="flex gap-2">
                                <button onClick={() => handleEdit(item)} className="p-1 text-light-muted hover:text-gold-primary">
                                    <Edit size={16} />
                                </button>
                                <button onClick={() => handleDelete(item.id)} className="p-1 text-light-muted hover:text-error">
                                    <Trash2 size={16} />
                                </button>
                            </div>
                        </div>
                        {item.arabic && (
                            <p className="mt-3 text-gold-primary text-right text-lg" dir="rtl">{item.arabic}</p>
                        )}
                        <p className="mt-2 text-light-primary">{item.translation}</p>
                        <div className="mt-3 flex gap-2 text-xs text-light-muted">
                            {item.source && <span>📖 {item.source}</span>}
                            {item.author && <span>✍️ {item.author}</span>}
                        </div>
                    </div>
                ))}
            </div>

            {items.length === 0 && (
                <div className="text-center py-12 text-light-muted">
                    <p>No inspirations found. Add your first one!</p>
                </div>
            )}

            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl p-6 w-full max-w-lg">
                        <h2 className="text-xl font-bold text-light-primary mb-4">
                            {editingItem ? 'Edit Inspiration' : 'Add New Inspiration'}
                        </h2>
                        <form onSubmit={editingItem?.isToday ? handleUpdateToday : handleSubmit} className="space-y-4">
                            <select
                                value={formData.type}
                                onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg disabled:opacity-50"
                                required
                                disabled={editingItem?.isToday}
                            >
                                <option value="quote">Quote</option>
                                <option value="hadith">Hadith</option>
                                <option value="ayat">Ayat</option>
                            </select>
                            <textarea
                                placeholder="Arabic (optional)"
                                value={formData.arabic}
                                onChange={(e) => setFormData({ ...formData, arabic: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg text-right"
                                dir="rtl"
                                rows={2}
                            />
                            <textarea
                                placeholder="Translation / Text"
                                value={formData.translation}
                                onChange={(e) => setFormData({ ...formData, translation: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                                rows={3}
                                required
                            />
                            <input
                                type="text"
                                placeholder="Source (e.g., Surah Al-Baqarah 2:255)"
                                value={formData.source}
                                onChange={(e) => setFormData({ ...formData, source: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                            />
                            <input
                                type="text"
                                placeholder="Author (for quotes)"
                                value={formData.author}
                                onChange={(e) => setFormData({ ...formData, author: e.target.value })}
                                className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg"
                            />
                            <div className="flex gap-3">
                                <button type="button" onClick={() => setShowModal(false)} className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon">
                                    Cancel
                                </button>
                                <button type="submit" className="flex-1 px-4 py-2 bg-gold-primary text-iconBlack rounded-lg hover:bg-gold-highlight">
                                    {editingItem ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
