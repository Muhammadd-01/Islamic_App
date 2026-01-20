import { useState, useEffect } from 'react';
import { Plus, Edit, Trash2, Search, Loader2, Image as ImageIcon, X } from 'lucide-react';
import { newsApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

export default function News() {
    const { notify } = useNotification();
    const [news, setNews] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingNews, setEditingNews] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [imageFile, setImageFile] = useState(null);

    const [formData, setFormData] = useState({
        title: '',
        content: '',
        author: '',
        source: '',
        imageUrl: ''
    });

    useEffect(() => {
        fetchNews();
    }, []);

    const fetchNews = async () => {
        try {
            setLoading(true);
            const { data } = await newsApi.getAll();
            setNews(data);
        } catch (error) {
            console.error('Error fetching news:', error);
            notify.error('Failed to fetch news');
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
            data.append('author', formData.author);
            data.append('source', formData.source);
            if (formData.imageUrl) data.append('imageUrl', formData.imageUrl);

            if (imageFile) {
                data.append('image', imageFile);
            }

            if (editingNews) {
                await newsApi.update(editingNews.id, data);
                notify.success('News updated successfully');
            } else {
                await newsApi.create(data);
                notify.success('News created successfully');
            }

            fetchNews();
            closeModal();
        } catch (error) {
            console.error('Error saving news:', error);
            notify.error('Failed to save news: ' + (error.response?.data?.error || error.message));
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this news item?')) return;
        setDeletingId(id);
        try {
            await newsApi.delete(id);
            setNews(news.filter(n => n.id !== id));
            notify.success('News deleted successfully');
        } catch (error) {
            console.error('Error deleting news:', error);
            notify.error('Failed to delete news');
        } finally {
            setDeletingId(null);
        }
    };

    const openModal = (newsItem = null) => {
        if (newsItem) {
            setEditingNews(newsItem);
            setFormData({
                title: newsItem.title || '',
                content: newsItem.content || '',
                author: newsItem.author || '',
                source: newsItem.source || '',
                imageUrl: newsItem.imageUrl || ''
            });
        } else {
            setEditingNews(null);
            setFormData({
                title: '',
                content: '',
                author: '',
                source: '',
                imageUrl: ''
            });
        }
        setImageFile(null);
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingNews(null);
        setImageFile(null);
    };

    const filteredNews = news.filter(item =>
        item.title?.toLowerCase().includes(search.toLowerCase()) ||
        item.content?.toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">News Management</h1>
                    <p className="text-light-muted">Manage Islamic news and updates</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark transition"
                >
                    <Plus size={20} />
                    Add News
                </button>
            </div>

            <div className="relative">
                <Search className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                <input
                    type="text"
                    placeholder="Search news..."
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
                    {filteredNews.map((item) => (
                        <div key={item.id} className="bg-dark-card border border-dark-icon rounded-xl overflow-hidden hover:border-gold-primary/50 transition-colors">
                            <div className="h-48 bg-dark-icon relative">
                                {item.imageUrl ? (
                                    <img src={item.imageUrl} alt={item.title} className="w-full h-full object-cover" />
                                ) : (
                                    <div className="flex items-center justify-center h-full">
                                        <ImageIcon size={40} className="text-light-muted opacity-50" />
                                    </div>
                                )}
                            </div>
                            <div className="p-4">
                                <h3 className="text-lg font-semibold text-light-primary mb-2 line-clamp-1">{item.title}</h3>
                                <p className="text-light-muted text-sm mb-4 line-clamp-2">{item.content}</p>
                                <div className="flex justify-between items-center text-xs text-light-muted mb-4">
                                    <span>By {item.author}</span>
                                    <span>{new Date(item.createdAt).toLocaleDateString()}</span>
                                </div>
                                <div className="flex gap-2">
                                    <button
                                        onClick={() => openModal(item)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-dark-icon text-gold-primary py-2 rounded-lg hover:bg-dark-icon/80"
                                    >
                                        <Edit size={16} />
                                        Edit
                                    </button>
                                    <button
                                        onClick={() => handleDelete(item.id)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-red-500/10 text-red-400 py-2 rounded-lg hover:bg-red-500/20"
                                        disabled={deletingId === item.id}
                                    >
                                        {deletingId === item.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 size={16} />}
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
                                {editingNews ? 'Edit News' : 'Add News'}
                            </h2>
                            <button onClick={closeModal} className="text-light-muted hover:text-light-primary">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Title</label>
                                <input
                                    type="text"
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Content</label>
                                <textarea
                                    value={formData.content}
                                    onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary h-32 resize-none"
                                    required
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Author</label>
                                    <input
                                        type="text"
                                        value={formData.author}
                                        onChange={(e) => setFormData({ ...formData, author: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Source</label>
                                    <input
                                        type="text"
                                        value={formData.source}
                                        onChange={(e) => setFormData({ ...formData, source: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary"
                                    />
                                </div>
                            </div>

                            <ImageUpload
                                label="Cover Image"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="news-images"
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
                                    {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : (editingNews ? 'Update' : 'Create')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
