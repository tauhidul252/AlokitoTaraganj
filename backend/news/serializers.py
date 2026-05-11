from rest_framework import serializers
from .models import NewsPost

class NewsPostSerializer(serializers.ModelSerializer):
    class Meta:
        model = NewsPost
        fields = ['id', 'title', 'content', 'image', 'source', 'is_published', 'created_at']
