from .translations_dashboard import TRANSLATIONS

def dashboard_translations(request):
    lang = request.session.get('django_language', 'bn')
    return {
        'lang': lang,
        't': TRANSLATIONS.get(lang, TRANSLATIONS['bn'])
    }
