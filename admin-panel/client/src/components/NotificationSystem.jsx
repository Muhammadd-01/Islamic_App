import { createContext, useContext, useState, useCallback } from 'react';
import { X, CheckCircle, AlertCircle, AlertTriangle, Info } from 'lucide-react';

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

    // Convenience methods
    const notify = {
        success: (message, title) => addNotification({ type: 'success', title, message }),
        error: (message, title) => addNotification({ type: 'error', title, message }),
        warning: (message, title) => addNotification({ type: 'warning', title, message }),
        info: (message, title) => addNotification({ type: 'info', title, message }),
    };

    return (
        <NotificationContext.Provider value={{ notify, addNotification, removeNotification }}>
            {children}
            <NotificationContainer
                notifications={notifications}
                removeNotification={removeNotification}
            />
        </NotificationContext.Provider>
    );
}

// CSS for animation (add to your global CSS or tailwind config)
// @keyframes slide-in {
//   from { transform: translateX(100%); opacity: 0; }
//   to { transform: translateX(0); opacity: 1; }
// }
// .animate-slide-in { animation: slide-in 0.3s ease-out; }
