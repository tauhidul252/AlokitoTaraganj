from django.db import models
from django.contrib.auth.models import User

class Category(models.Model):
    name = models.CharField(max_length=100, verbose_name="ক্যাটাগরি নাম")
    slug = models.SlugField(max_length=120, unique=True, verbose_name="স্লাগ")

    class Meta:
        verbose_name = "ক্যাটাগরি"
        verbose_name_plural = "ক্যাটাগরি সমূহ"

    def __str__(self):
        return self.name

class ReporterProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='reporter_profile')
    is_verified = models.BooleanField(default=False, verbose_name="ভেরিফাইড?")
    organization = models.CharField(max_length=150, blank=True, null=True, verbose_name="সংবাদ প্রতিষ্ঠান")
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True, verbose_name="প্রোফাইল ছবি")
    bio = models.TextField(blank=True, null=True, verbose_name="পরিচিতি")

    def __str__(self):
        return f"{self.user.username} - {'Verified' if self.is_verified else 'Not Verified'}"

    class Meta:
        verbose_name = "রিপোর্টার প্রোফাইল"
        verbose_name_plural = "রিপোর্টার প্রোফাইল সমূহ"

class NewsPost(models.Model):
    STATUS_CHOICES = (
        ('pending', 'অপেক্ষমান (Pending)'),
        ('approved', 'অনুমোদিত (Approved)'),
        ('rejected', 'বাতিল (Rejected)'),
    )

    title = models.CharField(max_length=200, verbose_name="শিরোনাম")
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='news_posts', verbose_name="ক্যাটাগরি")
    content = models.TextField(verbose_name="বিস্তারিত খবর")
    image = models.ImageField(upload_to='news_images/', null=True, blank=True, verbose_name="খবরের ছবি")
    
    author = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='authored_news', verbose_name="প্রতিবেদক/রিপোর্টার")
    approved_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='approved_news', verbose_name="অনুমোদনকারী")
    source = models.CharField(max_length=100, default="নিজস্ব প্রতিবেদক", verbose_name="খবরের উৎস")
    organization_name = models.CharField(max_length=100, blank=True, null=True, verbose_name="সংবাদ প্রতিষ্ঠানের নাম")
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', verbose_name="স্ট্যাটাস")
    is_published = models.BooleanField(default=False, verbose_name="প্রকাশিত?")
    
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="রিপোর্ট জমার সময়")
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = "নিউজ পোস্ট"
        verbose_name_plural = "নিউজ পোস্টসমূহ"

    def __str__(self):
        return self.title

    def save(self, *args, **kwargs):
        # Automatically set is_published based on status
        if self.status == 'approved':
            self.is_published = True
        else:
            self.is_published = False
        super().save(*args, **kwargs)

class NewsEditHistory(models.Model):
    ACTION_CHOICES = (
        ('edit', 'এডিট করা হয়েছে (Edited)'),
        ('status_change', 'স্ট্যাটাস পরিবর্তন (Status Changed)'),
    )

    news = models.ForeignKey(NewsPost, on_delete=models.CASCADE, related_name='history', verbose_name="নিউজ")
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, verbose_name="ব্যবহারকারী")
    action_type = models.CharField(max_length=20, choices=ACTION_CHOICES, verbose_name="ধরণ")
    
    old_status = models.CharField(max_length=20, null=True, blank=True, verbose_name="পুরানো স্ট্যাটাস")
    new_status = models.CharField(max_length=20, null=True, blank=True, verbose_name="নতুন স্ট্যাটাস")
    
    changes = models.TextField(null=True, blank=True, verbose_name="পরিবর্তনের বিবরণ")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="সময়")

    class Meta:
        ordering = ['-created_at']
        verbose_name = "এডিট হিস্ট্রি"
        verbose_name_plural = "এডিট হিস্ট্রি"

    def __str__(self):
        return f"{self.news.title} - {self.action_type} by {self.user.username}"
