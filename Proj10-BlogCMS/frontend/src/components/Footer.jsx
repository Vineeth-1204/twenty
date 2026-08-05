import React from 'react';
import { Link } from 'react-router-dom';
import { BookOpen, Heart, Code2 } from 'lucide-react';

export default function Footer() {
  return (
    <footer className="mt-auto border-t border-slate-200 dark:border-slate-800 bg-white/50 dark:bg-slate-950/50 backdrop-blur-sm transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
          
          {/* Brand Col */}
          <div className="md:col-span-2 space-y-4">
            <Link to="/" className="flex items-center space-x-3">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-600 flex items-center justify-center text-white shadow-md shadow-blue-500/20">
                <BookOpen className="w-5 h-5" />
              </div>
              <span className="text-xl font-bold tracking-tight text-slate-900 dark:text-white font-serif">
                Dev<span className="text-blue-600 dark:text-blue-400">Sphere</span>
              </span>
            </Link>
            <p className="text-xs text-slate-600 dark:text-slate-400 max-w-sm leading-relaxed">
              A high-performance modern Blog CMS built with FastAPI, SQLAlchemy, JWT Authentication, and React + Vite.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-900 dark:text-white mb-3">Navigation</h4>
            <ul className="space-y-2 text-xs text-slate-600 dark:text-slate-400">
              <li><Link to="/" className="hover:text-blue-600 transition-colors">Home Feed</Link></li>
              <li><Link to="/category/web-development" className="hover:text-blue-600 transition-colors">Web Development</Link></li>
              <li><Link to="/category/ui-ux-design" className="hover:text-blue-600 transition-colors">UI/UX Design</Link></li>
              <li><Link to="/admin" className="hover:text-blue-600 transition-colors">Admin Dashboard</Link></li>
            </ul>
          </div>

          {/* Tech Stack */}
          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-900 dark:text-white mb-3">Tech Stack</h4>
            <div className="flex flex-wrap gap-1.5">
              {['FastAPI', 'React 18', 'Vite', 'SQLAlchemy', 'JWT', 'TailwindCSS', 'SQLite'].map((tech) => (
                <span key={tech} className="px-2 py-0.5 rounded-full bg-slate-100 dark:bg-slate-800 text-[10px] font-medium text-slate-600 dark:text-slate-300 border border-slate-200/60 dark:border-slate-700">
                  {tech}
                </span>
              ))}
            </div>
          </div>

        </div>

        <div className="pt-8 border-t border-slate-200/60 dark:border-slate-800/60 flex flex-col sm:flex-row items-center justify-between text-xs text-slate-500 dark:text-slate-400">
          <p>© {new Date().getFullYear()} DevSphere Blog CMS. Built for learning FastAPI & Full-Stack architecture.</p>
          <div className="flex items-center space-x-4 mt-4 sm:mt-0">
            <span className="flex items-center gap-1">Crafted with <Heart className="w-3.5 h-3.5 text-rose-500 fill-rose-500 inline" /></span>
          </div>
        </div>
      </div>
    </footer>
  );
}
