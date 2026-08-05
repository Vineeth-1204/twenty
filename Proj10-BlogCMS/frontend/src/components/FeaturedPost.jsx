import React from 'react';
import { Link } from 'react-router-dom';
import { Clock, Eye, Calendar, ArrowRight, Sparkles } from 'lucide-react';
import { getImageUrl, formatDate, calculateReadingTime } from '../utils/helpers';

export default function FeaturedPost({ post }) {
  if (!post) return null;

  return (
    <div className="relative rounded-3xl overflow-hidden glass-card border border-blue-500/20 dark:border-blue-500/10 shadow-2xl transition-all duration-300">
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-0">
        
        {/* Featured Image Col */}
        <div className="lg:col-span-7 relative aspect-[16/10] lg:aspect-auto overflow-hidden">
          <img
            src={getImageUrl(post.cover_image)}
            alt={post.title}
            className="w-full h-full object-cover transition-transform duration-700 hover:scale-105"
          />
          <div className="absolute top-4 left-4 inline-flex items-center space-x-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/30">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Featured Post</span>
          </div>
        </div>

        {/* Content Col */}
        <div className="lg:col-span-5 p-6 sm:p-8 flex flex-col justify-between space-y-6">
          <div className="space-y-4">
            
            {/* Category & Date */}
            <div className="flex items-center space-x-3 text-xs text-slate-500 dark:text-slate-400">
              {post.category && (
                <span className="font-semibold text-blue-600 dark:text-blue-400 uppercase tracking-wider text-[11px]">
                  {post.category.name}
                </span>
              )}
              <span>•</span>
              <span className="flex items-center space-x-1">
                <Calendar className="w-3.5 h-3.5" />
                <span>{formatDate(post.created_at)}</span>
              </span>
            </div>

            {/* Title */}
            <h2 className="text-xl sm:text-2xl font-extrabold text-slate-900 dark:text-white hover:text-blue-600 dark:hover:text-blue-400 transition-colors leading-tight">
              <Link to={`/post/${post.slug}`}>
                {post.title}
              </Link>
            </h2>

            {/* Summary */}
            <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-300 leading-relaxed line-clamp-3">
              {post.summary || post.content.substring(0, 160) + "..."}
            </p>
          </div>

          {/* Author & CTA */}
          <div className="pt-4 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <img
                src={post.author?.avatar_url || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80"}
                alt={post.author?.full_name || post.author?.username}
                className="w-9 h-9 rounded-full object-cover border border-slate-200 dark:border-slate-700"
              />
              <div>
                <p className="text-xs font-semibold text-slate-900 dark:text-white">
                  {post.author?.full_name || post.author?.username}
                </p>
                <p className="text-[10px] text-slate-500">{calculateReadingTime(post.content)}</p>
              </div>
            </div>

            <Link
              to={`/post/${post.slug}`}
              className="inline-flex items-center space-x-2 px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold shadow-md shadow-blue-500/20 transition-all hover:scale-105"
            >
              <span>Read Full</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </div>

        </div>

      </div>
    </div>
  );
}
