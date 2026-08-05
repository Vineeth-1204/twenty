import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { 
  Calendar, Clock, Eye, User, Share2, Tag as TagIcon, 
  ArrowLeft, Check 
} from 'lucide-react';
import api from '../services/api';
import { getImageUrl, formatDate, calculateReadingTime } from '../utils/helpers';
import CommentSection from '../components/CommentSection';
import BlogCard from '../components/BlogCard';

export default function BlogDetail() {
  const { slug } = useParams();
  const [post, setPost] = useState(null);
  const [relatedPosts, setRelatedPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    const fetchPostData = async () => {
      setLoading(true);
      try {
        const res = await api.get(`/posts/${slug}`);
        setPost(res.data);

        // Fetch related posts by category
        if (res.data.category?.slug) {
          const relRes = await api.get(`/posts?category=${res.data.category.slug}&size=3`);
          setRelatedPosts((relRes.data.items || []).filter(p => p.id !== res.data.id));
        }
      } catch (err) {
        console.error("Failed to load article:", err);
      } finally {
        setLoading(false);
      }
    };

    if (slug) fetchPostData();
  }, [slug]);

  const handleShare = () => {
    navigator.clipboard.writeText(window.location.href);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-16 space-y-6 animate-pulse">
        <div className="h-4 w-24 bg-slate-200 dark:bg-slate-800 rounded" />
        <div className="h-10 w-3/4 bg-slate-200 dark:bg-slate-800 rounded" />
        <div className="h-80 w-full bg-slate-200 dark:bg-slate-800 rounded-3xl" />
        <div className="space-y-3">
          <div className="h-4 w-full bg-slate-200 dark:bg-slate-800 rounded" />
          <div className="h-4 w-5/6 bg-slate-200 dark:bg-slate-800 rounded" />
          <div className="h-4 w-4/5 bg-slate-200 dark:bg-slate-800 rounded" />
        </div>
      </div>
    );
  }

  if (!post) {
    return (
      <div className="max-w-md mx-auto my-20 p-8 glass-card text-center space-y-4">
        <h2 className="text-xl font-bold text-slate-900 dark:text-white">Article Not Found</h2>
        <p className="text-xs text-slate-500">The requested article could not be located or has been removed.</p>
        <Link to="/" className="inline-block px-4 py-2 bg-blue-600 text-white rounded-xl text-xs font-semibold">
          Back to Homepage
        </Link>
      </div>
    );
  }

  return (
    <article className="max-w-4xl mx-auto px-4 sm:px-6 py-10 space-y-10">
      
      {/* Back Button */}
      <Link
        to="/"
        className="inline-flex items-center space-x-2 text-xs font-semibold text-slate-600 dark:text-slate-400 hover:text-blue-600 transition-colors"
      >
        <ArrowLeft className="w-4 h-4" />
        <span>Back to Articles</span>
      </Link>

      {/* Article Header */}
      <header className="space-y-4">
        
        {/* Category & Stats */}
        <div className="flex flex-wrap items-center gap-3 text-xs text-slate-500 dark:text-slate-400">
          {post.category && (
            <span className="px-3 py-1 rounded-full text-xs font-semibold bg-blue-100 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400">
              {post.category.name}
            </span>
          )}
          <span>•</span>
          <span className="flex items-center space-x-1">
            <Calendar className="w-3.5 h-3.5" />
            <span>{formatDate(post.created_at)}</span>
          </span>
          <span>•</span>
          <span className="flex items-center space-x-1">
            <Clock className="w-3.5 h-3.5" />
            <span>{calculateReadingTime(post.content)}</span>
          </span>
          <span>•</span>
          <span className="flex items-center space-x-1">
            <Eye className="w-3.5 h-3.5" />
            <span>{post.views_count || 0} views</span>
          </span>
        </div>

        {/* Title */}
        <h1 className="text-2xl sm:text-4xl font-extrabold text-slate-900 dark:text-white leading-tight">
          {post.title}
        </h1>

        {/* Subtitle / Summary */}
        {post.summary && (
          <p className="text-sm sm:text-base text-slate-600 dark:text-slate-300 leading-relaxed font-normal">
            {post.summary}
          </p>
        )}

        {/* Author Header Row */}
        <div className="pt-4 flex items-center justify-between border-t border-slate-200 dark:border-slate-800">
          <div className="flex items-center space-x-3">
            <img
              src={post.author?.avatar_url || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80"}
              alt={post.author?.full_name || post.author?.username}
              className="w-10 h-10 rounded-full object-cover border border-slate-200 dark:border-slate-700"
            />
            <div>
              <h4 className="text-xs font-bold text-slate-900 dark:text-white">
                {post.author?.full_name || post.author?.username}
              </h4>
              <p className="text-[11px] text-slate-500">{post.author?.bio || "Author & Contributor"}</p>
            </div>
          </div>

          <button
            onClick={handleShare}
            className="flex items-center space-x-1.5 px-3 py-1.5 rounded-xl border border-slate-200 dark:border-slate-800 text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
          >
            {copied ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Share2 className="w-3.5 h-3.5" />}
            <span>{copied ? "Link Copied!" : "Share"}</span>
          </button>
        </div>

      </header>

      {/* Cover Image */}
      {post.cover_image && (
        <div className="rounded-3xl overflow-hidden aspect-[16/9] shadow-xl border border-slate-200/80 dark:border-slate-800">
          <img
            src={getImageUrl(post.cover_image)}
            alt={post.title}
            className="w-full h-full object-cover"
          />
        </div>
      )}

      {/* Article Markdown Content Body */}
      <div className="prose dark:prose-invert max-w-none prose-slate prose-headings:font-serif prose-headings:font-bold prose-a:text-blue-600 prose-img:rounded-2xl text-sm leading-relaxed">
        <ReactMarkdown remarkPlugins={[remarkGfm]}>
          {post.content}
        </ReactMarkdown>
      </div>

      {/* Tag Chips */}
      {post.tags && post.tags.length > 0 && (
        <div className="pt-6 border-t border-slate-200 dark:border-slate-800 flex items-center space-x-2">
          <TagIcon className="w-4 h-4 text-blue-500" />
          <div className="flex flex-wrap gap-2">
            {post.tags.map((tag) => (
              <Link
                key={tag.id}
                to={`/?tag=${tag.slug}`}
                className="px-3 py-1 rounded-lg bg-slate-100 dark:bg-slate-800 text-xs font-medium text-slate-700 dark:text-slate-300 hover:bg-blue-50 dark:hover:bg-blue-950/40 hover:text-blue-600 transition-colors"
              >
                #{tag.name}
              </Link>
            ))}
          </div>
        </div>
      )}

      {/* Comment Section */}
      <CommentSection postId={post.id} />

      {/* Related Articles */}
      {relatedPosts.length > 0 && (
        <section className="pt-10 border-t border-slate-200 dark:border-slate-800 space-y-6">
          <h3 className="text-lg font-bold text-slate-900 dark:text-white">Related Articles</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {relatedPosts.map((relPost) => (
              <BlogCard key={relPost.id} post={relPost} />
            ))}
          </div>
        </section>
      )}

    </article>
  );
}
