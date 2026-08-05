import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { formatDate } from '../utils/helpers';
import { MessageSquare, Send, Trash2, User } from 'lucide-react';
import api from '../services/api';

export default function CommentSection({ postId }) {
  const { user } = useAuth();
  const [comments, setComments] = useState([]);
  const [content, setContent] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const fetchComments = async () => {
    try {
      const res = await api.get(`/posts/${postId}/comments`);
      setComments(res.data);
    } catch (err) {
      console.error("Failed to load comments:", err);
    }
  };

  useEffect(() => {
    if (postId) fetchComments();
  }, [postId]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!content.trim() || submitting) return;

    setSubmitting(true);
    try {
      await api.post(`/posts/${postId}/comments`, { content });
      setContent('');
      await fetchComments();
    } catch (err) {
      console.error("Failed to post comment:", err);
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (commentId) => {
    if (!window.confirm("Are you sure you want to delete this comment?")) return;
    try {
      await api.delete(`/comments/${commentId}`);
      setComments(comments.filter(c => c.id !== commentId));
    } catch (err) {
      console.error("Failed to delete comment:", err);
    }
  };

  return (
    <section className="mt-12 pt-8 border-t border-slate-200 dark:border-slate-800 space-y-8">
      
      {/* Header */}
      <div className="flex items-center space-x-2">
        <MessageSquare className="w-5 h-5 text-blue-500" />
        <h3 className="text-lg font-bold text-slate-900 dark:text-white">
          Discussion ({comments.length})
        </h3>
      </div>

      {/* Input Box */}
      {user ? (
        <form onSubmit={handleSubmit} className="glass-card p-4 space-y-3">
          <div className="flex items-center space-x-3">
            <img
              src={user.avatar_url || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80"}
              alt={user.username}
              className="w-8 h-8 rounded-full object-cover"
            />
            <span className="text-xs font-semibold text-slate-900 dark:text-white">
              Comment as <span className="text-blue-500">{user.full_name || user.username}</span>
            </span>
          </div>

          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            rows={3}
            placeholder="What are your thoughts on this article?"
            required
            className="w-full p-3 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
          />

          <div className="flex justify-end">
            <button
              type="submit"
              disabled={submitting || !content.trim()}
              className="inline-flex items-center space-x-1.5 px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white text-xs font-semibold shadow-md shadow-blue-500/20 transition-all"
            >
              <span>{submitting ? "Posting..." : "Post Comment"}</span>
              <Send className="w-3.5 h-3.5" />
            </button>
          </div>
        </form>
      ) : (
        <div className="glass-card p-6 text-center text-xs text-slate-500 dark:text-slate-400 space-y-2">
          <p>Want to join the discussion?</p>
          <a href="/login" className="inline-block font-semibold text-blue-600 dark:text-blue-400 hover:underline">
            Log in or create an account to comment
          </a>
        </div>
      )}

      {/* Comment List */}
      <div className="space-y-4">
        {comments.length === 0 ? (
          <p className="text-center text-xs text-slate-400 py-6">
            No comments yet. Be the first to start the conversation!
          </p>
        ) : (
          comments.map((comment) => (
            <div key={comment.id} className="glass-card p-4 space-y-2">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2.5">
                  <img
                    src={comment.author?.avatar_url || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80"}
                    alt={comment.author?.username}
                    className="w-7 h-7 rounded-full object-cover"
                  />
                  <div>
                    <span className="text-xs font-semibold text-slate-900 dark:text-white">
                      {comment.author?.full_name || comment.author?.username}
                    </span>
                    <span className="text-[10px] text-slate-400 ml-2">
                      {formatDate(comment.created_at)}
                    </span>
                  </div>
                </div>

                {(user && (user.id === comment.author?.id || user.is_admin)) && (
                  <button
                    onClick={() => handleDelete(comment.id)}
                    className="p-1 text-slate-400 hover:text-rose-500 rounded transition-colors"
                    title="Delete comment"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                )}
              </div>

              <p className="text-xs text-slate-700 dark:text-slate-300 pl-9 whitespace-pre-line leading-relaxed">
                {comment.content}
              </p>
            </div>
          ))
        )}
      </div>

    </section>
  );
}
