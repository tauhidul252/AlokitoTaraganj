import os

base_dir = r'f:\AlokitoTaraganj\backend\news\templates\news'
os.makedirs(base_dir, exist_ok=True)

base_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alokito Taraganj | Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['Outfit', 'sans-serif'], },
                    colors: { brand: { 50: '#eff6ff', 100: '#dbeafe', 500: '#3b82f6', 600: '#2563eb', 700: '#1d4ed8', 900: '#1e3a8a'} }
                }
            }
        }
    </script>
    <style>
        .glass-panel { background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(12px); border: 1px solid rgba(255, 255, 255, 0.4); }
        .gradient-brand { background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%); }
    </style>
</head>
<body class="bg-gray-50 text-gray-800 antialiased h-screen flex overflow-hidden">
    {% if user.is_authenticated %}
    
    <!-- Mobile overlay -->
    <div id="mobile-overlay" class="fixed inset-0 bg-gray-900/50 z-20 hidden lg:hidden transition-opacity" onclick="toggleSidebar()"></div>

    <!-- Sidebar -->
    <aside id="sidebar" class="fixed inset-y-0 left-0 z-30 w-64 transform -translate-x-full lg:translate-x-0 lg:static lg:inset-0 transition duration-300 ease-in-out gradient-brand text-white flex flex-col shadow-2xl">
        <div class="h-20 flex items-center justify-between px-6 border-b border-white/10">
            <h1 class="text-xl font-bold tracking-wide flex items-center">
                <i data-lucide="zap" class="w-6 h-6 mr-2 text-yellow-300"></i> Alokito Admin
            </h1>
            <button onclick="toggleSidebar()" class="lg:hidden text-white/70 hover:text-white">
                <i data-lucide="x" class="w-6 h-6"></i>
            </button>
        </div>
        <nav class="flex-1 px-4 py-6 space-y-2 overflow-y-auto">
            <a href="{% url 'dashboard-news-list' %}" class="flex items-center px-4 py-3 bg-white/10 rounded-xl transition-all hover:bg-white/20 font-medium">
                <i data-lucide="newspaper" class="w-5 h-5 mr-3"></i> News
            </a>
        </nav>
        <div class="p-4 border-t border-white/10">
            <form action="{% url 'dashboard-logout' %}" method="post">
                {% csrf_token %}
                <button type="submit" class="w-full flex items-center justify-center px-4 py-2.5 bg-white/10 hover:bg-red-500 hover:text-white rounded-xl transition-all font-medium text-white/90">
                    <i data-lucide="log-out" class="w-5 h-5 mr-2"></i> Logout
                </button>
            </form>
        </div>
    </aside>
    
    <!-- Main Content -->
    <div class="flex-1 flex flex-col min-w-0 overflow-hidden bg-[#f8fafc]">
        <!-- Top header -->
        <header class="glass-panel sticky top-0 z-10 px-4 sm:px-8 py-4 flex justify-between items-center shadow-sm">
            <div class="flex items-center">
                <button onclick="toggleSidebar()" class="lg:hidden mr-4 text-gray-500 hover:text-gray-700 focus:outline-none">
                    <i data-lucide="menu" class="w-6 h-6"></i>
                </button>
                <h2 class="text-xl font-bold text-gray-800 hidden sm:block">{% block header_title %}Dashboard{% endblock %}</h2>
            </div>
            <div class="flex items-center space-x-3 sm:space-x-4">
                <span class="font-medium text-sm sm:text-base text-gray-600">Hello, {{ user.username }}</span>
                <div class="w-9 h-9 sm:w-10 sm:h-10 rounded-full gradient-brand flex items-center justify-center text-white font-bold shadow-md">{{ user.username|make_list|first|upper }}</div>
            </div>
        </header>
        
        <!-- Main scrollable area -->
        <main class="flex-1 overflow-x-hidden overflow-y-auto p-4 sm:p-8">
            {% block content %}{% endblock %}
        </main>
    </div>

    <script>
        lucide.createIcons();
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('mobile-overlay');
            sidebar.classList.toggle('-translate-x-full');
            overlay.classList.toggle('hidden');
        }
    </script>
    {% else %}
        {% block login_content %}{% endblock %}
    {% endif %}
</body>
</html>"""

login_html = """{% extends "news/base.html" %}
{% block login_content %}
<div class="min-h-screen flex flex-col sm:justify-center items-center pt-6 sm:pt-0 bg-gray-50 p-4 relative overflow-hidden">
    <!-- Abstract background blobs -->
    <div class="absolute top-[-10%] left-[-10%] w-96 h-96 bg-blue-400 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-blob"></div>
    <div class="absolute top-[20%] right-[-10%] w-96 h-96 bg-sky-300 rounded-full mix-blend-multiply filter blur-3xl opacity-30 animate-blob animation-delay-2000"></div>

    <div class="w-full sm:max-w-md mt-6 px-8 py-10 glass-panel shadow-2xl rounded-3xl relative z-10">
        <div class="text-center mb-10">
            <div class="w-16 h-16 gradient-brand rounded-2xl mx-auto flex items-center justify-center shadow-lg mb-4 transform rotate-3">
                <i data-lucide="zap" class="w-8 h-8 text-yellow-300"></i>
            </div>
            <h1 class="text-3xl font-bold text-gray-900">Welcome Back</h1>
            <p class="text-gray-500 mt-2 text-sm">Sign in to manage your app.</p>
        </div>
        <form method="post" class="space-y-6">
            {% csrf_token %}
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">Username</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <i data-lucide="user" class="h-5 w-5 text-gray-400"></i>
                    </div>
                    <input type="text" name="username" class="w-full pl-10 pr-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent transition-all bg-white" required placeholder="Enter your username">
                </div>
            </div>
            <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">Password</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <i data-lucide="lock" class="h-5 w-5 text-gray-400"></i>
                    </div>
                    <input type="password" name="password" class="w-full pl-10 pr-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent transition-all bg-white" required placeholder="••••••••">
                </div>
            </div>
            <button type="submit" class="w-full gradient-brand text-white font-bold py-3.5 px-4 rounded-xl shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 transition-all flex justify-center items-center">
                <span>Sign in</span>
                <i data-lucide="arrow-right" class="w-5 h-5 ml-2"></i>
            </button>
        </form>
    </div>
</div>
<script src="https://unpkg.com/lucide@latest"></script>
<script>lucide.createIcons();</script>
{% endblock %}"""

list_html = """{% extends "news/base.html" %}
{% block header_title %}News Management{% endblock %}
{% block content %}
<div class="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
    <div>
        <h3 class="text-2xl font-bold text-gray-800">All News Posts</h3>
        <p class="text-gray-500 text-sm mt-1">Manage and organize your app's news content.</p>
    </div>
    <a href="{% url 'dashboard-news-create' %}" class="gradient-brand text-white px-5 py-2.5 rounded-xl font-semibold shadow-md hover:shadow-lg transform hover:-translate-y-0.5 transition-all flex items-center w-full sm:w-auto justify-center">
        <i data-lucide="plus" class="w-5 h-5 mr-2"></i> Add Post
    </a>
</div>

<div class="glass-panel rounded-2xl shadow-sm overflow-hidden border border-gray-200">
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50/80">
                <tr>
                    <th class="px-4 sm:px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Title</th>
                    <th class="hidden sm:table-cell px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Source</th>
                    <th class="px-4 sm:px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
                    <th class="hidden md:table-cell px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Date</th>
                    <th class="px-4 sm:px-6 py-4 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100 bg-white">
                {% for news in news_list %}
                <tr class="hover:bg-blue-50/50 transition-colors group">
                    <td class="px-4 sm:px-6 py-4">
                        <div class="flex items-center">
                            {% if news.image %}
                            <img class="h-10 w-10 sm:h-12 sm:w-12 rounded-xl object-cover mr-3 sm:mr-4 shadow-sm" src="{{ news.image.url }}" alt="">
                            {% else %}
                            <div class="h-10 w-10 sm:h-12 sm:w-12 rounded-xl bg-brand-50 flex items-center justify-center mr-3 sm:mr-4 text-brand-600 font-bold shadow-sm">
                                <i data-lucide="image" class="w-5 h-5 opacity-50"></i>
                            </div>
                            {% endif %}
                            <div>
                                <div class="text-sm font-bold text-gray-900 line-clamp-2">{{ news.title }}</div>
                                <div class="text-xs text-gray-500 sm:hidden mt-1">{{ news.source }}</div>
                            </div>
                        </div>
                    </td>
                    <td class="hidden sm:table-cell px-6 py-4 whitespace-nowrap text-sm text-gray-600 font-medium">{{ news.source }}</td>
                    <td class="px-4 sm:px-6 py-4 whitespace-nowrap">
                        {% if news.is_published %}
                        <span class="px-3 py-1 inline-flex text-xs leading-5 font-bold rounded-full bg-green-100 text-green-700 border border-green-200">Published</span>
                        {% else %}
                        <span class="px-3 py-1 inline-flex text-xs leading-5 font-bold rounded-full bg-amber-100 text-amber-700 border border-amber-200">Draft</span>
                        {% endif %}
                    </td>
                    <td class="hidden md:table-cell px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-medium">{{ news.created_at|date:"M d, Y" }}</td>
                    <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <div class="flex items-center justify-end space-x-3">
                            <a href="{% url 'dashboard-news-update' news.pk %}" class="text-brand-600 hover:text-brand-900 bg-brand-50 p-2 rounded-lg transition-colors" title="Edit">
                                <i data-lucide="edit-2" class="w-4 h-4"></i>
                            </a>
                            <a href="{% url 'dashboard-news-delete' news.pk %}" class="text-red-600 hover:text-red-900 bg-red-50 p-2 rounded-lg transition-colors" title="Delete">
                                <i data-lucide="trash-2" class="w-4 h-4"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                {% empty %}
                <tr>
                    <td colspan="5" class="px-6 py-12 text-center">
                        <div class="flex flex-col items-center justify-center">
                            <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                                <i data-lucide="file-x" class="w-8 h-8 text-gray-400"></i>
                            </div>
                            <h3 class="text-lg font-bold text-gray-900 mb-1">No news posts yet</h3>
                            <p class="text-gray-500">Get started by creating your first news post.</p>
                        </div>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</div>
{% endblock %}"""

form_html = """{% extends "news/base.html" %}
{% block header_title %}{% if object %}Edit News{% else %}Create News{% endif %}{% endblock %}
{% block content %}
<div class="max-w-4xl mx-auto">
    <div class="mb-6 flex items-center">
        <a href="{% url 'dashboard-news-list' %}" class="text-gray-400 hover:text-brand-600 mr-4 transition-colors p-2 bg-white rounded-full shadow-sm">
            <i data-lucide="arrow-left" class="w-5 h-5"></i>
        </a>
        <div>
            <h3 class="text-2xl font-bold text-gray-800">{% if object %}Edit Post{% else %}Create New Post{% endif %}</h3>
            <p class="text-gray-500 text-sm mt-1">Fill out the form below to {% if object %}update{% else %}publish{% endif %} news.</p>
        </div>
    </div>

    <div class="glass-panel rounded-3xl shadow-sm border border-gray-200 overflow-hidden bg-white">
        <form method="post" enctype="multipart/form-data" class="p-6 sm:p-10">
            {% csrf_token %}
            
            <div class="space-y-6">
                {% for field in form %}
                <div class="{% if field.name == 'is_published' %}flex items-center p-4 bg-gray-50 rounded-xl border border-gray-100{% endif %}">
                    {% if field.name != 'is_published' %}
                        <label class="block text-sm font-bold text-gray-700 mb-2">{{ field.label }}</label>
                    {% endif %}
                    
                    {% if field.name == 'is_published' %}
                        {{ field }}
                        <label class="ml-3 text-sm font-bold text-gray-700 cursor-pointer" for="{{ field.id_for_label }}">Publish this post immediately</label>
                    {% else %}
                        {{ field }}
                    {% endif %}
                    
                    {% if field.errors %}
                        <p class="text-red-500 text-xs font-medium mt-1.5 flex items-center"><i data-lucide="alert-circle" class="w-3 h-3 mr-1"></i> {{ field.errors.0 }}</p>
                    {% endif %}
                </div>
                {% endfor %}
            </div>

            <div class="pt-8 mt-8 border-t border-gray-100 flex flex-col-reverse sm:flex-row sm:justify-end gap-3 sm:gap-4">
                <a href="{% url 'dashboard-news-list' %}" class="px-6 py-3 border border-gray-200 text-gray-700 rounded-xl font-bold hover:bg-gray-50 transition-colors text-center w-full sm:w-auto">Cancel</a>
                <button type="submit" class="gradient-brand text-white px-8 py-3 rounded-xl font-bold shadow-md hover:shadow-lg transform hover:-translate-y-0.5 transition-all flex items-center justify-center w-full sm:w-auto">
                    <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                    {% if object %}Update Post{% else %}Publish Post{% endif %}
                </button>
            </div>
        </form>
    </div>
</div>
{% endblock %}"""

delete_html = """{% extends "news/base.html" %}
{% block header_title %}Delete News{% endblock %}
{% block content %}
<div class="max-w-lg mx-auto mt-10">
    <div class="glass-panel rounded-3xl shadow-xl p-8 sm:p-10 bg-white text-center border border-red-100 relative overflow-hidden">
        <div class="absolute top-0 left-0 w-full h-2 bg-red-500"></div>
        
        <div class="w-20 h-20 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-6">
            <div class="w-14 h-14 bg-red-100 rounded-full flex items-center justify-center">
                <i data-lucide="alert-triangle" class="w-8 h-8 text-red-500"></i>
            </div>
        </div>
        
        <h3 class="text-2xl font-bold text-gray-900 mb-3">Confirm Deletion</h3>
        <p class="text-gray-500 mb-8 leading-relaxed">Are you absolutely sure you want to delete <br><strong class="text-gray-800">"{{ object.title }}"</strong>?<br>This action cannot be undone and will permanently remove this post.</p>
        
        <form method="post" class="flex flex-col sm:flex-row justify-center gap-3">
            {% csrf_token %}
            <a href="{% url 'dashboard-news-list' %}" class="px-6 py-3.5 border border-gray-200 text-gray-700 rounded-xl font-bold hover:bg-gray-50 transition-colors w-full sm:w-auto">Cancel</a>
            <button type="submit" class="bg-red-500 hover:bg-red-600 text-white px-8 py-3.5 rounded-xl font-bold shadow-md hover:shadow-lg transition-all flex items-center justify-center w-full sm:w-auto">
                <i data-lucide="trash-2" class="w-5 h-5 mr-2"></i> Delete Post
            </button>
        </form>
    </div>
</div>
{% endblock %}"""

with open(f'{base_dir}/base.html', 'w', encoding='utf-8') as f: f.write(base_html)
with open(f'{base_dir}/login.html', 'w', encoding='utf-8') as f: f.write(login_html)
with open(f'{base_dir}/dashboard_news_list.html', 'w', encoding='utf-8') as f: f.write(list_html)
with open(f'{base_dir}/dashboard_news_form.html', 'w', encoding='utf-8') as f: f.write(form_html)
with open(f'{base_dir}/dashboard_news_confirm_delete.html', 'w', encoding='utf-8') as f: f.write(delete_html)
