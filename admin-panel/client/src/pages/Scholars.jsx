import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Image as ImageIcon, X } from 'lucide-react';
import { scholarsApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

export default function Scholars() {
    const { notify } = useNotification();
    const [scholars, setScholars] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingScholar, setEditingScholar] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [imageFile, setImageFile] = useState(null);

    const [formData, setFormData] = useState({
        name: '',
        specialty: '',
        bio: '',
        imageUrl: '',
        isAvailableFor1on1: false,
        consultationFee: 0
    });

    useEffect(() => {
        fetchScholars();
    }, []);

    const fetchScholars = async () => {
        try {
            setLoading(true);
            const { data } = await scholarsApi.getAll();
            setScholars(data);
        } catch (error) {
            console.error('Error fetching scholars:', error);
            notify.error('Failed to fetch scholars');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            const data = new FormData();
            data.append('name', formData.name);
            data.append('specialty', formData.specialty);
            data.append('bio', formData.bio);
            data.append('isAvailableFor1on1', formData.isAvailableFor1on1);
            data.append('consultationFee', formData.consultationFee);
            if (formData.imageUrl) data.append('imageUrl', formData.imageUrl);

            if (imageFile) {
                data.append('image', imageFile);
            }

            if (editingScholar) {
                await scholarsApi.update(editingScholar.id, data);
                notify.success('Scholar updated successfully');
            } else {
                await scholarsApi.create(data);
                notify.success('Scholar created successfully');
            }

            fetchScholars();
            closeModal();
        } catch (error) {
            console.error('Error saving scholar:', error);
            notify.error('Failed to save scholar: ' + (error.response?.data?.error || error.message));
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this scholar?')) return;
        setDeletingId(id);
        try {
            await scholarsApi.delete(id);
            setScholars(scholars.filter(s => s.id !== id));
            notify.success('Scholar deleted successfully');
        } catch (error) {
            console.error('Error deleting scholar:', error);
            notify.error('Failed to delete scholar');
        } finally {
            setDeletingId(null);
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
                consultationFee: scholar.consultationFee || 0
            });
        } else {
            setEditingScholar(null);
            setFormData({
                name: '',
                specialty: '',
                bio: '',
                imageUrl: '',
                isAvailableFor1on1: false,
                consultationFee: 0
            });
        }
        setImageFile(null);
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingScholar(null);
        setImageFile(null);
    };

    const filteredScholars = scholars.filter(s =>
        s.name?.toLowerCase().includes(search.toLowerCase()) ||
        s.specialty?.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Scholars Management</h1>
                    <p className="text-light-muted">Manage scholars and consultations</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark transition"
                >
                    <Plus size={20} />
                    Add Scholar
                </button>
            </div>

            <div className="relative">
                <Search className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                <input
                    type="text"
                    placeholder="Search scholars..."
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
                    {filteredScholars.map((scholar) => (
                        <div key={scholar.id} className="bg-dark-card border border-dark-icon rounded-xl overflow-hidden hover:border-gold-primary/50 transition-colors">
                            <div className="h-48 bg-dark-icon relative">
                                {scholar.imageUrl ? (
                                    <img src={scholar.imageUrl} alt={scholar.name} className="w-full h-full object-cover" />
                                ) : (
                                    <div className="flex items-center justify-center h-full">
                                        <ImageIcon size={40} className="text-light-muted opacity-50" />
                                    </div>
                                )}
                                {scholar.isAvailableFor1on1 && (
                                    <div className="absolute top-2 right-2 bg-green-500 text-white text-xs px-2 py-1 rounded-full">
                                        Available
                                    </div>
                                )}
                            </div>
                            <div className="p-4">
                                <h3 className="text-lg font-semibold text-light-primary mb-1">{scholar.name}</h3>
                                <p className="text-gold-primary text-sm mb-2">{scholar.specialty}</p>
                                <p className="text-light-muted text-sm mb-4 line-clamp-2">{scholar.bio}</p>
                                <div className="flex justify-between items-center text-sm text-light-muted mb-4">
                                    <span>Consultation:</span>
                                    <span className="text-gold-primary font-bold">${scholar.consultationFee}</span>
                                </div>
                                <div className="flex gap-2">
                                    <button
                                        onClick={() => openModal(scholar)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-dark-icon text-gold-primary py-2 rounded-lg hover:bg-dark-icon/80"
                                    >
                                        <Edit size={16} />
                                        Edit
                                    </button>
                                    <button
                                        onClick={() => handleDelete(scholar.id)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-red-500/10 text-red-400 py-2 rounded-lg hover:bg-red-500/20"
                                        disabled={deletingId === scholar.id}
                                    >
                                        {deletingId === scholar.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 size={16} />}
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
                                {editingScholar ? 'Edit Scholar' : 'Add Scholar'}
                            </h2>
                            <button onClick={closeModal} className="text-light-muted hover:text-light-primary">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Name</label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Specialty</label>
                                <input
                                    type="text"
                                    value={formData.specialty}
                                    onChange={(e) => setFormData({ ...formData, specialty: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Bio</label>
                                <textarea
                                    value={formData.bio}
                                    onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary h-24 resize-none"
                                    required
                                />
                            </div>

                            <ImageUpload
                                label="Profile Image"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="scholar-images"
                            />

                            <div className="flex items-center gap-3">
                                <input
                                    type="checkbox"
                                    id="isAvailable"
                                    checked={formData.isAvailableFor1on1}
                                    onChange={(e) => setFormData({ ...formData, isAvailableFor1on1: e.target.checked })}
                                    className="w-5 h-5 rounded text-gold-primary bg-dark-main border-dark-icon"
                                />
                                <label htmlFor="isAvailable" className="text-light-muted">Available for 1-on-1 Consultation</label>
                            </div>

                            {formData.isAvailableFor1on1 && (
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Consultation Fee ($)</label>
                                    <input
                                        type="number"
                                        value={formData.consultationFee}
                                        onChange={(e) => setFormData({ ...formData, consultationFee: parseFloat(e.target.value) || 0 })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                        min="0"
                                    />
                                </div>
                            )}

                            <div className="flex gap-3 pt-4">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon">
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting}
                                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark disabled:opacity-50"
                                >
                                    {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : (editingScholar ? 'Update' : 'Create')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
