import React from 'react';
import { Link } from 'react-router-dom';
import { Clock, Eye, Calendar, User } from 'lucide-react';
import { getImageUrl, formatDate, calculateReadingTime } from '../utils/helpers';

export default function BlogCard({ post }) {
  if (!post) return null;

  return (
    <article className="glass-card flex flex-col overflow-hidden group">
      
      {/* Cover Image Container */}
      <Link to={`/post/${post.slug}`} className="relative aspect-[16/9] overflow-hidden bg-slate-200 dark:bg-slate-800">
        <img
          src={getImageUrl(post.cover_image)}
          alt={post.title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500 ease-out"
        />
        {post.category && (
          <span className="absolute top-3 left-3 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-white/90 dark:bg-slate-900/90 text-blue-600 dark:text-blue-400 backdrop-blur-md shadow-sm border border-white/20">
            {post.category.name}
          </span>
        )}
      </Link>

      {/* Content Container */}
      <div className="p-5 flex-1 flex flex-col justify-between">
        <div className="space-y-2">
          
          {/* Post Meta */}
          <div className="flex items-center space-x-3 text-[11px] text-slate-500 dark:text-slate-400">
            <span className="flex items-center space-x-1">
              <Calendar className="w-3 h-3" />
              <span>{formatDate(post.created_at)}</span>
            </span>
            <span>•</span>
            <span className="flex items-center space-x-1">
              <Clock className="w-3 h-3" />
              <span>{calculateReadingTime(post.content)}</span>
            </span>
          </div>

          {/* Title */}
          <h3 className="text-base font-bold text-slate-900 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors line-clamp-2 leading-snug">
            <Link to={`/post/${post.slug}`}>
              {post.title}
            </Link>
          </h3>

          {/* Summary */}
          <p className="text-xs text-slate-600 dark:text-slate-400 line-clamp-2 leading-relaxed">
            {post.summary || post.content.substring(0, 120) + "..."}
          </p>
        </div>

        {/* Card Footer: Author & Tag Chips */}
        <div className="mt-5 pt-4 border-t border-slate-100 dark:border-slate-800/80 flex items-center justify-between">
          <div className="flex items-center space-x-2.5 min-w-0">
            <img
              src={post.author?.avatar_url || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80"}
              alt={post.author?.full_name || post.author?.username}
              className="w-6 h-6 rounded-full object-cover flex-shrink-0"
            />
            <span className="text-xs font-medium text-slate-700 dark:text-slate-300 truncate">
              {post.author?.full_name || post.author?.username}
            </span>
          </div>

          <div className="flex items-center space-x-1 text-[11px] text-slate-400 flex-shrink-0">
            <Eye className="w-3.5 h-3.5" />
            <span>{post.views_count || 0}</span>
          </div>
        </div>

      </div>

    </article>
  );
}
