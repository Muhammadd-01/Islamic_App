import { useState, useEffect } from 'react';
import { User, Lock, Camera, Save, Eye, EyeOff, MessageSquare, RefreshCw } from 'lucide-react';
import { auth } from '../config/firebase';
import { updatePassword, EmailAuthProvider, reauthenticateWithCredential } from 'firebase/auth';
import { settingsApi } from '../services/api';
import { useNotification } from '../components/NotificationSystem';

function AdminProfile() {
    const [currentPassword, setCurrentPassword] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [showCurrentPassword, setShowCurrentPassword] = useState(false);
    const [showNewPassword, setShowNewPassword] = useState(false);
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState({ type: '', text: '' });
    const [profileImage, setProfileImage] = useState(null);
    const [imagePreview, setImagePreview] = useState(null);

    const [whatsappNumber, setWhatsappNumber] = useState('');
    const [waData, setWaData] = useState({ status: 'DISCONNECTED', qrCode: null });
    const [adminData, setAdminData] = useState({ password: '' });
    const [showAdminPassword, setShowAdminPassword] = useState(false);
    const [waLoading, setWaLoading] = useState(false);
    const { notify } = useNotification();

    const user = auth.currentUser;

    useEffect(() => {
        if (user?.photoURL) {
            setImagePreview(user.photoURL);
        }
        fetchWhatsAppStatus();
        fetchAdminData();

        // Poll for WhatsApp status
        const interval = setInterval(fetchWhatsAppStatus, 5000);
        return () => clearInterval(interval);
    }, [user]);

    const fetchAdminData = async () => {
        try {
            const { data } = await settingsApi.getAdminData();
            if (data.success) {
                setAdminData(data.data);
            }
        } catch (error) {
            console.error('Error fetching admin data:', error);
        }
    };

    const fetchWhatsAppStatus = async () => {
        try {
            const { data } = await settingsApi.getWhatsApp();
            if (data.success) {
                setWhatsappNumber(data.settings.number || '');
                setWaData(data.whatsapp);
            }
        } catch (error) {
            console.error('Error fetching WA status:', error);
        }
    };

    const handleWhatsAppUpdate = async (e) => {
        e.preventDefault();
        setWaLoading(true);
        try {
            await settingsApi.updateWhatsApp({ number: whatsappNumber });
            notify.success('System WhatsApp number updated!');
        } catch (error) {
            notify.error('Failed to update WhatsApp number');
        } finally {
            setWaLoading(false);
        }
    };

    const handleWAReset = async () => {
        if (!window.confirm('Are you sure you want to reset the WhatsApp session?')) return;
        setWaLoading(true);
        try {
            await settingsApi.resetWhatsApp();
            notify.success('WhatsApp session reset initiated');
            fetchWhatsAppStatus();
        } catch (error) {
            notify.error('Failed to reset WhatsApp session');
        } finally {
            setWaLoading(false);
        }
    };

    const handlePasswordChange = async (e) => {
        e.preventDefault();
        setMessage({ type: '', text: '' });

        if (newPassword !== confirmPassword) {
            setMessage({ type: 'error', text: 'New passwords do not match!' });
            return;
        }

        if (newPassword.length < 6) {
            setMessage({ type: 'error', text: 'Password must be at least 6 characters!' });
            return;
        }

        setLoading(true);
        try {
            // Re-authenticate user
            const credential = EmailAuthProvider.credential(user.email, currentPassword);
            await reauthenticateWithCredential(user, credential);

            // 1. Update Firebase Auth Password
            await updatePassword(user, newPassword);

            // 2. Sync with Firestore for display
            await settingsApi.updateAdminData({ password: newPassword });
            setAdminData(prev => ({ ...prev, password: newPassword }));

            notify.success('Password updated successfully!');
            setCurrentPassword('');
            setNewPassword('');
            setConfirmPassword('');
        } catch (error) {
            console.error('Error updating password:', error);
            if (error.code === 'auth/wrong-password') {
                notify.error('Current password is incorrect!');
            } else {
                notify.error('Failed to update password.');
            }
        } finally {
            setLoading(false);
        }
    };

    const handleImageChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            setProfileImage(file);
            setImagePreview(URL.createObjectURL(file));
        }
    };

    const handleImageUpload = async () => {
        if (!profileImage) return;

        setLoading(true);
        try {
            const formData = new FormData();
            formData.append('image', profileImage);

            const res = await settingsApi.updateAdminProfileImage(formData);

            if (res.data.success) {
                const downloadURL = res.data.url;
                // Update Firebase Auth Profile
                await user.updateProfile({ photoURL: downloadURL });

                // Also update Firestore admin_profile with the image URL
                await settingsApi.updateAdminData({ photoURL: downloadURL });

                setImagePreview(downloadURL);
                notify.success('Profile image updated successfully!');
            }
            setProfileImage(null);
        } catch (error) {
            console.error('Error uploading image:', error);
            notify.error('Failed to upload image. Please check your Supabase connection.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-8">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold text-light-primary">Admin Profile</h1>
            </div>

            {/* Message */}
            {message.text && (
                <div className={`p-4 rounded-lg ${message.type === 'success' ? 'bg-green-500/20 text-green-400' : 'bg-red-500/20 text-red-400'}`}>
                    {message.text}
                </div>
            )}

            <div className="grid gap-8 lg:grid-cols-2">
                {/* Profile Image Section */}
                <div className="bg-dark-card rounded-xl border border-dark-icon p-6">
                    <h2 className="text-lg font-semibold text-light-primary mb-6 flex items-center gap-2">
                        <Camera size={20} className="text-gold-primary" />
                        Profile Image
                    </h2>

                    <div className="flex flex-col items-center gap-6">
                        <div className="relative">
                            <div className="w-32 h-32 rounded-full bg-dark-icon overflow-hidden border-4 border-gold-primary/30">
                                {imagePreview ? (
                                    <img src={imagePreview} alt="Profile" className="w-full h-full object-cover" />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center">
                                        <User size={48} className="text-light-muted" />
                                    </div>
                                )}
                            </div>
                            <label className="absolute bottom-0 right-0 p-2 bg-gold-primary rounded-full cursor-pointer hover:bg-gold-dark transition-colors">
                                <Camera size={16} className="text-dark-main" />
                                <input
                                    type="file"
                                    accept="image/*"
                                    onChange={handleImageChange}
                                    className="hidden"
                                />
                            </label>
                        </div>

                        <div className="text-center">
                            <p className="text-light-primary font-medium">{user?.displayName || 'Admin'}</p>
                            <p className="text-light-muted text-sm">{user?.email}</p>
                        </div>

                        {profileImage && (
                            <button
                                onClick={handleImageUpload}
                                disabled={loading}
                                className="flex items-center gap-2 px-6 py-2 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors disabled:opacity-50"
                            >
                                <Save size={16} />
                                {loading ? 'Uploading...' : 'Save Image'}
                            </button>
                        )}
                    </div>
                </div>

                {/* Admin Panel Login Info (Firestore Sync) */}
                <div className="bg-dark-card rounded-xl border border-dark-icon p-6">
                    <h2 className="text-lg font-semibold text-light-primary mb-6 flex items-center gap-2">
                        <Lock size={20} className="text-gold-primary" />
                        Admin Panel Login Info
                    </h2>

                    <div className="space-y-4">
                        <div>
                            <label className="block text-sm text-light-muted mb-1">Email</label>
                            <div className="p-3 bg-dark-icon rounded-lg text-light-primary border border-dark-icon">
                                {user?.email}
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm text-light-muted mb-1 flex justify-between items-center">
                                <span>Current Password (from Firestore)</span>
                                <button
                                    onClick={() => setShowAdminPassword(!showAdminPassword)}
                                    className="text-gold-primary hover:text-gold-dark transition-colors flex items-center gap-1 text-xs"
                                >
                                    {showAdminPassword ? (
                                        <><EyeOff size={14} /> Hide</>
                                    ) : (
                                        <><Eye size={14} /> Show</>
                                    )}
                                </button>
                            </label>
                            <div className="p-3 bg-dark-icon rounded-lg text-light-primary border border-dark-icon font-mono">
                                {showAdminPassword ? adminData.password : '••••••••'}
                            </div>
                            <p className="mt-2 text-[10px] text-light-muted italic">
                                * This is the password stored in Firestore for your reference.
                            </p>
                        </div>
                    </div>
                </div>

                {/* System WhatsApp Settings */}
                <div className="bg-dark-card rounded-xl border border-dark-icon p-6">
                    <h2 className="text-lg font-semibold text-light-primary mb-6 flex items-center gap-2">
                        <MessageSquare size={20} className="text-gold-primary" />
                        System WhatsApp Notification
                    </h2>

                    <div className="space-y-6">
                        <div className="p-4 rounded-lg bg-dark-main border border-dark-icon">
                            <div className="flex justify-between items-start mb-4">
                                <span className="text-sm text-light-muted">Status</span>
                                <div className="flex items-center gap-2">
                                    <div className={`w-2 h-2 rounded-full ${waData.status === 'CONNECTED' ? 'bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.5)]' : waData.status === 'AUTHENTICATED' ? 'bg-blue-500 animate-pulse' : waData.status === 'QR_READY' ? 'bg-gold-primary animate-pulse' : 'bg-red-500'}`} />
                                    <span className={`text-xs font-bold uppercase ${waData.status === 'CONNECTED' ? 'text-green-500' : waData.status === 'AUTHENTICATED' ? 'text-blue-500' : waData.status === 'QR_READY' ? 'text-gold-primary' : 'text-red-500'}`}>
                                        {waData.status}
                                    </span>
                                </div>
                            </div>

                            {waData.status === 'QR_READY' && waData.qrCode && (
                                <div className="flex flex-col items-center gap-4 py-4 bg-white rounded-lg mb-4">
                                    <img src={waData.qrCode} alt="WhatsApp QR Code" className="w-48 h-48" />
                                    <p className="text-dark-main text-xs font-medium text-center px-4">
                                        Scan this QR code with your WhatsApp app <br /> (Settings {'>'} Linked Devices)
                                    </p>
                                </div>
                            )}

                            {waData.status === 'CONNECTED' && (
                                <div className="flex flex-col items-center gap-2 py-8 text-center">
                                    <div className="w-16 h-16 bg-green-500/10 rounded-full flex items-center justify-center mb-2">
                                        <MessageSquare size={32} className="text-green-500" />
                                    </div>
                                    <p className="text-light-primary font-medium">WhatsApp is Linked!</p>
                                    <p className="text-light-muted text-sm">System messages will be sent from this number.</p>
                                    <button
                                        onClick={handleWAReset}
                                        className="mt-4 text-xs text-red-400 hover:text-red-300 flex items-center gap-1"
                                    >
                                        <RefreshCw size={12} /> Unlink Device
                                    </button>
                                </div>
                            )}

                            {waData.status === 'AUTHENTICATED' && (
                                <div className="flex flex-col items-center gap-2 py-8 text-center">
                                    <div className="w-16 h-16 bg-blue-500/10 rounded-full flex items-center justify-center mb-2">
                                        <RefreshCw size={32} className="text-blue-500 animate-spin" />
                                    </div>
                                    <p className="text-blue-400 font-medium">Authenticated!</p>
                                    <p className="text-light-muted text-sm">Finishing sync... Ready in a moment.</p>
                                    <button
                                        onClick={handleWAReset}
                                        className="mt-4 text-xs text-red-400 hover:text-red-300 flex items-center gap-1"
                                    >
                                        <RefreshCw size={12} /> Force Reset
                                    </button>
                                </div>
                            )}

                            {(waData.status === 'DISCONNECTED' || waData.status === 'INITIALIZING') && (
                                <div className="py-8 text-center text-light-muted">
                                    <RefreshCw className="w-8 h-8 animate-spin mx-auto mb-2 opacity-50" />
                                    <p className="text-sm">Initializing WhatsApp client...</p>
                                </div>
                            )}
                        </div>

                        <form onSubmit={handleWhatsAppUpdate} className="space-y-4">
                            <div>
                                <label className="block text-sm text-light-muted mb-2">System Admin Number</label>
                                <div className="relative">
                                    <input
                                        type="text"
                                        value={whatsappNumber}
                                        onChange={(e) => setWhatsappNumber(e.target.value)}
                                        className="w-full px-4 py-3 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:outline-none focus:border-gold-primary"
                                        placeholder="e.g. +923160212457"
                                        required
                                    />
                                    <MessageSquare size={18} className="absolute right-3 top-1/2 -translate-y-1/2 text-light-muted" />
                                </div>
                                <p className="text-[10px] text-light-muted mt-2">
                                    * This number will be stored as the primary contact for system alerts.
                                </p>
                            </div>

                            <button
                                type="submit"
                                disabled={waLoading}
                                className="w-full flex items-center justify-center gap-2 px-6 py-3 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors disabled:opacity-50 font-bold"
                            >
                                <Save size={16} />
                                {waLoading ? 'Updating...' : 'Update Admin Number'}
                            </button>
                        </form>
                    </div>
                </div>

                {/* Change Password Section */}
                <div className="bg-dark-card rounded-xl border border-dark-icon p-6">
                    <h2 className="text-lg font-semibold text-light-primary mb-6 flex items-center gap-2">
                        <Lock size={20} className="text-gold-primary" />
                        Change Password
                    </h2>

                    <form onSubmit={handlePasswordChange} className="space-y-4">
                        <div>
                            <label className="block text-sm text-light-muted mb-2">Current Password</label>
                            <div className="relative">
                                <input
                                    type={showCurrentPassword ? 'text' : 'password'}
                                    value={currentPassword}
                                    onChange={(e) => setCurrentPassword(e.target.value)}
                                    className="w-full px-4 py-3 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:outline-none focus:border-gold-primary"
                                    required
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-light-muted hover:text-light-primary"
                                >
                                    {showCurrentPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                </button>
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm text-light-muted mb-2">New Password</label>
                            <div className="relative">
                                <input
                                    type={showNewPassword ? 'text' : 'password'}
                                    value={newPassword}
                                    onChange={(e) => setNewPassword(e.target.value)}
                                    className="w-full px-4 py-3 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:outline-none focus:border-gold-primary"
                                    required
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowNewPassword(!showNewPassword)}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-light-muted hover:text-light-primary"
                                >
                                    {showNewPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                </button>
                            </div>
                        </div>

                        <div>
                            <label className="block text-sm text-light-muted mb-2">Confirm New Password</label>
                            <input
                                type="password"
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                className="w-full px-4 py-3 bg-dark-main border border-dark-icon rounded-lg text-light-primary focus:outline-none focus:border-gold-primary"
                                required
                            />
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full flex items-center justify-center gap-2 px-6 py-3 bg-gold-primary text-dark-main rounded-lg hover:bg-gold-dark transition-colors disabled:opacity-50"
                        >
                            <Lock size={16} />
                            {loading ? 'Updating...' : 'Update Password'}
                        </button>
                    </form>
                </div>
            </div>
        </div>
    );
}

export default AdminProfile;
