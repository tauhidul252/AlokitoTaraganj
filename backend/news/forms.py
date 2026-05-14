from django import forms
from .models import (NewsPost, Category, ReporterProfile, BloodDonor, 
    Doctor, Job, EmergencyContact, BusSchedule, TouristSpot, 
    EducationInstitution, GovernmentService, ProfessionalService, Complaint, Hospital, Advertisement, HomeService, AppConfiguration)
from django.contrib.auth.models import User, Group

class CategoryForm(forms.ModelForm):
    class Meta:
        model = Category
        fields = ['name', 'slug']
        widgets = {
            'name': forms.TextInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            }),
            'slug': forms.TextInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
                'placeholder': 'e.g. politics'
            }),
        }

class NewsPostForm(forms.ModelForm):
    class Meta:
        model = NewsPost
        fields = ['title', 'category', 'content', 'image', 'source', 'status', 'is_breaking', 'breaking_type', 'custom_breaking_type']
        widgets = {
            'title': forms.TextInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            }),
            'category': forms.Select(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            }),
            'content': forms.Textarea(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
                'rows': 5,
            }),
            'source': forms.TextInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            }),
            'image': forms.FileInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 transition-all'
            }),
            'status': forms.Select(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'
            }),
            'is_breaking': forms.CheckboxInput(attrs={
                'class': 'w-5 h-5 rounded text-blue-600 focus:ring-blue-500 transition-all'
            }),
            'breaking_type': forms.Select(
                choices=NewsPost.BREAKING_CHOICES,
                attrs={
                    'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all bg-white',
                }
            ),
        }
    
    custom_breaking_type = forms.CharField(
        required=False,
        label="অন্যান্য টাইপ লিখুন (Custom Type)",
        widget=forms.TextInput(attrs={
            'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            'placeholder': 'টাইপ এখানে লিখুন...'
        })
    )

    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop('user', None)
        self.t = kwargs.pop('t', None) # Get translation dictionary
        super(NewsPostForm, self).__init__(*args, **kwargs)
        
        # Handle custom breaking type if it's not in choices
        if self.instance.pk and self.instance.breaking_type:
            choice_values = [c[0] for c in NewsPost.BREAKING_CHOICES]
            if self.instance.breaking_type not in choice_values:
                self.initial['breaking_type'] = 'Other'
                self.initial['custom_breaking_type'] = self.instance.breaking_type

        # Set dynamic placeholders and labels if t is provided
        if self.t:
            if 'title' in self.fields: self.fields['title'].widget.attrs['placeholder'] = self.t.get('ph_title', '')
            if 'content' in self.fields: self.fields['content'].widget.attrs['placeholder'] = self.t.get('ph_content', '')
            if 'source' in self.fields: self.fields['source'].widget.attrs['placeholder'] = self.t.get('ph_source', '')
            
            # Dynamically set status choices based on translation dictionary
            if 'status' in self.fields:
                self.fields['status'].choices = [
                    ('pending', self.t.get('pending_label', 'Pending')),
                    ('approved', self.t.get('approved_label', 'Approved')),
                    ('rejected', self.t.get('rejected_label', 'Rejected')),
                ]

        # Only allow admin or moderators to change the status
        if 'status' in self.fields:
            # If not admin and not moderator, remove status (for reporters)
            if self.user and not self.user.is_superuser and not self.user.groups.filter(name='Moderator').exists():
                self.fields.pop('status')
            # If news is already approved and user is not superuser, disable status change
            elif self.instance.pk and self.instance.status == 'approved' and not self.user.is_superuser:
                self.fields['status'].disabled = True
                self.fields['status'].help_text = "অনুমোদিত নিউজ শুধুমাত্র অ্যাডমিন পরিবর্তন করতে পারবেন।" if self.t and self.t.get('bn') else "Only Admin can change approved status."
    
    def clean(self):
        cleaned_data = super().clean()
        bt = cleaned_data.get('breaking_type')
        cbt = cleaned_data.get('custom_breaking_type')
        
        if bt == 'Other' and cbt:
            cleaned_data['breaking_type'] = cbt
            self.instance.breaking_type = cbt
        else:
            self.instance.breaking_type = bt
            
        return cleaned_data

    def save(self, commit=True):
        instance = super().save(commit=False)
        # breaking_type is already set in clean()
        if commit:
            instance.save()
        return instance

class AdminUserForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput(attrs={
        'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
    }), required=False)
    role = forms.ChoiceField(
        choices=[
            ('Admin', 'Admin'),
            ('Moderator', 'Moderator'),
            ('Reporter', 'Reporter'),
        ],
        widget=forms.Select(attrs={
            'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'
        }),
        required=False,
    )
    is_verified = forms.BooleanField(required=False)
    organization = forms.CharField(max_length=150, required=False, widget=forms.TextInput(attrs={
        'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
    }))

    class Meta:
        model = User
        fields = ['username', 'first_name', 'last_name', 'email', 'role']
        widgets = {
            'username': forms.TextInput(attrs={'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'}),
            'first_name': forms.TextInput(attrs={'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'}),
            'last_name': forms.TextInput(attrs={'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'}),
            'email': forms.EmailInput(attrs={'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'}),
        }

    def __init__(self, *args, **kwargs):
        self.t = kwargs.pop('t', None)
        kwargs.pop('requesting_user', None)  # Consumed by view; not needed in form logic
        super(AdminUserForm, self).__init__(*args, **kwargs)
        if self.t:
            if 'username' in self.fields: self.fields['username'].widget.attrs['placeholder'] = self.t.get('ph_username', '')
            if 'first_name' in self.fields: self.fields['first_name'].widget.attrs['placeholder'] = self.t.get('ph_name', '')
            if 'last_name' in self.fields: self.fields['last_name'].widget.attrs['placeholder'] = self.t.get('ph_surname', '')
            if 'email' in self.fields: self.fields['email'].widget.attrs['placeholder'] = self.t.get('ph_email', '')
            if 'password' in self.fields: self.fields['password'].widget.attrs['placeholder'] = self.t.get('ph_password', '')
            
            # Translate labels and choices
            if 'role' in self.fields:
                self.fields['role'].label = self.t.get('roles', 'Role')
                self.fields['role'].choices = [
                    ('', '— ' + self.t.get('select_role', 'Select Role') + ' —'),
                    ('Admin', self.t.get('admin', 'Admin')),
                    ('Moderator', self.t.get('moderator', 'Moderator')),
                    ('Reporter', self.t.get('reporter', 'Reporter')),
                ]
            
            # Set initial role for updates
            if self.instance.pk:
                if self.instance.is_superuser:
                    self.initial['role'] = 'Admin'
                elif self.instance.groups.filter(name='Moderator').exists():
                    self.initial['role'] = 'Moderator'
                elif self.instance.groups.filter(name='Reporter').exists():
                    self.initial['role'] = 'Reporter'
                
                # Load profile data if exists
                if hasattr(self.instance, 'reporter_profile'):
                    self.initial['is_verified'] = self.instance.reporter_profile.is_verified
                    self.initial['organization'] = self.instance.reporter_profile.organization
            
            self.fields['is_verified'].label = self.t.get('is_verified', "Verified Reporter?")
            self.fields['organization'].label = self.t.get('organization', "News Organization")
            self.fields['organization'].widget.attrs['placeholder'] = self.t.get('ph_organization', 'e.g. Alokito Taraganj')

    def save(self, commit=True):
        user = super().save(commit=False)
        password = self.cleaned_data.get("password")
        if password:
            user.set_password(password)
        elif not self.instance.pk:
            user.set_unusable_password()

        # Apply role-based permissions
        role_name = self.cleaned_data.get('role')
        if role_name == 'Admin':
            user.is_superuser = True
            user.is_staff = True
        elif role_name == 'Moderator':
            user.is_superuser = False
            user.is_staff = True
        else:  # Reporter or blank
            user.is_superuser = False
            user.is_staff = False

        if commit:
            user.save()
            if role_name == 'Admin':
                user.groups.clear()  # Admins don't need a group
            elif role_name:
                group, _ = Group.objects.get_or_create(name=role_name)
                user.groups.set([group])

            # Handle ReporterProfile
            is_verified = self.cleaned_data.get('is_verified', False)
            organization = self.cleaned_data.get('organization', '')
            profile, _ = ReporterProfile.objects.get_or_create(user=user)
            profile.is_verified = is_verified
            profile.organization = organization
            profile.save()

        return user

class ProfileForm(forms.ModelForm):
    # Fields from ReporterProfile
    avatar = forms.ImageField(required=False, widget=forms.FileInput(attrs={
        'class': 'hidden',
        'id': 'avatar-input',
        'accept': 'image/*'
    }))
    bio = forms.CharField(required=False, widget=forms.Textarea(attrs={
        'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all resize-none',
        'rows': 3,
    }))

    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'email']
        widgets = {
            'first_name': forms.TextInput(attrs={'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'}),
            'last_name': forms.TextInput(attrs={'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'}),
            'email': forms.EmailInput(attrs={'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'}),
        }

    def __init__(self, *args, **kwargs):
        self.t = kwargs.pop('t', None)
        super(ProfileForm, self).__init__(*args, **kwargs)
        # Load existing profile data
        if self.instance.pk:
            try:
                profile = self.instance.reporter_profile
                self.initial['bio'] = profile.bio
            except Exception:
                pass
        if self.t:
            if 'first_name' in self.fields: self.fields['first_name'].widget.attrs['placeholder'] = self.t.get('ph_name', '')
            if 'last_name' in self.fields: self.fields['last_name'].widget.attrs['placeholder'] = self.t.get('ph_surname', '')
            if 'email' in self.fields: self.fields['email'].widget.attrs['placeholder'] = self.t.get('ph_email', '')
            self.fields['bio'].widget.attrs['placeholder'] = '{% if lang == "bn" %}নিজের সম্পর্কে লিখুন...{% else %}Write about yourself...{% endif %}'

    def save(self, commit=True):
        user = super().save(commit=commit)
        if commit:
            profile, _ = ReporterProfile.objects.get_or_create(user=user)
            profile.bio = self.cleaned_data.get('bio', '')
            if self.cleaned_data.get('avatar'):
                profile.avatar = self.cleaned_data['avatar']
            profile.save()
        return user


# ─── Service Forms ──────────────────────────────────────────────────────────

INPUT_CLASS = 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all'
SELECT_CLASS = 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all bg-white'
TEXTAREA_CLASS = 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all resize-none'
FILE_CLASS = 'w-full px-4 py-3 rounded-xl border border-gray-200 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100'


class BloodDonorForm(forms.ModelForm):
    class Meta:
        model = BloodDonor
        fields = ['name', 'blood_group', 'phone', 'location', 'is_available']
        widgets = {
            'name': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Rahim Uddin'}),
            'blood_group': forms.Select(attrs={'class': SELECT_CLASS}),
            'phone': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': '01XXXXXXXXX'}),
            'location': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Sadar, Taraganj'}),
            'is_available': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


class DoctorForm(forms.ModelForm):
    class Meta:
        model = Doctor
        fields = ['name', 'specialty', 'degree', 'location', 'phone', 'is_available']
        widgets = {
            'name': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'Dr. Abdul Malek'}),
            'specialty': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Cardiologist'}),
            'degree': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. MBBS, FCPS'}),
            'location': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Sadar Hospital'}),
            'phone': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': '01XXXXXXXXX (optional)'}),
            'is_available': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


class JobForm(forms.ModelForm):
    class Meta:
        model = Job
        fields = ['title', 'company', 'job_type', 'description', 'location', 'deadline', 'apply_link', 'is_active']
        widgets = {
            'title': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Sales Executive'}),
            'company': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Local Distributor Ltd.'}),
            'job_type': forms.Select(attrs={'class': SELECT_CLASS}),
            'description': forms.Textarea(attrs={'class': TEXTAREA_CLASS, 'rows': 4, 'placeholder': 'Job description...'}),
            'location': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Sadar Road'}),
            'deadline': forms.DateInput(attrs={'class': INPUT_CLASS, 'type': 'date'}),
            'apply_link': forms.URLInput(attrs={'class': INPUT_CLASS, 'placeholder': 'https://...'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


class EmergencyContactForm(forms.ModelForm):
    class Meta:
        model = EmergencyContact
        fields = ['title', 'number', 'subtitle', 'icon', 'color_hex', 'order', 'is_active']
        widgets = {
            'title': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Police Control Room'}),
            'number': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 999'}),
            'subtitle': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 24/7 Service'}),
            'icon': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'lucide icon name e.g. phone, shield'}),
            'color_hex': forms.TextInput(attrs={'class': INPUT_CLASS, 'type': 'color'}),
            'order': forms.NumberInput(attrs={'class': INPUT_CLASS}),
            'is_active': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


class BusScheduleForm(forms.ModelForm):
    class Meta:
        model = BusSchedule
        fields = ['route_name', 'departure_time', 'bus_type', 'fare', 'is_active']
        widgets = {
            'route_name': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Dhaka to Taraganj'}),
            'departure_time': forms.TimeInput(attrs={'class': INPUT_CLASS, 'type': 'time'}),
            'bus_type': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. AC / Non-AC'}),
            'fare': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': '500'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields:
            if not isinstance(self.fields[field].widget, (forms.CheckboxInput, forms.RadioSelect)):
                self.fields[field].widget.attrs.update({'class': INPUT_CLASS})

class TouristSpotForm(forms.ModelForm):
    class Meta:
        model = TouristSpot
        fields = ['title', 'description', 'image_url', 'image', 'location', 'map_link', 'order', 'is_active']
        widgets = {
            'title': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Lalbagh Fort'}),
            'description': forms.Textarea(attrs={'class': TEXTAREA_CLASS, 'rows': 4, 'placeholder': 'Description...'}),
            'image_url': forms.URLInput(attrs={'class': INPUT_CLASS, 'placeholder': 'https://... (image URL)'}),
            'image': forms.FileInput(attrs={'class': FILE_CLASS}),
            'location': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. Old Dhaka'}),
            'map_link': forms.URLInput(attrs={'class': INPUT_CLASS, 'placeholder': 'https://maps.google.com/...'}),
            'order': forms.NumberInput(attrs={'class': INPUT_CLASS}),
            'is_active': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


class EducationForm(forms.ModelForm):
    class Meta:
        model = EducationInstitution
        fields = ['name', 'institution_type', 'location', 'phone', 'is_active']
        widgets = {
            'name': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'institution_type': forms.Select(attrs={'class': INPUT_CLASS}),
            'location': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'phone': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'is_active': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


class GovernmentServiceForm(forms.ModelForm):
    class Meta:
        model = GovernmentService
        fields = ['title', 'description', 'url', 'icon', 'logo', 'is_active']
        widgets = {
            'title': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'description': forms.Textarea(attrs={'class': TEXTAREA_CLASS, 'rows': 3}),
            'url': forms.URLInput(attrs={'class': INPUT_CLASS}),
            'icon': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'logo': forms.FileInput(attrs={'class': FILE_CLASS}),
            'is_active': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


class ProfessionalServiceForm(forms.ModelForm):
    class Meta:
        model = ProfessionalService
        fields = ['category', 'name', 'phone', 'location', 'is_available']
        widgets = {
            'category': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'name': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'phone': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'location': forms.TextInput(attrs={'class': INPUT_CLASS}),
            'is_available': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }


class ComplaintForm(forms.ModelForm):
    class Meta:
        model = Complaint
        fields = ['complaint_type', 'description', 'is_resolved']
        widgets = {
            'complaint_type': forms.Select(attrs={'class': INPUT_CLASS}),
            'description': forms.Textarea(attrs={'class': TEXTAREA_CLASS, 'rows': 4}),
            'is_resolved': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }
class HospitalForm(forms.ModelForm):
    class Meta:
        model = Hospital
        fields = ['name', 'address', 'specialized_services', 'phone', 'image', 'is_verified', 'is_active', 'order']
        widgets = {
            'name': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'হাসপাতালের নাম'}),
            'address': forms.Textarea(attrs={'class': TEXTAREA_CLASS, 'rows': 3, 'placeholder': 'ঠিকানা'}),
            'specialized_services': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. ICU, NICU'}),
            'phone': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'ফোন নম্বর'}),
            'image': forms.FileInput(attrs={'class': FILE_CLASS}),
            'is_verified': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'order': forms.NumberInput(attrs={'class': INPUT_CLASS}),
        }

class AdvertisementForm(forms.ModelForm):
    class Meta:
        model = Advertisement
        fields = ['title', 'image', 'link', 'placement', 'start_date', 'end_date', 'target_views', 'priority', 'is_active']
        widgets = {
            'title': forms.TextInput(attrs={'class': INPUT_CLASS, 'placeholder': 'বিজ্ঞাপনের শিরোনাম'}),
            'image': forms.FileInput(attrs={'class': FILE_CLASS}),
            'link': forms.URLInput(attrs={'class': INPUT_CLASS, 'placeholder': 'লিংক (ঐচ্ছিক)'}),
            'placement': forms.Select(attrs={'class': INPUT_CLASS}),
            'start_date': forms.DateInput(attrs={'class': INPUT_CLASS, 'type': 'date'}),
            'end_date': forms.DateInput(attrs={'class': INPUT_CLASS, 'type': 'date'}),
            'target_views': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': '০ দিলে আনলিমিটেড'}),
            'priority': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': '১ থেকে ১০'}),
            'is_active': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }
        help_texts = {
            'image': 'সেরা ফলাফলের জন্য ৬০০x১০০ পিক্সেল সাইজের ইমেজ ব্যবহার করুন (Recommended: 600x100 px).',
        }

class AppConfigurationForm(forms.ModelForm):
    class Meta:
        model = AppConfiguration
        fields = '__all__'
        widgets = {
            'is_admob_enabled_global': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'is_local_ads_enabled_global': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'ad_carousel_interval': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 5'}),
            'admob_frequency': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 3'}),
            'fraud_20m_limit': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 5'}),
            'fraud_20m_window': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 20'}),
            'fraud_2h_limit': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 10'}),
            'fraud_2h_window': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 120'}),
            'fraud_block_hours': forms.NumberInput(attrs={'class': INPUT_CLASS, 'placeholder': 'e.g. 2'}),
            
            # Per-page Checkboxes
            'show_admob_home': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_home': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_news': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_news': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_emergency': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_emergency': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_directory': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_directory': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_professional': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_professional': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_job_board': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_job_board': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_complaint': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_complaint': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_hospital': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_hospital': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_doctor': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_doctor': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_blood': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_blood': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_transport': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_transport': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_education': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_education': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_government': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_government': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_tourist': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_tourist': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_admob_site_footer': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
            'show_local_site_footer': forms.CheckboxInput(attrs={'class': 'w-5 h-5 rounded text-blue-600'}),
        }
        help_texts = {
            'is_admob_enabled_global': 'পুরো অ্যাপে AdMob বিজ্ঞাপন চালু বা বন্ধ করুন।',
            'is_local_ads_enabled_global': 'পুরো অ্যাপে লোকাল (আপনার আপলোড করা) বিজ্ঞাপন চালু বা বন্ধ করুন।',
            'ad_carousel_interval': 'কত সেকেন্ড পর পর ব্যানার বিজ্ঞাপন পরিবর্তন হবে।',
            'admob_frequency': 'কতগুলো লোকাল অ্যাডের পর একটি AdMob অ্যাড শো করবে।',
            'fraud_20m_limit': 'প্রথম সময় সীমার মধ্যে সর্বোচ্চ কতবার ক্লিক করা যাবে।',
            'fraud_20m_window': 'প্রথম ক্লিক ট্র্যাকিং পিরিয়ড (মিনিটে)।',
            'fraud_2h_limit': 'দ্বিতীয় সময় সীমার মধ্যে সর্বোচ্চ কতবার ক্লিক করা যাবে।',
            'fraud_2h_window': 'দ্বিতীয় ক্লিক ট্র্যাকিং পিরিয়ড (মিনিটে)।',
            'fraud_block_hours': 'লিমিট ক্রস করলে কত ঘণ্টার জন্য ওই ডিভাইস থেকে অ্যাড বন্ধ থাকবে।',
        }
