import { useEffect, useState } from 'react';
import { Trash2, Loader2, RefreshCw, Plus, X, User, Play, FileText } from 'lucide-react';
import { scientistsApi } from '../services/api';

function ScientistsPage() {
    const [scientists, setScientists] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [showForm, setShowForm] = useState(false);
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
            setError(err.response?.data?.error || 'Failed to load scientists');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
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

            await scientistsApi.create(data);

            setShowForm(false);
            setImageFile(null);
            setFormData({
                name: '', bio: '', field: '', birthDeath: '', achievements: '', imageUrl: '', category: 'muslim', contentType: 'video', videoUrl: '', documentUrl: ''
            });
            fetchScientists();
        } catch (err) {
            alert('Failed to save: ' + (err.response?.data?.error || err.message));
        }
    };

    const handleDelete = async (id) => {
        if (!confirm('Delete this scientist?')) return;
        try {
            await scientistsApi.delete(id);
            setScientists(scientists.filter(s => s.id !== id));
        } catch (err) {
            alert('Failed to delete: ' + err.message);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Muslim Scientists</h1>
                    <p className="text-gray-500">Manage profiles of great Islamic scholars and scientists</p>
                </div>
                <div className="flex gap-3">
                    <button
                        onClick={() => setShowForm(true)}
                        className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors"
                    >
                        <Plus size={18} /> Add Scientist
                    </button>
                    <button onClick={fetchScientists} className="p-2 bg-gray-100 rounded-lg hover:bg-gray-200">
                        <RefreshCw size={18} />
                    </button>
                </div>
            </div>

            {error && <div className="bg-red-50 text-red-600 p-4 rounded-lg">{error}</div>}

            {loading ? (
                <div className="flex justify-center h-64 items-center"><Loader2 className="animate-spin text-primary-500 w-8 h-8" /></div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {scientists.map(item => (
                        <div key={item.id} className="bg-white rounded-xl shadow-sm overflow-hidden flex flex-col">
                            <div className="h-48 bg-gray-100 overflow-hidden relative">
                                {item.imageUrl ? (
                                    <img src={item.imageUrl} alt={item.name} className="w-full h-full object-cover" />
                                ) : (
                                    <div className="flex items-center justify-center h-full text-gray-400"><User size={48} /></div>
                                )}
                            </div>
                            <div className="p-4 flex-1">
                                <h3 className="text-lg font-bold text-gray-800">{item.name}</h3>
                                <p className="text-sm text-primary-600 mb-2">{item.field}</p>
                                <p className="text-xs text-gray-500 mb-2">{item.birthDeath}</p>
                                <p className="text-gray-600 text-sm line-clamp-3">{item.bio}</p>
                            </div>
                            <div className="p-4 border-t bg-gray-50 flex justify-end">
                                <button onClick={() => handleDelete(item.id)} className="text-red-500 hover:bg-red-50 p-2 rounded-lg">
                                    <Trash2 size={18} />
                                </button>
                            </div>
                        </div>
                    ))}
                    {scientists.length === 0 && <p className="col-span-full text-center text-gray-500 py-10">No scientists found.</p>}
                </div>
            )}

            {showForm && (
                <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto border border-dark-icon">
                        <div className="p-6 border-b border-dark-icon flex justify-between items-center">
                            <h2 className="text-xl font-bold text-light-primary">Add Scientist</h2>
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
                            <div>
                                <label className="block text-sm font-medium mb-1 text-light-muted">Profile Image (Upload from Device)</label>
                                <input type="file" accept="image/*" onChange={e => setImageFile(e.target.files[0])} className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary file:mr-4 file:py-1 file:px-3 file:rounded file:border-0 file:bg-gold-primary file:text-dark-main file:font-medium" />
                            </div>
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
                                    <p className="text-xs text-light-muted mt-1">Enter a YouTube video URL</p>
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
                                    {formData.documentUrl && <p className="text-xs text-green-400 mt-1">✓ Document selected</p>}
                                </div>
                            )}
                            <button type="submit" className="w-full bg-gold-primary text-dark-main py-3 rounded-lg hover:bg-gold-dark font-medium transition-colors">Create Scientist</button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

export default ScientistsPage;
