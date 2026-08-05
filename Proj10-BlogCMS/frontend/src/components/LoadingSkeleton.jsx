import React from 'react';

export function BlogCardSkeleton() {
  return (
    <div className="glass-card flex flex-col overflow-hidden animate-pulse">
      <div className="aspect-[16/9] bg-slate-200 dark:bg-slate-800" />
      <div className="p-5 space-y-3 flex-1 flex flex-col justify-between">
        <div className="space-y-2">
          <div className="h-3 w-1/3 bg-slate-200 dark:bg-slate-800 rounded" />
          <div className="h-5 w-5/6 bg-slate-200 dark:bg-slate-800 rounded" />
          <div className="h-3 w-full bg-slate-200 dark:bg-slate-800 rounded" />
          <div className="h-3 w-4/5 bg-slate-200 dark:bg-slate-800 rounded" />
        </div>
        <div className="pt-4 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className="w-6 h-6 rounded-full bg-slate-200 dark:bg-slate-800" />
            <div className="h-3 w-20 bg-slate-200 dark:bg-slate-800 rounded" />
          </div>
          <div className="h-3 w-8 bg-slate-200 dark:bg-slate-800 rounded" />
        </div>
      </div>
    </div>
  );
}

export function BlogGridSkeleton({ count = 6 }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {Array.from({ length: count }).map((_, i) => (
        <BlogCardSkeleton key={i} />
      ))}
    </div>
  );
}
