import os
import django
import urllib.request
from django.core.files.base import ContentFile
import random

# Initialize Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from news.models import NewsPost

def generate_news():
    print("Generating 15+ news posts...")
    
    titles = [
        "তারাগঞ্জে নতুন শিক্ষা প্রকল্প উদ্বোধন",
        "স্থানীয় কৃষকদের জন্য বিশেষ প্রণোদনা ঘোষণা",
        "তারাগঞ্জ হাইস্কুলে বার্ষিক ক্রীড়া প্রতিযোগিতা সম্পন্ন",
        "উপজেলা স্বাস্থ্য কমপ্লেক্সে নতুন অ্যাম্বুলেন্স প্রদান",
        "তারাগঞ্জে শীতবস্ত্র বিতরণ করল স্বেচ্ছাসেবী সংগঠন",
        "বন্যায় ক্ষতিগ্রস্তদের মাঝে ত্রাণ সামগ্রী বিতরণ",
        "তারাগঞ্জ বাজারে ভ্রাম্যমাণ আদালতের অভিযান",
        "নতুন রাস্তা নির্মাণের কাজ শুরু, জনমনে স্বস্তি",
        "তারাগঞ্জে ডিজিটাল মেলার আয়োজন",
        "মাদক বিরোধী বিশেষ অভিযান, গ্রেপ্তার ৩",
        "স্থানীয় কৃষকদের মাঝে বিনামূল্যে সার ও বীজ বিতরণ",
        "তারাগঞ্জে বৃক্ষরোপণ কর্মসূচি পালিত",
        "উপজেলা চত্বরে বিজ্ঞান মেলা শুরু",
        "তারাগঞ্জে কৃতী শিক্ষার্থীদের সংবর্ধনা প্রদান",
        "বিনা মূল্যে চক্ষু চিকিৎসা ক্যাম্প অনুষ্ঠিত",
        "তারাগঞ্জে নতুন বিদ্যুৎ উপকেন্দ্রের কাজ সম্পন্ন",
        "স্থানীয় নারীদের জন্য সেলাই প্রশিক্ষণ কর্মশালা",
        "তারাগঞ্জ উপজেলা পরিষদের নতুন বাজেট ঘোষণা"
    ]
    
    contents = [
        "আজ তারাগঞ্জ উপজেলায় একটি বিশেষ কর্মসূচির মাধ্যমে এই উদ্যোগ গ্রহণ করা হয়েছে। স্থানীয় গণ্যমান্য ব্যক্তিবর্গ এবং সরকারি কর্মকর্তারা এই অনুষ্ঠানে উপস্থিত ছিলেন। এই উদ্যোগের ফলে স্থানীয় জনগণ ব্যাপকভাবে উপকৃত হবেন বলে আশা করা যাচ্ছে।",
        "তারাগঞ্জ উপজেলা প্রশাসনের পক্ষ থেকে এই বিশেষ পদক্ষেপ নেওয়া হয়েছে। দীর্ঘদিন ধরে স্থানীয়দের এই দাবি ছিল, যা আজ পূরণ হলো। সংশ্লিষ্ট সবাই এই উদ্যোগকে সাধুবাদ জানিয়েছেন। ভবিষ্যতে এ ধরনের আরও পদক্ষেপ নেওয়া হবে বলে জানানো হয়।",
        "অত্যন্ত উৎসবমুখর পরিবেশে আজকের এই আয়োজনটি সম্পন্ন হয়। এতে স্থানীয়দের স্বতঃস্ফূর্ত অংশগ্রহণ লক্ষ্য করা যায়। উপস্থিত সবাই এই আয়োজনের ভূয়সী প্রশংসা করেন এবং প্রতি বছর এ ধরনের আয়োজনের দাবি জানান।"
    ]
    
    sources = ["প্রথম আলো", "যুগান্তর", "স্থানীয় প্রতিনিধি", "তারাগঞ্জ বার্তা", "ডেইলি স্টার", "বাংলাদেশ প্রতিদিন", "প্রশাসন"]
    
    for i in range(18):
        title = titles[i]
        content = random.choice(contents) * 3
        source = random.choice(sources)
        
        print(f"[{i+1}/18] Downloading image for News {i+1}")
        
        try:
            req = urllib.request.Request(
                f"https://picsum.photos/seed/{random.randint(1, 1000)}/800/600", 
                headers={'User-Agent': 'Mozilla/5.0'}
            )
            with urllib.request.urlopen(req, timeout=10) as response:
                if response.status == 200:
                    image_data = response.read()
                    post = NewsPost(
                        title=title,
                        content=content,
                        source=source,
                        is_published=True
                    )
                    image_name = f"news_image_{random.randint(1000, 9999)}.jpg"
                    post.image.save(image_name, ContentFile(image_data), save=False)
                    post.save()
                    print(f"Successfully created News {i+1}")
                else:
                    print(f"Failed to fetch image for News {i+1}")
        except Exception as e:
            print(f"Error creating post {i+1}: {e}")

if __name__ == "__main__":
    generate_news()
    print("Done!")
