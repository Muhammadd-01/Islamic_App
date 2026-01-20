import { useState, useRef } from 'react';
import { Upload, X, Image as ImageIcon, Loader2 } from 'lucide-react';

/**
 * Reusable Image Upload Component for Admin Panel
 * Supports both file upload from device and URL input
 */
export default function ImageUpload({
    value,
    onChange,
    onFileSelect,
    label = 'Image',
    placeholder = 'Enter image URL or upload',
    bucket = 'images'
}) {
    const [preview, setPreview] = useState(null);
    const [uploading, setUploading] = useState(false);
    const [mode, setMode] = useState('file'); // 'file' or 'url'
    const fileInputRef = useRef(null);

    const handleFileChange = async (e) => {
        const file = e.target.files?.[0];
        if (!file) return;

        // Show preview
        const reader = new FileReader();
        reader.onload = (e) => setPreview(e.target.result);
        reader.readAsDataURL(file);

        // Pass file to parent for upload
        if (onFileSelect) {
            onFileSelect(file);
        }
    };

    const handleUrlChange = (e) => {
        const url = e.target.value;
        onChange(url);
        setPreview(url);
    };

    const clearImage = () => {
        setPreview(null);
        onChange('');
        if (fileInputRef.current) {
            fileInputRef.current.value = '';
        }
        if (onFileSelect) {
            onFileSelect(null);
        }
    };

    return (
        <div className="space-y-2">
            <label className="block text-sm font-medium text-light-primary">{label}</label>

            {/* Mode Toggle */}
            <div className="flex gap-2 mb-2">
                <button
                    type="button"
                    onClick={() => setMode('file')}
                    className={`flex-1 px-3 py-1.5 text-sm rounded-lg transition-colors ${mode === 'file'
                            ? 'bg-gold-primary text-dark-main'
                            : 'bg-dark-icon text-light-muted hover:bg-dark-icon/80'
                        }`}
                >
                    📁 From Device
                </button>
                <button
                    type="button"
                    onClick={() => setMode('url')}
                    className={`flex-1 px-3 py-1.5 text-sm rounded-lg transition-colors ${mode === 'url'
                            ? 'bg-gold-primary text-dark-main'
                            : 'bg-dark-icon text-light-muted hover:bg-dark-icon/80'
                        }`}
                >
                    🔗 URL
                </button>
            </div>

            {mode === 'file' ? (
                <div className="relative">
                    <input
                        ref={fileInputRef}
                        type="file"
                        accept="image/*"
                        onChange={handleFileChange}
                        className="hidden"
                        id={`image-upload-${label}`}
                    />
                    <label
                        htmlFor={`image-upload-${label}`}
                        className="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-dark-icon rounded-lg cursor-pointer hover:border-gold-primary transition-colors bg-dark-main"
                    >
                        {preview ? (
                            <div className="relative w-full h-full">
                                <img
                                    src={preview}
                                    alt="Preview"
                                    className="w-full h-full object-cover rounded-lg"
                                />
                                <button
                                    type="button"
                                    onClick={(e) => { e.preventDefault(); clearImage(); }}
                                    className="absolute top-2 right-2 p-1 bg-red-500 rounded-full hover:bg-red-600"
                                >
                                    <X size={14} className="text-white" />
                                </button>
                            </div>
                        ) : (
                            <div className="flex flex-col items-center text-light-muted">
                                <Upload size={24} className="mb-2" />
                                <span className="text-sm">Click to upload image</span>
                                <span className="text-xs text-light-muted/60">PNG, JPG up to 5MB</span>
                            </div>
                        )}
                    </label>
                </div>
            ) : (
                <div className="space-y-2">
                    <input
                        type="url"
                        value={value || ''}
                        onChange={handleUrlChange}
                        placeholder={placeholder}
                        className="w-full px-4 py-2 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:outline-none focus:border-gold-primary"
                    />
                    {preview && preview.startsWith('http') && (
                        <div className="relative h-32 rounded-lg overflow-hidden">
                            <img
                                src={preview}
                                alt="Preview"
                                className="w-full h-full object-cover"
                                onError={() => setPreview(null)}
                            />
                            <button
                                type="button"
                                onClick={clearImage}
                                className="absolute top-2 right-2 p-1 bg-red-500 rounded-full hover:bg-red-600"
                            >
                                <X size={14} className="text-white" />
                            </button>
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}
