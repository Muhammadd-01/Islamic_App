import { useEffect, useState } from 'react';
import { Trash2, Loader2, BookOpen, RefreshCw, Plus, Edit, X, Check } from 'lucide-react';
import { booksApi } from '../services/api';
import { useNotification } from '../components/NotificationSystem';

function BooksPage() {
    const { notify } = useNotification();
    const [books, setBooks] = useState([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [error, setError] = useState(null);
    const [showForm, setShowForm] = useState(false);
    const [editingBook, setEditingBook] = useState(null);
    const [imageFile, setImageFile] = useState(null);
    const [formData, setFormData] = useState({
        title: '',
        author: '',
        description: '',
        coverUrl: '',
        price: '',
        isFree: false,
        rating: '5',
    });

    useEffect(() => {
        fetchBooks();
    }, []);

    const fetchBooks = async () => {
        try {
            setLoading(true);
            const { data } = await booksApi.getAll();
            setBooks(data.books);
        } catch (err) {
            notify.error('Failed to load books');
            setError(err.response?.data?.message || 'Failed to load books');
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
            data.append('author', formData.author);
            data.append('description', formData.description);
            data.append('price', formData.price);
            data.append('isFree', formData.isFree);
            data.append('rating', formData.rating);

            if (formData.coverUrl) data.append('coverUrl', formData.coverUrl);
            if (imageFile) data.append('image', imageFile);

            if (editingBook) {
                await booksApi.update(editingBook.id, data);
                notify.success(`"${formData.title}" updated successfully!`);
            } else {
                await booksApi.create(data);
                notify.success(`"${formData.title}" added successfully!`);
            }
            setShowForm(false);
            setEditingBook(null);
            setImageFile(null);
            setFormData({
                title: '',
                author: '',
                description: '',
                coverUrl: '',
                price: '',
                isFree: false,
                rating: '5',
            });
            fetchBooks();
        } catch (err) {
            notify.error('Failed to save book: ' + (err.response?.data?.message || err.message));
        } finally {
            setSubmitting(false);
        }
    };

    const handleEdit = (book) => {
        setEditingBook(book);
        setImageFile(null);
        setFormData({
            title: book.title,
            author: book.author,
            description: book.description || '',
            coverUrl: book.coverUrl || '',
            price: book.price?.toString() || '',
            isFree: book.isFree || false,
            rating: book.rating?.toString() || '5',
        });
        setShowForm(true);
    };

    const handleDelete = async (bookId, bookTitle) => {
        setDeletingId(bookId);
        try {
            await booksApi.delete(bookId);
            setBooks(books.filter(b => b.id !== bookId));
            notify.success(`"${bookTitle}" deleted successfully!`);
        } catch (err) {
            notify.error('Failed to delete book: ' + (err.response?.data?.message || err.message));
        } finally {
            setDeletingId(null);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Books</h1>
                    <p className="text-light-muted">Manage library books (shown in app)</p>
                </div>
                <div className="flex gap-3">
                    <button
                        onClick={() => {
                            setEditingBook(null);
                            setFormData({
                                title: '',
                                author: '',
                                description: '',
                                coverUrl: '',
                                price: '',
                                isFree: false,
                                rating: '5',
                            });
                            setImageFile(null);
                            setShowForm(true);
                        }}
                        className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main font-medium rounded-lg hover:bg-gold-dark transition-all shadow-[0_0_15px_rgba(251,191,36,0.2)]"
                    >
                        <Plus size={18} />
                        Add Book
                    </button>
                    <button
                        onClick={fetchBooks}
                        className="flex items-center gap-2 px-4 py-2 bg-dark-card border border-dark-icon text-light-primary rounded-lg hover:bg-dark-icon transition-all shadow-sm"
                    >
                        <RefreshCw size={18} />
                    </button>
                </div>
            </div>

            {error && (
                <div className="bg-red-500/10 border border-red-500/20 text-red-500 p-4 rounded-lg">{error}</div>
            )}

            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
                </div>
            ) : (
                <div className="bg-dark-card border border-dark-icon rounded-xl shadow-lg overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-dark-main border-b border-dark-icon">
                                <tr>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Book</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Author</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Price</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Rating</th>
                                    <th className="px-6 py-4 text-right text-sm font-semibold text-light-muted uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-dark-icon">
                                {books.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" className="px-6 py-8 text-center text-light-muted">
                                            No books found. Add your first book!
                                        </td>
                                    </tr>
                                ) : (
                                    books.map((book) => (
                                        <tr key={book.id} className="hover:bg-gold-primary/[0.02] transition-colors group">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-12 h-16 bg-dark-main border border-dark-icon rounded overflow-hidden">
                                                        {book.coverUrl ? (
                                                            <img
                                                                src={book.coverUrl}
                                                                alt={book.title}
                                                                className="w-full h-full object-cover"
                                                            />
                                                        ) : (
                                                            <div className="w-full h-full flex items-center justify-center">
                                                                <BookOpen className="w-6 h-6 text-dark-icon" />
                                                            </div>
                                                        )}
                                                    </div>
                                                    <div>
                                                        <p className="font-medium text-light-primary">{book.title}</p>
                                                        <p className="text-xs text-light-muted">{book.id.slice(0, 8)}...</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-light-primary">{book.author}</td>
                                            <td className="px-6 py-4">
                                                {book.isFree ? (
                                                    <span className="px-2 py-1 bg-green-500/20 text-green-400 rounded-full text-xs font-medium">Free</span>
                                                ) : (
                                                    <span className="font-medium text-light-primary">${book.price?.toFixed(2) || '0.00'}</span>
                                                )}
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-1.5 text-light-primary font-medium">
                                                    <span className="text-gold-primary">★</span>
                                                    <span>{book.rating?.toFixed(1) || '0.0'}</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    <button
                                                        onClick={() => handleEdit(book)}
                                                        className="p-2 text-gold-primary hover:bg-gold-primary/10 rounded-lg transition-all"
                                                        disabled={deletingId === book.id}
                                                    >
                                                        <Edit className="w-5 h-5" />
                                                    </button>
                                                    <button
                                                        onClick={() => handleDelete(book.id, book.title)}
                                                        className="p-2 text-light-muted hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-all opacity-0 group-hover:opacity-100"
                                                        disabled={deletingId === book.id}
                                                    >
                                                        {deletingId === book.id ? (
                                                            <Loader2 className="w-5 h-5 animate-spin" />
                                                        ) : (
                                                            <Trash2 className="w-5 h-5" />
                                                        )}
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {/* Add/Edit Modal */}
            {showForm && (
                <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card rounded-xl max-w-lg w-full max-h-[90vh] overflow-y-auto border border-dark-icon">
                        <div className="p-6 border-b border-dark-icon flex items-center justify-between">
                            <h2 className="text-xl font-bold text-light-primary">{editingBook ? 'Edit Book' : 'Add New Book'}</h2>
                            <button onClick={() => setShowForm(false)} className="p-2 hover:bg-dark-icon rounded-lg text-light-muted">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium mb-1 text-light-muted">Title *</label>
                                <input
                                    type="text"
                                    required
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1 text-light-muted">Author *</label>
                                <input
                                    type="text"
                                    required
                                    value={formData.author}
                                    onChange={(e) => setFormData({ ...formData, author: e.target.value })}
                                    className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1 text-light-muted">Description</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none"
                                    rows="3"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-1 text-light-muted">Book Cover Image (Upload)</label>
                                <input
                                    type="file"
                                    accept="image/*"
                                    onChange={(e) => setImageFile(e.target.files[0])}
                                    className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary file:mr-4 file:py-1 file:px-3 file:rounded file:border-0 file:bg-gold-primary file:text-dark-main file:font-medium"
                                />
                                <p className="text-xs text-light-muted mt-1">Or enter URL below</p>
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-1 text-light-muted">Cover URL (Optional)</label>
                                <input
                                    type="text"
                                    value={formData.coverUrl}
                                    onChange={(e) => setFormData({ ...formData, coverUrl: e.target.value })}
                                    className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none"
                                    placeholder="https://example.com/cover.jpg"
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium mb-1 text-light-muted">Price</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        value={formData.price}
                                        onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                                        className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none disabled:opacity-50"
                                        disabled={formData.isFree}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium mb-1 text-light-muted">Rating</label>
                                    <input
                                        type="number"
                                        step="0.1"
                                        min="0"
                                        max="5"
                                        value={formData.rating}
                                        onChange={(e) => setFormData({ ...formData, rating: e.target.value })}
                                        className="w-full bg-dark-main border border-dark-icon rounded-lg px-3 py-2 text-light-primary focus:border-gold-primary focus:outline-none"
                                    />
                                </div>
                            </div>
                            <div className="flex items-center gap-2">
                                <input
                                    type="checkbox"
                                    id="isFree"
                                    checked={formData.isFree}
                                    onChange={(e) => setFormData({ ...formData, isFree: e.target.checked, price: e.target.checked ? '0' : formData.price })}
                                    className="w-4 h-4 accent-gold-primary"
                                />
                                <label htmlFor="isFree" className="text-sm text-light-muted">This book is free</label>
                            </div>
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={() => setShowForm(false)}
                                    className="flex-1 px-4 py-2 bg-dark-icon text-light-muted rounded-lg hover:bg-dark-icon/80 transition-colors"
                                    disabled={submitting}
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 px-4 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark font-medium transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
                                    disabled={submitting}
                                >
                                    {submitting ? (
                                        <Loader2 className="w-5 h-5 animate-spin" />
                                    ) : (
                                        <Check className="w-5 h-5" />
                                    )}
                                    {submitting ? 'Saving...' : (editingBook ? 'Update' : 'Create')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

export default BooksPage;
