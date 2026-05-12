from .translations_dashboard import TRANSLATIONS

def dashboard_translations(request):
    lang = request.session.get('django_language', 'bn')
    user = request.user
    is_moderator = user.is_authenticated and user.groups.filter(name='Moderator').exists()
    return {
        'lang': lang,
        't': TRANSLATIONS.get(lang, TRANSLATIONS['bn']),
        'is_moderator': is_moderator
    }
