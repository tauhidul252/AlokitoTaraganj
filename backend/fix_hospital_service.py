import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from news.models import HomeService

def fix_hospital_service():
    # Update or create the Hospital home service
    service, created = HomeService.objects.get_or_create(
        title='Hospitals',
        defaults={
            'icon': 'stethoscope',
            'color_hex': '#0D9488',
            'route_type': 'screen',
            'target': 'HospitalScreen',
            'order': 9
        }
    )
    if not created:
        service.target = 'HospitalScreen'
        service.route_type = 'screen'
        service.save()
        print("Updated existing Hospital service.")
    else:
        print("Created new Hospital service.")

if __name__ == '__main__':
    fix_hospital_service()
