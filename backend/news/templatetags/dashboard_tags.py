from django import template

register = template.Library()

@register.filter(name='set_placeholder')
def set_placeholder(field, placeholder_text):
    field.field.widget.attrs['placeholder'] = placeholder_text
    return field

@register.filter(name='add_class')
def add_class(field, css_class):
    return field.as_widget(attrs={"class": css_class})
