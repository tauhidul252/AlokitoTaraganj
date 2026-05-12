from django.contrib.auth.models import User, Group

for username in ['moderator', 'reporter']:
    try:
        u = User.objects.get(username=username)
        groups = list(u.groups.values_list('name', flat=True))
        print(username, 'is_active:', u.is_active, 'is_staff:', u.is_staff, 'groups:', groups, 'has_usable_pw:', u.has_usable_password())
    except User.DoesNotExist:
        print(username, 'not found')
