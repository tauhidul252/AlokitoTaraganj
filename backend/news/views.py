from rest_framework import generics, views as rf_views, status
from rest_framework.response import Response
from .models import (NewsPost, Category, BloodDonor, Doctor, Job, 
    EmergencyContact, BusSchedule, TouristSpot, EducationInstitution, 
    GovernmentService, ProfessionalService, Complaint, HomeService, Hospital, Advertisement, AppConfiguration)
from .serializers import (NewsPostSerializer, CategorySerializer,
    BloodDonorSerializer, DoctorSerializer, JobSerializer,
    EmergencyContactSerializer, BusScheduleSerializer, TouristSpotSerializer,
    EducationSerializer, GovernmentServiceSerializer, ProfessionalServiceSerializer,
    ComplaintSerializer, HomeServiceSerializer, HospitalSerializer, AdvertisementSerializer, AppConfigurationSerializer)

class CategoryListAPIView(generics.ListAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

class NewsPostListAPIView(generics.ListAPIView):
    serializer_class = NewsPostSerializer

    def get_queryset(self):
        queryset = NewsPost.objects.filter(is_published=True)
        
        search_query = self.request.query_params.get('search')
        if search_query:
            from django.db.models import Q
            queryset = queryset.filter(Q(title__icontains=search_query) | Q(content__icontains=search_query))

        category_id = self.request.query_params.get('category')
        if category_id and category_id != '0': # '0' represents 'All'
            queryset = queryset.filter(category_id=category_id)
            
        today_filter = self.request.query_params.get('today')
        if today_filter == 'true':
            from django.utils import timezone
            queryset = queryset.filter(created_at__date=timezone.now().date())
            
        return queryset.order_by('-created_at')

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

from django.db.models import F, FloatField, ExpressionWrapper, Case, When
from django.utils import timezone

class AdvertisementListAPIView(generics.ListAPIView):
    serializer_class = AdvertisementSerializer

    def get_queryset(self):
        today = timezone.now().date()
        qs = Advertisement.objects.filter(is_active=True)
        
        # Filter out expired ads or future ads
        qs = qs.exclude(start_date__gt=today)
        qs = qs.exclude(end_date__lt=today)
        
        # Filter out maxed impression ads (if target_views > 0)
        qs = qs.exclude(target_views__gt=0, views__gte=F('target_views'))
        
        # Algorithmic Sort: Calculate CTR and sort by Priority > CTR > Date
        qs = qs.annotate(
            ctr_calc=ExpressionWrapper(
                Case(
                    When(views=0, then=0.0),
                    default=(F('clicks') * 100.0) / F('views'),
                    output_field=FloatField()
                ),
                output_field=FloatField()
            )
        ).order_by('-priority', '-ctr_calc', '-created_at')
        
        return qs

class AppConfigurationAPIView(generics.RetrieveAPIView):
    serializer_class = AppConfigurationSerializer

    def get_object(self):
        obj, created = AppConfiguration.objects.get_or_create(id=1)
        return obj

class AdvertisementTrackViewAPI(rf_views.APIView):
    def post(self, request, pk, *args, **kwargs):
        try:
            ad = Advertisement.objects.get(pk=pk)
            ad.views += 1
            ad.save(update_fields=['views'])
            return Response({"status": "success", "views": ad.views})
        except Advertisement.DoesNotExist:
            return Response({"status": "not found"}, status=status.HTTP_404_NOT_FOUND)

class AdvertisementTrackClickAPI(rf_views.APIView):
    def post(self, request, pk, *args, **kwargs):
        try:
            ad = Advertisement.objects.get(pk=pk)
            ad.clicks += 1
            ad.save(update_fields=['clicks'])
            return Response({"status": "success", "clicks": ad.clicks})
        except Advertisement.DoesNotExist:
            return Response({"status": "not found"}, status=status.HTTP_404_NOT_FOUND)
