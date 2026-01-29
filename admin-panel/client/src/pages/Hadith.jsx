import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Image as ImageIcon, X, FileText, Music } from 'lucide-react';
import { hadithsApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import FileUpload from '../components/FileUpload';
import { useNotification } from '../components/NotificationSystem';

export default function Hadith() {
    const { notify } = useNotification();
    const [hadiths, setHadiths] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingHadith, setEditingHadith] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [imageFile, setImageFile] = useState(null);
    const [pdfFile, setPdfFile] = useState(null);
    const [audioFile, setAudioFile] = useState(null);

    const [formData, setFormData] = useState({
        title: '',
        content: '',
        narrator: '',
        book: '',
        chapter: '',
        grade: '',
        imageUrl: '',
        pdfUrl: '',
        audioUrl: '',
        translation: ''
    });

    useEffect(() => {
        fetchHadiths();
    }, []);

    const fetchHadiths = async () => {
        try {
            setLoading(true);
            const { data } = await hadithsApi.getAll();
            setHadiths(data);
        } catch (error) {
            console.error('Error fetching hadiths:', error);
            notify.error('Failed to fetch hadiths');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            const data = new FormData();
            data.append('title', formData.title);
            data.append('content', formData.content);
            data.append('narrator', formData.narrator);
            data.append('book', formData.book);
            data.append('chapter', formData.chapter);
            data.append('grade', formData.grade);
            data.append('pdfUrl', formData.pdfUrl);
            data.append('audioUrl', formData.audioUrl);
            data.append('translation', formData.translation);
            if (formData.imageUrl) data.append('imageUrl', formData.imageUrl);

            if (imageFile) data.append('image', imageFile);
            if (pdfFile) data.append('pdf', pdfFile);
            if (audioFile) data.append('audio', audioFile);

            if (editingHadith) {
                await hadithsApi.update(editingHadith.id, data);
                notify.success('Hadith updated successfully');
            } else {
                await hadithsApi.create(data);
                notify.success('Hadith created successfully');
            }

            fetchHadiths();
            closeModal();
        } catch (error) {
            console.error('Error saving hadith:', error);
            notify.error('Failed to save hadith: ' + (error.response?.data?.error || error.message));
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this hadith?')) return;
        setDeletingId(id);
        try {
            await hadithsApi.delete(id);
            setHadiths(hadiths.filter(h => h.id !== id));
            notify.success('Hadith deleted successfully');
        } catch (error) {
            console.error('Error deleting hadith:', error);
            notify.error('Failed to delete hadith');
        } finally {
            setDeletingId(null);
        }
    };

    const openModal = (hadith = null) => {
        if (hadith) {
            setEditingHadith(hadith);
            setFormData({
                title: hadith.title || '',
                content: hadith.content || '',
                narrator: hadith.narrator || '',
                book: hadith.book || '',
                chapter: hadith.chapter || '',
                grade: hadith.grade || '',
                imageUrl: hadith.imageUrl || '',
                pdfUrl: hadith.pdfUrl || '',
                audioUrl: hadith.audioUrl || '',
                translation: hadith.translation || ''
            });
        } else {
            setEditingHadith(null);
            setFormData({
                title: '',
                content: '',
                narrator: '',
                book: '',
                chapter: '',
                grade: '',
                imageUrl: '',
                pdfUrl: '',
                audioUrl: '',
                translation: ''
            });
        }
        setImageFile(null);
        setPdfFile(null);
        setAudioFile(null);
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingHadith(null);
        setImageFile(null);
    };

    const filteredHadiths = hadiths.filter(h =>
        h.title?.toLowerCase().includes(search.toLowerCase()) ||
        h.content?.toLowerCase().includes(search.toLowerCase()) ||
        h.narrator?.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Hadith Collection</h1>
                    <p className="text-light-muted">Manage Hadith collection and grades</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark transition"
                >
                    <Plus size={20} />
                    Add Hadith
                </button>
            </div>

            <div className="relative">
                <Search className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                <input
                    type="text"
                    placeholder="Search hadiths..."
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
                    {filteredHadiths.map((hadith) => (
                        <div key={hadith.id} className="bg-dark-card border border-dark-icon rounded-xl p-4 hover:border-gold-primary/50 transition-colors">
                            <div className="flex justify-between items-start mb-3">
                                <div>
                                    <h3 className="text-lg font-semibold text-light-primary">{hadith.title}</h3>
                                    <span className="text-xs text-gold-primary bg-gold-primary/10 px-2 py-1 rounded inline-block mt-1">
                                        {hadith.book} {hadith.chapter ? `- ${hadith.chapter}` : ''}
                                    </span>
                                </div>
                                {hadith.imageUrl && (
                                    <img src={hadith.imageUrl} alt="Reference" className="w-10 h-10 rounded object-cover" />
                                )}
                            </div>
                            <p className="text-light-muted text-sm mb-4 line-clamp-4 leading-relaxed">{hadith.content}</p>
                            <div className="flex justify-between items-center text-xs text-light-muted mb-4 border-t border-dark-icon pt-3">
                                <span>Narrator: {hadith.narrator}</span>
                                <span className={`px-2 py-1 rounded ${hadith.grade?.toLowerCase() === 'sahih' ? 'bg-green-500/20 text-green-400' : 'bg-yellow-500/20 text-yellow-400'}`}>
                                    {hadith.grade}
                                </span>
                            </div>
                            <div className="flex gap-2">
                                <button
                                    onClick={() => openModal(hadith)}
                                    className="flex-1 flex items-center justify-center gap-1 bg-dark-icon text-gold-primary py-2 rounded-lg hover:bg-dark-icon/80"
                                >
                                    <Edit size={16} />
                                    Edit
                                </button>
                                <button
                                    onClick={() => handleDelete(hadith.id)}
                                    className="flex-1 flex items-center justify-center gap-1 bg-red-500/10 text-red-400 py-2 rounded-lg hover:bg-red-500/20"
                                    disabled={deletingId === hadith.id}
                                >
                                    {deletingId === hadith.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 size={16} />}
                                </button>
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
                                {editingHadith ? 'Edit Hadith' : 'Add Hadith'}
                            </h2>
                            <button onClick={closeModal} className="text-light-muted hover:text-light-primary">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Title/Topic</label>
                                <input
                                    type="text"
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Content (Matn)</label>
                                <textarea
                                    value={formData.content}
                                    onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary h-32 resize-none"
                                    required
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Book Name</label>
                                    <input
                                        type="text"
                                        value={formData.book}
                                        onChange={(e) => setFormData({ ...formData, book: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                        placeholder="e.g. Sahih Bukhari"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Chapter/No.</label>
                                    <input
                                        type="text"
                                        value={formData.chapter}
                                        onChange={(e) => setFormData({ ...formData, chapter: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    />
                                </div>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Narrator</label>
                                    <input
                                        type="text"
                                        value={formData.narrator}
                                        onChange={(e) => setFormData({ ...formData, narrator: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Grade</label>
                                    <select
                                        value={formData.grade}
                                        onChange={(e) => setFormData({ ...formData, grade: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    >
                                        <option value="">Select Grade</option>
                                        <option value="Sahih">Sahih</option>
                                        <option value="Hasan">Hasan</option>
                                        <option value="Da'if">Da'if</option>
                                        <option value="Maudu">Maudu</option>
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Translation</label>
                                <textarea
                                    value={formData.translation}
                                    onChange={(e) => setFormData({ ...formData, translation: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary h-24 resize-none"
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <FileUpload
                                    label="Related PDF"
                                    value={formData.pdfUrl}
                                    onChange={(val) => setFormData({ ...formData, pdfUrl: val })}
                                    onFileSelect={setPdfFile}
                                    accept=".pdf"
                                    icon={FileText}
                                />
                                <FileUpload
                                    label="Recitation (Audio)"
                                    value={formData.audioUrl}
                                    onChange={(val) => setFormData({ ...formData, audioUrl: val })}
                                    onFileSelect={setAudioFile}
                                    accept="audio/*"
                                    icon={Music}
                                />
                            </div>

                            <ImageUpload
                                label="Reference Image"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="hadith-images"
                            />

                            <div className="flex gap-3 pt-4">
                                <button type="button" onClick={closeModal} className="flex-1 px-4 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon">
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting}
                                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark disabled:opacity-50"
                                >
                                    {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : (editingHadith ? 'Update' : 'Create')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
