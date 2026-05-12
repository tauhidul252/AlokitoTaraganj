from django.contrib import admin
from .models import NewsPost, Category, ReporterProfile

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
    list_display = ('title', 'author', 'status', 'is_published', 'created_at')
    list_filter = ('status', 'is_published', 'created_at')
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
