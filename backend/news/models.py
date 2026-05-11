from django.db import models
from django.contrib.auth.models import User

class NewsPost(models.Model):
    STATUS_CHOICES = (
        ('pending', 'অপেক্ষমান (Pending)'),
        ('approved', 'অনুমোদিত (Approved)'),
        ('rejected', 'বাতিল (Rejected)'),
    )

    title = models.CharField(max_length=200, verbose_name="শিরোনাম")
    content = models.TextField(verbose_name="বিস্তারিত খবর")
    image = models.ImageField(upload_to='news_images/', null=True, blank=True, verbose_name="খবরের ছবি")
    
    author = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, verbose_name="প্রতিবেদক/রিপোর্টার")
    source = models.CharField(max_length=100, default="নিজস্ব প্রতিবেদক", verbose_name="খবরের উৎস")
    
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
