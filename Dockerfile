FROM lscr.io/linuxserver/calibre-web:latest

# Download the required CSS and JS files
COPY css/ /app/calibre-web/cps/static/css
COPY js/ /app/calibre-web/cps/static/js

# Inject the HTML snippet into layout.html before </body>
RUN sed -i "/<\/body>/i {% if current_user.is_authenticated or g.allow_anonymous %}\
<link href=\"/static/css/style.css\" rel=\"stylesheet\" />\
<script type=\"module\">\
    import { createChat } from '/static/js/chat.bundle.es.js';\
    createChat({\
        webhookUrl: '{{ n8n_webhook }}'\
    });\
</script>\
{% endif %}" /app/calibre-web/cps/templates/layout.html


# Inject CSP with N8N_HOST env variable
RUN sed -i "/csp += \"; object-src 'none';\"/i \ \ \ \ n8n_host = os.getenv('N8N_HOST', 'https://example.domain.com')\n    csp += \"; connect-src 'self' \" + n8n_host" /app/calibre-web/cps/web.py


RUN sed -i "/from .string_helper import strip_whitespaces/a \
@app.context_processor\n\
def inject_env_vars():\n\
    return {\n\
        'n8n_webhook': os.getenv('N8N_WEBHOOK', 'https://default.example.com/webhook/default/chat')\n\
    }\n" /app/calibre-web/cps/web.py




#debugging tools
RUN apt update
RUN apt install vim -y
RUN apt install wget -y
