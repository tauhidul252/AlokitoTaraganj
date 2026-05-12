import os
import django
import random
from datetime import datetime, timedelta

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from news.models import (BloodDonor, Doctor, Job, EmergencyContact, 
                         BusSchedule, TouristSpot, EducationInstitution, 
                         GovernmentService, ProfessionalService, Complaint, HomeService)

def populate():
    print("Populating Demo Data...")

    # 1. Blood Donors
    groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
    locations = ['Taraganj Bazar', 'Kuratoli', 'Hadiari', 'Sayer', 'Alampur', 'Ikarchali']
    for i in range(12):
        BloodDonor.objects.get_or_create(
            name=f"Donor {i+1}",
            blood_group=random.choice(groups),
            phone=f"017123456{i:02d}",
            location=random.choice(locations),
            is_available=random.choice([True, True, False])
        )

    # 2. Doctors
    specialties = ['Medicine', 'Cardiology', 'Pediatrics', 'Gynae', 'Orthopedics', 'Dental']
    for i in range(10):
        Doctor.objects.get_or_create(
            name=f"Dr. {random.choice(['Abir', 'Sifat', 'Rahat', 'Nadia', 'Tasfia'])} {i+1}",
            specialty=random.choice(specialties),
            degree="MBBS, BCS (Health)",
            location="Upazila Health Complex, Taraganj",
            phone=f"018123456{i:02d}",
            is_available=True
        )

    # 3. Jobs
    job_types = ['Full Time', 'Part Time', 'Contract']
    for i in range(10):
        Job.objects.get_or_create(
            title=f"Position {i+1}",
            company=f"Taraganj Enterprise {i+1}",
            location="Taraganj, Rangpur",
            description="We are looking for an energetic candidate for this position.",
            job_type=random.choice(job_types),
            deadline=datetime.now().date() + timedelta(days=random.randint(5, 30)),
            apply_link="https://example.com/apply"
        )

    # 4. Emergency Contacts
    icons = ['phone', 'shield', 'flame', 'ambulance']
    categories = ['General', 'Police', 'Fire', 'Hospital', 'Ambulance']
    for i in range(20):
        cat = random.choice(categories)
        EmergencyContact.objects.get_or_create(
            title=f"{cat} Contact {i+1}",
            category=cat,
            number=f"12{i+1}",
            subtitle="Available 24/7",
            icon=random.choice(icons),
            color_hex=random.choice(['#ef4444', '#f97316', '#3b82f6', '#10b981']),
            order=i
        )

    # 5. Bus Schedules
    routes = ['Taraganj to Dhaka', 'Taraganj to Rangpur', 'Dhaka to Taraganj']
    bus_types = ['AC', 'Non-AC']
    for i in range(10):
        BusSchedule.objects.get_or_create(
            route_name=random.choice(routes),
            departure_time=f"{random.randint(7, 22):02d}:00:00",
            bus_type=random.choice(bus_types),
            fare=random.randint(200, 1200)
        )

    # 6. Tourist Spots
    for i in range(8):
        TouristSpot.objects.get_or_create(
            title=f"Beautiful Spot {i+1}",
            description="A very calm and beautiful place to visit with family and friends in Taraganj.",
            location="Taraganj, Rangpur",
            image_url="https://images.unsplash.com/photo-1500382017468-9049fed747ef",
            order=i
        )

    # 7. Education
    edu_types = ['Primary', 'High School', 'College', 'University', 'Madrasa']
    for i in range(12):
        EducationInstitution.objects.get_or_create(
            name=f"Institution {i+1}",
            institution_type=random.choice(edu_types),
            location="Taraganj",
            phone=f"015123456{i:02d}"
        )

    # 8. Govt Services
    govt_icons = ['credit_card', 'map', 'book', 'globe']
    for i in range(10):
        GovernmentService.objects.get_or_create(
            title=f"E-Service {i+1}",
            description="Access official government portal for this service.",
            url="https://bangladesh.gov.bd",
            icon=random.choice(govt_icons)
        )

    # 9. Professional Services
    prof_cats = ['Electrician', 'Plumber', 'Mason', 'Cleaner', 'Truck Rental']
    for i in range(15):
        ProfessionalService.objects.get_or_create(
            category=random.choice(prof_cats),
            name=f"Expert {i+1}",
            phone=f"019123456{i:02d}",
            location="Taraganj Area"
        )

    # 10. Complaints
    comp_types = ['Road', 'Water', 'Electricity', 'Corruption']
    for i in range(10):
        Complaint.objects.create(
            name=f"Complainant {i+1}",
            phone=f"017000000{i:02d}",
            complaint_type=random.choice(comp_types),
            description=f"Issue reported regarding {random.choice(comp_types).lower()} quality in our area.",
            is_anonymous=random.choice([True, False])
        )

    # 11. Home Services
    home_services = [
        ('E-Services', 'globe', '#3b82f6', 'screen', 'GovernmentServicesScreen', 0),
        ('Blood Bank', 'droplet', '#ef4444', 'screen', 'BloodBankScreen', 1),
        ('Find Doctor', 'user-plus', '#06b6d4', 'screen', 'FindDoctorScreen', 2),
        ('Emergency', 'phone-call', '#f87171', 'tab', '3', 3),
        ('Expert Svc', 'hammer', '#92400e', 'screen', 'ProfessionalServicesScreen', 4),
        ('Job Board', 'briefcase', '#3f51b5', 'screen', 'JobBoardScreen', 5),
        ('Complaint', 'message-square', '#f97316', 'screen', 'ComplaintBoxScreen', 6),
        ('News', 'newspaper', '#03a9f4', 'tab', '1', 7),
        ('Hospitals', 'stethoscope', '#009688', 'screen', 'HospitalScreen', 8),
        ('Police', 'shield-alert', '#3f51b5', 'screen', 'PoliceScreen', 9),
        ('Fire Svc', 'flame', '#f59e0b', 'screen', 'FireServiceScreen', 10),
        ('Directory', 'book-open', '#9c27b0', 'tab', '2', 11),
        ('Transport', 'bus', '#4caf50', 'screen', 'TransportScreen', 12),
        ('Tourism', 'camera', '#e91e63', 'screen', 'TouristSpotsScreen', 13),
        ('Education', 'graduation-cap', '#795548', 'screen', 'EducationScreen', 14),
    ]
    for title, icon, color, r_type, target, order in home_services:
        HomeService.objects.get_or_create(
            title=title, icon=icon, color_hex=color, 
            route_type=r_type, target=target, order=order
        )

    print("Success: 100+ demo entries added!")

if __name__ == '__main__':
    populate()
