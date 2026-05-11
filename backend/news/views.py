from rest_framework import generics
from .models import NewsPost
from .serializers import NewsPostSerializer

class NewsPostListAPIView(generics.ListAPIView):
    queryset = NewsPost.objects.filter(is_published=True)
    serializer_class = NewsPostSerializer

class NewsPostDetailAPIView(generics.RetrieveAPIView):
    queryset = NewsPost.objects.filter(is_published=True)
    serializer_class = NewsPostSerializer
