import { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Search, X, Save, ExternalLink, DollarSign } from 'lucide-react';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

export default function CoursesPage() {
    const [courses, setCourses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingCourse, setEditingCourse] = useState(null);
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        instructor: '',
        duration: '',
        level: 'Beginner',
        imageUrl: '',
        enrollUrl: '',
        isFree: false,
        price: 0,
    });

    useEffect(() => {
        fetchCourses();
    }, []);

    const fetchCourses = async () => {
        try {
            const res = await fetch(`${API_URL}/courses`);
            const data = await res.json();
            setCourses(data);
        } catch (error) {
            console.error('Error fetching courses:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const url = editingCourse
                ? `${API_URL}/courses/${editingCourse.id}`
                : `${API_URL}/courses`;
            const method = editingCourse ? 'PUT' : 'POST';

            await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
            });

            fetchCourses();
            closeModal();
        } catch (error) {
            console.error('Error saving course:', error);
        }
    };

    const handleDelete = async (id) => {
        if (!confirm('Are you sure you want to delete this course?')) return;
        try {
            await fetch(`${API_URL}/courses/${id}`, { method: 'DELETE' });
            fetchCourses();
        } catch (error) {
            console.error('Error deleting course:', error);
        }
    };

    const openModal = (course = null) => {
        if (course) {
            setEditingCourse(course);
            setFormData({
                title: course.title || '',
                description: course.description || '',
                instructor: course.instructor || '',
                duration: course.duration || '',
                level: course.level || 'Beginner',
                imageUrl: course.imageUrl || '',
                enrollUrl: course.enrollUrl || '',
                isFree: course.isFree || false,
                price: course.price || 0,
            });
        } else {
            setEditingCourse(null);
            setFormData({
                title: '',
                description: '',
                instructor: '',
                duration: '',
                level: 'Beginner',
                imageUrl: '',
                enrollUrl: '',
                isFree: false,
                price: 0,
            });
        }
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingCourse(null);
    };

    const filteredCourses = courses.filter(
        (c) =>
            c.title?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            c.instructor?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const getLevelColor = (level) => {
        switch (level?.toLowerCase()) {
            case 'beginner': return 'bg-green-500/10 text-green-400';
            case 'intermediate': return 'bg-yellow-500/10 text-yellow-400';
            case 'advanced': return 'bg-red-500/10 text-red-400';
            default: return 'bg-blue-500/10 text-blue-400';
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-white">Courses Management</h1>
                    <p className="text-gray-400">Manage courses and scholarships</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-black px-4 py-2 rounded-lg font-medium hover:bg-gold-light transition"
                >
                    <Plus size={20} />
                    Add Course
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
                <input
                    type="text"
                    placeholder="Search courses..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 bg-dark-card border border-dark-icon rounded-lg text-white focus:border-gold-primary"
                />
            </div>

            {/* Courses Grid */}
            {loading ? (
                <div className="flex justify-center py-12">
                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gold-primary"></div>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filteredCourses.map((course) => (
                        <div
                            key={course.id}
                            className="bg-dark-card border border-dark-icon rounded-xl overflow-hidden"
                        >
                            <div className="h-40 bg-dark-icon flex items-center justify-center relative">
                                {course.imageUrl ? (
                                    <img
                                        src={course.imageUrl}
                                        alt={course.title}
                                        className="w-full h-full object-cover"
                                    />
                                ) : (
                                    <span className="text-4xl">📚</span>
                                )}
                                <div className="absolute top-2 right-2">
                                    {course.isFree ? (
                                        <span className="bg-green-500 text-white text-xs px-2 py-1 rounded font-medium">FREE</span>
                                    ) : (
                                        <span className="bg-gold-primary text-black text-xs px-2 py-1 rounded font-medium">${course.price}</span>
                                    )}
                                </div>
                                <div className="absolute top-2 left-2">
                                    <span className={`text-xs px-2 py-1 rounded font-medium ${getLevelColor(course.level)}`}>
                                        {course.level}
                                    </span>
                                </div>
                            </div>
                            <div className="p-4">
                                <h3 className="text-lg font-semibold text-white line-clamp-1">{course.title}</h3>
                                <p className="text-gold-primary text-sm">{course.instructor}</p>
                                <p className="text-gray-400 text-sm mt-2 line-clamp-2">{course.description}</p>
                                <div className="flex items-center gap-2 mt-3 text-gray-500 text-xs">
                                    <span>⏱️ {course.duration}</span>
                                </div>
                                <div className="flex gap-2 mt-4">
                                    <button
                                        onClick={() => openModal(course)}
                                        className="flex-1 flex items-center justify-center gap-1 bg-dark-icon text-gold-primary py-2 rounded-lg hover:bg-dark-icon/80"
                                    >
                                        <Edit2 size={16} />
                                        Edit
                                    </button>
                                    <button
                                        onClick={() => handleDelete(course.id)}
                                        className="flex items-center justify-center gap-1 bg-red-500/10 text-red-400 px-4 py-2 rounded-lg hover:bg-red-500/20"
                                    >
                                        <Trash2 size={16} />
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {/* Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
                        <div className="flex justify-between items-center p-4 border-b border-dark-icon">
                            <h2 className="text-xl font-semibold text-white">
                                {editingCourse ? 'Edit Course' : 'Add New Course'}
                            </h2>
                            <button onClick={closeModal} className="text-gray-400 hover:text-white">
                                <X size={24} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-4 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Title</label>
                                <input
                                    type="text"
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Instructor</label>
                                <input
                                    type="text"
                                    value={formData.instructor}
                                    onChange={(e) => setFormData({ ...formData, instructor: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Description</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white h-20 resize-none"
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-300 mb-1">Duration</label>
                                    <input
                                        type="text"
                                        value={formData.duration}
                                        onChange={(e) => setFormData({ ...formData, duration: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                        placeholder="e.g., 8 weeks"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-300 mb-1">Level</label>
                                    <select
                                        value={formData.level}
                                        onChange={(e) => setFormData({ ...formData, level: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                    >
                                        <option value="Beginner">Beginner</option>
                                        <option value="Intermediate">Intermediate</option>
                                        <option value="Advanced">Advanced</option>
                                        <option value="All Levels">All Levels</option>
                                    </select>
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Image URL</label>
                                <input
                                    type="url"
                                    value={formData.imageUrl}
                                    onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-300 mb-1">Enrollment URL</label>
                                <input
                                    type="url"
                                    value={formData.enrollUrl}
                                    onChange={(e) => setFormData({ ...formData, enrollUrl: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                    placeholder="https://deen-sphere.vercel.app/..."
                                />
                            </div>
                            <div className="flex items-center gap-3">
                                <input
                                    type="checkbox"
                                    id="isFree"
                                    checked={formData.isFree}
                                    onChange={(e) => setFormData({ ...formData, isFree: e.target.checked })}
                                    className="w-5 h-5 rounded"
                                />
                                <label htmlFor="isFree" className="text-gray-300">Free Course</label>
                            </div>
                            {!formData.isFree && (
                                <div>
                                    <label className="block text-sm font-medium text-gray-300 mb-1">Price ($)</label>
                                    <input
                                        type="number"
                                        value={formData.price}
                                        onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) || 0 })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-white"
                                        min="0"
                                    />
                                </div>
                            )}
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="flex-1 py-2 border border-dark-icon text-gray-300 rounded-lg hover:bg-dark-icon"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 flex items-center justify-center gap-2 bg-gold-primary text-black py-2 rounded-lg font-medium hover:bg-gold-light"
                                >
                                    <Save size={18} />
                                    {editingCourse ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
