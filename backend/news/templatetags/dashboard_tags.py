from django import template

register = template.Library()

@register.filter(name='set_placeholder')
def set_placeholder(field, placeholder_text):
    field.field.widget.attrs['placeholder'] = placeholder_text
    return field

@register.filter(name='add_class')
def add_class(field, css_class):
    return field.as_widget(attrs={"class": css_class})

@register.filter(name='get_attr')
def get_attr(obj, attr_name):
    # This filter dynamically gets an attribute from an object.
    # We can also check if it's a callable and call it, but simple getattr is usually enough
    if hasattr(obj, attr_name):
        value = getattr(obj, attr_name)
        if callable(value):
            return value()
        return value
    return ''

@register.filter(name='split')
def split(value, arg):
    return value.split(arg)
