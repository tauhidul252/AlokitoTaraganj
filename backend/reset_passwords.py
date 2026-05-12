from django.contrib.auth.models import User

users_to_reset = ['admin', 'moderator', 'reporter']

for username in users_to_reset:
    try:
        u = User.objects.get(username=username)
        u.set_password(username + '123')
        u.save()
        print(f'Successfully reset password for {username} to {username}123')
    except User.DoesNotExist:
        print(f'User {username} not found, skipping.')
