from django.shortcuts import render, redirect
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView, DeleteView, TemplateView
from django.contrib.auth.views import LoginView, LogoutView
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.contrib.auth.models import User
from .models import (NewsPost, NewsEditHistory, Category, ReporterProfile, 
    BloodDonor, Doctor, Job, EmergencyContact, BusSchedule, TouristSpot,
    EducationInstitution, GovernmentService, ProfessionalService, Complaint, Hospital, Advertisement, AppConfiguration)
from .forms import (NewsPostForm, AdminUserForm, ProfileForm, CategoryForm, 
    BloodDonorForm, DoctorForm, JobForm, EmergencyContactForm, BusScheduleForm, TouristSpotForm,
    EducationForm, GovernmentServiceForm, ProfessionalServiceForm, ComplaintForm, HospitalForm, AdvertisementForm, AppConfigurationForm)
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
            context['total_ads'] = Advertisement.objects.count()
            context['total_hospitals'] = Hospital.objects.count()
            
        return context

class AdminOnlyRequiredMixin(UserPassesTestMixin):
    def test_func(self):
        return self.request.user.is_superuser
    login_url = 'dashboard-login'

class DashboardLoginView(LoginView):
    template_name = 'news/dashboard_login.html'
    redirect_authenticated_user = True
    
    def get_success_url(self):
        return reverse_lazy('dashboard-home')


class DashboardLogoutView(LogoutView):
    next_page = 'dashboard-login'


class DashboardNewsListView(LoginRequiredMixin, ListView):
    model = NewsPost
    template_name = 'news/dashboard_news_list.html'
    context_object_name = 'news_posts'
    paginate_by = 10

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser or user.groups.filter(name='Moderator').exists():
            return NewsPost.objects.all()
        return NewsPost.objects.filter(author=user)

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['title'] = "নিউজ লিস্ট"
        return ctx

class DashboardNewsCreateView(LoginRequiredMixin, CreateView):
    model = NewsPost
    form_class = NewsPostForm
    template_name = 'news/dashboard_news_form.html'
    success_url = reverse_lazy('dashboard-news-list')

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        kwargs['user'] = self.request.user
        return kwargs

    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)

class DashboardNewsUpdateView(LoginRequiredMixin, UpdateView):
    model = NewsPost
    form_class = NewsPostForm
    template_name = 'news/dashboard_news_form.html'
    success_url = reverse_lazy('dashboard-news-list')

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        kwargs['user'] = self.request.user
        return kwargs

    def form_valid(self, form):
        # Tracking status change for history
        old_status = self.get_object().status
        new_status = form.cleaned_data.get('status', old_status)
        
        response = super().form_valid(form)
        
        if old_status != new_status:
            NewsEditHistory.objects.create(
                news=self.object,
                editor=self.request.user,
                previous_status=old_status,
                new_status=new_status,
                comment=f"Status changed from {old_status} to {new_status}"
            )
        return response

class DashboardNewsDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = NewsPost
    success_url = reverse_lazy('dashboard-news-list')
    template_name = 'news/service_confirm_delete.html'
    
    def test_func(self):
        user = self.request.user
        news = self.get_object()
        return user.is_superuser or user.groups.filter(name='Moderator').exists() or news.author == user


# User Management
class DashboardUserListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = User
    template_name = 'news/dashboard_user_list.html'
    context_object_name = 'users'

    def get_queryset(self):
        return User.objects.all().order_by('-date_joined')

class DashboardUserCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = User
    form_class = AdminUserForm
    template_name = 'news/dashboard_user_form.html'
    success_url = reverse_lazy('dashboard-user-list')

class DashboardUserUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = User
    form_class = AdminUserForm
    template_name = 'news/dashboard_user_form.html'
    success_url = reverse_lazy('dashboard-user-list')

class DashboardUserDeleteView(LoginRequiredMixin, UserPassesTestMixin, DeleteView):
    model = User
    success_url = reverse_lazy('dashboard-user-list')
    template_name = 'news/service_confirm_delete.html'

    def test_func(self):
        return self.request.user.is_superuser

# Profile View
class ProfileUpdateView(LoginRequiredMixin, UpdateView):
    model = User
    form_class = ProfileForm
    template_name = 'news/dashboard_profile.html'
    success_url = reverse_lazy('dashboard-profile')

    def get_object(self, queryset=None):
        return self.request.user

# Category Views
class CategoryListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = Category
    template_name = 'news/dashboard_category_list.html'
    context_object_name = 'categories'

class CategoryCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = Category
    form_class = CategoryForm
    template_name = 'news/dashboard_category_form.html'
    success_url = reverse_lazy('dashboard-category-list')

class CategoryUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = Category
    form_class = CategoryForm
    template_name = 'news/dashboard_category_form.html'
    success_url = reverse_lazy('dashboard-category-list')

class CategoryDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = Category
    success_url = reverse_lazy('dashboard-category-list')
    template_name = 'news/service_confirm_delete.html'

def toggle_reporter_verify(request, pk):
    if not request.user.is_superuser:
        return redirect('dashboard-login')
    
    user = User.objects.get(pk=pk)
    profile, _ = ReporterProfile.objects.get_or_create(user=user)
    profile.is_verified = not profile.is_verified
    profile.save()
    return redirect('dashboard-user-list')

# ─── Service Management Views ──────────────────────────────────────────────────

# Blood Donor
class BloodDonorListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = BloodDonor
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "রক্তদাতা তালিকা"
        context['add_url'] = 'service-blood-create'
        context['edit_url'] = 'service-blood-update'
        context['delete_url'] = 'service-blood-delete'
        context['fields'] = ['name', 'blood_group', 'phone', 'is_available']
        return context

class BloodDonorCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = BloodDonor
    form_class = BloodDonorForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-blood-list')

class BloodDonorUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = BloodDonor
    form_class = BloodDonorForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-blood-list')

class BloodDonorDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = BloodDonor
    success_url = reverse_lazy('service-blood-list')
    template_name = 'news/service_confirm_delete.html'

# Doctor
class DoctorListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = Doctor
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "ডাক্তার তালিকা"
        context['add_url'] = 'service-doctor-create'
        context['edit_url'] = 'service-doctor-update'
        context['delete_url'] = 'service-doctor-delete'
        context['fields'] = ['name', 'specialty', 'phone', 'is_available']
        return context

class DoctorCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = Doctor
    form_class = DoctorForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-doctor-list')

class DoctorUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = Doctor
    form_class = DoctorForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-doctor-list')

class DoctorDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = Doctor
    success_url = reverse_lazy('service-doctor-list')
    template_name = 'news/service_confirm_delete.html'

# Job
class JobListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = Job
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "চাকরি তালিকা"
        context['add_url'] = 'service-job-create'
        context['edit_url'] = 'service-job-update'
        context['delete_url'] = 'service-job-delete'
        context['fields'] = ['title', 'company', 'deadline', 'is_active']
        return context

class JobCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = Job
    form_class = JobForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-job-list')

class JobUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = Job
    form_class = JobForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-job-list')

class JobDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = Job
    success_url = reverse_lazy('service-job-list')
    template_name = 'news/service_confirm_delete.html'

# Emergency Contact
class EmergencyContactListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = EmergencyContact
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "জরুরি যোগাযোগ"
        context['add_url'] = 'service-emergency-create'
        context['edit_url'] = 'service-emergency-update'
        context['delete_url'] = 'service-emergency-delete'
        context['fields'] = ['title', 'number', 'category', 'is_active']
        return context

class EmergencyContactCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = EmergencyContact
    form_class = EmergencyContactForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-emergency-list')

class EmergencyContactUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = EmergencyContact
    form_class = EmergencyContactForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-emergency-list')

class EmergencyContactDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = EmergencyContact
    success_url = reverse_lazy('service-emergency-list')
    template_name = 'news/service_confirm_delete.html'

# Bus Schedule
class BusScheduleListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = BusSchedule
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "বাস সময়সূচি"
        context['add_url'] = 'service-bus-create'
        context['edit_url'] = 'service-bus-update'
        context['delete_url'] = 'service-bus-delete'
        context['fields'] = ['route_name', 'departure_time', 'fare', 'is_active']
        return context

class BusScheduleCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = BusSchedule
    form_class = BusScheduleForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-bus-list')

class BusScheduleUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = BusSchedule
    form_class = BusScheduleForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-bus-list')

class BusScheduleDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = BusSchedule
    success_url = reverse_lazy('service-bus-list')
    template_name = 'news/service_confirm_delete.html'

# Tourist Spot
class TouristSpotListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = TouristSpot
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "পর্যটন স্থান"
        context['add_url'] = 'service-tourist-create'
        context['edit_url'] = 'service-tourist-update'
        context['delete_url'] = 'service-tourist-delete'
        context['fields'] = ['title', 'location', 'is_active']
        return context

class TouristSpotCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = TouristSpot
    form_class = TouristSpotForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-tourist-list')

class TouristSpotUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = TouristSpot
    form_class = TouristSpotForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-tourist-list')

class TouristSpotDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = TouristSpot
    success_url = reverse_lazy('service-tourist-list')
    template_name = 'news/service_confirm_delete.html'

# Education
class EducationListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = EducationInstitution
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "শিক্ষা প্রতিষ্ঠান"
        context['add_url'] = 'service-education-create'
        context['edit_url'] = 'service-education-update'
        context['delete_url'] = 'service-education-delete'
        context['fields'] = ['name', 'institution_type', 'location', 'is_active']
        return context

class EducationCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = EducationInstitution
    form_class = EducationForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-education-list')

class EducationUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = EducationInstitution
    form_class = EducationForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-education-list')

class EducationDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = EducationInstitution
    success_url = reverse_lazy('service-education-list')
    template_name = 'news/service_confirm_delete.html'

# Government Services
class GovtServiceListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = GovernmentService
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "সরকারি সেবা"
        context['add_url'] = 'service-govt-create'
        context['edit_url'] = 'service-govt-update'
        context['delete_url'] = 'service-govt-delete'
        context['fields'] = ['title', 'url', 'logo', 'is_active']
        return context

class GovtServiceCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = GovernmentService
    form_class = GovernmentServiceForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-govt-list')

class GovtServiceUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = GovernmentService
    form_class = GovernmentServiceForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-govt-list')

class GovtServiceDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = GovernmentService
    success_url = reverse_lazy('service-govt-list')
    template_name = 'news/service_confirm_delete.html'

# Expert Services
class ExpertServiceListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = ProfessionalService
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "পেশাজীবী সেবা"
        context['add_url'] = 'service-expert-create'
        context['edit_url'] = 'service-expert-update'
        context['delete_url'] = 'service-expert-delete'
        context['fields'] = ['name', 'category', 'phone', 'is_available']
        return context

class ExpertServiceCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = ProfessionalService
    form_class = ProfessionalServiceForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-expert-list')

class ExpertServiceUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = ProfessionalService
    form_class = ProfessionalServiceForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-expert-list')

class ExpertServiceDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = ProfessionalService
    success_url = reverse_lazy('service-expert-list')
    template_name = 'news/service_confirm_delete.html'

# Complaint Management
class ComplaintListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = Complaint
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "অভিযোগ তালিকা"
        context['edit_url'] = 'service-complaint-update'
        context['delete_url'] = 'service-complaint-delete'
        context['fields'] = ['complaint_type', 'is_resolved', 'created_at']
        return context

class ComplaintUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = Complaint
    form_class = ComplaintForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-complaint-list')

class ComplaintDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = Complaint
    success_url = reverse_lazy('service-complaint-list')
    template_name = 'news/service_confirm_delete.html'

class DashboardPasswordChangeView(LoginRequiredMixin, TemplateView):
    template_name = 'news/dashboard_password_change.html'

def set_language(request, lang_code):
    request.session['django_language'] = lang_code
    return redirect(request.META.get('HTTP_REFERER', 'dashboard-home'))

class AppConfigurationUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = AppConfiguration
    form_class = AppConfigurationForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('app-settings')

    def get_object(self, queryset=None):
        obj, created = AppConfiguration.objects.get_or_create(id=1)
        return obj

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['service_title'] = "অ্যাপ সেটিংস"
        context['back_url'] = reverse_lazy('dashboard-home')
        return context

class ComplaintUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = Complaint
    form_class = ComplaintForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-complaint-list')

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['service_title'] = 'Complaint'
        ctx['back_url'] = reverse_lazy('service-complaint-list')
        return ctx
# Hospital
class HospitalListView(LoginRequiredMixin, AdminOnlyRequiredMixin, ListView):
    model = Hospital
    template_name = 'news/service_list.html'
    context_object_name = 'items'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = "হাসপাতাল তালিকা"
        context['add_url'] = 'service-hospital-create'
        context['edit_url'] = 'service-hospital-update'
        context['delete_url'] = 'service-hospital-delete'
        context['fields'] = ['name', 'phone', 'is_verified']
        return context

class HospitalCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = Hospital
    form_class = HospitalForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-hospital-list')

class HospitalUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = Hospital
    form_class = HospitalForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('service-hospital-list')

class HospitalDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = Hospital
    success_url = reverse_lazy('service-hospital-list')
    template_name = 'news/service_confirm_delete.html'

# Advertisement
# Advertisement & Settings
class AdsManagementView(LoginRequiredMixin, AdminOnlyRequiredMixin, TemplateView):
    template_name = 'news/ads_management.html'

    def get_context_data(self, **kwargs):
        ctx = super().get_context_data(**kwargs)
        ctx['title'] = "অ্যাড ম্যানেজমেন্ট সেন্টার"
        ctx['items'] = Advertisement.objects.all().order_by('-created_at')
        config, _ = AppConfiguration.objects.get_or_create(id=1)
        ctx['config_form'] = kwargs.get('config_form') or AppConfigurationForm(instance=config)
        ctx['fields'] = ['title', 'placement', 'is_active', 'views', 'target_views', 'clicks', 'priority']
        ctx['add_url'] = 'service-ad-create'
        ctx['edit_url'] = 'service-ad-update'
        ctx['delete_url'] = 'service-ad-delete'
        return ctx

    def post(self, request, *args, **kwargs):
        config, _ = AppConfiguration.objects.get_or_create(id=1)
        form = AppConfigurationForm(request.POST, instance=config)
        if form.is_valid():
            form.save()
            return redirect('ads-management')
        return self.render_to_response(self.get_context_data(config_form=form))

class AdvertisementCreateView(LoginRequiredMixin, AdminOnlyRequiredMixin, CreateView):
    model = Advertisement
    form_class = AdvertisementForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('ads-management')

class AdvertisementUpdateView(LoginRequiredMixin, AdminOnlyRequiredMixin, UpdateView):
    model = Advertisement
    form_class = AdvertisementForm
    template_name = 'news/service_form.html'
    success_url = reverse_lazy('ads-management')

class AdvertisementDeleteView(LoginRequiredMixin, AdminOnlyRequiredMixin, DeleteView):
    model = Advertisement
    success_url = reverse_lazy('ads-management')
    template_name = 'news/service_confirm_delete.html'
