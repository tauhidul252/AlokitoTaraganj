from rest_framework import serializers
from .models import NewsPost, Category

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
            'is_published', 'created_at',
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
