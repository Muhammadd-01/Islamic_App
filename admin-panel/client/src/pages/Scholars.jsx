import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Image as ImageIcon, X, CalendarDays, ExternalLink, Mail, Phone } from 'lucide-react';
import { scholarsApi, bookingsApi } from '../services/api';
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
    const [showBookings, setShowBookings] = useState(false);
    const [selectedScholarForBookings, setSelectedScholarForBookings] = useState(null);
    const [bookings, setBookings] = useState([]);
    const [loadingBookings, setLoadingBookings] = useState(false);

    const [formData, setFormData] = useState({
        name: '',
        specialty: '',
        bio: '',
        imageUrl: '',
        isAvailableFor1on1: false,
        consultationFee: 0,
        whatsappNumber: '',
        isBooked: false
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
            data.append('whatsappNumber', formData.whatsappNumber);
            data.append('isBooked', formData.isBooked);
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
        const confirmed = await notify.confirm({
            title: 'Delete Scholar',
            message: 'Are you sure you want to delete this scholar? This action cannot be undone.',
            confirmText: 'Delete',
            cancelText: 'Cancel'
        });
        if (!confirmed) return;
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
                consultationFee: scholar.consultationFee || 0,
                whatsappNumber: scholar.whatsappNumber || '',
                isBooked: scholar.isBooked || false
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
                whatsappNumber: '',
                isBooked: false
            });
        }
        setImageFile(null);
        setShowModal(true);
    };

    const openBookings = async (scholar) => {
        setSelectedScholarForBookings(scholar);
        setShowBookings(true);
        setLoadingBookings(true);
        try {
            const { data } = await bookingsApi.getByScholar(scholar.id);
            setBookings(data.bookings || []);
        } catch (error) {
            console.error('Error fetching bookings:', error);
            notify.error('Failed to fetch bookings');
        } finally {
            setLoadingBookings(false);
        }
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
                                    <div className="absolute top-2 right-2 flex flex-col gap-1 items-end">
                                        <div className="bg-green-500 text-white text-xs px-2 py-1 rounded-full shadow-lg"> Available </div>
                                        {scholar.isBooked && (
                                            <div className="bg-red-500 text-white text-xs px-2 py-1 rounded-full shadow-lg font-bold animate-pulse"> BOOKED </div>
                                        )}
                                    </div>
                                )}
                            </div>
                            <div className="p-4">
                                <h3 className="text-lg font-semibold text-light-primary mb-1">{scholar.name}</h3>
                                <p className="text-gold-primary text-sm mb-2">{scholar.specialty}</p>
                                <p className="text-light-muted text-sm mb-4 line-clamp-2">{scholar.bio}</p>
                                <div className="flex gap-2">
                                    <button
                                        onClick={() => openBookings(scholar)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-gold-primary/10 text-gold-primary py-2 rounded-lg hover:bg-gold-primary/20"
                                    >
                                        <CalendarDays size={16} />
                                        Bookings
                                    </button>
                                    <button
                                        onClick={() => openModal(scholar)}
                                        className="flex items-center justify-center p-2 bg-dark-icon text-gold-primary rounded-lg hover:bg-dark-icon/80"
                                        title="Edit Scholar"
                                    >
                                        <Edit size={16} />
                                    </button>
                                    <button
                                        onClick={() => handleDelete(scholar.id)}
                                        className="flex items-center justify-center p-2 bg-red-500/10 text-red-400 rounded-lg hover:bg-red-500/20"
                                        disabled={deletingId === scholar.id}
                                        title="Delete Scholar"
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

                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">WhatsApp Number (with country code)</label>
                                <input
                                    type="text"
                                    value={formData.whatsappNumber}
                                    onChange={(e) => setFormData({ ...formData, whatsappNumber: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    placeholder="e.g. +923XXXXXXXXX"
                                />
                            </div>

                            <div className="space-y-4 pt-2">
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
                                    <div className="pl-8 anim-slide-down">
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

                                <div className="flex items-center gap-3 bg-red-500/5 p-3 rounded-lg border border-red-500/10">
                                    <input
                                        type="checkbox"
                                        id="isBooked"
                                        checked={formData.isBooked}
                                        onChange={(e) => setFormData({ ...formData, isBooked: e.target.checked })}
                                        className="w-5 h-5 rounded text-red-500 bg-dark-main border-dark-icon"
                                    />
                                    <label htmlFor="isBooked" className="text-red-400 font-bold">Mark as BOOKED (Force)</label>
                                </div>
                            </div>

                            <div className="flex gap-3 pt-6">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon">
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting}
                                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark disabled:opacity-50 font-bold"
                                >
                                    {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : (editingScholar ? 'Update Scholar' : 'Create Scholar')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {showBookings && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-4xl max-h-[90vh] flex flex-col">
                        <div className="flex items-center justify-between p-6 border-b border-dark-icon">
                            <div>
                                <h2 className="text-xl font-bold text-light-primary">Bookings for {selectedScholarForBookings?.name}</h2>
                                <p className="text-sm text-light-muted">View all consultation sessions</p>
                            </div>
                            <button onClick={() => setShowBookings(false)} className="text-light-muted hover:text-light-primary">
                                <X size={20} />
                            </button>
                        </div>

                        <div className="p-6 overflow-y-auto custom-scrollbar flex-1">
                            {loadingBookings ? (
                                <div className="flex items-center justify-center py-12">
                                    <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
                                </div>
                            ) : bookings.length === 0 ? (
                                <div className="text-center py-12">
                                    <CalendarDays size={48} className="mx-auto text-dark-icon mb-4" />
                                    <p className="text-light-muted">No bookings found for this scholar yet.</p>
                                </div>
                            ) : (
                                <div className="space-y-4">
                                    {bookings.map((booking) => (
                                        <div key={booking.id} className="bg-dark-main border border-dark-icon rounded-lg p-4 hover:border-gold-primary/30 transition-colors">
                                            <div className="flex flex-wrap justify-between items-start gap-4">
                                                <div className="space-y-2">
                                                    <div className="flex items-center gap-2">
                                                        <h4 className="font-bold text-light-primary">{booking.userName}</h4>
                                                        <span className="bg-gold-primary/10 text-gold-primary text-[10px] px-2 py-0.5 rounded-full uppercase font-bold">
                                                            {booking.status}
                                                        </span>
                                                    </div>
                                                    <div className="flex flex-col gap-1">
                                                        <div className="flex items-center gap-2 text-sm text-light-muted">
                                                            <Mail size={14} className="text-gold-primary" />
                                                            {booking.userEmail}
                                                        </div>
                                                        <div className="flex items-center gap-2 text-sm text-light-muted">
                                                            <Phone size={14} className="text-gold-primary" />
                                                            {booking.userPhone}
                                                        </div>
                                                    </div>
                                                </div>
                                                <div className="text-right">
                                                    <div className="text-gold-primary font-bold text-lg mb-1">
                                                        ${booking.fee}
                                                    </div>
                                                    <div className="text-sm text-light-primary">
                                                        {booking.dateTime}
                                                    </div>
                                                    <div className="text-[10px] text-light-muted mt-1 uppercase tracking-wider">
                                                        Ref: {booking.id.slice(-8)}
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        <div className="p-6 border-t border-dark-icon bg-dark-main/50">
                            <button
                                onClick={() => setShowBookings(false)}
                                className="w-full px-4 py-2 bg-dark-icon text-light-primary rounded-lg hover:bg-dark-icon/80 transition"
                            >
                                Close View
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
