import { createContext, useContext, useState, useCallback } from 'react';
import { X, CheckCircle, AlertCircle, AlertTriangle, Info, HelpCircle } from 'lucide-react';

// Notification types
const NOTIFICATION_TYPES = {
    success: {
        icon: CheckCircle,
        bgColor: 'bg-green-500/20',
        borderColor: 'border-green-500',
        textColor: 'text-green-400',
        iconColor: 'text-green-400'
    },
    error: {
        icon: AlertCircle,
        bgColor: 'bg-red-500/20',
        borderColor: 'border-red-500',
        textColor: 'text-red-400',
        iconColor: 'text-red-400'
    },
    warning: {
        icon: AlertTriangle,
        bgColor: 'bg-yellow-500/20',
        borderColor: 'border-yellow-500',
        textColor: 'text-yellow-400',
        iconColor: 'text-yellow-400'
    },
    info: {
        icon: Info,
        bgColor: 'bg-blue-500/20',
        borderColor: 'border-blue-500',
        textColor: 'text-blue-400',
        iconColor: 'text-blue-400'
    },
    confirm: {
        icon: HelpCircle,
        bgColor: 'bg-gold-500/20',
        borderColor: 'border-gold-primary',
        textColor: 'text-gold-primary',
        iconColor: 'text-gold-primary'
    }
};

// Context for notifications
const NotificationContext = createContext(null);

export function useNotification() {
    const context = useContext(NotificationContext);
    if (!context) {
        throw new Error('useNotification must be used within NotificationProvider');
    }
    return context;
}

// Single Notification Toast Component
function NotificationToast({ notification, onClose }) {
    const config = NOTIFICATION_TYPES[notification.type] || NOTIFICATION_TYPES.info;
    const Icon = config.icon;

    return (
        <div
            className={`flex items-start gap-3 p-4 rounded-lg border ${config.bgColor} ${config.borderColor} shadow-lg backdrop-blur-sm animate-slide-in max-w-sm`}
            role="alert"
        >
            <Icon size={20} className={`${config.iconColor} flex-shrink-0 mt-0.5`} />
            <div className="flex-1 min-w-0">
                {notification.title && (
                    <p className={`font-semibold ${config.textColor}`}>{notification.title}</p>
                )}
                <p className={`text-sm ${notification.title ? 'text-light-muted' : config.textColor}`}>
                    {notification.message}
                </p>
            </div>
            <button
                onClick={onClose}
                className="text-light-muted hover:text-light-primary transition-colors flex-shrink-0"
            >
                <X size={16} />
            </button>
        </div>
    );
}

// Confirmation Dialog Component
function ConfirmationDialog({ isOpen, options, onResolve }) {
    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
            <div className="bg-dark-card border border-dark-icon rounded-2xl max-w-md w-full shadow-2xl overflow-hidden animate-scale-in">
                <div className="p-6">
                    <div className="flex items-center gap-4 mb-4">
                        <div className="p-3 rounded-full bg-gold-primary/10 text-gold-primary">
                            <HelpCircle size={24} />
                        </div>
                        <h3 className="text-xl font-bold text-light-primary">{options.title || 'Confirm Action'}</h3>
                    </div>
                    <p className="text-light-muted text-base leading-relaxed">
                        {options.message || 'Are you sure you want to proceed?'}
                    </p>
                </div>

                <div className="flex gap-3 p-4 bg-dark-icon/20">
                    <button
                        onClick={() => onResolve(false)}
                        className="flex-1 px-4 py-2.5 rounded-xl border border-dark-icon text-light-primary hover:bg-dark-icon/50 transition-all font-medium"
                    >
                        {options.cancelText || 'Cancel'}
                    </button>
                    <button
                        onClick={() => onResolve(true)}
                        className="flex-1 px-4 py-2.5 rounded-xl bg-gold-primary text-dark-main hover:bg-gold-dark transition-all font-bold shadow-lg shadow-gold-primary/20"
                    >
                        {options.confirmText || 'Confirm'}
                    </button>
                </div>
            </div>
        </div>
    );
}

// Notification Container
function NotificationContainer({ notifications, removeNotification }) {
    return (
        <div className="fixed top-4 right-4 z-[100] flex flex-col gap-3 pointer-events-none">
            {notifications.map((notification) => (
                <div key={notification.id} className="pointer-events-auto">
                    <NotificationToast
                        notification={notification}
                        onClose={() => removeNotification(notification.id)}
                    />
                </div>
            ))}
        </div>
    );
}

// Notification Provider
export function NotificationProvider({ children }) {
    const [notifications, setNotifications] = useState([]);
    const [confirmDialog, setConfirmDialog] = useState({ isOpen: false, options: {}, resolve: null });

    const addNotification = useCallback(({ type = 'info', title, message, duration = 5000 }) => {
        const id = Date.now() + Math.random();
        const notification = { id, type, title, message };

        setNotifications((prev) => [...prev, notification]);

        // Auto-remove after duration
        if (duration > 0) {
            setTimeout(() => {
                removeNotification(id);
            }, duration);
        }

        return id;
    }, []);

    const removeNotification = useCallback((id) => {
        setNotifications((prev) => prev.filter((n) => n.id !== id));
    }, []);

    const confirm = useCallback((options = {}) => {
        return new Promise((resolve) => {
            setConfirmDialog({
                isOpen: true,
                options,
                resolve
            });
        });
    }, []);

    const handleConfirmResolve = (result) => {
        if (confirmDialog.resolve) {
            confirmDialog.resolve(result);
        }
        setConfirmDialog({ isOpen: false, options: {}, resolve: null });
    };

    // Convenience methods
    const notify = {
        success: (message, title) => addNotification({ type: 'success', title, message }),
        error: (message, title) => addNotification({ type: 'error', title, message }),
        warning: (message, title) => addNotification({ type: 'warning', title, message }),
        info: (message, title) => addNotification({ type: 'info', title, message }),
        confirm: (options) => confirm(options)
    };

    return (
        <NotificationContext.Provider value={{ notify, addNotification, removeNotification }}>
            {children}
            <NotificationContainer
                notifications={notifications}
                removeNotification={removeNotification}
            />
            <ConfirmationDialog
                isOpen={confirmDialog.isOpen}
                options={confirmDialog.options}
                onResolve={handleConfirmResolve}
            />
        </NotificationContext.Provider>
    );
}

