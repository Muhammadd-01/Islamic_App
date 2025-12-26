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
                    <h1 className="text-2xl font-bold text-gray-800">Community Questions</h1>
                    <p className="text-gray-500">Answer questions from app users</p>
                </div>
                <div className="flex gap-3">
                    <select
                        value={statusFilter}
                        onChange={(e) => setStatusFilter(e.target.value)}
                        className="px-4 py-2 bg-white border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500"
                    >
                        <option value="">All Questions</option>
                        <option value="pending">Pending</option>
                        <option value="answered">Answered</option>
                    </select>
                    <button
                        onClick={fetchQuestions}
                        className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 transition-colors"
                    >
                        <RefreshCw size={18} />
                        Refresh
                    </button>
                </div>
            </div>

            {error && (
                <div className="bg-red-50 text-red-600 p-4 rounded-lg">{error}</div>
            )}

            {loading ? (
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-primary-500" />
                </div>
            ) : (
                <div className="space-y-4">
                    {questions.length === 0 ? (
                        <div className="bg-white rounded-xl p-8 text-center text-gray-500">
                            No questions found
                        </div>
                    ) : (
                        questions.map((question) => (
                            <div key={question.id} className="bg-white rounded-xl shadow-sm p-6">
                                <div className="flex items-start justify-between gap-4">
                                    <div className="flex items-start gap-4 flex-1">
                                        <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center flex-shrink-0">
                                            <MessageCircle className="w-5 h-5 text-primary-600" />
                                        </div>
                                        <div className="flex-1">
                                            <div className="flex items-center gap-2 mb-2">
                                                <span className="font-medium">{question.userName || 'Anonymous'}</span>
                                                <span className="text-xs text-gray-400">
                                                    {question.createdAt ? new Date(question.createdAt).toLocaleDateString() : ''}
                                                </span>
                                                <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${question.status === 'answered'
                                                        ? 'bg-green-100 text-green-700'
                                                        : 'bg-yellow-100 text-yellow-700'
                                                    }`}>
                                                    {question.status || 'pending'}
                                                </span>
                                            </div>
                                            <p className="text-gray-800 mb-4">{question.question}</p>

                                            {question.answer && (
                                                <div className="bg-green-50 border-l-4 border-green-500 p-4 rounded-r-lg">
                                                    <p className="text-sm text-gray-600 mb-1 font-medium">Answer:</p>
                                                    <p className="text-gray-800">{question.answer}</p>
                                                </div>
                                            )}

                                            {question.status !== 'answered' && answeringId === question.id && (
                                                <div className="mt-4">
                                                    <textarea
                                                        value={answerText}
                                                        onChange={(e) => setAnswerText(e.target.value)}
                                                        placeholder="Type your answer..."
                                                        className="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-primary-500"
                                                        rows="3"
                                                    />
                                                    <div className="flex gap-2 mt-2">
                                                        <button
                                                            onClick={() => {
                                                                setAnsweringId(null);
                                                                setAnswerText('');
                                                            }}
                                                            className="px-4 py-2 border rounded-lg hover:bg-gray-50"
                                                        >
                                                            Cancel
                                                        </button>
                                                        <button
                                                            onClick={() => handleAnswer(question.id)}
                                                            className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
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
                                                className="px-3 py-1.5 bg-primary-500 text-white text-sm rounded-lg hover:bg-primary-600"
                                            >
                                                Answer
                                            </button>
                                        )}
                                        <button
                                            onClick={() => handleDelete(question.id)}
                                            className="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors"
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

            <div className="text-sm text-gray-500">
                Showing {questions.length} questions
            </div>
        </div>
    );
}

export default QuestionsPage;
