import { useState, useRef } from 'react';
import { Upload, X, FileText, Music, Loader2 } from 'lucide-react';

export default function FileUpload({ label, value, onChange, onFileSelect, accept = "*", icon: Icon = Upload, bucket = 'uploads' }) {
    const [dragging, setDragging] = useState(false);
    const fileInputRef = useRef(null);

    const handleFileChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            onFileSelect(file);
            // Create a preview URL if it's an image, or just show the filename
            onChange(file.name);
        }
    };

    const clearFile = () => {
        onFileSelect(null);
        onChange('');
        if (fileInputRef.current) fileInputRef.current.value = '';
    };

    return (
        <div>
            <label className="block text-sm font-medium text-light-muted mb-1">{label}</label>
            <div
                onDragOver={(e) => { e.preventDefault(); setDragging(true); }}
                onDragLeave={() => setDragging(false)}
                onDrop={(e) => {
                    e.preventDefault();
                    setDragging(false);
                    const file = e.dataTransfer.files[0];
                    if (file) {
                        onFileSelect(file);
                        onChange(file.name);
                    }
                }}
                className={`relative border-2 border-dashed rounded-lg p-4 transition-colors ${dragging ? 'border-gold-primary bg-gold-primary/5' : 'border-dark-icon hover:border-gold-primary/50'
                    }`}
            >
                {value ? (
                    <div className="flex items-center justify-between bg-dark-main p-2 rounded border border-dark-icon">
                        <div className="flex items-center gap-2 overflow-hidden">
                            <Icon size={18} className="text-gold-primary flex-shrink-0" />
                            <span className="text-sm text-light-primary truncate">{value}</span>
                        </div>
                        <button
                            type="button"
                            onClick={clearFile}
                            className="p-1 hover:bg-red-500/10 text-red-400 rounded transition-colors"
                        >
                            <X size={16} />
                        </button>
                    </div>
                ) : (
                    <div
                        onClick={() => fileInputRef.current?.click()}
                        className="flex flex-col items-center justify-center py-2 cursor-pointer"
                    >
                        <Icon size={24} className="text-light-muted mb-2" />
                        <p className="text-xs text-light-muted">Click or drag {label.toLowerCase()}</p>
                    </div>
                )}
                <input
                    ref={fileInputRef}
                    type="file"
                    accept={accept}
                    onChange={handleFileChange}
                    className="hidden"
                />
            </div>
        </div>
    );
}
