FROM lscr.io/linuxserver/calibre-web:latest

# Download the required CSS and JS files
COPY css/ /app/calibre-web/cps/static/css
COPY js/ /app/calibre-web/cps/static/js

# Inject the HTML snippet into layout.html before </body>
RUN sed -i '/<\/body>/i \
{% if current_user.is_authenticated or g.allow_anonymous %}\
<link href="/static/css/style.css" rel="stylesheet" />\n\
<script type="module">\n\
    import { createChat } from '\''/static/js/chat.bundle.es.js'\'';\n\
    createChat({\n\
        webhookUrl: '\''https://n8n.nerdiverset.no/webhook/b818f9b2-27cf-4f7f-94fb-a6c205005c28/chat'\''\n\
    });\n\
</script>\
{% endif %}' /app/calibre-web/cps/templates/layout.html


RUN sed -i "/csp += \"; object-src 'none';\"/i \ \ \ \ csp += \"; connect-src 'self' http://n8n.nerdiverset.no\"" /app/calibre-web/cps/web.py


#debugging tools
RUN apt update
RUN apt install vim -y
RUN apt install wget -y
