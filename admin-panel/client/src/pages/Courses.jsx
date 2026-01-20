import { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, Search, X, Save, ExternalLink, DollarSign, Loader2, Image as ImageIcon } from 'lucide-react';
import { coursesApi } from '../services/api';
import ImageUpload from '../components/ImageUpload';
import { useNotification } from '../components/NotificationSystem';

export default function CoursesPage() {
    const { notify } = useNotification();
    const [courses, setCourses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [editingCourse, setEditingCourse] = useState(null);
    const [submitting, setSubmitting] = useState(false);
    const [deletingId, setDeletingId] = useState(null);
    const [imageFile, setImageFile] = useState(null);

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
            setLoading(true);
            const { data } = await coursesApi.getAll();
            setCourses(data);
        } catch (error) {
            console.error('Error fetching courses:', error);
            notify.error('Failed to fetch courses');
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
            data.append('description', formData.description);
            data.append('instructor', formData.instructor);
            data.append('duration', formData.duration);
            data.append('level', formData.level);
            if (formData.imageUrl) data.append('imageUrl', formData.imageUrl);
            if (formData.enrollUrl) data.append('enrollUrl', formData.enrollUrl);
            data.append('isFree', formData.isFree);
            data.append('price', formData.price);

            if (imageFile) {
                data.append('image', imageFile);
            }

            if (editingCourse) {
                await coursesApi.update(editingCourse.id, data);
                notify.success('Course updated successfully');
            } else {
                await coursesApi.create(data);
                notify.success('Course created successfully');
            }

            fetchCourses();
            closeModal();
        } catch (error) {
            console.error('Error saving course:', error);
            notify.error('Failed to save course: ' + (error.response?.data?.error || error.message));
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this course?')) return;
        setDeletingId(id);
        try {
            await coursesApi.delete(id);
            setCourses(courses.filter(c => c.id !== id));
            notify.success('Course deleted successfully');
        } catch (error) {
            console.error('Error deleting course:', error);
            notify.error('Failed to delete course');
        } finally {
            setDeletingId(null);
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
        setImageFile(null);
        setShowModal(true);
    };

    const closeModal = () => {
        setShowModal(false);
        setEditingCourse(null);
        setImageFile(null);
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
                    <h1 className="text-2xl font-bold text-light-primary">Courses Management</h1>
                    <p className="text-light-muted">Manage courses and scholarships</p>
                </div>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-gold-primary text-dark-main px-4 py-2 rounded-lg font-medium hover:bg-gold-dark transition"
                >
                    <Plus size={20} />
                    Add Course
                </button>
            </div>

            {/* Search */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-light-muted" size={20} />
                <input
                    type="text"
                    placeholder="Search courses..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 bg-dark-card border border-dark-icon rounded-lg text-light-primary focus:border-gold-primary focus:ring-1 focus:ring-gold-primary"
                />
            </div>

            {/* Courses Grid */}
            {loading ? (
                <div className="flex justify-center py-12">
                    <Loader2 className="animate-spin text-gold-primary w-8 h-8" />
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filteredCourses.map((course) => (
                        <div
                            key={course.id}
                            className="bg-dark-card border border-dark-icon rounded-xl overflow-hidden hover:border-gold-primary/50 transition-colors"
                        >
                            <div className="h-40 bg-dark-icon flex items-center justify-center relative">
                                {course.imageUrl ? (
                                    <img
                                        src={course.imageUrl}
                                        alt={course.title}
                                        className="w-full h-full object-cover"
                                    />
                                ) : (
                                    <ImageIcon size={40} className="text-light-muted opacity-50" />
                                )}
                                <div className="absolute top-2 right-2">
                                    {course.isFree ? (
                                        <span className="bg-green-500 text-white text-xs px-2 py-1 rounded font-medium">FREE</span>
                                    ) : (
                                        <span className="bg-gold-primary text-dark-main text-xs px-2 py-1 rounded font-medium">${course.price}</span>
                                    )}
                                </div>
                                <div className="absolute top-2 left-2">
                                    <span className={`text-xs px-2 py-1 rounded font-medium ${getLevelColor(course.level)}`}>
                                        {course.level}
                                    </span>
                                </div>
                            </div>
                            <div className="p-4">
                                <h3 className="text-lg font-semibold text-light-primary line-clamp-1">{course.title}</h3>
                                <p className="text-gold-primary text-sm">{course.instructor}</p>
                                <p className="text-light-muted text-sm mt-2 line-clamp-2">{course.description}</p>
                                <div className="flex items-center gap-2 mt-3 text-light-muted text-xs">
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
                                        disabled={deletingId === course.id}
                                    >
                                        {deletingId === course.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 size={16} />}
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
                    <div className="bg-dark-card border border-dark-icon rounded-xl w-full max-w-lg max-h-[90vh] overflow-y-auto custom-scrollbar">
                        <div className="flex justify-between items-center p-6 border-b border-dark-icon sticky top-0 bg-dark-card z-10">
                            <h2 className="text-xl font-semibold text-light-primary">
                                {editingCourse ? 'Edit Course' : 'Add New Course'}
                            </h2>
                            <button onClick={closeModal} className="text-light-muted hover:text-light-primary">
                                <X size={24} />
                            </button>
                        </div>
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Title</label>
                                <input
                                    type="text"
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:ring-2 focus:ring-gold-primary"
                                    required
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Instructor</label>
                                <input
                                    type="text"
                                    value={formData.instructor}
                                    onChange={(e) => setFormData({ ...formData, instructor: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:ring-2 focus:ring-gold-primary"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Description</label>
                                <textarea
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:ring-2 focus:ring-gold-primary h-20 resize-none"
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Duration</label>
                                    <input
                                        type="text"
                                        value={formData.duration}
                                        onChange={(e) => setFormData({ ...formData, duration: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:ring-2 focus:ring-gold-primary"
                                        placeholder="e.g., 8 weeks"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Level</label>
                                    <select
                                        value={formData.level}
                                        onChange={(e) => setFormData({ ...formData, level: e.target.value })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:ring-2 focus:ring-gold-primary"
                                    >
                                        <option value="Beginner">Beginner</option>
                                        <option value="Intermediate">Intermediate</option>
                                        <option value="Advanced">Advanced</option>
                                        <option value="All Levels">All Levels</option>
                                    </select>
                                </div>
                            </div>

                            <ImageUpload
                                label="Course Image"
                                value={formData.imageUrl}
                                onChange={(url) => setFormData({ ...formData, imageUrl: url })}
                                onFileSelect={setImageFile}
                                bucket="course-images"
                            />

                            <div>
                                <label className="block text-sm font-medium text-light-muted mb-1">Enrollment URL</label>
                                <input
                                    type="url"
                                    value={formData.enrollUrl}
                                    onChange={(e) => setFormData({ ...formData, enrollUrl: e.target.value })}
                                    className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:ring-2 focus:ring-gold-primary"
                                    placeholder="https://deen-sphere.vercel.app/..."
                                />
                            </div>
                            <div className="flex items-center gap-3">
                                <input
                                    type="checkbox"
                                    id="isFree"
                                    checked={formData.isFree}
                                    onChange={(e) => setFormData({ ...formData, isFree: e.target.checked })}
                                    className="w-5 h-5 rounded text-gold-primary focus:ring-gold-primary bg-dark-main border-dark-icon"
                                />
                                <label htmlFor="isFree" className="text-light-muted">Free Course</label>
                            </div>
                            {!formData.isFree && (
                                <div>
                                    <label className="block text-sm font-medium text-light-muted mb-1">Price ($)</label>
                                    <input
                                        type="number"
                                        value={formData.price}
                                        onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) || 0 })}
                                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:ring-2 focus:ring-gold-primary"
                                        min="0"
                                    />
                                </div>
                            )}
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="flex-1 py-2 border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon transition-colors"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={submitting}
                                    className="flex-1 flex items-center justify-center gap-2 bg-gold-primary text-dark-main py-2 rounded-lg font-medium hover:bg-gold-dark transition-colors disabled:opacity-50"
                                >
                                    {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : <Save size={18} />}
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
