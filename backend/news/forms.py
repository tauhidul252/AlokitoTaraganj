from django import forms
from .models import NewsPost, Category, ReporterProfile
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
        fields = ['title', 'category', 'content', 'image', 'source', 'status']
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
        }

    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop('user', None)
        self.t = kwargs.pop('t', None) # Get translation dictionary
        super(NewsPostForm, self).__init__(*args, **kwargs)
        
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
