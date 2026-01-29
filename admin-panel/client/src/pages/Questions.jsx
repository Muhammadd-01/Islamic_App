import { useEffect, useState } from 'react';
import { Trash2, Loader2, MessageCircle, RefreshCw, Send } from 'lucide-react';
import { questionsApi } from '../services/api';

function QuestionsPage() {
    const [questions, setQuestions] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [statusFilter, setStatusFilter] = useState('');
    const [answeringId, setAnsweringId] = useState(null);
    const [answerText, setAnswerText] = useState('');

    useEffect(() => {
        fetchQuestions();
    }, [statusFilter]);

    const fetchQuestions = async () => {
        try {
            setLoading(true);
            const { data } = await questionsApi.getAll({ status: statusFilter });
            setQuestions(data.questions);
        } catch (err) {
            setError(err.response?.data?.message || 'Failed to load questions');
        } finally {
            setLoading(false);
        }
    };

    const handleAnswer = async (questionId) => {
        if (!answerText.trim()) {
            alert('Please enter an answer');
            return;
        }

        try {
            await questionsApi.answer(questionId, answerText);
            setAnsweringId(null);
            setAnswerText('');
            fetchQuestions();
        } catch (err) {
            alert('Failed to submit answer: ' + (err.response?.data?.message || err.message));
        }
    };

    const handleDelete = async (questionId) => {
        if (!confirm('Are you sure you want to delete this question?')) {
            return;
        }

        try {
            await questionsApi.delete(questionId);
            setQuestions(questions.filter(q => q.id !== questionId));
        } catch (err) {
            alert('Failed to delete: ' + (err.response?.data?.message || err.message));
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-light-primary">Community Questions</h1>
                    <p className="text-light-muted">Answer questions from app users</p>
                </div>
                <div className="flex gap-3">
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="px-4 py-2 bg-dark-card border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none transition-all hover:border-gold-primary/30"
                    >
                        <option value="">All Questions</option>
                        <option value="pending">Pending</option>
                        <option value="answered">Answered</option>
                    </select>
                    <button
                        onClick={fetchQuestions}
                        className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main font-medium rounded-lg hover:bg-gold-dark transition-all shadow-[0_0_15px_rgba(251,191,36,0.2)]"
                    >
                        <RefreshCw size={18} />
                        Refresh
                    </button>
                </div>
            </div>

            {error && (
                <div className="bg-red-500/10 border border-red-500/20 text-red-500 p-4 rounded-lg">{error}</div>
            )}

            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-gold-primary" />
                </div>
            ) : (
                <div className="space-y-4">
                    {questions.length === 0 ? (
                        <div className="bg-dark-card border border-dark-icon rounded-xl p-8 text-center text-light-muted">
                            No questions found
                        </div>
                    ) : (
                        questions.map((question) => (
                            <div key={question.id} className="bg-dark-card border border-dark-icon rounded-xl p-6 hover:border-gold-primary/30 transition-all group">
                                <div className="flex items-start justify-between gap-4">
                                    <div className="flex items-start gap-4 flex-1">
                                        <div className="w-10 h-10 bg-gold-primary/10 rounded-full flex items-center justify-center flex-shrink-0">
                                            <MessageCircle className="w-5 h-5 text-gold-primary" />
                                        </div>
                                        <div className="flex-1">
                                            <div className="flex items-center gap-2 mb-2">
                                                <span className="font-medium text-light-primary">{question.userName || 'Anonymous'}</span>
                                                <span className="text-xs text-light-muted">
                                                    {question.createdAt ? new Date(question.createdAt).toLocaleDateString() : ''}
                                                </span>
                                                <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${question.status === 'answered'
                                                    ? 'bg-green-500/20 text-green-400'
                                                    : 'bg-gold-primary/20 text-gold-primary'
                                                    }`}>
                                                    {question.status || 'pending'}
                                                </span>
                                            </div>
                                            <p className="text-light-primary mb-4">{question.question}</p>

                                            {question.answer && (
                                                <div className="bg-green-500/10 border-l-4 border-green-400 p-4 rounded-r-lg">
                                                    <p className="text-sm text-green-400/80 mb-1 font-medium">Answer:</p>
                                                    <p className="text-light-primary">{question.answer}</p>
                                                </div>
                                            )}

                                            {question.status !== 'answered' && answeringId === question.id && (
                                                <div className="mt-4">
                                                    <textarea
                                                        autoFocus
                                                        value={answerText}
                                                        onChange={(e) => setAnswerText(e.target.value)}
                                                        placeholder="Type your answer..."
                                                        className="w-full px-4 py-3 bg-dark-main border border-dark-icon text-light-primary rounded-lg focus:ring-2 focus:ring-gold-primary outline-none transition-all hover:border-gold-primary/30"
                                                        rows="3"
                                                    />
                                                    <div className="flex gap-2 mt-2">
                                                        <button
                                                            onClick={() => {
                                                                setAnsweringId(null);
                                                                setAnswerText('');
                                                            }}
                                                            className="px-4 py-2 bg-dark-main border border-dark-icon text-light-muted rounded-lg hover:bg-dark-icon transition-all"
                                                        >
                                                            Cancel
                                                        </button>
                                                        <button
                                                            onClick={() => handleAnswer(question.id)}
                                                            className="flex items-center gap-2 px-4 py-2 bg-gold-primary text-dark-main font-medium rounded-lg hover:bg-gold-dark transition-all"
                                                        >
                                                            <Send size={16} />
                                                            Submit Answer
                                                        </button>
                                                    </div>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        {question.status !== 'answered' && answeringId !== question.id && (
                                            <button
                                                onClick={() => {
                                                    setAnsweringId(question.id);
                                                    setAnswerText('');
                                                }}
                                                className="px-3 py-1.5 bg-gold-primary text-dark-main text-sm font-medium rounded-lg hover:bg-gold-dark transition-all"
                                            >
                                                Answer
                                            </button>
                                        )}
                                        <button
                                            onClick={() => handleDelete(question.id)}
                                            className="p-2 text-light-muted hover:text-red-400 hover:bg-red-400/10 rounded-lg transition-all opacity-0 group-hover:opacity-100"
                                        >
                                            <Trash2 className="w-5 h-5" />
                                        </button>
                                    </div>
                                </div>
                            </div>
                        ))
                    )}
                </div>
            )}

            <div className="text-sm text-light-muted">
                Showing {questions.length} questions
            </div>
        </div>
    );
}

export default QuestionsPage;
