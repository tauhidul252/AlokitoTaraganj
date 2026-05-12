from rest_framework import generics
from .models import NewsPost, Category
from .serializers import NewsPostSerializer, CategorySerializer

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
