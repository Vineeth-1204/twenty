import React from 'react';
import { Layers } from 'lucide-react';

export default function CategoryPills({ categories, activeCategory, onSelectCategory }) {
  return (
    <div className="flex items-center space-x-2 overflow-x-auto pb-2 scrollbar-none">
      <button
        onClick={() => onSelectCategory(null)}
        className={`px-4 py-2 rounded-full text-xs font-semibold whitespace-nowrap transition-all ${
          activeCategory === null
            ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20'
            : 'bg-white dark:bg-slate-900 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 border border-slate-200 dark:border-slate-800'
        }`}
      >
        All Articles
      </button>

      {categories.map((cat) => (
        <button
          key={cat.id}
          onClick={() => onSelectCategory(cat.slug)}
          className={`px-4 py-2 rounded-full text-xs font-semibold whitespace-nowrap transition-all ${
            activeCategory === cat.slug
              ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20'
              : 'bg-white dark:bg-slate-900 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 border border-slate-200 dark:border-slate-800'
          }`}
        >
          {cat.name} {cat.posts_count > 0 && <span className="ml-1.5 opacity-70">({cat.posts_count})</span>}
        </button>
      ))}
    </div>
  );
}
