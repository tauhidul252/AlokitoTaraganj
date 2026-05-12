from django.urls import path
from . import views, views_dashboard

urlpatterns = [
    # API URLs
    path('api/v1/categories/', views.CategoryListAPIView.as_view(), name='category-list'),
    path('api/v1/news/', views.NewsPostListAPIView.as_view(), name='news-list'),
    path('api/v1/news/<int:pk>/', views.NewsPostDetailAPIView.as_view(), name='news-detail'),
    
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
]
