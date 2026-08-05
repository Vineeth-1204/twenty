import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import api from '../services/api';
import FeaturedPost from '../components/FeaturedPost';
import BlogCard from '../components/BlogCard';
import CategoryPills from '../components/CategoryPills';
import TagCloud from '../components/TagCloud';
import { BlogGridSkeleton } from '../components/LoadingSkeleton';
import { ChevronLeft, ChevronRight, Sparkles, BookOpen } from 'lucide-react';

export default function Home() {
  const [searchParams, setSearchParams] = useSearchParams();
  const activeCategory = searchParams.get('category');
  const activeTag = searchParams.get('tag');
  const page = parseInt(searchParams.get('page') || '1', 10);

  const [posts, setPosts] = useState([]);
  const [featuredPost, setFeaturedPost] = useState(null);
  const [categories, setCategories] = useState([]);
  const [tags, setTags] = useState([]);
  const [pagination, setPagination] = useState({ total: 0, pages: 1, size: 6 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchMetadata = async () => {
      try {
        const [catRes, tagRes] = await Promise.all([
          api.get('/categories'),
          api.get('/tags')
        ]);
        setCategories(catRes.data);
        setTags(tagRes.data);
      } catch (err) {
        console.error("Failed to load metadata:", err);
      }
    };

    fetchMetadata();
  }, []);

  useEffect(() => {
    const fetchPosts = async () => {
      setLoading(true);
      try {
        let url = `/posts?page=${page}&size=6`;
        if (activeCategory) url += `&category=${activeCategory}`;
        if (activeTag) url += `&tag=${activeTag}`;

        const res = await api.get(url);
        const fetchedPosts = res.data.items || [];
        setPosts(fetchedPosts);
        setPagination({
          total: res.data.total,
          pages: res.data.pages,
          size: res.data.size
        });

        // Set top published article as hero featured post on page 1 without filters
        if (!activeCategory && !activeTag && page === 1 && fetchedPosts.length > 0) {
          setFeaturedPost(fetchedPosts[0]);
        } else {
          setFeaturedPost(null);
        }
      } catch (err) {
        console.error("Failed to fetch blog posts:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchPosts();
  }, [activeCategory, activeTag, page]);

  const handleCategorySelect = (slug) => {
    const params = new URLSearchParams(searchParams);
    if (slug) {
      params.set('category', slug);
    } else {
      params.delete('category');
    }
    params.set('page', '1');
    setSearchParams(params);
  };

  const handleTagSelect = (slug) => {
    const params = new URLSearchParams(searchParams);
    if (slug) {
      params.set('tag', slug);
    } else {
      params.delete('tag');
    }
    params.set('page', '1');
    setSearchParams(params);
  };

  const handlePageChange = (newPage) => {
    const params = new URLSearchParams(searchParams);
    params.set('page', newPage.toString());
    setSearchParams(params);
  };

  // Remaining grid posts (skip hero featured post if visible)
  const gridPosts = featuredPost ? posts.slice(1) : posts;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-10">
      
      {/* Category Pills Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border-b border-slate-200/80 dark:border-slate-800 pb-4">
        <CategoryPills
          categories={categories}
          activeCategory={activeCategory}
          onSelectCategory={handleCategorySelect}
        />
      </div>

      {/* Hero Featured Post Banner */}
      {!loading && featuredPost && (
        <FeaturedPost post={featuredPost} />
      )}

      {/* Main Grid & Sidebar Container */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        
        {/* Articles Feed */}
        <div className="lg:col-span-8 space-y-8">
          
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-bold text-slate-900 dark:text-white flex items-center gap-2">
              <BookOpen className="w-5 h-5 text-blue-500" />
              <span>{activeCategory ? `Category: ${activeCategory}` : activeTag ? `Tag: #${activeTag}` : "Latest Publications"}</span>
            </h2>
            <span className="text-xs text-slate-500 font-medium">{pagination.total} Articles</span>
          </div>

          {loading ? (
            <BlogGridSkeleton count={6} />
          ) : gridPosts.length === 0 ? (
            <div className="glass-card p-12 text-center space-y-3">
              <Sparkles className="w-8 h-8 text-blue-500 mx-auto" />
              <h3 className="text-base font-bold text-slate-900 dark:text-white">No articles found</h3>
              <p className="text-xs text-slate-500 max-w-sm mx-auto">
                No published blog posts match the selected category or tag filters. Try clearing your filters.
              </p>
              <button
                onClick={() => setSearchParams({})}
                className="px-4 py-2 rounded-xl bg-blue-600 text-white text-xs font-semibold"
              >
                Clear Filters
              </button>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              {gridPosts.map((post) => (
                <BlogCard key={post.id} post={post} />
              ))}
            </div>
          )}

          {/* Pagination Controls */}
          {pagination.pages > 1 && (
            <div className="flex items-center justify-center space-x-2 pt-6">
              <button
                disabled={page <= 1}
                onClick={() => handlePageChange(page - 1)}
                className="p-2 rounded-xl border border-slate-200 dark:border-slate-800 disabled:opacity-30 hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-700 dark:text-slate-300 transition-colors"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>

              <span className="text-xs font-semibold text-slate-600 dark:text-slate-400 px-3">
                Page {page} of {pagination.pages}
              </span>

              <button
                disabled={page >= pagination.pages}
                onClick={() => handlePageChange(page + 1)}
                className="p-2 rounded-xl border border-slate-200 dark:border-slate-800 disabled:opacity-30 hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-700 dark:text-slate-300 transition-colors"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          )}

        </div>

        {/* Sidebar */}
        <div className="lg:col-span-4 space-y-6">
          
          {/* Tag Cloud */}
          <TagCloud
            tags={tags}
            activeTag={activeTag}
            onSelectTag={handleTagSelect}
          />

          {/* Newsletter / Info Card */}
          <div className="glass-card p-6 space-y-3 bg-gradient-to-br from-blue-600/10 via-indigo-600/5 to-transparent border-blue-500/20">
            <h3 className="text-sm font-bold text-slate-900 dark:text-white">🚀 Build with FastAPI</h3>
            <p className="text-xs text-slate-600 dark:text-slate-300 leading-relaxed">
              This CMS project demonstrates FastAPI async architecture, JWT token security, SQLAlchemy ORM, and React 18 frontend integration.
            </p>
          </div>

        </div>

      </div>

    </div>
  );
}
