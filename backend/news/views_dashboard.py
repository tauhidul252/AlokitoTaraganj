from django.shortcuts import render, redirect
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView, DeleteView, TemplateView
from django.contrib.auth.views import LoginView, LogoutView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.contrib.auth.models import User
from .models import NewsPost, NewsEditHistory, Category, ReporterProfile
from .forms import NewsPostForm, AdminUserForm, ProfileForm, CategoryForm
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
            context['reporters'] = User.objects.filter(groups__name='Reporter').count()
            context['moderators'] = User.objects.filter(groups__name='Moderator').count()
            
        return context

class AdminModeratorRequiredMixin(UserPassesTestMixin):
    def test_func(self):
        user = self.request.user
        return user.is_superuser or user.groups.filter(name='Moderator').exists()
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
            # Set approved_by if status is changed to approved
            if form.cleaned_data.get('status') == 'approved':
                form.instance.approved_by = self.request.user
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

    def form_valid(self, form):
        # Store original values to check for changes
        old_obj = NewsPost.objects.get(pk=self.object.pk)
        old_status = old_obj.status
        new_status = form.cleaned_data.get('status')
        
        # Security: if original status was approved and user is not admin, keep it approved
        if old_status == 'approved' and not self.request.user.is_superuser:
            form.instance.status = 'approved'
            new_status = 'approved'
        
        # Detect detailed changes
        detailed_changes = []
        
        # Check title
        if str(old_obj.title).strip() != str(form.cleaned_data.get('title')).strip():
            detailed_changes.append(f"<b>Title Changed:</b><br>Old: {old_obj.title}<br>New: {form.cleaned_data.get('title')}")
        
        # Check source
        if str(old_obj.source).strip() != str(form.cleaned_data.get('source')).strip():
            detailed_changes.append(f"<b>Source Changed:</b><br>Old: {old_obj.source}<br>New: {form.cleaned_data.get('source')}")
            
        # Check content (Save full old content)
        if str(old_obj.content).strip() != str(form.cleaned_data.get('content')).strip():
            detailed_changes.append(f"<b>Content Updated. Previous content was:</b><br><div class='mt-2 p-3 bg-gray-100 rounded-lg text-[11px] whitespace-pre-wrap'>{old_obj.content}</div>")
            
        # Check image
        if form.files.get('image'):
            detailed_changes.append("<b>Image was replaced.</b>")
        
        # Determine action type
        action_type = 'edit'
        if old_status != new_status:
            action_type = 'status_change'
            
        # Manually save to ensure data is updated before creating history record
        self.object = form.save()
        
        # Construct change message
        if action_type == 'status_change':
            change_msg = f"Status: {old_status} → {new_status}"
        elif detailed_changes:
            change_msg = "<br><br>".join(detailed_changes)
        else:
            change_msg = "Re-saved without changes"

        # Record the history
        NewsEditHistory.objects.create(
            news=self.object,
            user=self.request.user,
            action_type=action_type,
            old_status=old_status,
            new_status=new_status,
            changes=change_msg
        )
        
        # Set approved_by if status is changed to approved (or kept approved)
        if new_status == 'approved':
            self.object.approved_by = self.request.user
            self.object.save()
            
        return redirect(self.get_success_url())

class DashboardNewsDeleteView(LoginRequiredMixin, DeleteView):
    model = NewsPost
    template_name = 'news/dashboard_news_confirm_delete.html'
    success_url = reverse_lazy('dashboard-news-list')
    login_url = 'dashboard-login'
    
    def get_queryset(self):
        qs = super().get_queryset()
        user = self.request.user
        if user.is_superuser:
            return qs
        if user.groups.filter(name='Moderator').exists():
            return qs.exclude(status='approved')
        return qs.filter(author=user).exclude(status='approved')

# User Management Views
class DashboardUserListView(AdminModeratorRequiredMixin, ListView):
    model = User
    template_name = 'news/dashboard_user_list.html'
    context_object_name = 'users'

class DashboardUserCreateView(AdminModeratorRequiredMixin, CreateView):
    model = User
    form_class = AdminUserForm
    template_name = 'news/dashboard_user_form.html'
    success_url = reverse_lazy('dashboard-user-list')
    context_object_name = 'edited_user'  # Prevent shadowing template's {{ user }} (logged-in admin)

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        lang = self.request.session.get('django_language', 'bn')
        kwargs['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        kwargs['requesting_user'] = self.request.user
        return kwargs

class DashboardUserUpdateView(AdminModeratorRequiredMixin, UpdateView):
    model = User
    form_class = AdminUserForm
    template_name = 'news/dashboard_user_form.html'
    success_url = reverse_lazy('dashboard-user-list')
    context_object_name = 'edited_user'  # Prevent shadowing template's {{ user }} (logged-in admin)

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        lang = self.request.session.get('django_language', 'bn')
        kwargs['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        kwargs['requesting_user'] = self.request.user
        return kwargs

    def form_valid(self, form):
        response = super().form_valid(form)
        # CRITICAL FIX: After saving any user, always re-anchor the session
        # to the currently logged-in admin, not the user being edited.
        # Without this, Django's session auth hash check can switch/invalidate
        # the admin's session and log them in as the edited user.
        from django.contrib.auth import update_session_auth_hash
        update_session_auth_hash(self.request, self.request.user)
        return response

from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth import update_session_auth_hash
from django.contrib import messages

# ... (previous views)

class DashboardUserDeleteView(AdminModeratorRequiredMixin, DeleteView):
    model = User
    template_name = 'news/dashboard_user_confirm_delete.html'
    success_url = reverse_lazy('dashboard-user-list')
    context_object_name = 'edited_user'  # Prevent shadowing template's {{ user }} (logged-in admin)

# Profile and Settings Views
class ProfileUpdateView(LoginRequiredMixin, UpdateView):
    model = User
    form_class = ProfileForm
    template_name = 'news/dashboard_profile.html'
    success_url = reverse_lazy('dashboard-home')
    login_url = 'dashboard-login'
    context_object_name = 'profile_user'  # Prevent shadowing template's {{ user }} (logged-in admin)

    def get_object(self):
        return self.request.user

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        lang = self.request.session.get('django_language', 'bn')
        kwargs['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        # Pass FILES so the avatar ImageField can process uploads
        if self.request.method in ('POST', 'PUT'):
            kwargs['files'] = self.request.FILES
        return kwargs

    def form_valid(self, form):
        response = super().form_valid(form)
        from django.contrib.auth import update_session_auth_hash
        update_session_auth_hash(self.request, self.request.user)
        return response

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

# Category Management Views
class CategoryListView(AdminModeratorRequiredMixin, ListView):
    model = Category
    template_name = 'news/dashboard_category_list.html'
    context_object_name = 'categories'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        lang = self.request.session.get('django_language', 'bn')
        context['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return context

class CategoryCreateView(AdminModeratorRequiredMixin, CreateView):
    model = Category
    form_class = CategoryForm
    template_name = 'news/dashboard_category_form.html'
    success_url = reverse_lazy('dashboard-category-list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        lang = self.request.session.get('django_language', 'bn')
        context['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return context

class CategoryUpdateView(AdminModeratorRequiredMixin, UpdateView):
    model = Category
    form_class = CategoryForm
    template_name = 'news/dashboard_category_form.html'
    success_url = reverse_lazy('dashboard-category-list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        lang = self.request.session.get('django_language', 'bn')
        context['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return context

class CategoryDeleteView(AdminModeratorRequiredMixin, DeleteView):
    model = Category
    template_name = 'news/dashboard_category_confirm_delete.html'
    success_url = reverse_lazy('dashboard-category-list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        lang = self.request.session.get('django_language', 'bn')
        context['t'] = TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
        return context


# ─── Reporter Verification Toggle ────────────────────────────────────────────
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST

@login_required(login_url='dashboard-login')
@require_POST
def toggle_reporter_verify(request, pk):
    """One-click toggle to verify/unverify a reporter. Admin & Moderator only."""
    if not (request.user.is_superuser or request.user.groups.filter(name='Moderator').exists()):
        from django.http import HttpResponseForbidden
        return HttpResponseForbidden()
    
    target_user = User.objects.get(pk=pk)
    profile, _ = ReporterProfile.objects.get_or_create(user=target_user)
    profile.is_verified = not profile.is_verified  # Toggle
    profile.save()
    return redirect('dashboard-user-list')
