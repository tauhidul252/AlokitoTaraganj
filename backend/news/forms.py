from django import forms
from .models import NewsPost
from django.contrib.auth.models import User, Group

class NewsPostForm(forms.ModelForm):
    class Meta:
        model = NewsPost
        fields = ['title', 'content', 'image', 'source', 'status']
        widgets = {
            'title': forms.TextInput(attrs={
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

class UserForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput(attrs={
        'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
    }), required=False)
    groups = forms.ModelMultipleChoiceField(
        queryset=Group.objects.all(),
        widget=forms.CheckboxSelectMultiple(attrs={
            'class': 'rounded text-blue-600 focus:ring-blue-500'
        }),
        required=False,
    )

    class Meta:
        model = User
        fields = ['username', 'first_name', 'last_name', 'email', 'password', 'groups']
        widgets = {
            'username': forms.TextInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            }),
            'first_name': forms.TextInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            }),
            'last_name': forms.TextInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            }),
            'email': forms.EmailInput(attrs={
                'class': 'w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all',
            }),
        }

    def __init__(self, *args, **kwargs):
        self.t = kwargs.pop('t', None)
        super(UserForm, self).__init__(*args, **kwargs)
        if self.t:
            if 'username' in self.fields: self.fields['username'].widget.attrs['placeholder'] = self.t.get('ph_username', '')
            if 'first_name' in self.fields: self.fields['first_name'].widget.attrs['placeholder'] = self.t.get('ph_name', '')
            if 'last_name' in self.fields: self.fields['last_name'].widget.attrs['placeholder'] = self.t.get('ph_surname', '')
            if 'email' in self.fields: self.fields['email'].widget.attrs['placeholder'] = self.t.get('ph_email', '')
            if 'password' in self.fields: self.fields['password'].widget.attrs['placeholder'] = self.t.get('ph_password', '')
            if 'groups' in self.fields: self.fields['groups'].label = self.t.get('roles', 'Roles')

    def save(self, commit=True):
        user = super().save(commit=False)
        password = self.cleaned_data.get("password")
        if password:
            user.set_password(password)
        if commit:
            user.save()
            if 'groups' in self.cleaned_data:
                user.groups.set(self.cleaned_data['groups'])
        return user
