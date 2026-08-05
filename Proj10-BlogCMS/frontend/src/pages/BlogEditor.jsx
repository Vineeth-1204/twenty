import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { 
  Save, Eye, Edit3, Image as ImageIcon, Upload, X, ArrowLeft, 
  Check, Loader2, Tag as TagIcon, Layers 
} from 'lucide-react';
import api from '../services/api';
import { getImageUrl } from '../utils/helpers';

export default function BlogEditor() {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEditing = Boolean(id);

  const [title, setTitle] = useState('');
  const [summary, setSummary] = useState('');
  const [content, setContent] = useState('');
  const [coverImage, setCoverImage] = useState('');
  const [status, setStatus] = useState('draft');
  const [categoryId, setCategoryId] = useState('');
  const [selectedTagIds, setSelectedTagIds] = useState([]);

  const [categories, setCategories] = useState([]);
  const [tags, setTags] = useState([]);
  const [activeTab, setActiveTab] = useState('edit'); // 'edit' | 'preview'
  const [loading, setLoading] = useState(false);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [catRes, tagRes] = await Promise.all([
          api.get('/categories'),
          api.get('/tags')
        ]);
        setCategories(catRes.data);
        setTags(tagRes.data);

        if (isEditing) {
          const postRes = await api.get(`/posts/${id}`);
          const p = postRes.data;
          setTitle(p.title || '');
          setSummary(p.summary || '');
          setContent(p.content || '');
          setCoverImage(p.cover_image || '');
          setStatus(p.status || 'draft');
          setCategoryId(p.category?.id ? p.category.id.toString() : '');
          setSelectedTagIds(p.tags ? p.tags.map(t => t.id) : []);
        }
      } catch (err) {
        console.error("Failed to load editor data:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [id, isEditing]);

  const handleImageUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('file', file);

    setUploadingImage(true);
    try {
      const res = await api.post('/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      setCoverImage(res.data.url);
    } catch (err) {
      alert(err.response?.data?.detail || "Image upload failed");
    } finally {
      setUploadingImage(false);
    }
  };

  const handleToggleTag = (tagId) => {
    if (selectedTagIds.includes(tagId)) {
      setSelectedTagIds(selectedTagIds.filter(t => t !== tagId));
    } else {
      setSelectedTagIds([...selectedTagIds, tagId]);
    }
  };

  const handleSubmit = async (targetStatus) => {
    if (!title.trim() || !content.trim()) {
      alert("Title and content are required.");
      return;
    }

    setSaving(true);
    try {
      const payload = {
        title,
        summary,
        content,
        cover_image: coverImage,
        status: targetStatus,
        category_id: categoryId ? parseInt(categoryId, 10) : None,
        tag_ids: selectedTagIds
      };

      if (isEditing) {
        await api.put(`/posts/${id}`, payload);
      } else {
        await api.post('/posts', payload);
      }

      navigate('/admin');
    } catch (err) {
      console.error("Failed to save post:", err);
      alert(err.response?.data?.detail || "Failed to save blog post");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-[70vh] flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-blue-500 animate-spin" />
      </div>
    );
  }

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 py-8 space-y-6">
      
      {/* Editor Top Actions Bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border-b border-slate-200 dark:border-slate-800 pb-4">
        <div className="flex items-center space-x-3">
          <Link
            to="/admin"
            className="p-2 rounded-xl border border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
          </Link>
          <h1 className="text-xl font-bold text-slate-900 dark:text-white">
            {isEditing ? "Edit Article" : "Create New Article"}
          </h1>
        </div>

        <div className="flex items-center space-x-3">
          
          {/* Edit / Preview Tabs */}
          <div className="flex items-center p-1 rounded-xl bg-slate-100 dark:bg-slate-800 text-xs font-semibold">
            <button
              onClick={() => setActiveTab('edit')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg transition-all ${
                activeTab === 'edit'
                  ? 'bg-white dark:bg-slate-900 text-blue-600 dark:text-blue-400 shadow-sm'
                  : 'text-slate-600 dark:text-slate-400'
              }`}
            >
              <Edit3 className="w-3.5 h-3.5" />
              <span>Write</span>
            </button>
            <button
              onClick={() => setActiveTab('preview')}
              className={`flex items-center space-x-1.5 px-3 py-1.5 rounded-lg transition-all ${
                activeTab === 'preview'
                  ? 'bg-white dark:bg-slate-900 text-blue-600 dark:text-blue-400 shadow-sm'
                  : 'text-slate-600 dark:text-slate-400'
              }`}
            >
              <Eye className="w-3.5 h-3.5" />
              <span>Preview</span>
            </button>
          </div>

          {/* Action Buttons */}
          <button
            onClick={() => handleSubmit('draft')}
            disabled={saving}
            className="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-800 text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
          >
            Save Draft
          </button>

          <button
            onClick={() => handleSubmit('published')}
            disabled={saving}
            className="inline-flex items-center space-x-1.5 px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white text-xs font-semibold shadow-md shadow-blue-500/20 transition-all"
          >
            {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
            <span>Publish Now</span>
          </button>

        </div>
      </div>

      {activeTab === 'edit' ? (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          
          {/* Main Content Area */}
          <div className="lg:col-span-8 space-y-4">
            
            {/* Title Input */}
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Article Title..."
              className="w-full text-2xl font-extrabold bg-transparent text-slate-900 dark:text-white placeholder-slate-400 focus:outline-none border-b border-slate-200 dark:border-slate-800 pb-2"
            />

            {/* Summary Input */}
            <textarea
              value={summary}
              onChange={(e) => setSummary(e.target.value)}
              rows={2}
              placeholder="Brief summary or subtitle..."
              className="w-full p-3 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            />

            {/* Markdown Content Editor */}
            <div className="space-y-1">
              <label className="text-xs font-semibold text-slate-700 dark:text-slate-300">
                Markdown Body Content
              </label>
              <textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                rows={16}
                placeholder="Write your article in Markdown syntax... (# Heading, **bold**, `code`, etc.)"
                className="w-full p-4 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs font-mono text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500 leading-relaxed"
              />
            </div>

          </div>

          {/* Sidebar Settings Area */}
          <div className="lg:col-span-4 space-y-6">
            
            {/* Cover Image Upload Card */}
            <div className="glass-card p-5 space-y-3">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-900 dark:text-white flex items-center gap-1.5">
                <ImageIcon className="w-4 h-4 text-blue-500" />
                <span>Cover Image</span>
              </h3>

              {coverImage ? (
                <div className="relative rounded-xl overflow-hidden aspect-[16/9] group">
                  <img
                    src={getImageUrl(coverImage)}
                    alt="Cover preview"
                    className="w-full h-full object-cover"
                  />
                  <button
                    onClick={() => setCoverImage('')}
                    className="absolute top-2 right-2 p-1.5 rounded-full bg-slate-900/80 text-white hover:bg-rose-600 transition-colors"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>
              ) : (
                <label className="border-2 border-dashed border-slate-300 dark:border-slate-700 rounded-xl p-6 flex flex-col items-center justify-center cursor-pointer hover:border-blue-500 transition-colors bg-slate-50/50 dark:bg-slate-950/50">
                  {uploadingImage ? (
                    <Loader2 className="w-6 h-6 text-blue-500 animate-spin" />
                  ) : (
                    <>
                      <Upload className="w-6 h-6 text-slate-400 mb-1" />
                      <span className="text-xs font-semibold text-slate-700 dark:text-slate-300">Upload Image</span>
                      <span className="text-[10px] text-slate-400">PNG, JPG, WEBP up to 5MB</span>
                    </>
                  )}
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleImageUpload}
                    className="hidden"
                  />
                </label>
              )}

              <input
                type="text"
                value={coverImage}
                onChange={(e) => setCoverImage(e.target.value)}
                placeholder="Or paste image URL..."
                className="w-full p-2 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-[11px] text-slate-900 dark:text-white focus:outline-none"
              />
            </div>

            {/* Category Dropdown Card */}
            <div className="glass-card p-5 space-y-3">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-900 dark:text-white flex items-center gap-1.5">
                <Layers className="w-4 h-4 text-blue-500" />
                <span>Category</span>
              </h3>

              <select
                value={categoryId}
                onChange={(e) => setCategoryId(e.target.value)}
                className="w-full p-2.5 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-xs text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Category...</option>
                {categories.map((cat) => (
                  <option key={cat.id} value={cat.id}>{cat.name}</option>
                ))}
              </select>
            </div>

            {/* Tag Selector Card */}
            <div className="glass-card p-5 space-y-3">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-900 dark:text-white flex items-center gap-1.5">
                <TagIcon className="w-4 h-4 text-blue-500" />
                <span>Tags</span>
              </h3>

              <div className="flex flex-wrap gap-1.5">
                {tags.map((tag) => {
                  const isSelected = selectedTagIds.includes(tag.id);
                  return (
                    <button
                      key={tag.id}
                      type="button"
                      onClick={() => handleToggleTag(tag.id)}
                      className={`px-2.5 py-1 rounded-lg text-xs font-medium transition-all ${
                        isSelected
                          ? 'bg-blue-600 text-white shadow-sm'
                          : 'bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-slate-200'
                      }`}
                    >
                      #{tag.name}
                    </button>
                  );
                })}
              </div>
            </div>

          </div>

        </div>
      ) : (
        /* Markdown Preview Mode */
        <div className="glass-card p-8 space-y-6">
          <div className="border-b border-slate-200 dark:border-slate-800 pb-4 space-y-2">
            <h1 className="text-3xl font-extrabold text-slate-900 dark:text-white">
              {title || "Untitled Article"}
            </h1>
            {summary && <p className="text-sm text-slate-600 dark:text-slate-400">{summary}</p>}
          </div>

          {coverImage && (
            <div className="rounded-2xl overflow-hidden aspect-[16/9]">
              <img src={getImageUrl(coverImage)} alt="Preview cover" className="w-full h-full object-cover" />
            </div>
          )}

          <div className="prose dark:prose-invert max-w-none prose-slate text-sm">
            <ReactMarkdown remarkPlugins={[remarkGfm]}>
              {content || "*No content written yet.*"}
            </ReactMarkdown>
          </div>
        </div>
      )}

    </div>
  );
}
