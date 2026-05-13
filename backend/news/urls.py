from django.urls import path
from . import views, views_dashboard

urlpatterns = [
    # API URLs
    path('api/v1/categories/', views.CategoryListAPIView.as_view(), name='category-list'),
    path('api/v1/news/', views.NewsPostListAPIView.as_view(), name='news-list'),
    path('api/v1/news/<int:pk>/', views.NewsPostDetailAPIView.as_view(), name='news-detail'),
    # Service APIs
    path('api/v1/blood-donors/', views.BloodDonorListAPIView.as_view(), name='api-blood-donors'),
    path('api/v1/doctors/', views.DoctorListAPIView.as_view(), name='api-doctors'),
    path('api/v1/jobs/', views.JobListAPIView.as_view(), name='api-jobs'),
    path('api/v1/emergency/', views.EmergencyContactListAPIView.as_view(), name='api-emergency'),
    path('api/v1/bus-schedules/', views.BusScheduleListAPIView.as_view(), name='api-bus'),
    path('api/v1/tourist-spots/', views.TouristSpotListAPIView.as_view(), name='api-tourist'),
    path('api/v1/education/', views.EducationListAPIView.as_view(), name='api-education'),
    path('api/v1/govt-services/', views.GovernmentServiceListAPIView.as_view(), name='api-govt'),
    path('api/v1/expert-services/', views.ProfessionalServiceListAPIView.as_view(), name='api-expert'),
    path('api/v1/complaints/', views.ComplaintCreateAPIView.as_view(), name='api-complaint-create'),
    path('api/v1/home-services/', views.HomeServiceList.as_view(), name='api-home-services'),
    path('api/v1/hospitals/', views.HospitalListCreateAPIView.as_view(), name='api-hospitals'),
    path('api/v1/ads/', views.AdvertisementListAPIView.as_view(), name='api-ads'),
    path('api/v1/ads/<int:pk>/view/', views.AdvertisementTrackViewAPI.as_view(), name='api-ads-track-view'),
    path('api/v1/ads/<int:pk>/click/', views.AdvertisementTrackClickAPI.as_view(), name='api-ads-track-click'),
    path('api/v1/settings/', views.AppConfigurationAPIView.as_view(), name='api-settings'),
    
    # Dashboard URLs
    path('login/', views_dashboard.DashboardLoginView.as_view(), name='dashboard-login'),
    path('logout/', views_dashboard.DashboardLogoutView.as_view(), name='dashboard-logout'),
    
    # Dashboard Home
    path('', views_dashboard.DashboardHomeView.as_view(), name='dashboard-home'),
    
    # Dashboard News URLs
    path('news/', views_dashboard.DashboardNewsListView.as_view(), name='dashboard-news-list'),
    path('news/create/', views_dashboard.DashboardNewsCreateView.as_view(), name='dashboard-news-create'),
    path('update/<int:pk>/', views_dashboard.DashboardNewsUpdateView.as_view(), name='dashboard-news-update'),
    path('delete/<int:pk>/', views_dashboard.DashboardNewsDeleteView.as_view(), name='dashboard-news-delete'),

    # Dashboard User URLs
    path('users/', views_dashboard.DashboardUserListView.as_view(), name='dashboard-user-list'),
    path('users/create/', views_dashboard.DashboardUserCreateView.as_view(), name='dashboard-user-create'),
    path('users/update/<int:pk>/', views_dashboard.DashboardUserUpdateView.as_view(), name='dashboard-user-update'),
    path('users/delete/<int:pk>/', views_dashboard.DashboardUserDeleteView.as_view(), name='dashboard-user-delete'),
    path('users/toggle-verify/<int:pk>/', views_dashboard.toggle_reporter_verify, name='dashboard-toggle-verify'),

    # Dashboard Category URLs
    path('categories/', views_dashboard.CategoryListView.as_view(), name='dashboard-category-list'),
    path('categories/create/', views_dashboard.CategoryCreateView.as_view(), name='dashboard-category-create'),
    path('categories/update/<int:pk>/', views_dashboard.CategoryUpdateView.as_view(), name='dashboard-category-update'),
    path('categories/delete/<int:pk>/', views_dashboard.CategoryDeleteView.as_view(), name='dashboard-category-delete'),

    # Profile & Settings
    path('profile/', views_dashboard.ProfileUpdateView.as_view(), name='dashboard-profile'),
    path('password-change/', views_dashboard.DashboardPasswordChangeView.as_view(), name='dashboard-password-change'),
    path('set-language/<str:lang_code>/', views_dashboard.set_language, name='set-language'),

    # ── Services ──────────────────────────────────────────────────────────────
    # Blood Donor
    path('services/blood/', views_dashboard.BloodDonorListView.as_view(), name='service-blood-list'),
    path('services/blood/add/', views_dashboard.BloodDonorCreateView.as_view(), name='service-blood-create'),
    path('services/blood/<int:pk>/edit/', views_dashboard.BloodDonorUpdateView.as_view(), name='service-blood-update'),
    path('services/blood/<int:pk>/delete/', views_dashboard.BloodDonorDeleteView.as_view(), name='service-blood-delete'),

    # Doctor
    path('services/doctors/', views_dashboard.DoctorListView.as_view(), name='service-doctor-list'),
    path('services/doctors/add/', views_dashboard.DoctorCreateView.as_view(), name='service-doctor-create'),
    path('services/doctors/<int:pk>/edit/', views_dashboard.DoctorUpdateView.as_view(), name='service-doctor-update'),
    path('services/doctors/<int:pk>/delete/', views_dashboard.DoctorDeleteView.as_view(), name='service-doctor-delete'),

    # Job
    path('services/jobs/', views_dashboard.JobListView.as_view(), name='service-job-list'),
    path('services/jobs/add/', views_dashboard.JobCreateView.as_view(), name='service-job-create'),
    path('services/jobs/<int:pk>/edit/', views_dashboard.JobUpdateView.as_view(), name='service-job-update'),
    path('services/jobs/<int:pk>/delete/', views_dashboard.JobDeleteView.as_view(), name='service-job-delete'),

    # Emergency Contact
    path('services/emergency/', views_dashboard.EmergencyContactListView.as_view(), name='service-emergency-list'),
    path('services/emergency/add/', views_dashboard.EmergencyContactCreateView.as_view(), name='service-emergency-create'),
    path('services/emergency/<int:pk>/edit/', views_dashboard.EmergencyContactUpdateView.as_view(), name='service-emergency-update'),
    path('services/emergency/<int:pk>/delete/', views_dashboard.EmergencyContactDeleteView.as_view(), name='service-emergency-delete'),

    # Bus Schedule
    path('services/bus/', views_dashboard.BusScheduleListView.as_view(), name='service-bus-list'),
    path('services/bus/add/', views_dashboard.BusScheduleCreateView.as_view(), name='service-bus-create'),
    path('services/bus/<int:pk>/edit/', views_dashboard.BusScheduleUpdateView.as_view(), name='service-bus-update'),
    path('services/bus/<int:pk>/delete/', views_dashboard.BusScheduleDeleteView.as_view(), name='service-bus-delete'),

    # Tourist Spot
    path('services/tourist/', views_dashboard.TouristSpotListView.as_view(), name='service-tourist-list'),
    path('services/tourist/add/', views_dashboard.TouristSpotCreateView.as_view(), name='service-tourist-create'),
    path('services/tourist/<int:pk>/edit/', views_dashboard.TouristSpotUpdateView.as_view(), name='service-tourist-update'),
    path('services/tourist/<int:pk>/delete/', views_dashboard.TouristSpotDeleteView.as_view(), name='service-tourist-delete'),

    # Education
    path('services/education/', views_dashboard.EducationListView.as_view(), name='service-education-list'),
    path('services/education/add/', views_dashboard.EducationCreateView.as_view(), name='service-education-create'),
    path('services/education/<int:pk>/edit/', views_dashboard.EducationUpdateView.as_view(), name='service-education-update'),
    path('services/education/<int:pk>/delete/', views_dashboard.EducationDeleteView.as_view(), name='service-education-delete'),

    # Govt Services
    path('services/govt/', views_dashboard.GovtServiceListView.as_view(), name='service-govt-list'),
    path('services/govt/add/', views_dashboard.GovtServiceCreateView.as_view(), name='service-govt-create'),
    path('services/govt/<int:pk>/edit/', views_dashboard.GovtServiceUpdateView.as_view(), name='service-govt-update'),
    path('services/govt/<int:pk>/delete/', views_dashboard.GovtServiceDeleteView.as_view(), name='service-govt-delete'),

    # Expert Services
    path('services/expert/', views_dashboard.ExpertServiceListView.as_view(), name='service-expert-list'),
    path('services/expert/add/', views_dashboard.ExpertServiceCreateView.as_view(), name='service-expert-create'),
    path('services/expert/<int:pk>/edit/', views_dashboard.ExpertServiceUpdateView.as_view(), name='service-expert-update'),
    path('services/expert/<int:pk>/delete/', views_dashboard.ExpertServiceDeleteView.as_view(), name='service-expert-delete'),

    # Complaints
    path('services/complaints/', views_dashboard.ComplaintListView.as_view(), name='service-complaint-list'),
    path('services/complaints/<int:pk>/edit/', views_dashboard.ComplaintUpdateView.as_view(), name='service-complaint-update'),
    path('services/complaints/<int:pk>/delete/', views_dashboard.ComplaintDeleteView.as_view(), name='service-complaint-delete'),
    # Hospital
    path('services/hospitals/', views_dashboard.HospitalListView.as_view(), name='service-hospital-list'),
    path('services/hospitals/add/', views_dashboard.HospitalCreateView.as_view(), name='service-hospital-create'),
    path('services/hospitals/<int:pk>/edit/', views_dashboard.HospitalUpdateView.as_view(), name='service-hospital-update'),
    path('services/hospitals/<int:pk>/delete/', views_dashboard.HospitalDeleteView.as_view(), name='service-hospital-delete'),
    # Advertisement
    path('services/ads/', views_dashboard.AdvertisementListView.as_view(), name='service-ad-list'),
    path('services/ads/add/', views_dashboard.AdvertisementCreateView.as_view(), name='service-ad-create'),
    path('services/ads/<int:pk>/edit/', views_dashboard.AdvertisementUpdateView.as_view(), name='service-ad-update'),
    path('services/ads/<int:pk>/delete/', views_dashboard.AdvertisementDeleteView.as_view(), name='service-ad-delete'),
    # App Settings
    path('settings/', views_dashboard.AppConfigurationUpdateView.as_view(), name='app-settings'),
]
