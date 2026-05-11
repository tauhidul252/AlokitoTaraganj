from django.shortcuts import render, redirect
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView, DeleteView, TemplateView
from django.contrib.auth.views import LoginView, LogoutView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.contrib.auth.models import User
from .models import NewsPost
from .forms import NewsPostForm, UserForm
from .translations_dashboard import TRANSLATIONS

class DashboardHomeView(LoginRequiredMixin, TemplateView):
    template_name = 'news/dashboard_home.html'
    login_url = 'dashboard-login'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        user = self.request.user
        
        # News Stats
        if user.is_superuser or user.groups.filter(name='Moderator').exists():
            news_qs = NewsPost.objects.all()
        else:
            news_qs = NewsPost.objects.filter(author=user)
            
        context['total_news'] = news_qs.count()
        context['pending_news'] = news_qs.filter(status='pending').count()
        context['approved_news'] = news_qs.filter(status='approved').count()
        
        # User Stats (Only for superusers)
        if user.is_superuser:
            context['total_users'] = User.objects.count()
            context['collectors'] = User.objects.filter(groups__name='News Collector').count()
            context['moderators'] = User.objects.filter(groups__name='Moderator').count()
            
        return context

class SuperUserRequiredMixin(UserPassesTestMixin):
    def test_func(self):
        return self.request.user.is_superuser
    login_url = 'dashboard-login'

class DashboardLoginView(LoginView):
    template_name = 'news/dashboard_login.html'
    redirect_authenticated_user = True
    
    def get_success_url(self):
        return reverse_lazy('dashboard-news-list')

class DashboardLogoutView(LogoutView):
    next_page = 'dashboard-login'

class DashboardNewsListView(LoginRequiredMixin, ListView):
    model = NewsPost
    template_name = 'news/dashboard_news_list.html'
    context_object_name = 'news_list'
    login_url = 'dashboard-login'

    def get_queryset(self):
        qs = super().get_queryset()
        user = self.request.user
        if user.is_superuser or user.groups.filter(name='Moderator').exists():
            return qs
        return qs.filter(author=user)

class DashboardNewsCreateView(LoginRequiredMixin, CreateView):
    model = NewsPost
    form_class = NewsPostForm
    template_name = 'news/dashboard_news_form.html'
    success_url = reverse_lazy('dashboard-news-list')
    login_url = 'dashboard-login'

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        lang = self.request.session.get('django_language', 'bn')
        kwargs['user'] = self.request.user
        kwargs['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return kwargs

    def form_valid(self, form):
        if not self.request.user.is_superuser and not self.request.user.groups.filter(name='Moderator').exists():
            form.instance.status = 'pending'
            form.instance.author = self.request.user
        else:
            if getattr(form.instance, 'author', None) is None:
                form.instance.author = self.request.user
        return super().form_valid(form)

class DashboardNewsUpdateView(LoginRequiredMixin, UpdateView):
    model = NewsPost
    form_class = NewsPostForm
    template_name = 'news/dashboard_news_form.html'
    success_url = reverse_lazy('dashboard-news-list')
    login_url = 'dashboard-login'

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        lang = self.request.session.get('django_language', 'bn')
        kwargs['user'] = self.request.user
        kwargs['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return kwargs

class DashboardNewsDeleteView(LoginRequiredMixin, DeleteView):
    model = NewsPost
    template_name = 'news/dashboard_news_confirm_delete.html'
    success_url = reverse_lazy('dashboard-news-list')
    login_url = 'dashboard-login'
    
    def get_queryset(self):
        qs = super().get_queryset()
        user = self.request.user
        if user.is_superuser or user.groups.filter(name='Moderator').exists():
            return qs
        return qs.filter(author=user)

# User Management Views
class DashboardUserListView(SuperUserRequiredMixin, ListView):
    model = User
    template_name = 'news/dashboard_user_list.html'
    context_object_name = 'users'

class DashboardUserCreateView(SuperUserRequiredMixin, CreateView):
    model = User
    form_class = UserForm
    template_name = 'news/dashboard_user_form.html'
    success_url = reverse_lazy('dashboard-user-list')

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        lang = self.request.session.get('django_language', 'bn')
        kwargs['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return kwargs

class DashboardUserUpdateView(SuperUserRequiredMixin, UpdateView):
    model = User
    form_class = UserForm
    template_name = 'news/dashboard_user_form.html'
    success_url = reverse_lazy('dashboard-user-list')

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        lang = self.request.session.get('django_language', 'bn')
        kwargs['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return kwargs

from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth import update_session_auth_hash
from django.contrib import messages

# ... (previous views)

class DashboardUserDeleteView(SuperUserRequiredMixin, DeleteView):
    model = User
    template_name = 'news/dashboard_user_confirm_delete.html'
    success_url = reverse_lazy('dashboard-user-list')

# Profile and Settings Views
class ProfileUpdateView(LoginRequiredMixin, UpdateView):
    model = User
    form_class = UserForm # We can reuse UserForm or make a specific one
    template_name = 'news/dashboard_profile.html'
    success_url = reverse_lazy('dashboard-home')
    login_url = 'dashboard-login'

    def get_object(self):
        return self.request.user

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        lang = self.request.session.get('django_language', 'bn')
        kwargs['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return kwargs

    def get_form(self, form_class=None):
        form = super().get_form(form_class)
        # Remove fields that shouldn't be edited by the user themselves in profile
        if 'groups' in form.fields:
            form.fields.pop('groups')
        if 'password' in form.fields:
            form.fields.pop('password')
        return form

class DashboardPasswordChangeView(LoginRequiredMixin, TemplateView):
    template_name = 'news/dashboard_password_change.html'
    
    def get(self, request):
        form = PasswordChangeForm(request.user)
        return render(request, self.template_name, {'form': form})
        
    def post(self, request):
        form = PasswordChangeForm(request.user, request.POST)
        if form.is_valid():
            user = form.save()
            update_session_auth_hash(request, user)
            messages.success(request, 'Your password was successfully updated!')
            return redirect('dashboard-home')
        return render(request, self.template_name, {'form': form})

def set_language(request, lang_code):
    request.session['django_language'] = lang_code
    return redirect(request.META.get('HTTP_REFERER', '/'))
