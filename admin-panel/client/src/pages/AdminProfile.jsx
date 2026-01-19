import { useState, useEffect } from 'react';
import { User, Lock, Camera, Save, Eye, EyeOff } from 'lucide-react';
import { auth } from '../config/firebase';
import { updatePassword, EmailAuthProvider, reauthenticateWithCredential } from 'firebase/auth';
import { getStorage, ref, uploadBytes, getDownloadURL } from 'firebase/storage';

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

    const user = auth.currentUser;

    useEffect(() => {
        if (user?.photoURL) {
            setImagePreview(user.photoURL);
        }
    }, [user]);

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

            // Update password
            await updatePassword(user, newPassword);

            setMessage({ type: 'success', text: 'Password updated successfully!' });
            setCurrentPassword('');
            setNewPassword('');
            setConfirmPassword('');
        } catch (error) {
            console.error('Error updating password:', error);
            if (error.code === 'auth/wrong-password') {
                setMessage({ type: 'error', text: 'Current password is incorrect!' });
            } else {
                setMessage({ type: 'error', text: 'Failed to update password. Please try again.' });
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
            const storage = getStorage();
            const storageRef = ref(storage, `admin-profiles/${user.uid}`);
            await uploadBytes(storageRef, profileImage);
            const downloadURL = await getDownloadURL(storageRef);

            // Update user profile
            await user.updateProfile({ photoURL: downloadURL });

            setMessage({ type: 'success', text: 'Profile image updated successfully!' });
            setProfileImage(null);
        } catch (error) {
            console.error('Error uploading image:', error);
            setMessage({ type: 'error', text: 'Failed to upload image. Please try again.' });
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
