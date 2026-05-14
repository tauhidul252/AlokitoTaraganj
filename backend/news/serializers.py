from rest_framework import serializers
from .models import (NewsPost, Category, BloodDonor, Doctor, Job, 
    EmergencyContact, BusSchedule, TouristSpot, EducationInstitution, 
    GovernmentService, ProfessionalService, Complaint, HomeService, Hospital, Advertisement, AppConfiguration)

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'slug']

class NewsPostSerializer(serializers.ModelSerializer):
    category_name = serializers.ReadOnlyField(source='category.name')
    is_verified    = serializers.SerializerMethodField()
    author_name    = serializers.SerializerMethodField()
    author_organization = serializers.SerializerMethodField()

    class Meta:
        model = NewsPost
        fields = [
            'id', 'title', 'category', 'category_name',
            'content', 'image', 'source',
            'organization_name',
            'author_name', 'author_organization', 'is_verified',
            'is_published', 'is_breaking', 'breaking_type', 'created_at',
        ]

    def get_is_verified(self, obj):
        if obj.author and hasattr(obj.author, 'reporter_profile'):
            return obj.author.reporter_profile.is_verified
        return False

    def get_author_name(self, obj):
        if obj.author:
            full = obj.author.get_full_name()
            return full if full.strip() else obj.author.username
        return None

    def get_author_organization(self, obj):
        """Return reporter's organization from ReporterProfile if set."""
        if obj.author and hasattr(obj.author, 'reporter_profile'):
            return obj.author.reporter_profile.organization or None
        return None


# ─── Service Serializers ─────────────────────────────────────────────────────────

class BloodDonorSerializer(serializers.ModelSerializer):
    class Meta:
        model = BloodDonor
        fields = ['id', 'name', 'blood_group', 'phone', 'location', 'is_available']

class DoctorSerializer(serializers.ModelSerializer):
    class Meta:
        model = Doctor
        fields = ['id', 'name', 'specialty', 'degree', 'location', 'phone', 'is_available']

class JobSerializer(serializers.ModelSerializer):
    class Meta:
        model = Job
        fields = ['id', 'title', 'company', 'job_type', 'description', 'location', 'deadline', 'apply_link', 'is_active']

class EmergencyContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyContact
        fields = ['id', 'title', 'category', 'number', 'subtitle', 'icon', 'color_hex', 'order', 'is_active']

class BusScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = BusSchedule
        fields = ['id', 'route_name', 'departure_time', 'bus_type', 'fare', 'is_active']

class TouristSpotSerializer(serializers.ModelSerializer):
    class Meta:
        model = TouristSpot
        fields = ['id', 'title', 'description', 'image_url', 'image', 'location', 'map_link', 'order', 'is_active']


class EducationSerializer(serializers.ModelSerializer):
    class Meta:
        model = EducationInstitution
        fields = ['id', 'name', 'institution_type', 'location', 'phone', 'is_active']


class GovernmentServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = GovernmentService
        fields = ['id', 'title', 'description', 'url', 'icon', 'logo', 'is_active']


class ProfessionalServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProfessionalService
        fields = ['id', 'category', 'name', 'phone', 'location', 'is_available']


class ComplaintSerializer(serializers.ModelSerializer):
    class Meta:
        model = Complaint
        fields = ['id', 'name', 'phone', 'complaint_type', 'description', 'is_anonymous', 'created_at', 'is_resolved']
        read_only_fields = ['created_at', 'is_resolved']


class HomeServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = HomeService
        fields = '__all__'

class HospitalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Hospital
        fields = '__all__'

class AdvertisementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Advertisement
        fields = '__all__'

class AppConfigurationSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppConfiguration
        fields = '__all__'
