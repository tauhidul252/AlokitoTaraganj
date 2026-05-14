from django.db import models
from django.contrib.auth.models import User

class Category(models.Model):
    name = models.CharField(max_length=100, verbose_name="ক্যাটাগরি নাম")
    slug = models.SlugField(unique=True)

    class Meta:
        verbose_name = "সংবাদ ক্যাটাগরি"
        verbose_name_plural = "সংবাদ ক্যাটাগরিসমূহ"

    def __str__(self):
        return self.name

class ReporterProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='reporter_profile')
    organization = models.CharField(max_length=150, blank=True, null=True, default='', verbose_name="নিউজ অর্গানাইজেশন")
    is_verified = models.BooleanField(default=False, verbose_name="ভেরিফাইড?")
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    bio = models.TextField(blank=True, default='')

    def __str__(self):
        return f"Profile of {self.user.username}"

class NewsPost(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    title = models.CharField(max_length=200, verbose_name="শিরোনাম")
    category = models.ForeignKey(Category, on_delete=models.CASCADE, verbose_name="ক্যাটাগরি", null=True, blank=True)
    content = models.TextField(verbose_name="বিস্তারিত সংবাদ")
    image = models.ImageField(upload_to='news_images/', null=True, blank=True, verbose_name="ছবি")
    author = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name="লেখক", null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', verbose_name="অবস্থা")
    source = models.CharField(max_length=100, blank=True, verbose_name="উৎস")
    organization_name = models.CharField(max_length=150, blank=True, null=True, default='', verbose_name="সংস্থার নাম")
    is_published = models.BooleanField(default=False, verbose_name="প্রকাশিত?")
    is_breaking = models.BooleanField(default=False, verbose_name="ব্রেকিং নিউজ?")
    BREAKING_CHOICES = [
        ('BREAKING', 'BREAKING'),
        ('বিজ্ঞপ্তি', 'বিজ্ঞপ্তি (Notice)'),
        ('ঘোষণা', 'ঘোষণা (Announcement)'),
        ('জরুরি', 'জরুরি (Emergency)'),
        ('Other', 'অন্যান্য (Other)'),
    ]
    breaking_type = models.CharField(max_length=50, default='BREAKING', verbose_name="ব্রেকিং টাইপ")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "সংবাদ"
        verbose_name_plural = "সংবাদসমূহ"
        ordering = ['-created_at']

    def __str__(self):
        return self.title

class NewsEditHistory(models.Model):
    news = models.ForeignKey(NewsPost, on_delete=models.CASCADE, related_name='edit_history')
    editor = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    edited_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)
    previous_status = models.CharField(max_length=20, default='', null=True, blank=True)
    new_status = models.CharField(max_length=20, default='', null=True, blank=True)
    comment = models.TextField(blank=True, null=True)

    class Meta:
        verbose_name = "নিউজ এডিট ইতিহাস"
        verbose_name_plural = "নিউজ এডিট ইতিহাসসমূহ"


# ─── Service Models ────────────────────────────────────────────────────────────

class BloodDonor(models.Model):
    BLOOD_GROUPS = [
        ('A+', 'A+'), ('A-', 'A-'),
        ('B+', 'B+'), ('B-', 'B-'),
        ('AB+', 'AB+'), ('AB-', 'AB-'),
        ('O+', 'O+'), ('O-', 'O-'),
    ]
    name = models.CharField(max_length=100, verbose_name="দাতার নাম")
    blood_group = models.CharField(max_length=5, choices=BLOOD_GROUPS, verbose_name="রক্তের গ্রুপ")
    phone = models.CharField(max_length=20, verbose_name="ফোন নম্বর")
    location = models.CharField(max_length=150, verbose_name="অবস্থান")
    is_available = models.BooleanField(default=True, verbose_name="এভেইল্যাবল?")
    last_donation_date = models.DateField(null=True, blank=True, verbose_name="শেষ রক্তদানের তারিখ")
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "রক্তদাতা"
        verbose_name_plural = "রক্তদাতাসমূহ"
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} ({self.blood_group})"

class Doctor(models.Model):
    name = models.CharField(max_length=150, verbose_name="ডাক্তারের নাম")
    specialty = models.CharField(max_length=100, verbose_name="বিশেষজ্ঞ")
    degree = models.CharField(max_length=200, verbose_name="ডিগ্রি")
    location = models.CharField(max_length=200, verbose_name="চেম্বার/হাসপাতাল")
    phone = models.CharField(max_length=100, blank=True, verbose_name="ফোন (ঐচ্ছিক)")
    is_available = models.BooleanField(default=True, verbose_name="সক্রিয়?")
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "ডাক্তার"
        verbose_name_plural = "ডাক্তারগণ"
        ordering = ['-created_at']

    def __str__(self):
        return self.name

class Job(models.Model):
    JOB_TYPES = [
        ('Full Time', 'Full Time'),
        ('Part Time', 'Part Time'),
        ('Contract', 'Contract'),
        ('Internship', 'Internship'),
    ]
    title = models.CharField(max_length=200, verbose_name="পদবি")
    company = models.CharField(max_length=200, verbose_name="কোম্পানি")
    job_type = models.CharField(max_length=50, choices=JOB_TYPES, default='Full Time', verbose_name="ধরণ")
    description = models.TextField(verbose_name="বিবরণ")
    location = models.CharField(max_length=200, verbose_name="অবস্থান")
    deadline = models.DateField(verbose_name="ডেডলাইন")
    apply_link = models.URLField(blank=True, verbose_name="আবেদনের লিংক")
    is_active = models.BooleanField(default=True, verbose_name="সক্রিয়?")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "চাকরির বিজ্ঞপ্তি"
        verbose_name_plural = "চাকরির বিজ্ঞপ্তিসমূহ"
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} at {self.company}"


class EmergencyContact(models.Model):
    CATEGORY_CHOICES = [
        ('General', 'General'),
        ('Police', 'Police'),
        ('Fire', 'Fire Service'),
        ('Hospital', 'Hospital'),
        ('Ambulance', 'Ambulance'),
    ]
    title = models.CharField(max_length=150, verbose_name="শিরোনাম")
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='General', verbose_name="ধরণ")
    number = models.CharField(max_length=30, verbose_name="নম্বর")
    subtitle = models.CharField(max_length=200, blank=True, verbose_name="বিবরণ")
    icon = models.CharField(max_length=50, default='phone', verbose_name="আইকন (lucide)")
    color_hex = models.CharField(max_length=10, default='#1d4ed8', verbose_name="রঙ (Hex)")
    order = models.PositiveIntegerField(default=0, verbose_name="ক্রম")
    is_active = models.BooleanField(default=True, verbose_name="সক্রিয়?")
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "জরুরি যোগাযোগ"
        verbose_name_plural = "জরুরি যোগাযোগসমূহ"
        ordering = ['order', 'title']

    def __str__(self):
        return f"{self.title} - {self.number}"


class Hospital(models.Model):
    name = models.CharField(max_length=200, verbose_name="হাসপাতালের নাম", null=True, blank=True, default='')
    address = models.TextField(verbose_name="ঠিকানা", null=True, blank=True, default='')
    specialized_services = models.CharField(max_length=500, blank=True, help_text="ICU, NICU, Dialysis etc.", verbose_name="বিশেষ সেবা", default='')
    phone = models.CharField(max_length=100, verbose_name="ফোন নম্বর", null=True, blank=True, default='')
    image = models.ImageField(upload_to='hospitals/', blank=True, null=True, verbose_name="ছবি")
    is_verified = models.BooleanField(default=False, verbose_name="ভেরিফাইড?")
    order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "হাসপাতাল"
        verbose_name_plural = "হাসপাতালসমূহ"
        ordering = ['order', 'name']

    def __str__(self):
        return self.name if self.name else "Unnamed Hospital"

class BusSchedule(models.Model):
    route_name = models.CharField(max_length=200, verbose_name="রুটের নাম", null=True, blank=True, default='')
    departure_time = models.TimeField(verbose_name="ছাড়ার সময়", null=True, blank=True)
    bus_type = models.CharField(max_length=50, default='Regular', verbose_name="বাসের ধরন (AC/Non-AC)")
    fare = models.DecimalField(max_digits=8, decimal_places=2, verbose_name="ভাড়া (টাকা)", null=True, blank=True)
    is_active = models.BooleanField(default=True, verbose_name="সক্রিয়?")
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "বাস সময়সূচি"
        verbose_name_plural = "বাস সময়সূচিসমূহ"
        ordering = ['departure_time']

    def __str__(self):
        return f"{self.route_name} - {self.departure_time}"


class TouristSpot(models.Model):
    title = models.CharField(max_length=200, verbose_name="নাম", null=True, blank=True, default='')
    description = models.TextField(verbose_name="বিবরণ", null=True, blank=True, default='')
    image_url = models.URLField(blank=True, verbose_name="ছবির URL", default='')
    image = models.ImageField(upload_to='tourist_spots/', null=True, blank=True, verbose_name="ছবি আপলোড")
    location = models.CharField(max_length=200, blank=True, verbose_name="অবস্থান", default='')
    map_link = models.URLField(blank=True, verbose_name="ম্যাপ লিংক", default='')
    order = models.PositiveIntegerField(default=0, verbose_name="ক্রম")
    is_active = models.BooleanField(default=True, verbose_name="সক্রিয়?")
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "পর্যটন স্থান"
        verbose_name_plural = "পর্যটন স্থানসমূহ"
        ordering = ['order', 'title']

    def __str__(self):
        return self.title if self.title else "Unnamed Spot"


class EducationInstitution(models.Model):
    INSTITUTION_TYPES = [
        ('Primary', 'Primary School'),
        ('High School', 'High School'),
        ('College', 'College'),
        ('University', 'University'),
        ('Madrasa', 'Madrasa'),
        ('Other', 'Other'),
    ]
    name = models.CharField(max_length=200, null=True, blank=True, default='')
    institution_type = models.CharField(max_length=50, choices=INSTITUTION_TYPES, null=True, blank=True)
    location = models.CharField(max_length=200, null=True, blank=True, default='')
    phone = models.CharField(max_length=50, blank=True, null=True, default='')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "শিক্ষা প্রতিষ্ঠান"
        verbose_name_plural = "শিক্ষা প্রতিষ্ঠানসমূহ"
        ordering = ['-created_at']

    def __str__(self):
        return self.name if self.name else "Unnamed Institution"


class GovernmentService(models.Model):
    title = models.CharField(max_length=200, null=True, blank=True, default='')
    description = models.TextField(blank=True, null=True, default='')
    url = models.URLField(null=True, blank=True, default='')
    icon = models.CharField(max_length=50, default='globe')
    logo = models.ImageField(upload_to='govt_services/', null=True, blank=True, verbose_name="লোগো/ছবি")
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "সরকারি সেবা"
        verbose_name_plural = "সরকারি সেবাসমূহ"
        ordering = ['-created_at']

    def __str__(self):
        return self.title if self.title else "Unnamed Service"


class ProfessionalService(models.Model):
    category = models.CharField(max_length=100, verbose_name="ক্যাটাগরি (উদা: ইলেকট্রিশিয়ান, মেকানিক)", null=True, blank=True, default='')
    name = models.CharField(max_length=150, verbose_name="নাম", null=True, blank=True, default='')
    phone = models.CharField(max_length=50, verbose_name="ফোন নম্বর", null=True, blank=True, default='')
    location = models.CharField(max_length=200, verbose_name="ঠিকানা/এলাকা", null=True, blank=True, default='')
    is_available = models.BooleanField(default=True, verbose_name="এখন পাওয়া যাবে?")
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    class Meta:
        verbose_name = "পেশাজীবী সেবা"
        verbose_name_plural = "পেশাজীবী সেবাসমূহ"
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} ({self.category})"


class Complaint(models.Model):
    COMPLAINT_TYPES = [
        ('Electricity', 'বিদ্যুৎ'),
        ('Water', 'পানি'),
        ('Roads', 'রাস্তাঘাট'),
        ('Waste', 'বর্জ্য'),
        ('Other', 'অন্যান্য'),
    ]
    name = models.CharField(max_length=100, blank=True, null=True, default='')
    phone = models.CharField(max_length=20, blank=True, null=True, default='')
    complaint_type = models.CharField(max_length=50, choices=COMPLAINT_TYPES, null=True, blank=True)
    description = models.TextField(null=True, blank=True, default='')
    is_anonymous = models.BooleanField(default=False)
    is_resolved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "অভিযোগ"
        verbose_name_plural = "অভিযোগসমূহ"
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.complaint_type} - {self.created_at.date()}"


class HomeService(models.Model):
    title = models.CharField(max_length=100, verbose_name="সেবার নাম", default='')
    icon = models.CharField(max_length=50, default='wrench', verbose_name="আইকন (Lucide)")
    color_hex = models.CharField(max_length=10, default='#3b82f6', verbose_name="রঙ (Hex)")
    route_type = models.CharField(max_length=20, choices=[('screen', 'Screen'), ('tab', 'Tab')], default='screen')
    target = models.CharField(max_length=100, blank=True, verbose_name="টার্গেট (Screen Name or Tab Index)")
    order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)

    class Meta:
        verbose_name = "হোম সার্ভিস"
        verbose_name_plural = "হোম সার্ভিসসমূহ"
        ordering = ['order']

    def __str__(self):
        return self.title

class Advertisement(models.Model):
    title = models.CharField(max_length=200, verbose_name="বিজ্ঞাপনের শিরোনাম")
    image = models.ImageField(upload_to='ads/', verbose_name="বিজ্ঞাপন ছবি", help_text="সেরা ফলাফলের জন্য ৬০০x১০০ পিক্সেল (আড়াআড়ি) সাইজের ইমেজ ব্যবহার করুন।")
    link = models.URLField(blank=True, null=True, verbose_name="লিংক (ঐচ্ছিক)")
    is_active = models.BooleanField(default=True, verbose_name="সক্রিয়?")
    views = models.PositiveIntegerField(default=0, verbose_name="ইমপ্রেশন (Views)")
    clicks = models.PositiveIntegerField(default=0, verbose_name="ক্লিকসমূহ")
    target_views = models.PositiveIntegerField(default=0, verbose_name="টার্গেট ইমপ্রেশন", help_text="০ দিলে আনলিমিটেড")
    priority = models.PositiveIntegerField(default=1, verbose_name="প্রায়োরিটি", help_text="বেশি হলে অ্যাড আগে দেখাবে")
    start_date = models.DateField(null=True, blank=True, verbose_name="শুরুর তারিখ")
    end_date = models.DateField(null=True, blank=True, verbose_name="শেষের তারিখ")
    PLACEMENT_CHOICES = [
        ('all', 'সব পেজ (All)'),
        ('home', 'হোম পেজ (Home)'),
        ('news', 'নিউজ পেজ (News)'),
        ('emergency', 'জরুরি সেবা (Emergency)'),
        ('directory', 'ডিরেক্টরি (Directory)'),
        ('hospital', 'হাসপাতাল (Hospital)'),
        ('professional', 'পেশাজীবী সেবা (Professional)'),
        ('job_board', 'জব বোর্ড (Jobs)'),
        ('blood', 'রক্তদান (Blood)'),
        ('complaint', 'অভিযোগ (Complaint)'),
        ('education', 'শিক্ষা প্রতিষ্ঠান (Education)'),
        ('site_footer', 'Site Footer (Global Bottom)'),
    ]
    placement = models.CharField(max_length=50, choices=PLACEMENT_CHOICES, default='all', verbose_name="অ্যাড প্লেসমেন্ট")
    created_at = models.DateTimeField(auto_now_add=True)

    @property
    def ctr(self):
        if self.views == 0:
            return 0.0
        return (self.clicks / self.views) * 100.0

    class Meta:
        verbose_name = "বিজ্ঞাপন"
        verbose_name_plural = "বিজ্ঞাপনসমূহ"
        ordering = ['-created_at']

    def __str__(self):
        return self.title

class AppConfiguration(models.Model):
    # Global settings
    is_admob_enabled_global = models.BooleanField(default=True, verbose_name="গ্লোবাল AdMob চালু?")
    is_local_ads_enabled_global = models.BooleanField(default=True, verbose_name="গ্লোবাল লোকাল অ্যাড চালু?")
    ad_carousel_interval = models.PositiveIntegerField(default=5, verbose_name="অ্যাড ক্যারোসেল বিরতি (সেকেন্ড)")
    admob_frequency = models.PositiveIntegerField(default=3, verbose_name="অ্যাডমোব ফ্রিকোয়েন্সি")
    
    # Fraud Protection
    fraud_20m_limit = models.IntegerField(default=5, verbose_name="Fraud: Limit 1 (Clicks)")
    fraud_20m_window = models.IntegerField(default=20, verbose_name="Fraud: Window 1 (Minutes)")
    fraud_2h_limit = models.IntegerField(default=10, verbose_name="Fraud: Limit 2 (Clicks)")
    fraud_2h_window = models.IntegerField(default=120, verbose_name="Fraud: Window 2 (Minutes)")
    fraud_block_hours = models.IntegerField(default=2, verbose_name="Fraud: Block Duration (Hours)")
    
    # Home Page
    show_admob_home = models.BooleanField(default=True, verbose_name="Home: AdMob")
    show_local_home = models.BooleanField(default=True, verbose_name="Home: Local Ads")
    
    # News Page
    show_admob_news = models.BooleanField(default=True, verbose_name="News: AdMob")
    show_local_news = models.BooleanField(default=True, verbose_name="News: Local Ads")
    
    # Emergency Page
    show_admob_emergency = models.BooleanField(default=True, verbose_name="Emergency: AdMob")
    show_local_emergency = models.BooleanField(default=True, verbose_name="Emergency: Local Ads")
    
    # Directory Page
    show_admob_directory = models.BooleanField(default=True, verbose_name="Directory: AdMob")
    show_local_directory = models.BooleanField(default=True, verbose_name="Directory: Local Ads")

    # Service Pages
    show_admob_professional = models.BooleanField(default=True, verbose_name="Professional: AdMob")
    show_local_professional = models.BooleanField(default=True, verbose_name="Professional: Local Ads")
    
    show_admob_job_board = models.BooleanField(default=True, verbose_name="Job Board: AdMob")
    show_local_job_board = models.BooleanField(default=True, verbose_name="Job Board: Local Ads")
    
    show_admob_complaint = models.BooleanField(default=True, verbose_name="Complaint: AdMob")
    show_local_complaint = models.BooleanField(default=True, verbose_name="Complaint: Local Ads")
    
    show_admob_hospital = models.BooleanField(default=True, verbose_name="Hospital: AdMob")
    show_local_hospital = models.BooleanField(default=True, verbose_name="Hospital: Local Ads")
    
    show_admob_doctor = models.BooleanField(default=True, verbose_name="Doctor: AdMob")
    show_local_doctor = models.BooleanField(default=True, verbose_name="Doctor: Local Ads")
    
    show_admob_blood = models.BooleanField(default=True, verbose_name="Blood Bank: AdMob")
    show_local_blood = models.BooleanField(default=True, verbose_name="Blood Bank: Local Ads")
    
    show_admob_transport = models.BooleanField(default=True, verbose_name="Transport: AdMob")
    show_local_transport = models.BooleanField(default=True, verbose_name="Transport: Local Ads")
    
    show_admob_education = models.BooleanField(default=True, verbose_name="Education: AdMob")
    show_local_education = models.BooleanField(default=True, verbose_name="Education: Local Ads")
    
    show_admob_government = models.BooleanField(default=True, verbose_name="Government: AdMob")
    show_local_government = models.BooleanField(default=True, verbose_name="Government: Local Ads")
    
    show_admob_tourist = models.BooleanField(default=True, verbose_name="Tourist: AdMob")
    show_local_tourist = models.BooleanField(default=True, verbose_name="Tourist: Local Ads")

    # Site Footer Banner (Marked banner in UI)
    show_admob_site_footer = models.BooleanField(default=True, verbose_name="Site Footer: AdMob")
    show_local_site_footer = models.BooleanField(default=True, verbose_name="Site Footer: Local Ads")

    class Meta:
        verbose_name = "অ্যাপ সেটিংস"
        verbose_name_plural = "অ্যাপ সেটিংস"
        
    def __str__(self):
        return "App Settings"
