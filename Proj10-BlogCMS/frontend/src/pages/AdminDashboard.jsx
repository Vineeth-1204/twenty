import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import api from '../services/api';
import { formatDate } from '../utils/helpers';
import { 
  PenSquare, Trash2, Eye, FileText, CheckCircle, Clock, 
  Plus, FolderPlus, Tag as TagIcon, Search, LayoutDashboard, Loader2 
} from 'lucide-react';

export default function AdminDashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();

  const [posts, setPosts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState('ALL');
  const [searchQuery, setSearchQuery] = useState('');

  // New Category Form Modal state
  const [showCatModal, setShowCatModal] = useState(false);
  const [catName, setCatName] = useState('');
  const [catDesc, setCatDesc] = useState('');
  const [creatingCat, setCreatingCat] = useState(false);

  const fetchDashboardData = async () => {
    setLoading(true);
    try {
      // Fetch both published and draft posts for logged-in author/admin
      const [postsRes, catRes] = await Promise.all([
        api.get('/posts?size=50&status=published'),
        api.get('/categories')
      ]);

      // Fetch drafts separately
      const draftsRes = await api.get('/posts?size=50&status=draft');

      const allPosts = [...(postsRes.data.items || []), ...(draftsRes.data.items || [])];
      
      // Filter posts by user ownership if not admin
      const userPosts = user.is_admin 
        ? allPosts 
        : allPosts.filter(p => p.author?.id === user.id);

      setPosts(userPosts);
      setCategories(catRes.data);
    } catch (err) {
      console.error("Failed to load dashboard data:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (user) fetchDashboardData();
  }, [user]);

  const handleToggleStatus = async (post) => {
    const newStatus = post.status === 'published' ? 'draft' : 'published';
    try {
      await api.put(`/posts/${post.id}`, { status: newStatus });
      setPosts(posts.map(p => p.id === post.id ? { ...p, status: newStatus } : p));
    } catch (err) {
      console.error("Failed to update status:", err);
    }
  };

  const handleDeletePost = async (postId) => {
    if (!window.confirm("Are you sure you want to permanently delete this blog post?")) return;
    try {
      await api.delete(`/posts/${postId}`);
      setPosts(posts.filter(p => p.id !== postId));
    } catch (err) {
      console.error("Failed to delete post:", err);
    }
  };

  const handleCreateCategory = async (e) => {
    e.preventDefault();
    if (!catName.trim() || creatingCat) return;

    setCreatingCat(true);
    try {
      const res = await api.post('/categories', {
        name: catName,
        description: catDesc
      });
      setCategories([...categories, res.data]);
      setCatName('');
      setCatDesc('');
      setShowCatModal(false);
    } catch (err) {
      alert(err.response?.data?.detail || "Failed to create category");
    } finally {
      setCreatingCat(false);
    }
  };

  // Filtered post calculation
  const filteredPosts = posts.filter(p => {
    const matchesStatus = filterStatus === 'ALL' || p.status === filterStatus.toLowerCase();
    const matchesSearch = p.title.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesStatus && matchesSearch;
  });

  const totalViews = posts.reduce((acc, p) => acc + (p.views_count || 0), 0);
  const publishedCount = posts.filter(p => p.status === 'published').length;
  const draftCount = posts.filter(p => p.status === 'draft').length;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">
      
      {/* Dashboard Top Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900 dark:text-white flex items-center gap-2">
            <LayoutDashboard className="w-6 h-6 text-blue-500" />
            <span>Content CMS Dashboard</span>
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Logged in as <span className="font-semibold text-blue-600">{user.full_name || user.username}</span> {user.is_admin && <span className="px-2 py-0.5 rounded-full bg-amber-100 text-amber-800 text-[10px] font-bold">Admin</span>}
          </p>
        </div>

        <div className="flex items-center space-x-3">
          <button
            onClick={() => setShowCatModal(true)}
            className="inline-flex items-center space-x-1.5 px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-800 text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
          >
            <FolderPlus className="w-4 h-4 text-emerald-500" />
            <span>Add Category</span>
          </button>

          <Link
            to="/editor"
            className="inline-flex items-center space-x-1.5 px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold shadow-md shadow-blue-500/20 transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>Create Article</span>
          </Link>
        </div>
      </div>

      {/* Analytics Summary Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        
        <div className="glass-card p-5 space-y-1">
          <p className="text-[11px] font-semibold text-slate-500 uppercase">Total Articles</p>
          <div className="flex items-center justify-between">
            <span className="text-2xl font-extrabold text-slate-900 dark:text-white">{posts.length}</span>
            <FileText className="w-5 h-5 text-blue-500 opacity-80" />
          </div>
        </div>

        <div className="glass-card p-5 space-y-1">
          <p className="text-[11px] font-semibold text-slate-500 uppercase">Published</p>
          <div className="flex items-center justify-between">
            <span className="text-2xl font-extrabold text-emerald-600 dark:text-emerald-400">{publishedCount}</span>
            <CheckCircle className="w-5 h-5 text-emerald-500 opacity-80" />
          </div>
        </div>

        <div className="glass-card p-5 space-y-1">
          <p className="text-[11px] font-semibold text-slate-500 uppercase">Drafts</p>
          <div className="flex items-center justify-between">
            <span className="text-2xl font-extrabold text-amber-600 dark:text-amber-400">{draftCount}</span>
            <Clock className="w-5 h-5 text-amber-500 opacity-80" />
          </div>
        </div>

        <div className="glass-card p-5 space-y-1">
          <p className="text-[11px] font-semibold text-slate-500 uppercase">Total Article Views</p>
          <div className="flex items-center justify-between">
            <span className="text-2xl font-extrabold text-indigo-600 dark:text-indigo-400">{totalViews}</span>
            <Eye className="w-5 h-5 text-indigo-500 opacity-80" />
          </div>
        </div>

      </div>

      {/* Articles Management Table */}
      <div className="glass-card overflow-hidden">
        
        {/* Table Filter Controls */}
        <div className="p-4 border-b border-slate-200 dark:border-slate-800 flex flex-col sm:flex-row items-center justify-between gap-4">
          
          <div className="flex items-center space-x-2">
            {['ALL', 'PUBLISHED', 'DRAFT'].map((st) => (
              <button
                key={st}
                onClick={() => setFilterStatus(st)}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                  filterStatus === st
                    ? 'bg-blue-600 text-white shadow-sm'
                    : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
                }`}
              >
                {st}
              </button>
            ))}
          </div>

          <div className="relative w-full sm:w-64">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search in articles..."
              className="w-full pl-9 pr-3 py-1.5 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

        </div>

        {/* Table Content */}
        {loading ? (
          <div className="py-16 text-center text-slate-400 flex flex-col items-center justify-center space-y-2">
            <Loader2 className="w-6 h-6 animate-spin text-blue-500" />
            <span className="text-xs">Loading articles...</span>
          </div>
        ) : filteredPosts.length === 0 ? (
          <div className="py-16 text-center text-xs text-slate-500">
            No articles match the filter parameters.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 dark:bg-slate-950 text-slate-500 font-semibold border-b border-slate-200 dark:border-slate-800 uppercase tracking-wider">
                <tr>
                  <th className="py-3 px-4">Article Title</th>
                  <th className="py-3 px-4">Category</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4">Views</th>
                  <th className="py-3 px-4">Created Date</th>
                  <th className="py-3 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800/80">
                {filteredPosts.map((post) => (
                  <tr key={post.id} className="hover:bg-slate-50/50 dark:hover:bg-slate-800/50 transition-colors">
                    
                    <td className="py-3 px-4 font-semibold text-slate-900 dark:text-white max-w-xs truncate">
                      <Link to={`/post/${post.slug}`} className="hover:text-blue-600">
                        {post.title}
                      </Link>
                    </td>

                    <td className="py-3 px-4 text-slate-600 dark:text-slate-400">
                      {post.category?.name || "Uncategorized"}
                    </td>

                    <td className="py-3 px-4">
                      <button
                        onClick={() => handleToggleStatus(post)}
                        className={`px-2.5 py-1 rounded-full text-[10px] font-bold uppercase transition-all ${
                          post.status === 'published'
                            ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-400'
                            : 'bg-amber-100 text-amber-700 dark:bg-amber-950/60 dark:text-amber-400'
                        }`}
                      >
                        {post.status}
                      </button>
                    </td>

                    <td className="py-3 px-4 text-slate-600 dark:text-slate-400">
                      {post.views_count || 0}
                    </td>

                    <td className="py-3 px-4 text-slate-500">
                      {formatDate(post.created_at)}
                    </td>

                    <td className="py-3 px-4 text-right space-x-2">
                      <Link
                        to={`/editor/${post.id}`}
                        className="inline-block p-1.5 text-slate-500 hover:text-blue-600 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors"
                        title="Edit Article"
                      >
                        <PenSquare className="w-4 h-4" />
                      </Link>

                      <button
                        onClick={() => handleDeletePost(post.id)}
                        className="p-1.5 text-slate-500 hover:text-rose-600 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors"
                        title="Delete Article"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>

                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

      </div>

      {/* Create Category Modal */}
      {showCatModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
          <div className="w-full max-w-md bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl p-6 space-y-4 shadow-2xl">
            <h3 className="text-base font-bold text-slate-900 dark:text-white">Create New Category</h3>
            
            <form onSubmit={handleCreateCategory} className="space-y-4">
              <div className="space-y-1">
                <label className="text-xs font-semibold text-slate-700 dark:text-slate-300">Category Name</label>
                <input
                  type="text"
                  value={catName}
                  onChange={(e) => setCatName(e.target.value)}
                  required
                  placeholder="e.g. Mobile Apps"
                  className="w-full p-2.5 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div className="space-y-1">
                <label className="text-xs font-semibold text-slate-700 dark:text-slate-300">Description</label>
                <textarea
                  value={catDesc}
                  onChange={(e) => setCatDesc(e.target.value)}
                  rows={3}
                  placeholder="Short description of articles in this category..."
                  className="w-full p-2.5 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
                />
              </div>

              <div className="flex items-center justify-end space-x-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowCatModal(false)}
                  className="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={creatingCat}
                  className="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold shadow-md shadow-blue-500/20"
                >
                  {creatingCat ? "Saving..." : "Create Category"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
