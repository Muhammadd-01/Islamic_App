import { useEffect, useState } from 'react';
import { Trash2, Loader2, Heart, RefreshCw, Eye, Settings, List } from 'lucide-react';
import { donationsApi } from '../services/api';

function DonationsPage() {
    const [donations, setDonations] = useState([]);
    const [settings, setSettings] = useState({
        'Bank Transfer': { Account: '', Number: '', Bank: '', IBAN: '' },
        'PayPal': { Email: '' },
        'Easypaisa': { Number: '', Name: '' },
        'JazzCash': { Number: '', Name: '' }
    });
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [error, setError] = useState(null);
    const [selectedDonation, setSelectedDonation] = useState(null);
    const [activeTab, setActiveTab] = useState('records'); // 'records' or 'setup'

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            setLoading(true);
            const [donationsRes, settingsRes] = await Promise.all([
                donationsApi.getAll(),
                donationsApi.getSettings()
            ]);
            setDonations(donationsRes.data.donations);
            if (settingsRes.data.settings) {
                // Merge fetched settings with default structure for safety
                setSettings(prev => ({
                    ...prev,
                    ...settingsRes.data.settings
                }));
            }
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to load data');
        } finally {
            setLoading(false);
        }
    };

    const handleSaveSettings = async (e) => {
        e.preventDefault();
        try {
            setSaving(true);
            await donationsApi.updateSettings(settings);
            alert('Settings saved successfully! Mobile app will sync automatically.');
        } catch (err) {
            alert('Failed to save settings: ' + (err.response?.data?.message || err.message));
        } finally {
            setSaving(false);
        }
    };

    const updateSetting = (method, field, value) => {
        setSettings(prev => ({
            ...prev,
            [method]: {
                ...prev[method],
                [field]: value
            }
        }));
    };

    const handleStatusChange = async (donationId, newStatus) => {
        try {
            await donationsApi.updateStatus(donationId, newStatus);
            setDonations(donations.map(d => d.id === donationId ? { ...d, status: newStatus } : d));
        } catch (err) {
            alert('Failed to update status: ' + (err.response?.data?.message || err.message));
        }
    };

    const handleDelete = async (donationId) => {
        if (!confirm('Are you sure you want to delete this donation record?')) {
            return;
        }

        try {
            await donationsApi.delete(donationId);
            setDonations(donations.filter(d => d.id !== donationId));
        } catch (err) {
            alert('Failed to delete donation: ' + (err.response?.data?.message || err.message));
        }
    };

    const getStatusColor = (status) => {
        switch (status) {
            case 'Verified': return 'bg-green-500/20 text-green-400';
            case 'Pending Verification': return 'bg-gold-primary/20 text-gold-primary';
            case 'Rejected': return 'bg-red-500/20 text-red-400';
            default: return 'bg-dark-icon text-light-muted';
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Donation Management</h1>
                    <p className="text-light-muted">Configure accounts and verify community support</p>
                </div>
                <div className="flex bg-dark-card border border-dark-icon p-1 rounded-xl">
                    <button
                        onClick={() => setActiveTab('records')}
                        className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${activeTab === 'records' ? 'bg-gold-primary text-dark-main' : 'text-light-muted hover:text-light-primary'}`}
                    >
                        <List size={18} />
                        Donation Records
                    </button>
                    <button
                        onClick={() => setActiveTab('setup')}
                        className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${activeTab === 'setup' ? 'bg-gold-primary text-dark-main' : 'text-light-muted hover:text-light-primary'}`}
                    >
                        <Settings size={18} />
                        Account Setup
                    </button>
                </div>
            </div>

            {error && (
                <div className="bg-red-500/10 border border-red-500/20 text-red-500 p-4 rounded-lg">
                    {error}
                </div>
            )}

            {activeTab === 'records' ? (
                /* RECORDS TABLE */
                <div className="bg-dark-card border border-dark-icon rounded-xl shadow-lg overflow-hidden">
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-dark-main border-b border-dark-icon">
                                <tr>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Donor</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Amount</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Method</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Status</th>
                                    <th className="px-6 py-4 text-left text-sm font-semibold text-light-muted uppercase tracking-wider">Date</th>
                                    <th className="px-6 py-4 text-right text-sm font-semibold text-light-muted uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-dark-icon">
                                {donations.length === 0 ? (
                                    <tr>
                                        <td colSpan="6" className="px-6 py-8 text-center text-light-muted">No donations found</td>
                                    </tr>
                                ) : (
                                    donations.map((donation) => (
                                        <tr key={donation.id} className="hover:bg-gold-primary/[0.02] transition-colors group">
                                            <td className="px-6 py-4 text-light-primary">
                                                <div className="flex items-center gap-3">
                                                    <div className="w-10 h-10 bg-gold-primary/10 border border-gold-primary/20 rounded-lg flex items-center justify-center">
                                                        <Heart className="w-5 h-5 text-gold-primary" />
                                                    </div>
                                                    <div>
                                                        <p className="font-semibold">{donation.userName}</p>
                                                        <p className="text-xs text-light-muted">{donation.userEmail}</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 font-bold text-light-primary">Rs. {donation.amount?.toLocaleString()}</td>
                                            <td className="px-6 py-4 text-light-primary/80 font-medium">{donation.method}</td>
                                            <td className="px-6 py-4">
                                                <select
                                                    value={donation.status}
                                                    onChange={(e) => handleStatusChange(donation.id, e.target.value)}
                                                    className={`px-3 py-1 rounded-full text-xs font-semibold border-none cursor-pointer outline-none transition-all ${getStatusColor(donation.status)}`}
                                                >
                                                    <option value="Pending Verification" className="bg-dark-card">Pending</option>
                                                    <option value="Verified" className="bg-dark-card">Verified</option>
                                                    <option value="Rejected" className="bg-dark-card">Rejected</option>
                                                </select>
                                            </td>
                                            <td className="px-6 py-4 text-light-muted text-sm">
                                                {donation.timestamp
                                                    ? new Date(donation.timestamp.seconds * 1000).toLocaleDateString()
                                                    : 'N/A'}
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <div className="flex items-center justify-end gap-2">
                                                    <button onClick={() => setSelectedDonation(donation)} className="p-2 text-gold-primary hover:bg-gold-primary/10 rounded-lg transition-all" title="View Details"><Eye className="w-5 h-5" /></button>
                                                    <button onClick={() => handleDelete(donation.id)} className="p-2 text-light-muted hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-all opacity-0 group-hover:opacity-100" title="Delete Record"><Trash2 className="w-5 h-5" /></button>
                                                </div>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            ) : (
                /* SETUP FORM */
                <form onSubmit={handleSaveSettings} className="grid grid-cols-1 md:grid-cols-2 gap-6 pb-12">
                    {/* Bank Transfer Section */}
                    <div className="bg-dark-card border border-dark-icon rounded-xl p-6 space-y-4">
                        <div className="flex items-center gap-2 text-gold-primary mb-4 font-bold border-b border-dark-icon pb-2">
                            <RefreshCw size={18} /> Bank Transfer Details
                        </div>
                        <div className="space-y-3">
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">Account Name</label>
                                <input type="text" value={settings['Bank Transfer'].Account} onChange={(e) => updateSetting('Bank Transfer', 'Account', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="e.g. DeenSphere Foundation" />
                            </div>
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">Account Number</label>
                                <input type="text" value={settings['Bank Transfer'].Number} onChange={(e) => updateSetting('Bank Transfer', 'Number', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="e.g. 1234 5678 9012" />
                            </div>
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">Bank Name</label>
                                <input type="text" value={settings['Bank Transfer'].Bank} onChange={(e) => updateSetting('Bank Transfer', 'Bank', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="e.g. Deen Bank" />
                            </div>
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">IBAN / SWIFT</label>
                                <input type="text" value={settings['Bank Transfer'].IBAN} onChange={(e) => updateSetting('Bank Transfer', 'IBAN', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="PK00DEEN..." />
                            </div>
                        </div>
                    </div>

                    {/* Easypaisa Section */}
                    <div className="bg-dark-card border border-dark-icon rounded-xl p-6 space-y-4">
                        <div className="flex items-center gap-2 text-gold-primary mb-4 font-bold border-b border-dark-icon pb-2">
                            <span className="w-5 h-5 flex items-center justify-center bg-green-500 rounded text-[10px] text-white">EP</span> Easypaisa Details
                        </div>
                        <div className="space-y-3">
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">Mobile Number</label>
                                <input type="text" value={settings['Easypaisa'].Number} onChange={(e) => updateSetting('Easypaisa', 'Number', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="03XXXXXXXXX" />
                            </div>
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">Account Holder Name</label>
                                <input type="text" value={settings['Easypaisa'].Name} onChange={(e) => updateSetting('Easypaisa', 'Name', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="Name on Easypaisa" />
                            </div>
                        </div>
                    </div>

                    {/* JazzCash Section */}
                    <div className="bg-dark-card border border-dark-icon rounded-xl p-6 space-y-4">
                        <div className="flex items-center gap-2 text-gold-primary mb-4 font-bold border-b border-dark-icon pb-2">
                            <span className="w-5 h-5 flex items-center justify-center bg-red-500 rounded text-[10px] text-white">JC</span> JazzCash Details
                        </div>
                        <div className="space-y-3">
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">Mobile Number</label>
                                <input type="text" value={settings['JazzCash'].Number} onChange={(e) => updateSetting('JazzCash', 'Number', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="03XXXXXXXXX" />
                            </div>
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">Account Holder Name</label>
                                <input type="text" value={settings['JazzCash'].Name} onChange={(e) => updateSetting('JazzCash', 'Name', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="Name on JazzCash" />
                            </div>
                        </div>
                    </div>

                    {/* PayPal Section */}
                    <div className="bg-dark-card border border-dark-icon rounded-xl p-6 space-y-4">
                        <div className="flex items-center gap-2 text-gold-primary mb-4 font-bold border-b border-dark-icon pb-2">
                            PayPal Details
                        </div>
                        <div className="space-y-3">
                            <div>
                                <label className="text-xs text-light-muted uppercase font-bold">PayPal Email</label>
                                <input type="email" value={settings['PayPal'].Email} onChange={(e) => updateSetting('PayPal', 'Email', e.target.value)} className="w-full mt-1 bg-dark-main border border-dark-icon rounded-lg p-2 text-light-primary focus:ring-1 focus:ring-gold-primary outline-none" placeholder="donate@example.com" />
                            </div>
                        </div>
                    </div>

                    <div className="md:col-span-2 flex justify-end">
                        <button
                            type="submit"
                            disabled={saving}
                            className="flex items-center gap-2 px-8 py-3 bg-gold-primary text-dark-main font-bold rounded-xl hover:bg-gold-dark transition-all disabled:opacity-50"
                        >
                            {saving ? <Loader2 className="animate-spin" size={20} /> : 'Save & Sync Details'}
                        </button>
                    </div>
                </form>
            )}

            {/* Modal for detail view */}
            {selectedDonation && (
                <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4" onClick={() => setSelectedDonation(null)}>
                    <div className="bg-dark-card border border-dark-icon rounded-xl max-w-lg w-full max-h-[80vh] overflow-y-auto shadow-2xl p-6" onClick={e => e.stopPropagation()}>
                        <div className="flex items-center justify-between border-b border-dark-icon pb-4 mb-4">
                            <h2 className="text-xl font-bold text-light-primary">Donation Details</h2>
                            <button onClick={() => setSelectedDonation(null)} className="p-2 hover:bg-dark-icon rounded-lg text-light-muted">✕</button>
                        </div>
                        <div className="space-y-4">
                            <div className="p-4 bg-dark-main border border-dark-icon rounded-xl space-y-2">
                                <p className="text-xs text-light-muted uppercase font-bold">Donor</p>
                                <p className="text-light-primary font-bold text-lg">{selectedDonation.userName}</p>
                                <p className="text-light-primary/70">{selectedDonation.userEmail}</p>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div className="p-4 bg-dark-main border border-dark-icon rounded-xl text-center">
                                    <p className="text-xs text-light-muted uppercase font-bold mb-1">Amount</p>
                                    <p className="text-xl font-black text-gold-primary">Rs. {selectedDonation.amount}</p>
                                </div>
                                <div className="p-4 bg-dark-main border border-dark-icon rounded-xl text-center">
                                    <p className="text-xs text-light-muted uppercase font-bold mb-1">Method</p>
                                    <p className="text-lg font-bold text-light-primary">{selectedDonation.method}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}

export default DonationsPage;
