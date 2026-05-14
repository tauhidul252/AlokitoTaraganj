from django.contrib import admin
from .models import (NewsPost, Category, ReporterProfile, BloodDonor, 
    Doctor, Job, EmergencyContact, BusSchedule, TouristSpot, 
    EducationInstitution, GovernmentService, ProfessionalService, 
    Complaint, HomeService, Hospital, Advertisement, AppConfiguration)
from .forms import NewsPostForm, AppConfigurationForm

@admin.register(AppConfiguration)
class AppConfigurationAdmin(admin.ModelAdmin):
    form = AppConfigurationForm
    def has_add_permission(self, request):
        return not AppConfiguration.objects.exists()
    
    def has_delete_permission(self, request, obj=None):
        return False

@admin.register(Doctor)
class DoctorAdmin(admin.ModelAdmin):
    list_display = ('name', 'specialty', 'phone', 'is_available')

@admin.register(Job)
class JobAdmin(admin.ModelAdmin):
    list_display = ('title', 'company', 'deadline', 'is_active')

@admin.register(EmergencyContact)
class EmergencyContactAdmin(admin.ModelAdmin):
    list_display = ('title', 'category', 'number', 'is_active')

@admin.register(BusSchedule)
class BusScheduleAdmin(admin.ModelAdmin):
    list_display = ('route_name', 'departure_time', 'bus_type', 'fare')

@admin.register(TouristSpot)
class TouristSpotAdmin(admin.ModelAdmin):
    list_display = ('title', 'location', 'is_active')

@admin.register(EducationInstitution)
class EducationInstitutionAdmin(admin.ModelAdmin):
    list_display = ('name', 'institution_type', 'location', 'is_active')

@admin.register(ProfessionalService)
class ProfessionalServiceAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'phone', 'is_available')

@admin.register(Complaint)
class ComplaintAdmin(admin.ModelAdmin):
    list_display = ('complaint_type', 'name', 'phone', 'is_resolved', 'created_at')
    list_filter = ('is_resolved', 'complaint_type')

@admin.register(BloodDonor)
class BloodDonorAdmin(admin.ModelAdmin):
    list_display = ('name', 'blood_group', 'location', 'is_available')

@admin.register(Hospital)
class HospitalAdmin(admin.ModelAdmin):
    list_display = ('name', 'phone', 'is_verified', 'is_active', 'order')
    list_editable = ('is_verified', 'is_active', 'order')

@admin.register(Advertisement)
class AdvertisementAdmin(admin.ModelAdmin):
    list_display = ('title', 'is_active', 'created_at')
    list_editable = ('is_active',)

@admin.register(HomeService)
class HomeServiceAdmin(admin.ModelAdmin):
    list_display = ('title', 'icon', 'route_type', 'target', 'order', 'is_active')
    list_editable = ('order', 'is_active')

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug')
    prepopulated_fields = {'slug': ('name',)}

@admin.register(ReporterProfile)
class ReporterProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'is_verified', 'organization')
    list_filter = ('is_verified',)
    search_fields = ('user__username', 'organization')

@admin.register(NewsPost)
class NewsPostAdmin(admin.ModelAdmin):
    form = NewsPostForm
    list_display = ('title', 'author', 'status', 'is_published', 'is_breaking', 'breaking_type', 'created_at')
    list_filter = ('status', 'is_published', 'is_breaking', 'breaking_type', 'created_at')
    search_fields = ('title', 'content')
    
    def get_queryset(self, request):
        qs = super().get_queryset(request)
        if request.user.is_superuser or request.user.groups.filter(name='Moderator').exists():
            return qs
        return qs.filter(author=request.user)

    def get_readonly_fields(self, request, obj=None):
        if not request.user.is_superuser and not request.user.groups.filter(name='Moderator').exists():
            return ('status', 'is_published', 'author', 'organization_name')
        return ()

    def save_model(self, request, obj, form, change):
        if getattr(obj, 'author', None) is None:
            obj.author = request.user
        super().save_model(request, obj, form, change)
        
    def has_change_permission(self, request, obj=None):
        if obj is not None and not request.user.is_superuser and not request.user.groups.filter(name='Moderator').exists():
            if obj.author != request.user:
                return False
        return super().has_change_permission(request, obj)

@admin.register(GovernmentService)
class GovernmentServiceAdmin(admin.ModelAdmin):
    list_display = ('title', 'url', 'icon', 'is_active')
    list_editable = ('is_active',)
