import React from 'react';
import { Tag as TagIcon } from 'lucide-react';

export default function TagCloud({ tags, activeTag, onSelectTag }) {
  if (!tags || tags.length === 0) return null;

  return (
    <div className="glass-card p-5 space-y-4">
      <div className="flex items-center space-x-2 border-b border-slate-100 dark:border-slate-800 pb-3">
        <TagIcon className="w-4 h-4 text-blue-500" />
        <h3 className="text-xs font-bold uppercase tracking-wider text-slate-900 dark:text-white">
          Popular Topics
        </h3>
      </div>

      <div className="flex flex-wrap gap-2">
        {tags.map((tag) => {
          const isActive = activeTag === tag.slug;
          return (
            <button
              key={tag.id}
              onClick={() => onSelectTag(isActive ? null : tag.slug)}
              className={`px-3 py-1 rounded-lg text-xs font-medium transition-all ${
                isActive
                  ? 'bg-blue-600 text-white shadow-sm'
                  : 'bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-blue-50 dark:hover:bg-blue-950/40 hover:text-blue-600 dark:hover:text-blue-400'
              }`}
            >
              #{tag.name}
            </button>
          );
        })}
      </div>
    </div>
  );
}
