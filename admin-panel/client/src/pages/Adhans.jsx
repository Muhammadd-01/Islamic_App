import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Music, X, Play, Pause } from 'lucide-react';
import { adhanApi } from '../services/api';
import { useNotification } from '../components/NotificationSystem';
import FileUpload from '../components/FileUpload';

export default function Adhans() {
    const { notify } = useNotification();
    const [adhans, setAdhans] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingAdhan, setEditingAdhan] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [playingId, setPlayingId] = useState(null);
    const [audio, setAudio] = useState(null);

    const [formData, setFormData] = useState({
        name: '',
        description: '',
        audioUrl: ''
    });

    useEffect(() => {
        fetchAdhans();
        return () => {
            if (audio) audio.pause();
        };
    }, []);

    const fetchAdhans = async () => {
        try {
            setLoading(true);
            const { data } = await adhanApi.getAll();
            setAdhans(data);
        } catch (error) {
            notify.error('Failed to fetch adhans');
        } finally {
            setLoading(false);
        }
    };

    const togglePlay = (url, id) => {
        if (playingId === id) {
            audio.pause();
            setPlayingId(null);
        } else {
            if (audio) audio.pause();
            const newAudio = new Audio(url);
            newAudio.play();
            newAudio.onended = () => setPlayingId(null);
            setAudio(newAudio);
            setPlayingId(id);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            if (editingAdhan) {
                await adhanApi.update(editingAdhan.id, formData);
                notify.success('Adhan updated');
            } else {
                await adhanApi.create(formData);
                notify.success('Adhan created');
            }
            fetchAdhans();
            closeModal();
        } catch (error) {
            notify.error('Failed to save');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Delete this adhan?')) return;
        try {
            await adhanApi.delete(id);
            setAdhans(adhans.filter(a => a.id !== id));
            notify.success('Deleted');
        } catch (error) {
            notify.error('Failed');
        }
    };

    const openModal = (item = null) => {
        if (item) {
            setEditingAdhan(item);
            setFormData({ name: item.name, description: item.description || '', audioUrl: item.audioUrl });
        } else {
            setEditingAdhan(null);
            setFormData({ name: '', description: '', audioUrl: '' });
        }
        setShowModal(true);
    };

    const closeModal = () => setShowModal(false);

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Adhan Management</h1>
                    <p className="text-light-muted">Select and manage Adhan sound files</p>
                </div>
                <button onClick={() => openModal()} className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark">
                    <Plus size={20} /> Add Adhan
                </button>
            </div>

            {loading ? (
                <div className="flex justify-center py-12"><Loader2 className="animate-spin text-gold-primary" /></div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {adhans.map(adhan => (
                        <div key={adhan.id} className="bg-dark-card border border-dark-icon rounded-xl p-5 hover:border-gold-primary/50 transition">
                            <div className="flex items-start justify-between mb-4">
                                <div>
                                    <h3 className="font-bold text-light-primary">{adhan.name}</h3>
                                    <p className="text-sm text-light-muted">{adhan.description}</p>
                                </div>
                                <button onClick={() => togglePlay(adhan.audioUrl, adhan.id)} className="w-10 h-10 rounded-full bg-gold-primary/20 text-gold-primary flex items-center justify-center">
                                    {playingId === adhan.id ? <Pause size={20} /> : <Play size={20} className="ml-1" />}
                                </button>
                            </div>
                            <div className="flex gap-2">
                                <button onClick={() => openModal(adhan)} className="flex-1 py-1.5 bg-dark-icon text-gold-primary rounded-lg text-sm">Edit</button>
                                <button onClick={() => handleDelete(adhan.id)} className="flex-1 py-1.5 bg-red-500/10 text-red-400 rounded-lg text-sm">Delete</button>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-md p-6">
                        <div className="flex items-center justify-between mb-6">
                            <h2 className="font-bold text-xl text-light-primary">{editingAdhan ? 'Edit' : 'Add'} Adhan</h2>
                            <button onClick={closeModal}><X size={20} className="text-light-muted" /></button>
                        </div>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div>
                                <label className="block text-sm text-light-muted mb-1">Adhan Name</label>
                                <input type="text" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary" required />
                            </div>
                            <div>
                                <label className="block text-sm text-light-muted mb-1">Description</label>
                                <textarea value={formData.description} onChange={e => setFormData({ ...formData, description: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary h-20" />
                            </div>
                            <FileUpload label="Audio File" value={formData.audioUrl} onChange={url => setFormData({ ...formData, audioUrl: url })} accept="audio/*" icon={Music} bucket="adhans" />
                            <div className="flex gap-3 pt-4">
                                <button type="button" onClick={closeModal} className="flex-1 py-2 text-light-muted">Cancel</button>
                                <button type="submit" disabled={submitting} className="flex-1 py-2 bg-gold-primary text-dark-main rounded-lg">
                                    {submitting ? <Loader2 className="animate-spin w-5 h-5 mx-auto" /> : 'Save'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
