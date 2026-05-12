from rest_framework import generics
from .models import (NewsPost, Category, BloodDonor, Doctor, Job, 
    EmergencyContact, BusSchedule, TouristSpot, EducationInstitution, 
    GovernmentService, ProfessionalService, Complaint, HomeService, Hospital, Advertisement)
from .serializers import (NewsPostSerializer, CategorySerializer,
    BloodDonorSerializer, DoctorSerializer, JobSerializer,
    EmergencyContactSerializer, BusScheduleSerializer, TouristSpotSerializer,
    EducationSerializer, GovernmentServiceSerializer, ProfessionalServiceSerializer,
    ComplaintSerializer, HomeServiceSerializer, HospitalSerializer, AdvertisementSerializer)

class CategoryListAPIView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

class NewsPostListAPIView(generics.ListAPIView):
    serializer_class = NewsPostSerializer

    def get_queryset(self):
        queryset = NewsPost.objects.filter(is_published=True)
        category_id = self.request.query_params.get('category')
        if category_id and category_id != '0': # '0' represents 'All'
            queryset = queryset.filter(category_id=category_id)
            
        today_filter = self.request.query_params.get('today')
        if today_filter == 'true':
            from django.utils import timezone
            queryset = queryset.filter(created_at__date=timezone.now().date())
            
        return queryset

class NewsPostDetailAPIView(generics.RetrieveAPIView):
    queryset = NewsPost.objects.filter(is_published=True)
    serializer_class = NewsPostSerializer


# ─── Service API Views ─────────────────────────────────────────────────────────

class BloodDonorListAPIView(generics.ListAPIView):
    queryset = BloodDonor.objects.filter(is_available=True)
    serializer_class = BloodDonorSerializer

    def get_queryset(self):
        qs = BloodDonor.objects.filter(is_available=True)
        group = self.request.query_params.get('group')
        if group:
            qs = qs.filter(blood_group=group)
        return qs

class DoctorListAPIView(generics.ListAPIView):
    queryset = Doctor.objects.filter(is_available=True)
    serializer_class = DoctorSerializer

    def get_queryset(self):
        qs = Doctor.objects.filter(is_available=True)
        specialty = self.request.query_params.get('specialty')
        if specialty:
            qs = qs.filter(specialty__icontains=specialty)
        return qs

class JobListAPIView(generics.ListAPIView):
    queryset = Job.objects.filter(is_active=True)
    serializer_class = JobSerializer

class EmergencyContactListAPIView(generics.ListAPIView):
    serializer_class = EmergencyContactSerializer
    
    def get_queryset(self):
        queryset = EmergencyContact.objects.filter(is_active=True)
        category = self.request.query_params.get('category')
        if category:
            queryset = queryset.filter(category=category)
        return queryset

class BusScheduleListAPIView(generics.ListAPIView):
    queryset = BusSchedule.objects.filter(is_active=True)
    serializer_class = BusScheduleSerializer

class TouristSpotListAPIView(generics.ListAPIView):
    queryset = TouristSpot.objects.filter(is_active=True)
    serializer_class = TouristSpotSerializer


class EducationListAPIView(generics.ListAPIView):
    queryset = EducationInstitution.objects.filter(is_active=True)
    serializer_class = EducationSerializer


class GovernmentServiceListAPIView(generics.ListAPIView):
    queryset = GovernmentService.objects.filter(is_active=True)
    serializer_class = GovernmentServiceSerializer


class ProfessionalServiceListAPIView(generics.ListAPIView):
    queryset = ProfessionalService.objects.filter(is_available=True)
    serializer_class = ProfessionalServiceSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        cat = self.request.query_params.get('category')
        if cat:
            qs = qs.filter(category=cat)
        return qs


class ComplaintCreateAPIView(generics.CreateAPIView):
    queryset = Complaint.objects.all()
    serializer_class = ComplaintSerializer

class HomeServiceList(generics.ListAPIView):
    queryset = HomeService.objects.filter(is_active=True)
    serializer_class = HomeServiceSerializer

class HospitalListCreateAPIView(generics.ListCreateAPIView):
    queryset = Hospital.objects.filter(is_active=True)
    serializer_class = HospitalSerializer

class AdvertisementListAPIView(generics.ListAPIView):
    queryset = Advertisement.objects.filter(is_active=True)
    serializer_class = AdvertisementSerializer
