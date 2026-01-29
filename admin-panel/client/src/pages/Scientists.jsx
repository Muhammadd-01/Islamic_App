import { useEffect, useState } from 'react';
import { Trash2, Loader2, RefreshCw, Plus, X, User, Play, FileText, Check, Edit } from 'lucide-react';
import { scientistsApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

function ScientistsPage() {
    const { notify } = useNotification();
    const [scientists, setScientists] = useState([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [error, setError] = useState(null);
    const [showForm, setShowForm] = useState(false);
    const [editingItem, setEditingItem] = useState(null);
    const [imageFile, setImageFile] = useState(null);
    const [formData, setFormData] = useState({
        name: '',
        bio: '',
        field: '',
        birthDeath: '',
        achievements: '',
        imageUrl: '',
        category: 'muslim',
        contentType: 'video',
        videoUrl: '',
        documentUrl: ''
    });

    useEffect(() => {
        fetchScientists();
    }, []);

    const fetchScientists = async () => {
        try {
            setLoading(true);
            const { data } = await scientistsApi.getAll();
            setScientists(data.scientists);
        } catch (err) {
            notify.error('Failed to load scientists');
            setError(err.response?.data?.error || 'Failed to load scientists');
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
            data.append('bio', formData.bio);
            data.append('field', formData.field);
            data.append('birthDeath', formData.birthDeath);
            if (formData.imageUrl) data.append('imageUrl', formData.imageUrl);

            const achievementsArray = formData.achievements.split('\n').filter(line => line.trim());
            data.append('achievements', JSON.stringify(achievementsArray));

            data.append('category', formData.category);
            data.append('contentType', formData.contentType);
            if (formData.videoUrl) data.append('videoUrl', formData.videoUrl);
            if (formData.documentUrl) data.append('documentUrl', formData.documentUrl);

            if (imageFile) data.append('image', imageFile);

            if (editingItem) {
                await scientistsApi.update(editingItem.id, data);
                notify.success('Scientist updated successfully');
            } else {
                await scientistsApi.create(data);
                notify.success('Scientist created successfully');
            }

            setShowForm(false);
            setEditingItem(null);
            setImageFile(null);
            resetForm();
            fetchScientists();
        } catch (err) {
            notify.error('Failed to save: ' + (err.response?.data?.error || err.message));
        } finally {
            setSubmitting(false);
        }
    };

    const resetForm = () => {
        setFormData({
            name: '', bio: '', field: '', birthDeath: '', achievements: '', imageUrl: '', category: 'muslim', contentType: 'video', videoUrl: '', documentUrl: ''
        });
    };

    const handleEdit = (item) => {
        setEditingItem(item);
        setFormData({
            name: item.name,
            bio: item.bio,
            field: item.field,
            birthDeath: item.birthDeath,
            achievements: Array.isArray(item.achievements) ? item.achievements.join('\n') : item.achievements || '',
            imageUrl: item.imageUrl || '',
            category: item.category || 'muslim',
            contentType: item.contentType || 'video',
            videoUrl: item.videoUrl || '',
            documentUrl: item.documentUrl || ''
        });
        setShowForm(true);
    };

    const handleDelete = async (id) => {
        setDeletingId(id);
        try {
            await scientistsApi.delete(id);
            setScientists(scientists.filter(s => s.id !== id));
            notify.success('Scientist deleted successfully');
        } catch (err) {
            notify.error('Failed to delete: ' + err.message);
        } finally {
            setDeletingId(null);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Muslim Scientists</h1>
                    <p className="text-light-muted">Manage profiles of great Islamic scholars and scientists</p>
                </div>
                <div className="flex gap-3">
                    <button
                        onClick={() => {
                            setEditingItem(null);
                            resetForm();
                            setShowForm(true);
                        }}
                        className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main font-medium rounded-lg hover:bg-gold-dark transition-all shadow-[0_0_15px_rgba(251,191,36,0.2)]"
                    >
                        <Plus size={18} /> Add Scientist
                    </button>
                    <button
                        onClick={fetchScientists}
                        className="p-2 bg-dark-card border border-dark-icon text-light-primary rounded-lg hover:bg-dark-icon transition-all shadow-sm"
                    >
                        <RefreshCw size={18} />
                    </button>
                </div>
            </div>

            {loading ? (
                <div className="flex justify-center h-64 items-center">
                    <Loader2 className="animate-spin text-gold-primary w-8 h-8" />
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {scientists.map(item => (
                        <div key={item.id} className="bg-dark-card border border-dark-icon rounded-xl overflow-hidden flex flex-col group hover:border-gold-primary/30 transition-all shadow-lg hover:shadow-gold-primary/5">
                            <div className="h-48 bg-dark-main overflow-hidden relative">
                                {item.imageUrl ? (
                                    <img
                                        src={item.imageUrl}
                                        alt={item.name}
                                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                                    />
                                ) : (
                                    <div className="flex items-center justify-center h-full text-dark-icon"><User size={48} /></div>
                                )}
                                <div className="absolute top-2 right-2 flex gap-2">
                                    <span className={`px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wider ${item.contentType === 'video' ? 'bg-red-500 text-white' : 'bg-gold-primary text-dark-main'}`}>
                                        {item.contentType === 'video' ? 'Video' : 'Document'}
                                    </span>
                                </div>
                            </div>
                            <div className="p-4 flex-1">
                                <h3 className="text-lg font-bold text-light-primary group-hover:text-gold-primary transition-colors">{item.name}</h3>
                                <p className="text-sm text-gold-primary font-medium mb-1">{item.field}</p>
                                <p className="text-xs text-light-muted mb-2 italic">{item.birthDeath}</p>
                                <p className="text-light-muted text-sm line-clamp-3 leading-relaxed">{item.bio}</p>
                            </div>
                            <div className="p-4 border-t border-dark-icon bg-dark-main/50 flex justify-end gap-2">
                                <button
                                    onClick={() => handleEdit(item)}
                                    className="p-2 text-gold-primary hover:bg-gold-primary/10 rounded-lg transition-all"
                                >
                                    <Edit size={18} />
                                </button>
                                <button
                                    onClick={() => handleDelete(item.id)}
                                    className="p-2 text-light-muted hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-all opacity-0 group-hover:opacity-100"
                                    disabled={deletingId === item.id}
                                >
                                    {deletingId === item.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 size={18} />}
                                </button>
                            </div>
                        </div>
                    ))}
                    {scientists.length === 0 && (
                        <div className="col-span-full bg-dark-card border border-dark-icon rounded-xl p-12 text-center text-light-muted">
                            No scientists found.
                        </div>
                    )}
                </div>
            )}

            {showForm && (
                <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto border border-dark-icon scrollbar-thin scrollbar-thumb-dark-icon scrollbar-track-transparent">
                        <div className="p-6 border-b border-dark-icon flex justify-between items-center sticky top-0 bg-dark-card z-10">
                            <h2 className="text-xl font-bold text-light-primary">{editingItem ? 'Edit Scientist' : 'Add Scientist'}</h2>
                            <button onClick={() => setShowForm(false)} className="p-2 hover:bg-dark-icon rounded text-light-muted"><X size={20} /></button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium mb-1 text-light-muted">Name</label>
                                    <input type="text" required value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1 text-light-muted">Field</label>
                                    <input type="text" required value={formData.field} onChange={e => setFormData({ ...formData, field: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none" />
                                </div>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium mb-1 text-light-muted">Birth - Death (e.g. 780 - 850)</label>
                                    <input type="text" required value={formData.birthDeath} onChange={e => setFormData({ ...formData, birthDeath: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none" />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1 text-light-muted">Category</label>
                                    <select value={formData.category} onChange={e => setFormData({ ...formData, category: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none">
                                        <option value="muslim">Islamic (Muslim Scientists)</option>
                                        <option value="western">Western Scientists</option>
                                    </select>
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1 text-light-muted">Biography</label>
                                <textarea required value={formData.bio} onChange={e => setFormData({ ...formData, bio: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none" rows="3"></textarea>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1 text-light-muted">Achievements (One per line)</label>
                                <textarea value={formData.achievements} onChange={e => setFormData({ ...formData, achievements: e.target.value })} className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none" rows="4"></textarea>
                            </div>

                            <ImageUpload
                                label="Profile Image"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="scientist-images"
                            />

                            <div>
                                <label className="block text-sm font-medium mb-2 text-light-muted">Content Type</label>
                                <div className="flex gap-3">
                                    <button
                                        type="button"
                                        onClick={() => setFormData({ ...formData, contentType: 'video' })}
                                        className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg transition-colors ${formData.contentType === 'video' ? 'bg-red-500/20 border border-red-500 text-red-400' : 'bg-dark-main border border-dark-icon text-light-muted hover:border-light-muted'}`}
                                    >
                                        <Play size={18} /> Video
                                    </button>
                                    <button
                                        type="button"
                                        onClick={() => setFormData({ ...formData, contentType: 'document' })}
                                        className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg transition-colors ${formData.contentType === 'document' ? 'bg-purple-500/20 border border-purple-500 text-purple-400' : 'bg-dark-main border border-dark-icon text-light-muted hover:border-light-muted'}`}
                                    >
                                        <FileText size={18} /> Document
                                    </button>
                                </div>
                            </div>
                            {formData.contentType === 'video' && (
                                <div>
                                    <label className="block text-sm font-medium mb-1 text-light-muted">YouTube Video URL</label>
                                    <input type="url" value={formData.videoUrl} onChange={e => setFormData({ ...formData, videoUrl: e.target.value })} placeholder="https://youtube.com/watch?v=..." className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none" />
                                </div>
                            )}
                            {formData.contentType === 'document' && (
                                <div>
                                    <label className="block text-sm font-medium mb-1 text-light-muted">Upload Document</label>
                                    <input
                                        type="file"
                                        accept=".pdf,.doc,.docx"
                                        onChange={e => {
                                            const file = e.target.files[0];
                                            if (file) {
                                                setFormData({ ...formData, documentFile: file, documentUrl: URL.createObjectURL(file) });
                                            }
                                        }}
                                        className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-gold-primary file:text-dark-main"
                                    />
                                    <p className="text-xs text-light-muted mt-1">Upload PDF or Word document (max 10MB)</p>
                                </div>
                            )}
                            <button
                                type="submit"
                                disabled={submitting}
                                className="w-full bg-gold-primary text-dark-main py-3 rounded-lg hover:bg-gold-dark font-medium transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                            >
                                {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : <Check className="w-5 h-5" />}
                                {editingItem ? 'Update Scientist' : 'Create Scientist'}
                            </button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

export default ScientistsPage;
