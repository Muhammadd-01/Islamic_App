import { useState } from 'react';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../config/firebase';
import { useNavigate } from 'react-router-dom';
import { Lock, Mail, Loader2 } from 'lucide-react';

export default function Login() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            await signInWithEmailAndPassword(auth, email, password);
            navigate('/');
        } catch (err) {
            console.error(err);
            setError('Invalid email or password');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-dark-main flex items-center justify-center p-4">
            <div className="bg-dark-card border border-dark-icon rounded-xl shadow-lg w-full max-w-md p-8">
                <div className="text-center mb-8">
                    <div className="w-16 h-16 mx-auth mb-4 flex items-center justify-center">
                        <img src="/deensphere_logo.png" alt="DeenSphere" className="w-16 h-16" />
                    </div>
                    <h1 className="text-2xl font-bold text-light-primary font-outfit">Admin Login</h1>
                    <p className="text-light-muted">Sign in to manage DeenSphere</p>
                </div>

                {error && (
                    <div className="bg-error/10 text-error p-3 rounded-lg mb-6 text-sm flex items-center gap-2">
                        <span>⚠️</span> {error}
                    </div>
                )}

                <form onSubmit={handleLogin} className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-light-muted mb-1">Email Address</label>
                        <div className="relative">
                            <Mail className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                            <input
                                type="email"
                                required
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                className="w-full pl-10 pr-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary focus:border-gold-primary transition-all outline-none"
                                placeholder="superadmin@islamicapp.com"
                            />
                        </div>
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-light-muted mb-1">Password</label>
                        <div className="relative">
                            <Lock className="absolute left-3 top-2.5 w-5 h-5 text-light-muted" />
                            <input
                                type="password"
                                required
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full pl-10 pr-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary focus:border-gold-primary transition-all outline-none"
                                placeholder="••••••••"
                            />
                        </div>
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full bg-gold-primary text-iconBlack py-2.5 rounded-lg hover:bg-gold-highlight transition-colors font-medium flex items-center justify-center gap-2 shadow-md"
                    >
                        {loading ? (
                            <Loader2 className="w-5 h-5 animate-spin" />
                        ) : (
                            'Sign In'
                        )}
                    </button>
                </form>
            </div>
        </div>
    );
}
