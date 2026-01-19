import { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Search, X, Save, Video, DollarSign } from 'lucide-react';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

export default function ScholarsPage() {
    const [scholars, setScholars] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingScholar, setEditingScholar] = useState(null);
    const [formData, setFormData] = useState({
        name: '',
        specialty: '',
        bio: '',
        imageUrl: '',
        isAvailableFor1on1: false,
        consultationFee: 0,
    });

    useEffect(() => {
        fetchScholars();
    }, []);

    const fetchScholars = async () => {
        try {
            const res = await fetch(`${API_URL}/scholars`);
            const data = await res.json();
            setScholars(data);
        } catch (error) {
            console.error('Error fetching scholars:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const url = editingScholar
                ? `${API_URL}/scholars/${editingScholar.id}`
                : `${API_URL}/scholars`;
            const method = editingScholar ? 'PUT' : 'POST';

            await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
            });

            fetchScholars();
            closeModal();
        } catch (error) {
            console.error('Error saving scholar:', error);
        }
    };

    const handleDelete = async (id) => {
        if (!confirm('Are you sure you want to delete this scholar?')) return;
        try {
            await fetch(`${API_URL}/scholars/${id}`, { method: 'DELETE' });
            fetchScholars();
        } catch (error) {
            console.error('Error deleting scholar:', error);
        }
    };

    const openModal = (scholar = null) => {
        if (scholar) {
            setEditingScholar(scholar);
            setFormData({
                name: scholar.name || '',
                specialty: scholar.specialty || '',
                bio: scholar.bio || '',
                imageUrl: scholar.imageUrl || '',
                isAvailableFor1on1: scholar.isAvailableFor1on1 || false,
                consultationFee: scholar.consultationFee || 0,
            });
        } else {
            setEditingScholar(null);
            setFormData({
                name: '',
                specialty: '',
                bio: '',
                imageUrl: '',
                isAvailableFor1on1: false,
                consultationFee: 0,
            });
        }
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingScholar(null);
    };

    const filteredScholars = scholars.filter(
        (s) =>
            s.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            s.specialty?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-white">Scholars Management</h1>
                    <p className="text-gray-400">Manage scholars available for consultations</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-black px-4 py-2 rounded-lg font-medium hover:bg-gold-light transition"
                >
                    <Plus size={20} />
                    Add Scholar
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
                <input
                    type="text"
                    placeholder="Search scholars..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 bg-dark-card border border-dark-icon rounded-lg text-white focus:border-gold-primary"
                />
            </div>

            {/* Scholars Grid */}
            {loading ? (
                <div className="flex justify-center py-12">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gold-primary"></div>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filteredScholars.map((scholar) => (
                        <div
                            key={scholar.id}
                            className="bg-dark-card border border-dark-icon rounded-xl overflow-hidden"
                        >
                            <div className="h-48 bg-dark-icon flex items-center justify-center">
                                {scholar.imageUrl ? (
                                    <img
                                        src={scholar.imageUrl}
                                        alt={scholar.name}
                                        className="w-full h-full object-cover"
                                    />
                                ) : (
                                    <span className="text-6xl text-gray-500">👤</span>
                                )}
                            </div>
                            <div className="p-4">
                                <h3 className="text-lg font-semibold text-white">{scholar.name}</h3>
                                <p className="text-gold-primary text-sm">{scholar.specialty}</p>
                                <p className="text-gray-400 text-sm mt-2 line-clamp-2">{scholar.bio}</p>
                                <div className="flex items-center gap-2 mt-3">
                                    {scholar.isAvailableFor1on1 ? (
                                        <span className="flex items-center gap-1 text-green-400 text-xs bg-green-400/10 px-2 py-1 rounded">
                                            <Video size={12} />
                                            Available
                                        </span>
                                    ) : (
                                        <span className="text-gray-500 text-xs">Not available</span>
                                    )}
                                    {scholar.consultationFee > 0 && (
                                        <span className="flex items-center gap-1 text-gold-primary text-xs bg-gold-primary/10 px-2 py-1 rounded">
                                            <DollarSign size={12} />
                                            ${scholar.consultationFee}/hr
                                        </span>
                                    )}
                                </div>
                                <div className="flex gap-2 mt-4">
                                    <button
                                        onClick={() => openModal(scholar)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-dark-icon text-gold-primary py-2 rounded-lg hover:bg-dark-icon/80"
                                    >
                                        <Edit2 size={16} />
                                        Edit
                                    </button>
                                    <button
                                        onClick={() => handleDelete(scholar.id)}
                                        className="flex items-center justify-center gap-1 bg-red-500/10 text-red-400 px-4 py-2 rounded-lg hover:bg-red-500/20"
                                    >
                                        <Trash2 size={16} />
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
                        <div className="flex justify-between items-center p-4 border-b border-dark-icon">
                            <h2 className="text-xl font-semibold text-white">
                                {editingScholar ? 'Edit Scholar' : 'Add New Scholar'}
                            </h2>
                            <button onClick={closeModal} className="text-gray-400 hover:text-white">
                                <X size={24} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-4 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Name</label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Specialty</label>
                                <input
                                    type="text"
                                    value={formData.specialty}
                                    onChange={(e) => setFormData({ ...formData, specialty: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                    placeholder="e.g., Fiqh, Quran, Hadith"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Bio</label>
                                <textarea
                                    value={formData.bio}
                                    onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white h-24 resize-none"
                                    placeholder="Scholar's biography..."
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Image URL</label>
                                <input
                                    type="url"
                                    value={formData.imageUrl}
                                    onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                    placeholder="https://..."
                                />
                            </div>
                            <div className="flex items-center gap-3">
                                <input
                                    type="checkbox"
                                    id="available"
                                    checked={formData.isAvailableFor1on1}
                                    onChange={(e) => setFormData({ ...formData, isAvailableFor1on1: e.target.checked })}
                                    className="w-5 h-5 rounded"
                                />
                                <label htmlFor="available" className="text-gray-300">Available for 1-on-1 Sessions</label>
                            </div>
                            {formData.isAvailableFor1on1 && (
                                <div>
                                    <label className="block text-sm font-medium text-gray-300 mb-1">Consultation Fee ($/hr)</label>
                                    <input
                                        type="number"
                                        value={formData.consultationFee}
                                        onChange={(e) => setFormData({ ...formData, consultationFee: parseFloat(e.target.value) || 0 })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                        min="0"
                                    />
                                </div>
                            )}
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="flex-1 py-2 border border-dark-icon text-gray-300 rounded-lg hover:bg-dark-icon"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 flex items-center justify-center gap-2 bg-gold-primary text-black py-2 rounded-lg font-medium hover:bg-gold-light"
                                >
                                    <Save size={18} />
                                    {editingScholar ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
