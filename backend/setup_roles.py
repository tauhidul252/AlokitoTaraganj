import os
import django

# Initialize Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.contrib.auth.models import Group, Permission
from django.contrib.contenttypes.models import ContentType
from news.models import NewsPost

def setup_roles():
    print("Setting up User Roles: Moderator and Reporter...")
    
    # Create Groups
    moderator_group, created = Group.objects.get_or_create(name='Moderator')
    collector_group, created = Group.objects.get_or_create(name='Reporter')
    
    # Get ContentType for NewsPost
    news_content_type = ContentType.objects.get_for_model(NewsPost)
    
    # Get permissions
    add_news = Permission.objects.get(codename='add_newspost', content_type=news_content_type)
    change_news = Permission.objects.get(codename='change_newspost', content_type=news_content_type)
    delete_news = Permission.objects.get(codename='delete_newspost', content_type=news_content_type)
    view_news = Permission.objects.get(codename='view_newspost', content_type=news_content_type)
    
    # Moderator permissions: Can add, change, delete, view
    moderator_group.permissions.add(add_news, change_news, delete_news, view_news)
    
    # Reporter permissions: Can add, change, view (Logic in views filters out other's posts)
    collector_group.permissions.add(add_news, change_news, view_news)
    
    print("Roles and permissions configured successfully!")

if __name__ == "__main__":
    setup_roles()
