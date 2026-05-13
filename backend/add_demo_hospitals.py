import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from news.models import Hospital

def add_demo_hospitals():
    hospitals = [
        {
            'name': 'Taraganj Upazila Health Complex',
            'address': 'Taraganj, Rangpur',
            'specialized_services': 'Emergency, Maternity, Outpatient',
            'phone': '01712-345678',
            'is_verified': True,
            'order': 1
        },
        {
            'name': 'Rangpur Medical College Hospital',
            'address': 'Rangpur City',
            'specialized_services': 'ICU, CCU, Surgery, Dialysis, Cardiology',
            'phone': '0521-65432',
            'is_verified': True,
            'order': 2
        },
        {
            'name': 'Popular Diagnostic Center',
            'address': 'Dhap, Rangpur',
            'specialized_services': 'Pathology, Radiology, Specialized Doctor Consultations',
            'phone': '01911-223344',
            'is_verified': True,
            'order': 3
        },
        {
            'name': 'Christian Missionary Hospital',
            'address': 'Rangpur',
            'specialized_services': 'General Surgery, Medicine',
            'phone': '01711-998877',
            'is_verified': False,
            'order': 4
        },
        {
            'name': 'Prime Medical College & Hospital',
            'address': 'Pirzabad, Rangpur',
            'specialized_services': 'Medical Education, General Health Services',
            'phone': '01819-001122',
            'is_verified': True,
            'order': 5
        }
    ]

    for h_data in hospitals:
        hospital, created = Hospital.objects.get_or_create(
            name=h_data['name'],
            defaults={
                'address': h_data['address'],
                'specialized_services': h_data['specialized_services'],
                'phone': h_data['phone'],
                'is_verified': h_data['is_verified'],
                'order': h_data['order']
            }
        )
        if created:
            print(f"Created hospital: {hospital.name}")
        else:
            print(f"Hospital already exists: {hospital.name}")

if __name__ == '__main__':
    add_demo_hospitals()
