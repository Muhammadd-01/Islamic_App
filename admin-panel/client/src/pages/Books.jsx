import { useEffect, useState } from 'react';
import { Trash2, Loader2, BookOpen, RefreshCw, Plus, Edit, X } from 'lucide-react';
import { booksApi } from '../services/api';

function BooksPage() {
    const [books, setBooks] = useState([]);
    const [loading, setLoading] = useState(true);
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
            setError(err.response?.data?.message || 'Failed to load books');
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
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
            } else {
                await booksApi.create(data);
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
            alert('Failed to save book: ' + (err.response?.data?.message || err.message));
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
        if (!confirm(`Are you sure you want to delete "${bookTitle}"?`)) {
            return;
        }

        try {
            await booksApi.delete(bookId);
            setBooks(books.filter(b => b.id !== bookId));
        } catch (err) {
            alert('Failed to delete book: ' + (err.response?.data?.message || err.message));
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Books</h1>
                    <p className="text-gray-500">Manage library books (shown in app)</p>
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
                        className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors"
                    >
                        <Plus size={18} />
                        Add Book
                    </button>
                    <button
                        onClick={fetchBooks}
                        className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                    >
                        <RefreshCw size={18} />
                    </button>
                </div>
            </div>

            {error && (
                <div className="bg-red-50 text-red-600 p-4 rounded-lg">{error}</div>
            )}

            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-primary-500" />
                </div>
            ) : (
                <div className="bg-white rounded-xl shadow-sm overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-gray-50 border-b">
                                <tr>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Book</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Author</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Price</th>
                                    <th className="px-6 py-4 text-left text-sm font-medium text-gray-500">Rating</th>
                                    <th className="px-6 py-4 text-right text-sm font-medium text-gray-500">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y">
                                {books.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" className="px-6 py-8 text-center text-gray-500">
                                            No books found. Add your first book!
                                        </td>
                                    </tr>
                                ) : (
                                    books.map((book) => (
                                        <tr key={book.id} className="hover:bg-gray-50">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-12 h-16 bg-gray-100 rounded overflow-hidden">
                                                        {book.coverUrl ? (
                                                            <img
                                                                src={book.coverUrl}
                                                                alt={book.title}
                                                                className="w-full h-full object-cover"
                                                            />
                                                        ) : (
                                                            <div className="w-full h-full flex items-center justify-center">
                                                                <BookOpen className="w-6 h-6 text-gray-400" />
                                                            </div>
                                                        )}
                                                    </div>
                                                    <div>
                                                        <p className="font-medium text-gray-800">{book.title}</p>
                                                        <p className="text-xs text-gray-400">{book.id.slice(0, 8)}...</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-gray-600">{book.author}</td>
                                            <td className="px-6 py-4">
                                                {book.isFree ? (
                                                    <span className="px-2 py-1 bg-green-100 text-green-700 rounded-full text-sm">Free</span>
                                                ) : (
                                                    <span className="font-medium">${book.price?.toFixed(2) || '0.00'}</span>
                                                )}
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-1">
                                                    <span className="text-yellow-500">★</span>
                                                    <span>{book.rating?.toFixed(1) || '0.0'}</span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    <button
                                                        onClick={() => handleEdit(book)}
                                                        className="p-2 text-blue-500 hover:bg-blue-50 rounded-lg transition-colors"
                                                    >
                                                        <Edit className="w-5 h-5" />
                                                    </button>
                                                    <button
                                                        onClick={() => handleDelete(book.id, book.title)}
                                                        className="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors"
                                                    >
                                                        <Trash2 className="w-5 h-5" />
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
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
                        <div className="p-6 border-b flex items-center justify-between">
                            <h2 className="text-xl font-bold">{editingBook ? 'Edit Book' : 'Add New Book'}</h2>
                            <button onClick={() => setShowForm(false)} className="p-2 hover:bg-gray-100 rounded-lg">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium mb-1">Title *</label>
                                <input
                                    type="text"
                                    required
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Author *</label>
                                <input
                                    type="text"
                                    required
                                    value={formData.author}
                                    onChange={(e) => setFormData({ ...formData, author: e.target.value })}
                                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Description</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
                                    rows="3"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-1">Book Cover Image (Upload)</label>
                                <input
                                    type="file"
                                    accept="image/*"
                                    onChange={(e) => setImageFile(e.target.files[0])}
                                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
                                />
                                <p className="text-xs text-gray-500 mt-1">Or enter URL below</p>
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-1">Cover URL (Optional)</label>
                                <input
                                    type="text"
                                    value={formData.coverUrl}
                                    onChange={(e) => setFormData({ ...formData, coverUrl: e.target.value })}
                                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
                                    placeholder="https://example.com/cover.jpg"
                                />
                            </div>

                            <div className="flex gap-4">
                                <div className="flex-1">
                                    <label className="block text-sm font-medium mb-1">Price</label>
                                    <input
                                        type="number"
                                        step="0.01"
                                        value={formData.price}
                                        onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
                                        disabled={formData.isFree}
                                    />
                                </div>
                                <div className="flex-1">
                                    <label className="block text-sm font-medium mb-1">Rating</label>
                                    <input
                                        type="number"
                                        step="0.1"
                                        min="0"
                                        max="5"
                                        value={formData.rating}
                                        onChange={(e) => setFormData({ ...formData, rating: e.target.value })}
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary-500"
                                    />
                                </div>
                            </div>
                            <div className="flex items-center gap-2">
                                <input
                                    type="checkbox"
                                    id="isFree"
                                    checked={formData.isFree}
                                    onChange={(e) => setFormData({ ...formData, isFree: e.target.checked, price: e.target.checked ? '0' : formData.price })}
                                    className="w-4 h-4"
                                />
                                <label htmlFor="isFree" className="text-sm">This book is free</label>
                            </div>
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={() => setShowForm(false)}
                                    className="flex-1 px-4 py-2 border rounded-lg hover:bg-gray-50"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
                                >
                                    {editingBook ? 'Update' : 'Create'}
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
