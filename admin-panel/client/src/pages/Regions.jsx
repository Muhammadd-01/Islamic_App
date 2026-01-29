import { useState, useEffect } from 'react';
import { Plus, Trash2, Loader2, Globe, Search, X } from 'lucide-react';
import { regionsApi } from '../services/api';
import { useNotification } from '../components/NotificationSystem';

export default function Regions() {
    const { notify } = useNotification();
    const [regions, setRegions] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [newRegion, setNewRegion] = useState('');
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);

    useEffect(() => {
        fetchRegions();
    }, []);

    const fetchRegions = async () => {
        try {
            setLoading(true);
            const { data } = await regionsApi.getAll();
            setRegions(data);
        } catch (error) {
            console.error('Error fetching regions:', error);
            notify.error('Failed to fetch regions');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!newRegion.trim()) return;
        setSubmitting(true);
        try {
            await regionsApi.create({ name: newRegion.trim() });
            notify.success('Region added successfully');
            setNewRegion('');
            setShowModal(false);
            fetchRegions();
        } catch (error) {
            notify.error('Failed to add region');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this region?')) return;
        setDeletingId(id);
        try {
            await regionsApi.delete(id);
            notify.success('Region deleted successfully');
            setRegions(regions.filter(r => r.id !== id));
        } catch (error) {
            notify.error('Failed to delete region');
        } finally {
            setDeletingId(null);
        }
    };

    const filteredRegions = regions.filter(region =>
        region.name.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Region Management</h1>
                    <p className="text-light-muted">Manage regions for user filtering and analytics</p>
                </div>
                <button
                    onClick={() => setShowModal(true)}
                    className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark transition-colors"
                >
                    <Plus size={20} />
                    Add Region
                </button>
            </div>

            <div className="relative group">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-light-muted group-focus-within:text-gold-primary transition-colors" />
                <input
                    type="text"
                    placeholder="Search regions..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 bg-dark-card border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none transition-all hover:border-gold-primary/30"
                />
            </div>

            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    {filteredRegions.map((region) => (
                        <div key={region.id} className="bg-dark-card border border-dark-icon p-6 rounded-xl hover:border-gold-primary/30 transition-all group flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-gold-primary/10 text-gold-primary rounded-lg">
                                    <Globe size={20} />
                                </div>
                                <span className="font-semibold text-light-primary">{region.name}</span>
                            </div>
                            <button
                                onClick={() => handleDelete(region.id)}
                                className="p-2 text-light-muted hover:text-red-400 transition-colors opacity-0 group-hover:opacity-100"
                                disabled={deletingId === region.id}
                            >
                                {deletingId === region.id ? <Loader2 size={18} className="animate-spin" /> : <Trash2 size={18} />}
                            </button>
                        </div>
                    ))}
                    {filteredRegions.length === 0 && (
                        <div className="col-span-full py-12 text-center text-light-muted bg-dark-card border border-dark-icon border-dashed rounded-xl">
                            No regions found. Click "Add Region" to create one.
                        </div>
                    )}
                </div>
            )}

            {showModal && (
                <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50 backdrop-blur-sm">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-md overflow-hidden shadow-2xl">
                        <div className="flex justify-between items-center p-6 border-b border-dark-icon bg-dark-main/30">
                            <h2 className="text-xl font-bold text-light-primary">Add New Region</h2>
                            <button onClick={() => setShowModal(false)} className="text-light-muted hover:text-light-primary transition-colors">
                                <X size={24} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Region Name</label>
                                <input
                                    required
                                    autoFocus
                                    type="text"
                                    value={newRegion}
                                    onChange={(e) => setNewRegion(e.target.value)}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none transition-all hover:border-gold-primary/30"
                                    placeholder="e.g. Asia, Europe, Karachi, etc."
                                />
                            </div>
                            <div className="flex gap-4 pt-4">
                                <button
                                    type="button"
                                    onClick={() => setShowModal(false)}
                                    className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon transition-all"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting || !newRegion.trim()}
                                    className="flex-1 bg-gold-primary text-dark-main font-medium px-4 py-2 rounded-lg hover:bg-gold-dark transition-all disabled:opacity-50 flex justify-center items-center"
                                >
                                    {submitting ? <Loader2 className="animate-spin" size={20} /> : 'Add Region'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
